import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/dio_provider.dart';
import '../auth/auth_session.dart';
import '../auth/session_provider.dart';
import '../crypto/device_keys_service.dart';
import '../crypto/group_crypto_service.dart';
import 'chat_models.dart';
import 'conversation_id.dart';

final groupRepositoryProvider = Provider<GroupRepository>((ref) {
  return GroupRepository(
    ref.watch(dioProvider),
    ref.watch(deviceKeysServiceProvider),
    () => ref.read(sessionProvider),
  );
});

class GroupSummary {
  const GroupSummary({
    required this.groupId,
    required this.conversationId,
    required this.title,
    required this.memberCount,
    required this.createdAt,
  });

  final String groupId;
  final String conversationId;
  final String title;
  final int memberCount;
  final DateTime createdAt;
}

class GroupInvitePreview {
  const GroupInvitePreview({
    required this.groupId,
    required this.conversationId,
    required this.title,
    required this.memberCount,
    required this.alreadyMember,
    this.avatarBlobId,
    this.avatarKey,
  });

  final String groupId;
  final String conversationId;
  final String title;
  final int memberCount;
  final bool alreadyMember;
  final String? avatarBlobId;
  final String? avatarKey;
}

class SeenReader {
  const SeenReader({
    required this.userId,
    this.username,
    this.displayName,
    this.readAt,
  });

  final String userId;
  final String? username;
  final String? displayName;
  final DateTime? readAt;

  String get label => (displayName?.isNotEmpty ?? false)
      ? displayName!
      : (username != null ? '@$username' : 'User');

  factory SeenReader.fromJson(Map<String, dynamic> j) => SeenReader(
        userId: j['user_id'] as String,
        username: j['username'] as String?,
        displayName: j['display_name'] as String?,
        readAt: j['read_at'] != null
            ? DateTime.tryParse(j['read_at'] as String)
            : null,
      );
}

class GroupMember {
  const GroupMember({
    required this.userId,
    required this.role,
    this.username,
    this.displayName,
    this.avatarUrl,
  });

  final String userId;
  final String role;
  final String? username;
  final String? displayName;
  final String? avatarUrl;

  bool get isAdmin => role == 'admin';
  String get label => (displayName?.isNotEmpty ?? false)
      ? displayName!
      : (username != null ? '@$username' : 'User');

  factory GroupMember.fromJson(Map<String, dynamic> j) => GroupMember(
        userId: j['user_id'] as String,
        role: (j['role'] as String?) ?? 'member',
        username: j['username'] as String?,
        displayName: j['display_name'] as String?,
        avatarUrl: j['avatar_url'] as String?,
      );
}

class GroupMeta {
  const GroupMeta({
    required this.groupId,
    required this.title,
    required this.createdBy,
    required this.currentKeyEpoch,
    required this.needsRekey,
    required this.myRole,
    required this.memberCount,
    this.avatarBlobId,
    this.avatarKey,
  });

  final String groupId;
  final String title;
  final String createdBy;
  final int currentKeyEpoch;
  final bool needsRekey;
  final String myRole;
  final int memberCount;
  final String? avatarBlobId;
  final String? avatarKey;

  bool get amAdmin => myRole == 'admin';
  bool get hasAvatar => (avatarBlobId?.isNotEmpty ?? false) && (avatarKey?.isNotEmpty ?? false);

  factory GroupMeta.fromJson(Map<String, dynamic> j) => GroupMeta(
        groupId: j['id'] as String,
        title: j['title'] as String,
        createdBy: j['created_by'] as String,
        currentKeyEpoch: (j['current_key_epoch'] as num?)?.toInt() ?? 1,
        needsRekey: (j['needs_rekey'] as bool?) ?? false,
        myRole: (j['my_role'] as String?) ?? 'member',
        memberCount: (j['member_count'] as num?)?.toInt() ?? 0,
        avatarBlobId: j['avatar_blob_id'] as String?,
        avatarKey: j['avatar_key'] as String?,
      );
}

class GroupRepository {
  GroupRepository(this._dio, this._deviceKeys, this._session);

  final Dio _dio;
  final DeviceKeysService _deviceKeys;
  final AuthSession Function() _session;

  // Last-known current key epoch per group. Lets the hot send path avoid a
  // round-trip on every message; refreshed on thread open and on membership
  // change events.
  final Map<String, int> _epochCache = {};

  String get _myUserId => _session().userId!;

  Future<GroupSummary> createGroup({
    required String title,
    required List<String> memberUsernames,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>('/groups', data: {
      'title': title,
      'memberUsernames': memberUsernames,
    });
    final groupId = res.data!['groupId'] as String;
    final conversationId = res.data!['conversationId'] as String;

    final groupKey = await GroupCryptoService.generateGroupKeyBytes();
    GroupCryptoService.cacheGroupKey(groupId, 1, groupKey);
    _epochCache[groupId] = 1;

    final members = await listMembers(groupId);
    await _sealKeyToMembers(
      groupId: groupId,
      epoch: 1,
      groupKey: groupKey,
      members: members,
      includeSelf: true,
    );

    return GroupSummary(
      groupId: groupId,
      conversationId: conversationId,
      title: title,
      memberCount: members.length,
      createdAt: DateTime.now(),
    );
  }

  Future<GroupMeta> getMeta(String groupId) async {
    final res = await _dio.get<Map<String, dynamic>>('/groups/$groupId');
    final meta = GroupMeta.fromJson(res.data!['group'] as Map<String, dynamic>);
    _epochCache[groupId] = meta.currentKeyEpoch;
    return meta;
  }

  Future<List<GroupMember>> listMembers(String groupId) async {
    final res = await _dio.get<Map<String, dynamic>>('/groups/$groupId/members');
    final rows = res.data!['members'] as List<dynamic>;
    return rows.map((r) => GroupMember.fromJson(r as Map<String, dynamic>)).toList();
  }

  /// Membership/lifecycle system lines for back-filling the timeline on cold open.
  Future<List<ChatMessage>> fetchSystemMessages(String groupId, {String? myUserId}) async {
    final res = await _dio.get<Map<String, dynamic>>('/groups/$groupId/events');
    final rows = res.data!['events'] as List<dynamic>;
    final convId = groupConversationId(groupId);
    return rows.map((raw) {
      final e = raw as Map<String, dynamic>;
      final type = e['type'] as String? ?? '';
      final actorIsMe = e['actor_user_id'] != null && e['actor_user_id'] == myUserId;
      final actor = actorIsMe
          ? 'You'
          : ((e['actor_display_name'] ?? e['actor_username']) as String? ?? 'Someone');
      final target =
          (e['target_display_name'] ?? e['target_username']) as String? ?? 'someone';
      final meta = e['meta'] as Map<String, dynamic>?;
      return ChatMessage(
        id: e['id'] as String,
        conversationId: convId,
        senderUserId: kSystemSenderId,
        text: _systemEventText(type, actor, target, newTitle: meta?['title'] as String?),
        createdAt: DateTime.parse(e['created_at'] as String),
        isMine: false,
      );
    }).toList();
  }

  static String _systemEventText(String type, String actor, String target, {String? newTitle}) {
    switch (type) {
      case 'member_added':
        return '$actor added $target';
      case 'member_joined':
        return '$actor joined via invite link';
      case 'member_removed':
        return '$actor removed $target';
      case 'member_left':
        return '$target left';
      case 'member_promoted':
        return '$target is now an admin';
      case 'member_demoted':
        return '$target is no longer an admin';
      case 'group_renamed':
        return newTitle != null
            ? '$actor changed the group name to "$newTitle"'
            : '$actor changed the group name';
      case 'group_deleted':
        return '$actor deleted this group';
      case 'group_avatar':
        return '$actor changed the group photo';
      default:
        return 'Group updated';
    }
  }

  /// Best-effort current epoch — cached after the first fetch.
  Future<int> currentEpoch(String groupId) async {
    final cached = _epochCache[groupId];
    if (cached != null) return cached;
    final meta = await getMeta(groupId);
    return meta.currentKeyEpoch;
  }

  void invalidateEpoch(String groupId) => _epochCache.remove(groupId);

  /// Loads the group key for a specific [epoch]. Decryption picks the epoch each
  /// message was sealed with; sending uses the current epoch.
  Future<Uint8List?> loadGroupKey(String groupId, int epoch) async {
    final cached = GroupCryptoService.cachedGroupKey(groupId, epoch);
    if (cached != null) return cached;

    final res = await _dio.get<Map<String, dynamic>>('/groups/$groupId/keys');
    final envelopes = (res.data!['envelopes'] as List<dynamic>?) ??
        ((res.data!['envelope'] != null) ? [res.data!['envelope']] : const []);
    if (envelopes.isEmpty) return null;

    Map<String, dynamic>? match;
    for (final raw in envelopes) {
      final e = raw as Map<String, dynamic>;
      if (((e['key_epoch'] as num?)?.toInt() ?? 1) == epoch) {
        match = e;
        break;
      }
    }
    if (match == null) return null;

    // Fallback for legacy envelopes without an embedded sealer key: assume the
    // group admin sealed it.
    String? fallbackPub;
    try {
      final members = await listMembers(groupId);
      final admin = members.firstWhere((m) => m.isAdmin, orElse: () => members.first);
      final device = await _deviceKeys.fetchPrimaryDevice(admin.userId, forceRefresh: true);
      fallbackPub = device?.publicKey;
    } catch (_) {}

    try {
      final key = await GroupCryptoService.decryptGroupKeyFromEnvelope(
        ciphertext: match['ciphertext'] as String,
        groupId: groupId,
        fallbackPeerPublicKeyBase64: fallbackPub,
      );
      GroupCryptoService.cacheGroupKey(groupId, epoch, key);
      return key;
    } catch (_) {
      return null;
    }
  }

  /// Admin-only: add members, then seal the current-epoch key to their devices.
  Future<List<GroupMember>> addMembers(String groupId, List<String> usernames) async {
    await _dio.post('/groups/$groupId/members', data: {'memberUsernames': usernames});
    final epoch = await currentEpoch(groupId);
    final key = await loadGroupKey(groupId, epoch);
    final members = await listMembers(groupId);
    if (key != null) {
      await _sealKeyToMembers(groupId: groupId, epoch: epoch, groupKey: key, members: members);
    }
    return members;
  }

  /// Admin-only: remove a member and immediately rotate the key so the removed
  /// device cannot read future messages.
  Future<void> removeMember(String groupId, String userId) async {
    final res = await _dio.delete<Map<String, dynamic>>(
      '/groups/$groupId/members/$userId',
      data: const <String, dynamic>{},
    );
    final emptied = (res.data?['emptied'] as bool?) ?? false;
    if (emptied) {
      invalidateEpoch(groupId);
      return;
    }
    final newEpoch = (res.data?['currentKeyEpoch'] as num?)?.toInt();
    if (newEpoch != null) {
      _epochCache[groupId] = newEpoch;
      await _rotateToEpoch(groupId, newEpoch);
    }
  }

  /// Leave the group myself.
  Future<void> leaveGroup(String groupId) async {
    await _dio.delete('/groups/$groupId/members/$_myUserId',
        data: const <String, dynamic>{});
    invalidateEpoch(groupId);
  }

  /// Admin-only: rename the group.
  Future<void> renameGroup(String groupId, String title) async {
    await _dio.post('/groups/$groupId/rename', data: {'title': title});
  }

  /// Admin-only: set (or clear) the group avatar. [blobId]/[key] reference an
  /// already-uploaded encrypted image blob; pass nulls to remove the photo.
  Future<void> setAvatar(String groupId, String? blobId, String? key) async {
    await _dio.post('/groups/$groupId/avatar', data: {'blobId': blobId, 'key': key});
  }

  /// Admin-only: promote/demote a member.
  Future<void> setRole(String groupId, String userId, String role) async {
    await _dio.post('/groups/$groupId/members/$userId/role', data: {'role': role});
  }

  /// Admin-only: fetch (reuse) the group's shareable invite token.
  Future<String> createInvite(String groupId) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/groups/$groupId/invite',
      data: const <String, dynamic>{},
    );
    return res.data!['token'] as String;
  }

  /// Admin-only: revoke all active invite tokens (existing links stop working).
  Future<void> revokeInvite(String groupId) async {
    await _dio.post('/groups/$groupId/invite/revoke', data: const <String, dynamic>{});
  }

  /// Preview a group from an invite token before joining.
  Future<GroupInvitePreview> previewInvite(String token) async {
    final res = await _dio.get<Map<String, dynamic>>('/groups/invite/$token');
    final g = res.data!['group'] as Map<String, dynamic>;
    return GroupInvitePreview(
      groupId: g['id'] as String,
      conversationId: g['conversation_id'] as String,
      title: g['title'] as String,
      memberCount: (g['member_count'] as num?)?.toInt() ?? 0,
      avatarBlobId: g['avatar_blob_id'] as String?,
      avatarKey: g['avatar_key'] as String?,
      alreadyMember: (res.data!['alreadyMember'] as bool?) ?? false,
    );
  }

  /// Join a group via an invite token. Returns the conversation id.
  Future<String> joinByInvite(String token) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/groups/invite/$token/join',
      data: const <String, dynamic>{},
    );
    return res.data!['conversationId'] as String;
  }

  /// Sender-only: which members have read [messageId] (group "Seen by N").
  Future<List<SeenReader>> messageSeenBy(String groupId, String messageId) async {
    final res = await _dio.get<Map<String, dynamic>>(
      '/groups/$groupId/messages/$messageId/seen',
    );
    final rows = (res.data!['readers'] as List<dynamic>?) ?? const [];
    return rows
        .map((r) => SeenReader.fromJson(r as Map<String, dynamic>))
        .toList();
  }

  /// Admin-only: delete the group for everyone.
  Future<void> deleteGroup(String groupId) async {
    await _dio.delete('/groups/$groupId', data: const <String, dynamic>{});
    invalidateEpoch(groupId);
  }

  /// If a rotation is pending and I'm the designated rotator (the admin with the
  /// lowest user id), generate and distribute the new-epoch key. Safe to call on
  /// thread open and before sending.
  Future<void> rotateIfNeeded(String groupId) async {
    final GroupMeta meta;
    try {
      meta = await getMeta(groupId);
    } catch (_) {
      return;
    }
    if (!meta.needsRekey || !meta.amAdmin) return;
    final members = await listMembers(groupId);
    final admins = members.where((m) => m.isAdmin).toList()
      ..sort((a, b) => a.userId.compareTo(b.userId));
    if (admins.isEmpty || admins.first.userId != _myUserId) return;
    await _rotateToEpoch(groupId, meta.currentKeyEpoch, members: members);
  }

  Future<void> _rotateToEpoch(String groupId, int epoch, {List<GroupMember>? members}) async {
    final newKey = await GroupCryptoService.generateGroupKeyBytes();
    GroupCryptoService.cacheGroupKey(groupId, epoch, newKey);
    final list = members ?? await listMembers(groupId);
    await _sealKeyToMembers(
        groupId: groupId, epoch: epoch, groupKey: newKey, members: list, includeSelf: true);
    try {
      await _dio.post('/groups/$groupId/rekeyed', data: const <String, dynamic>{});
    } catch (_) {}
    _epochCache[groupId] = epoch;
  }

  /// Once-per-session set of groups we've already healed key distribution for.
  final Set<String> _redistributed = {};

  /// Self-heal key distribution: if I currently hold the group key, (re)seal it
  /// to every member device — including members whose device joined later or was
  /// reinstalled and therefore never received an envelope. Members who don't
  /// hold the key simply no-op. Best-effort; safe to call on every thread open.
  Future<void> ensureKeyDistributed(String groupId, {bool force = false}) async {
    if (!force && _redistributed.contains(groupId)) return;
    final int epoch;
    try {
      epoch = await currentEpoch(groupId);
    } catch (_) {
      return;
    }
    var key = GroupCryptoService.cachedGroupKey(groupId, epoch);
    key ??= await loadGroupKey(groupId, epoch);
    if (key == null) return; // I don't have the key → can't help distribute.
    try {
      final members = await listMembers(groupId);
      await _sealKeyToMembers(
        groupId: groupId,
        epoch: epoch,
        groupKey: key,
        members: members,
        includeSelf: true,
      );
      _redistributed.add(groupId);
    } catch (_) {}
  }

  Future<void> _sealKeyToMembers({
    required String groupId,
    required int epoch,
    required Uint8List groupKey,
    required List<GroupMember> members,
    bool includeSelf = false,
  }) async {
    for (final m in members) {
      // Seal to our OWN devices too (includeSelf) so the key survives a
      // reinstall / new device — otherwise the sealer (e.g. the creator) keeps
      // the key only in memory and can never recover it.
      if (!includeSelf && m.userId == _myUserId) continue;
      final devices = await _deviceKeys.fetchAllDevices(m.userId, forceRefresh: true);
      for (final device in devices) {
        final enc = await GroupCryptoService.encryptGroupKeyForPeer(
          groupKey: groupKey,
          groupId: groupId,
          peerPublicKeyBase64: device.publicKey,
        );
        await _dio.post('/groups/$groupId/keys', data: {
          'recipientUserId': m.userId,
          'recipientDeviceId': device.deviceId,
          'ciphertext': enc,
          'keyEpoch': epoch,
        });
      }
    }
  }
}

import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/dio_provider.dart';
import '../auth/auth_session.dart';
import '../auth/session_provider.dart';
import '../crypto/device_keys_service.dart';
import '../crypto/group_crypto_service.dart';

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

class GroupRepository {
  GroupRepository(this._dio, this._deviceKeys, this._session);

  final Dio _dio;
  final DeviceKeysService _deviceKeys;
  final AuthSession Function() _session;

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
    GroupCryptoService.cacheGroupKey(groupId, groupKey);

    final membersRes = await _dio.get<Map<String, dynamic>>('/groups/$groupId/members');
    final members = membersRes.data!['members'] as List<dynamic>;

    for (final raw in members) {
      final m = raw as Map<String, dynamic>;
      final uid = m['user_id'] as String;
      if (uid == _myUserId) continue;
      final devices = await _deviceKeys.fetchAllDevices(uid, forceRefresh: true);
      for (final device in devices) {
        final enc = await GroupCryptoService.encryptGroupKeyForPeer(
          groupKey: groupKey,
          groupId: groupId,
          peerPublicKeyBase64: device.publicKey,
        );
        await _dio.post('/groups/$groupId/keys', data: {
          'recipientUserId': uid,
          'recipientDeviceId': device.deviceId,
          'ciphertext': enc,
        });
      }
    }

    return GroupSummary(
      groupId: groupId,
      conversationId: conversationId,
      title: title,
      memberCount: members.length,
      createdAt: DateTime.now(),
    );
  }

  Future<Uint8List?> loadGroupKey(String groupId) async {
    final cached = GroupCryptoService.cachedGroupKey(groupId);
    if (cached != null) return cached;

    final res = await _dio.get<Map<String, dynamic>>('/groups/$groupId/keys');
    final envelope = res.data!['envelope'] as Map<String, dynamic>?;
    if (envelope == null) return null;

    final adminRes = await _dio.get<Map<String, dynamic>>('/groups/$groupId/members');
    final members = adminRes.data!['members'] as List<dynamic>;
    final admin = members.firstWhere(
      (m) => (m as Map<String, dynamic>)['role'] == 'admin',
      orElse: () => members.first,
    ) as Map<String, dynamic>;
    final adminId = admin['user_id'] as String;
    final device = await _deviceKeys.fetchPrimaryDevice(adminId, forceRefresh: true);
    if (device == null) return null;

    final key = await GroupCryptoService.decryptGroupKeyFromEnvelope(
      ciphertext: envelope['ciphertext'] as String,
      groupId: groupId,
      peerPublicKeyBase64: device.publicKey,
    );
    GroupCryptoService.cacheGroupKey(groupId, key);
    return key;
  }
}

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../api/dio_provider.dart';
import '../auth/auth_session.dart';
import '../auth/session_provider.dart';
import '../crypto/chat_crypto_service.dart';
import '../crypto/device_keys_service.dart';
import '../crypto/group_crypto_service.dart';
import '../db/message_store.dart';
import 'chat_models.dart';
import 'conversation_id.dart';
import 'group_repository.dart';
import 'outbox_service.dart';

final chatRepositoryProvider = Provider<ChatRepository>((ref) {
  return ChatRepository(
    ref.watch(dioProvider),
    ref.watch(deviceKeysServiceProvider),
    ref.watch(groupRepositoryProvider),
    ref.watch(outboxServiceProvider),
    ref.watch(messageStoreProvider),
    () => ref.read(sessionProvider),
  );
});

class ChatRepository {
  ChatRepository(this._dio, this._deviceKeys, this._groups, this._outbox, this._store, this._session);

  final Dio _dio;
  final DeviceKeysService _deviceKeys;
  final GroupRepository _groups;
  final OutboxService _outbox;
  final MessageStore _store;
  final AuthSession Function() _session;

  MessageStore get store => _store;
  static const _uuid = Uuid();
  final Map<String, String> _decryptedTextCache = {};

  String get _myUserId => _session().userId!;

  Future<List<ConversationSummary>> fetchConversations() async {
    final res = await _dio.get<Map<String, dynamic>>('/conversations');
    final rows = res.data!['conversations'] as List<dynamic>;

    final list = rows.map((raw) {
      final row = raw as Map<String, dynamic>;
      final convType = row['conv_type'] as String? ?? 'dm';
      final isGroup = convType == 'group';
      final conversationId = row['conversation_id'] as String;
      final lastCiphertext = row['last_ciphertext'] as String?;
      return ConversationSummary(
        conversationId: conversationId,
        peer: ChatPeer.fromJson(row),
        lastAt: DateTime.parse(row['last_at'] as String),
        lastPreview: lastCiphertext != null && lastCiphertext.isNotEmpty ? '💬 Message' : '',
        isGroup: isGroup,
        groupId: isGroup ? groupIdFromConversation(conversationId) : null,
      );
    }).toList();
    // Cache for instant/offline chat list.
    await _store.upsertConversations(list);
    return list;
  }

  /// Fetch the recent window from the server and write it into the local store.
  /// The UI watches the store, so it updates reactively — no return value used.
  Future<void> syncConversation(String conversationId, {int limit = 25}) async {
    final fetched = await fetchMessages(conversationId, limit: limit);
    await _store.upsertMany(fetched);
  }

  Future<List<ChatMessage>> fetchMessages(String conversationId, {String? after, int limit = 25}) async {
    final res = await _dio.get<Map<String, dynamic>>(
      '/conversations/$conversationId/messages',
      queryParameters: {
        'limit': limit,
        if (after != null) 'after': after,
      },
    );
    if (res.data!['ok'] == false) {
      final err = res.data!['error'] as String? ?? 'Failed to load messages';
      throw DioException(requestOptions: res.requestOptions, message: err);
    }

    final rows = res.data!['messages'] as List<dynamic>;
    if (rows.isEmpty) return [];

    if (isGroupConversation(conversationId)) {
      return _fetchGroupMessages(conversationId, rows);
    }

    final peerId = peerUserIdFromConversation(conversationId, _myUserId);
    if (peerId == null) return [];

    final out = <ChatMessage>[];
    for (final raw in rows) {
      final row = raw as Map<String, dynamic>;
      final senderId = row['sender_user_id'] as String;
      final messageId = row['id'] as String;
      final text = _decryptedTextCache[messageId] ??
          await _decryptDmEnvelope(
            ciphertext: row['ciphertext'] as String,
            conversationId: conversationId,
            senderUserId: senderId,
            senderDeviceId: row['sender_device_id'] as String,
            peerUserId: peerId,
          );
      // Only cache successful decryptions — never the failure sentinel, so a
      // transient key miss can recover on the next poll.
      if (!text.startsWith('🔒')) {
        _decryptedTextCache[messageId] = text;
      }
      out.add(
        ChatMessage(
          id: row['id'] as String,
          conversationId: conversationId,
          senderUserId: senderId,
          text: text,
          createdAt: DateTime.parse(row['created_at'] as String),
          isMine: senderId == _myUserId,
          clientMessageId: row['client_message_id'] as String?,
        ),
      );
    }
    return out;
  }

  Future<List<ChatMessage>> _fetchGroupMessages(String conversationId, List<dynamic> rows) async {
    final groupId = groupIdFromConversation(conversationId);
    if (groupId == null) return [];
    final groupKey = await _groups.loadGroupKey(groupId);
    if (groupKey == null) {
      return rows.map((raw) {
        final row = raw as Map<String, dynamic>;
        return ChatMessage(
          id: row['id'] as String,
          conversationId: conversationId,
          senderUserId: row['sender_user_id'] as String,
          text: '🔒 Waiting for group key',
          createdAt: DateTime.parse(row['created_at'] as String),
          isMine: row['sender_user_id'] == _myUserId,
          clientMessageId: row['client_message_id'] as String?,
        );
      }).toList();
    }

    final out = <ChatMessage>[];
    for (final raw in rows) {
      final row = raw as Map<String, dynamic>;
      final senderId = row['sender_user_id'] as String;
      String text;
      try {
        text = await GroupCryptoService.decryptMessage(
          groupId: groupId,
          groupKey: groupKey,
          ciphertext: row['ciphertext'] as String,
        );
      } catch (_) {
        text = '🔒 Unable to decrypt';
      }
      out.add(
        ChatMessage(
          id: row['id'] as String,
          conversationId: conversationId,
          senderUserId: senderId,
          text: text,
          createdAt: DateTime.parse(row['created_at'] as String),
          isMine: senderId == _myUserId,
          clientMessageId: row['client_message_id'] as String?,
        ),
      );
    }
    return out;
  }

  Future<String> decryptEnvelope({
    required String ciphertext,
    required String conversationId,
    required String senderUserId,
    required String senderDeviceId,
    required String peerUserId,
  }) {
    if (isGroupConversation(conversationId)) {
      final groupId = groupIdFromConversation(conversationId);
      if (groupId == null) return Future.value('🔒 Unable to decrypt');
      return _decryptGroupPush(groupId, ciphertext);
    }
    return _decryptDmEnvelope(
      ciphertext: ciphertext,
      conversationId: conversationId,
      senderUserId: senderUserId,
      senderDeviceId: senderDeviceId,
      peerUserId: peerUserId,
    );
  }

  Future<String> _decryptGroupPush(String groupId, String ciphertext) async {
    final groupKey = await _groups.loadGroupKey(groupId);
    if (groupKey == null) return '🔒 Waiting for group key';
    try {
      return GroupCryptoService.decryptMessage(
        groupId: groupId,
        groupKey: groupKey,
        ciphertext: ciphertext,
      );
    } catch (_) {
      return '🔒 Unable to decrypt';
    }
  }

  Future<String> _decryptDmEnvelope({
    required String ciphertext,
    required String conversationId,
    required String senderUserId,
    required String senderDeviceId,
    required String peerUserId,
  }) async {
    final keyUserId = senderUserId == _myUserId ? peerUserId : senderUserId;
    final deviceId = senderUserId == _myUserId ? null : senderDeviceId;

    Future<String?> tryDecrypt(DeviceKeyEntry device) async {
      try {
        return await ChatCryptoService.decrypt(
          ciphertext: ciphertext,
          conversationId: conversationId,
          peerPublicKeyBase64: device.publicKey,
        );
      } catch (_) {
        return null;
      }
    }

    final primary = await _deviceKeys.fetchDeviceForUser(keyUserId, deviceId: deviceId);
    if (primary != null) {
      final text = await tryDecrypt(primary);
      if (text != null) return text;
    }

    var all = await _deviceKeys.fetchAllDevices(keyUserId, forceRefresh: false);
    for (final device in all) {
      final text = await tryDecrypt(device);
      if (text != null) return text;
    }

    _deviceKeys.invalidate(keyUserId);
    all = await _deviceKeys.fetchAllDevices(keyUserId, forceRefresh: true);
    for (final device in all) {
      final text = await tryDecrypt(device);
      if (text != null) return text;
    }
    return '🔒 Unable to decrypt';
  }

  Future<void> warmPeer(String peerUserId) => _deviceKeys.warmPeer(peerUserId);

  Future<String> sendMessage({
    required String recipientUserId,
    required String plaintext,
    String? clientMessageId,
  }) async {
    final conversationId = directConversationId(_myUserId, recipientUserId);
    final device = await _deviceKeys.fetchPrimaryDevice(recipientUserId, forceRefresh: true);
    if (device == null) {
      throw Exception('Recipient has no registered device — ask them to open the app');
    }

    final ciphertext = await ChatCryptoService.encrypt(
      plaintext: plaintext,
      conversationId: conversationId,
      peerPublicKeyBase64: device.publicKey,
    );

    final res = await _dio.post<Map<String, dynamic>>('/messages', data: {
      'conversationId': conversationId,
      'recipientUserId': recipientUserId,
      'recipientDeviceId': device.deviceId,
      'ciphertext': ciphertext,
      'clientMessageId': clientMessageId ?? _uuid.v4(),
    });
    return res.data!['envelopeId'] as String;
  }

  Future<String> sendGroupMessage({
    required String groupId,
    required String plaintext,
    String? clientMessageId,
  }) async {
    final conversationId = groupConversationId(groupId);
    var groupKey = GroupCryptoService.cachedGroupKey(groupId);
    groupKey ??= await _groups.loadGroupKey(groupId);
    if (groupKey == null) {
      throw Exception('Group encryption key not available yet');
    }

    final ciphertext = await GroupCryptoService.encryptMessage(
      groupId: groupId,
      groupKey: groupKey,
      plaintext: plaintext,
    );

    final res = await _dio.post<Map<String, dynamic>>('/messages', data: {
      'conversationId': conversationId,
      'ciphertext': ciphertext,
      'clientMessageId': clientMessageId ?? _uuid.v4(),
    });
    return res.data!['envelopeId'] as String;
  }

  /// Retry every queued (un-acked) outgoing message. Server idempotency by
  /// clientMessageId guarantees no duplicates even if the original send
  /// actually reached the server. Returns the ids that were confirmed.
  Future<List<({String clientMessageId, String envelopeId})>> flushOutbox() async {
    final entries = await _outbox.load();
    final confirmed = <({String clientMessageId, String envelopeId})>[];
    for (final e in entries) {
      try {
        final envelopeId = e.isGroup
            ? await sendGroupMessage(
                groupId: e.groupId!,
                plaintext: e.plaintext,
                clientMessageId: e.clientMessageId,
              )
            : await sendMessage(
                recipientUserId: e.recipientUserId!,
                plaintext: e.plaintext,
                clientMessageId: e.clientMessageId,
              );
        await _outbox.remove(e.clientMessageId);
        await _store.confirmSent(e.clientMessageId, envelopeId);
        confirmed.add((clientMessageId: e.clientMessageId, envelopeId: envelopeId));
      } catch (_) {
        await _outbox.markAttempt(e.clientMessageId);
        await _store.markFailed(e.clientMessageId, true);
      }
    }
    return confirmed;
  }

  OutboxService get outbox => _outbox;

  Future<void> sendTyping({
    required String conversationId,
    required bool isTyping,
  }) async {
    await _dio.post('/conversations/$conversationId/typing', data: {'isTyping': isTyping});
  }

  Future<void> sendDeliveryReceipt({
    required String conversationId,
    required String envelopeId,
  }) async {
    await _dio.post('/conversations/$conversationId/delivery', data: {'envelopeId': envelopeId});
  }

  Future<void> sendReadReceipt({
    required String conversationId,
    required String envelopeId,
  }) async {
    await _dio.post('/conversations/$conversationId/receipts', data: {'envelopeId': envelopeId});
  }

  Future<bool> canMessage(String targetUserId) async {
    final res = await _dio.get<Map<String, dynamic>>('/contacts/can-message/$targetUserId');
    return res.data!['canMessage'] as bool? ?? false;
  }

  Future<ChatPeer?> lookupByUsername(String username) async {
    final res = await _dio.get<Map<String, dynamic>>('/users/by-username/${username.toLowerCase()}');
    final user = res.data!['user'] as Map<String, dynamic>;
    return ChatPeer(
      userId: user['id'] as String,
      username: user['username'] as String?,
      displayName: user['displayName'] as String?,
      avatarUrl: user['avatarUrl'] as String?,
    );
  }

  Future<void> sendMessageRequest({
    required String toUserId,
    String? introMessage,
  }) async {
    await _dio.post('/message-requests', data: {
      'toUserId': toUserId,
      if (introMessage != null) 'introMessage': introMessage,
    });
  }

  Future<List<ChatPeer>> fetchContacts() async {
    final res = await _dio.get<Map<String, dynamic>>('/contacts');
    final rows = res.data!['contacts'] as List<dynamic>;
    return rows.map((r) => ChatPeer.fromJson(r as Map<String, dynamic>)).toList();
  }
}

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
import 'message_wire.dart';
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
        avatarBlobId: isGroup ? row['group_avatar_blob_id'] as String? : null,
        avatarKey: isGroup ? row['group_avatar_key'] as String? : null,
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
      final createdAt = DateTime.parse(row['created_at'] as String);
      final msg = _buildFromWire(
        conversationId: conversationId,
        id: messageId,
        senderId: senderId,
        rawText: text,
        createdAt: createdAt,
        clientMessageId: row['client_message_id'] as String?,
      );
      if (msg != null) out.add(msg);
    }
    return out;
  }

  /// Decodes the wire payload and turns it into a [ChatMessage], or applies a
  /// control payload (and returns null so it never renders as a bubble).
  ChatMessage? _buildFromWire({
    required String conversationId,
    required String id,
    required String senderId,
    required String rawText,
    required DateTime createdAt,
    String? clientMessageId,
    String? senderLabel,
  }) {
    // Sentinels (🔒 …) aren't wire-encoded — pass them straight through.
    final wire = rawText.startsWith('🔒') ? WireMessage(text: rawText) : ChatWire.decode(rawText);
    if (wire.isTimerControl) {
      _store.setDisappearing(conversationId, wire.timerSeconds);
      return null;
    }
    if (wire.isReaction) {
      final tid = wire.reactionTargetId;
      if (tid != null) {
        if (wire.reactionAdd && wire.reactionEmoji != null) {
          _store.setReaction(
            conversationId: conversationId,
            targetId: tid,
            reactorUserId: senderId,
            emoji: wire.reactionEmoji!,
          );
        } else {
          _store.removeReaction(targetId: tid, reactorUserId: senderId);
        }
      }
      return null;
    }
    return ChatMessage(
      id: id,
      conversationId: conversationId,
      senderUserId: senderId,
      text: wire.text,
      createdAt: createdAt,
      isMine: senderId == _myUserId,
      clientMessageId: clientMessageId,
      senderLabel: senderLabel,
      viewOnce: wire.viewOnce,
      expiresAt: wire.ttlSeconds > 0 ? createdAt.add(Duration(seconds: wire.ttlSeconds)) : null,
      mediaType: wire.mediaType,
      mediaBlobId: wire.mediaBlobId,
      mediaKey: wire.mediaKey,
      mediaMime: wire.mediaMime,
      mediaWidth: wire.mediaWidth,
      mediaHeight: wire.mediaHeight,
      mediaFilename: wire.mediaFilename,
      mediaSize: wire.mediaSize,
      mediaDurationMs: wire.mediaDurationMs,
      mediaWaveform: wire.mediaWaveform,
      replyToId: wire.replyToId,
      replySender: wire.replySender,
      replyPreview: wire.replyPreview,
      replyMediaType: wire.replyMediaType,
    );
  }

  Future<List<ChatMessage>> _fetchGroupMessages(String conversationId, List<dynamic> rows) async {
    final groupId = groupIdFromConversation(conversationId);
    if (groupId == null) return [];

    final out = <ChatMessage>[];
    for (final raw in rows) {
      final row = raw as Map<String, dynamic>;
      final senderId = row['sender_user_id'] as String;
      final ciphertext = row['ciphertext'] as String;
      String text;
      try {
        final epoch = GroupCryptoService.ciphertextEpoch(ciphertext);
        final groupKey = await _groups.loadGroupKey(groupId, epoch);
        text = groupKey == null
            ? '🔒 Waiting for group key'
            : await GroupCryptoService.decryptMessage(
                groupKey: groupKey,
                ciphertext: ciphertext,
              );
      } catch (_) {
        text = '🔒 Unable to decrypt';
      }
      final msg = _buildFromWire(
        conversationId: conversationId,
        id: row['id'] as String,
        senderId: senderId,
        rawText: text,
        createdAt: DateTime.parse(row['created_at'] as String),
        clientMessageId: row['client_message_id'] as String?,
      );
      if (msg != null) out.add(msg);
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
    final epoch = GroupCryptoService.ciphertextEpoch(ciphertext);
    final groupKey = await _groups.loadGroupKey(groupId, epoch);
    if (groupKey == null) return '🔒 Waiting for group key';
    try {
      return GroupCryptoService.decryptMessage(
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
    // Uniform rule: an envelope addressed to THIS device was encrypted by the
    // sender's device, so the conversation key derives from the SENDER device's
    // public key + our private key (ECDH is symmetric). This works for both
    // peer messages and our own self-copies.
    Future<String?> tryWithPub(String pub) async {
      try {
        return await ChatCryptoService.decrypt(
          ciphertext: ciphertext,
          conversationId: conversationId,
          peerPublicKeyBase64: pub,
        );
      } catch (_) {
        return null;
      }
    }

    // Self-copy sent from this very device → our own (local) key decrypts it.
    if (senderUserId == _myUserId) {
      final localPub = await ChatCryptoService.publicKeyBase64();
      final text = await tryWithPub(localPub);
      if (text != null) return text;
    }

    // Primary: the exact sender device's registered key.
    final exact = await _deviceKeys.fetchDeviceForUser(senderUserId, deviceId: senderDeviceId);
    if (exact != null) {
      final text = await tryWithPub(exact.publicKey);
      if (text != null) return text;
    }

    // Fallback: any of the sender's devices (covers key rotation / device id drift).
    var all = await _deviceKeys.fetchAllDevices(senderUserId, forceRefresh: false);
    for (final device in all) {
      final text = await tryWithPub(device.publicKey);
      if (text != null) return text;
    }

    _deviceKeys.invalidate(senderUserId);
    all = await _deviceKeys.fetchAllDevices(senderUserId, forceRefresh: true);
    for (final device in all) {
      final text = await tryWithPub(device.publicKey);
      if (text != null) return text;
    }
    return '🔒 Unable to decrypt';
  }

  Future<void> warmPeer(String peerUserId) => _deviceKeys.warmPeer(peerUserId);

  /// Permanently delete this device's server-side envelope for a view-once
  /// message so its ciphertext can never be re-fetched and decrypted again.
  /// Idempotent; safe to call on ingest and again on open.
  Future<void> consumeViewOnce(String messageId) async {
    try {
      await _dio.post('/messages/$messageId/consume', data: const <String, dynamic>{});
    } catch (_) {
      // Best-effort; the local copy is already wiped on view regardless.
    }
  }

  Future<String> sendMessage({
    required String recipientUserId,
    required String plaintext,
    String? clientMessageId,
    bool viewOnce = false,
    int ttlSeconds = 0,
    WireReply? reply,
  }) {
    final wired =
        ChatWire.encodeText(plaintext, viewOnce: viewOnce, ttlSeconds: ttlSeconds, reply: reply);
    return _sendDmWire(
      recipientUserId: recipientUserId,
      wired: wired,
      clientMessageId: clientMessageId,
    );
  }

  /// Sends an image as a DM. The blob is already encrypted + uploaded; its key
  /// travels here E2EE inside the wire payload.
  Future<String> sendDmImage({
    required String recipientUserId,
    required String blobId,
    required String blobKey,
    required String mime,
    int? width,
    int? height,
    int? size,
    String caption = '',
    String? clientMessageId,
    bool viewOnce = false,
    int ttlSeconds = 0,
    WireReply? reply,
  }) {
    final wired = ChatWire.encodeMedia(
      mediaType: 'image',
      blobId: blobId,
      blobKey: blobKey,
      mime: mime,
      width: width,
      height: height,
      size: size,
      caption: caption,
      viewOnce: viewOnce,
      ttlSeconds: ttlSeconds,
      reply: reply,
    );
    return _sendDmWire(
      recipientUserId: recipientUserId,
      wired: wired,
      clientMessageId: clientMessageId,
    );
  }

  /// Sends a generic file as a DM (key travels E2EE inside the wire payload).
  Future<String> sendDmFile({
    required String recipientUserId,
    required String blobId,
    required String blobKey,
    required String filename,
    required String mime,
    int? size,
    String caption = '',
    String? clientMessageId,
    bool viewOnce = false,
    int ttlSeconds = 0,
    WireReply? reply,
  }) {
    final wired = ChatWire.encodeFile(
      blobId: blobId,
      blobKey: blobKey,
      filename: filename,
      mime: mime,
      size: size,
      caption: caption,
      viewOnce: viewOnce,
      ttlSeconds: ttlSeconds,
      reply: reply,
    );
    return _sendDmWire(
      recipientUserId: recipientUserId,
      wired: wired,
      clientMessageId: clientMessageId,
    );
  }

  /// Sends a voice note as a DM (key travels E2EE inside the wire payload).
  Future<String> sendDmVoice({
    required String recipientUserId,
    required String blobId,
    required String blobKey,
    required String mime,
    required int durationMs,
    List<int> waveform = const [],
    int? size,
    String? clientMessageId,
    bool viewOnce = false,
    int ttlSeconds = 0,
    WireReply? reply,
  }) {
    final wired = ChatWire.encodeVoice(
      blobId: blobId,
      blobKey: blobKey,
      mime: mime,
      durationMs: durationMs,
      waveform: waveform,
      size: size,
      viewOnce: viewOnce,
      ttlSeconds: ttlSeconds,
      reply: reply,
    );
    return _sendDmWire(
      recipientUserId: recipientUserId,
      wired: wired,
      clientMessageId: clientMessageId,
    );
  }

  /// Sends an emoji reaction (or removes one) on [targetId] in a DM. Travels as
  /// an E2EE control payload — never rendered as a bubble by the recipient.
  Future<String> sendDmReaction({
    required String recipientUserId,
    required String targetId,
    required String emoji,
    required bool add,
  }) {
    final wired = ChatWire.encodeReaction(targetId: targetId, emoji: emoji, add: add);
    return _sendDmWire(recipientUserId: recipientUserId, wired: wired);
  }

  Future<String> _sendDmWire({
    required String recipientUserId,
    required String wired,
    String? clientMessageId,
  }) async {
    final conversationId = directConversationId(_myUserId, recipientUserId);

    // Multi-device E2EE: encrypt a separate copy for EVERY destination device —
    // all of the recipient's devices (so whichever they read on can decrypt)
    // and all of our own devices (self-read + multi-device sync). This is what
    // guarantees messages always decrypt even with stale/extra device keys.
    final recipientDevices = await _deviceKeys.fetchAllDevices(recipientUserId, forceRefresh: true);
    if (recipientDevices.isEmpty) {
      throw Exception('Recipient has no registered device — ask them to open the app');
    }
    final myDevices = await _deviceKeys.fetchAllDevices(_myUserId, forceRefresh: true);
    final myDeviceId = _session().deviceId;
    final myLocalPub = await ChatCryptoService.publicKeyBase64();

    // (userId, deviceId) -> public key. Use our authoritative LOCAL key for our
    // own current device so we can always re-read our own message even if the
    // server copy of our key briefly lags.
    final targets = <String, ({String userId, String deviceId, String pub})>{};
    void addTarget(String userId, String deviceId, String pub) {
      targets['$userId::$deviceId'] = (userId: userId, deviceId: deviceId, pub: pub);
    }

    for (final d in recipientDevices) {
      addTarget(recipientUserId, d.deviceId, d.publicKey);
    }
    for (final d in myDevices) {
      final pub = (myDeviceId != null && d.deviceId == myDeviceId) ? myLocalPub : d.publicKey;
      addTarget(_myUserId, d.deviceId, pub);
    }
    if (myDeviceId != null) {
      addTarget(_myUserId, myDeviceId, myLocalPub);
    }

    final envelopes = <Map<String, dynamic>>[];
    for (final t in targets.values) {
      final ciphertext = await ChatCryptoService.encrypt(
        plaintext: wired,
        conversationId: conversationId,
        peerPublicKeyBase64: t.pub,
      );
      envelopes.add({
        'recipientUserId': t.userId,
        'recipientDeviceId': t.deviceId,
        'ciphertext': ciphertext,
      });
    }

    final res = await _dio.post<Map<String, dynamic>>('/messages', data: {
      'conversationId': conversationId,
      'clientMessageId': clientMessageId ?? _uuid.v4(),
      'envelopes': envelopes,
    });
    return res.data!['envelopeId'] as String;
  }

  Future<String> sendGroupMessage({
    required String groupId,
    required String plaintext,
    String? clientMessageId,
    bool viewOnce = false,
    int ttlSeconds = 0,
    WireReply? reply,
  }) {
    final wired =
        ChatWire.encodeText(plaintext, viewOnce: viewOnce, ttlSeconds: ttlSeconds, reply: reply);
    return _sendGroupWire(groupId: groupId, wired: wired, clientMessageId: clientMessageId);
  }

  Future<String> sendGroupReaction({
    required String groupId,
    required String targetId,
    required String emoji,
    required bool add,
  }) {
    final wired = ChatWire.encodeReaction(targetId: targetId, emoji: emoji, add: add);
    return _sendGroupWire(groupId: groupId, wired: wired);
  }

  Future<String> sendGroupImage({
    required String groupId,
    required String blobId,
    required String blobKey,
    required String mime,
    int? width,
    int? height,
    int? size,
    String caption = '',
    String? clientMessageId,
    bool viewOnce = false,
    int ttlSeconds = 0,
    WireReply? reply,
  }) {
    final wired = ChatWire.encodeMedia(
      mediaType: 'image',
      blobId: blobId,
      blobKey: blobKey,
      mime: mime,
      width: width,
      height: height,
      size: size,
      caption: caption,
      viewOnce: viewOnce,
      ttlSeconds: ttlSeconds,
      reply: reply,
    );
    return _sendGroupWire(groupId: groupId, wired: wired, clientMessageId: clientMessageId);
  }

  Future<String> sendGroupFile({
    required String groupId,
    required String blobId,
    required String blobKey,
    required String filename,
    required String mime,
    int? size,
    String caption = '',
    String? clientMessageId,
    bool viewOnce = false,
    int ttlSeconds = 0,
    WireReply? reply,
  }) {
    final wired = ChatWire.encodeFile(
      blobId: blobId,
      blobKey: blobKey,
      filename: filename,
      mime: mime,
      size: size,
      caption: caption,
      viewOnce: viewOnce,
      ttlSeconds: ttlSeconds,
      reply: reply,
    );
    return _sendGroupWire(groupId: groupId, wired: wired, clientMessageId: clientMessageId);
  }

  Future<String> sendGroupVoice({
    required String groupId,
    required String blobId,
    required String blobKey,
    required String mime,
    required int durationMs,
    List<int> waveform = const [],
    int? size,
    String? clientMessageId,
    bool viewOnce = false,
    int ttlSeconds = 0,
    WireReply? reply,
  }) {
    final wired = ChatWire.encodeVoice(
      blobId: blobId,
      blobKey: blobKey,
      mime: mime,
      durationMs: durationMs,
      waveform: waveform,
      size: size,
      viewOnce: viewOnce,
      ttlSeconds: ttlSeconds,
      reply: reply,
    );
    return _sendGroupWire(groupId: groupId, wired: wired, clientMessageId: clientMessageId);
  }

  Future<String> _sendGroupWire({
    required String groupId,
    required String wired,
    String? clientMessageId,
  }) async {
    final conversationId = groupConversationId(groupId);
    final epoch = await _groups.currentEpoch(groupId);
    var groupKey = GroupCryptoService.cachedGroupKey(groupId, epoch);
    groupKey ??= await _groups.loadGroupKey(groupId, epoch);
    if (groupKey == null) {
      throw Exception('Group encryption key not available yet');
    }

    final ciphertext = await GroupCryptoService.encryptMessage(
      groupId: groupId,
      groupKey: groupKey,
      epoch: epoch,
      plaintext: wired,
    );

    final res = await _dio.post<Map<String, dynamic>>('/messages', data: {
      'conversationId': conversationId,
      'ciphertext': ciphertext,
      'clientMessageId': clientMessageId ?? _uuid.v4(),
    });
    return res.data!['envelopeId'] as String;
  }

  /// Broadcasts a disappearing-timer change to the peer/group as an encrypted
  /// control message. Recipients decode it, update their local timer, and never
  /// render a bubble. The control travels as an ordinary E2EE message body.
  Future<void> sendDisappearingTimer({
    required bool isGroup,
    String? recipientUserId,
    String? groupId,
    required int seconds,
  }) async {
    final wire = ChatWire.encodeTimerControl(seconds);
    if (isGroup && groupId != null) {
      await sendGroupMessage(groupId: groupId, plaintext: wire);
    } else if (recipientUserId != null) {
      await sendMessage(recipientUserId: recipientUserId, plaintext: wire);
    }
  }

  /// Retry every queued (un-acked) outgoing message. Server idempotency by
  /// clientMessageId guarantees no duplicates even if the original send
  /// actually reached the server. Returns the ids that were confirmed.
  Future<List<({String clientMessageId, String envelopeId})>> flushOutbox() async {
    final entries = await _outbox.load();
    final confirmed = <({String clientMessageId, String envelopeId})>[];
    for (final e in entries) {
      try {
        final reply = e.replyToId == null
            ? null
            : WireReply(
                id: e.replyToId!,
                sender: e.replySender,
                preview: e.replyPreview,
                mediaType: e.replyMediaType,
              );
        final envelopeId = e.isGroup
            ? await sendGroupMessage(
                groupId: e.groupId!,
                plaintext: e.plaintext,
                clientMessageId: e.clientMessageId,
                viewOnce: e.viewOnce,
                ttlSeconds: e.ttlSeconds,
                reply: reply,
              )
            : await sendMessage(
                recipientUserId: e.recipientUserId!,
                plaintext: e.plaintext,
                clientMessageId: e.clientMessageId,
                viewOnce: e.viewOnce,
                ttlSeconds: e.ttlSeconds,
                reply: reply,
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

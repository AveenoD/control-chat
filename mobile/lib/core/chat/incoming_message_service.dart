import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/session_provider.dart';
import '../db/message_store.dart';
import '../realtime/chat_realtime_service.dart';
import 'active_conversation.dart';
import 'chat_models.dart';
import 'typing_service.dart';
import 'chat_repository.dart';
import 'group_repository.dart';
import 'message_wire.dart';

final incomingMessageServiceProvider =
    Provider<IncomingMessageService>((ref) => IncomingMessageService(ref));

/// App-global consumer of realtime pushes. Unlike the per-conversation handler
/// in the chat thread screen, this runs for the whole session — so an incoming
/// message is decrypted, stored, and **delivery-acked immediately even when the
/// relevant chat (or the app's chat list) is not on screen**. This is what makes
/// the sender's "delivered" (✓✓) tick appear regardless of which screen the
/// recipient is on, matching WhatsApp/Signal behaviour.
///
/// It intentionally does NOT send *read* receipts — those stay tied to actually
/// viewing the conversation (handled by the thread screen → blue tick on seen).
class IncomingMessageService {
  IncomingMessageService(this._ref);

  final Ref _ref;
  StreamSubscription<Map<String, dynamic>>? _sub;

  /// Envelopes we've already delivery-acked (avoids duplicate POSTs).
  final Set<String> _ackedDelivery = {};

  /// Envelopes we've already ingested (avoids duplicate decrypt/store work).
  final Set<String> _processed = {};

  bool get _isRunning => _sub != null;

  void start() {
    if (_isRunning) return;
    _sub = _ref.read(chatRealtimeProvider).events.listen(_onEvent);
  }

  void stop() {
    _sub?.cancel();
    _sub = null;
    _ackedDelivery.clear();
    _processed.clear();
  }

  Future<void> _onEvent(Map<String, dynamic> data) async {
    final type = data['type'] as String?;
    final convId = data['conversationId'] as String?;

    // Status updates from the peer about MY messages — persist to the store so
    // the sender's ticks (✓✓ / read) are correct regardless of the open screen.
    if (type == 'delivery') {
      final eid = data['envelopeId'] as String?;
      if (convId != null && eid != null) {
        await _ref.read(messageStoreProvider).markStatusByServerId(convId, eid, delivered: true);
      }
      return;
    }
    if (type == 'receipt') {
      final eid = data['envelopeId'] as String?;
      if (convId != null && eid != null) {
        await _ref
            .read(messageStoreProvider)
            .markStatusByServerId(convId, eid, delivered: true, read: true);
      }
      return;
    }

    // Group membership/lifecycle system lines (plaintext metadata).
    if (type == 'group_event') {
      await _handleGroupEvent(data);
      return;
    }

    // Everything else we care about is an incoming message (carries ciphertext).
    // Typing / call / __synced are handled elsewhere and ignored here.
    final ciphertext = data['ciphertext'] as String?;
    final senderId = data['senderUserId'] as String?;
    if (ciphertext == null || senderId == null || convId == null) return;

    final myId = _ref.read(sessionProvider).userId;
    if (myId == null || senderId == myId) return;

    final envelopeId = data['envelopeId'] as String? ?? data['clientMessageId'] as String?;
    if (envelopeId != null) {
      if (_processed.contains(envelopeId)) return;
      _processed.add(envelopeId);
    }

    final repo = _ref.read(chatRepositoryProvider);
    final store = _ref.read(messageStoreProvider);

    String text;
    try {
      text = await repo.decryptEnvelope(
        ciphertext: ciphertext,
        conversationId: convId,
        senderUserId: senderId,
        senderDeviceId: data['senderDeviceId'] as String? ?? '',
        // For an incoming message the sender is always the peer.
        peerUserId: senderId,
      );
    } catch (_) {
      // Let the thread's sync recover it later; allow a future re-push to retry.
      if (envelopeId != null) _processed.remove(envelopeId);
      return;
    }

    // Feature metadata travels inside the E2EE plaintext.
    final wire = text.startsWith('🔒') ? WireMessage(text: text) : ChatWire.decode(text);

    if (wire.isTimerControl) {
      await store.setDisappearing(convId, wire.timerSeconds);
      return;
    }
    if (wire.isReaction) {
      final tid = wire.reactionTargetId;
      if (tid != null) {
        if (wire.reactionAdd && wire.reactionEmoji != null) {
          await store.setReaction(
            conversationId: convId,
            targetId: tid,
            reactorUserId: senderId,
            emoji: wire.reactionEmoji!,
          );
        } else {
          await store.removeReaction(targetId: tid, reactorUserId: senderId);
        }
      }
      return;
    }

    final now = DateTime.now();
    await store.upsertServerMessage(
      ChatMessage(
        id: envelopeId ?? 'rt-${now.millisecondsSinceEpoch}',
        conversationId: convId,
        senderUserId: senderId,
        text: wire.text,
        createdAt: now,
        isMine: false,
        clientMessageId: data['clientMessageId'] as String?,
        viewOnce: wire.viewOnce,
        expiresAt: wire.ttlSeconds > 0 ? now.add(Duration(seconds: wire.ttlSeconds)) : null,
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
      ),
      bumpUnread: _ref.read(activeConversationIdProvider) != convId,
    );

    _ref.read(peerTypingProvider.notifier).clear(convId);

    // View-once: we now hold the plaintext locally, so immediately delete the
    // server-side ciphertext — a re-download can never resurrect/re-decrypt it.
    if (wire.viewOnce && envelopeId != null) {
      repo.consumeViewOnce(envelopeId);
    }

    // Delivered the moment it lands on the device — independent of any screen.
    _sendDeliveryAck(convId, envelopeId);
  }

  Future<void> _handleGroupEvent(Map<String, dynamic> data) async {
    final convId = data['conversationId'] as String?;
    final groupId = data['groupId'] as String?;
    final eventType = data['eventType'] as String?;
    if (convId == null || eventType == null) return;

    final eventId = data['eventId'] as String?;
    if (eventId != null) {
      if (_processed.contains(eventId)) return;
      _processed.add(eventId);
    }

    final myId = _ref.read(sessionProvider).userId;
    final store = _ref.read(messageStoreProvider);

    // I was added back → reactivate the (previously left) chat.
    if (eventType == 'member_added' && data['targetUserId'] == myId) {
      await store.markGroupRejoined(convId);
    }

    final actorIsMe = data['actorUserId'] != null && data['actorUserId'] == myId;
    final actor = actorIsMe ? 'You' : (data['actorName'] as String? ?? 'Someone');
    final target = data['targetName'] as String? ?? 'someone';
    final newTitle = (data['meta'] as Map<String, dynamic>?)?['title'] as String?;
    final ts = DateTime.tryParse(data['ts'] as String? ?? '') ?? DateTime.now();

    await store.upsertServerMessage(
      ChatMessage(
        id: eventId ?? 'sys-${ts.millisecondsSinceEpoch}',
        conversationId: convId,
        senderUserId: kSystemSenderId,
        text: _systemText(eventType, actor, target, newTitle: newTitle),
        createdAt: ts,
        isMine: false,
      ),
      bumpUnread: _ref.read(activeConversationIdProvider) != convId,
    );

    // Group deleted for everyone → make the chat read-only (it no longer exists
    // server-side).
    if (eventType == 'group_deleted') {
      await store.markGroupLeft(convId);
      return;
    }

    // Avatar changed → refresh the conversation list so the new photo shows.
    if (eventType == 'group_avatar') {
      _ref.read(chatRepositoryProvider).fetchConversations().catchError(
            (_) => <ConversationSummary>[],
          );
    }

    // Membership changes rotate the shared key. Refresh our epoch view and let
    // the designated admin (lowest user id) generate + distribute the new key.
    if (groupId != null && (eventType == 'member_removed' || eventType == 'member_left')) {
      final groups = _ref.read(groupRepositoryProvider);
      groups.invalidateEpoch(groupId);
      groups.rotateIfNeeded(groupId).catchError((_) {});
    }

    // A new member (added or joined via link) has no key yet → any key-holder
    // re-seals the current key to all member devices, reaching the newcomer.
    if (groupId != null && (eventType == 'member_added' || eventType == 'member_joined')) {
      _ref
          .read(groupRepositoryProvider)
          .ensureKeyDistributed(groupId, force: true)
          .catchError((_) {});
    }
  }

  String _systemText(String eventType, String actor, String target, {String? newTitle}) {
    switch (eventType) {
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

  void _sendDeliveryAck(String conversationId, String? envelopeId) {
    if (envelopeId == null || _ackedDelivery.contains(envelopeId)) return;
    _ackedDelivery.add(envelopeId);
    _ref
        .read(chatRepositoryProvider)
        .sendDeliveryReceipt(conversationId: conversationId, envelopeId: envelopeId)
        .catchError((_) => _ackedDelivery.remove(envelopeId));
  }
}

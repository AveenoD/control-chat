import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../chat/chat_models.dart';
import 'app_database.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final messageStoreProvider = Provider<MessageStore>((ref) {
  return MessageStore(ref.watch(appDatabaseProvider));
});

bool _isSentinel(String body) => body.startsWith('🔒');

/// Chat-shaped API over the local Drift database. Everything the UI shows is
/// read from here; the network layer only writes into it. This is what makes
/// the app offline-capable and instant on open.
class MessageStore {
  MessageStore(this._db);

  final AppDatabase _db;

  ChatMessage _toMessage(Message r) => ChatMessage(
        id: r.serverId ?? 'local-${r.clientMessageId ?? r.localId}',
        conversationId: r.conversationId,
        senderUserId: r.senderUserId,
        text: r.body,
        createdAt: DateTime.fromMillisecondsSinceEpoch(r.createdAt),
        isMine: r.isMine,
        deliveredToPeer: r.delivered,
        readByPeer: r.readByPeer,
        senderLabel: r.senderLabel,
        clientMessageId: r.clientMessageId,
        sendFailed: r.sendFailed,
        viewOnce: r.viewOnce,
        viewed: r.viewed,
        expiresAt: r.expiresAt == null
            ? null
            : DateTime.fromMillisecondsSinceEpoch(r.expiresAt!),
      );

  /// Reactive stream of a conversation's messages, oldest → newest.
  Stream<List<ChatMessage>> watchMessages(String conversationId) {
    final query = _db.select(_db.messages)
      ..where((t) => t.conversationId.equals(conversationId))
      ..orderBy([(t) => OrderingTerm(expression: t.createdAt)]);
    return query.watch().map((rows) => rows.map(_toMessage).toList());
  }

  Future<List<ChatMessage>> getMessages(String conversationId) async {
    final query = _db.select(_db.messages)
      ..where((t) => t.conversationId.equals(conversationId))
      ..orderBy([(t) => OrderingTerm(expression: t.createdAt)]);
    return (await query.get()).map(_toMessage).toList();
  }

  Future<Message?> _findByServerOrClient(String? serverId, String? clientMessageId) {
    final q = _db.select(_db.messages)..limit(1);
    q.where((t) {
      Expression<bool> pred = const Constant(false);
      if (serverId != null) pred = pred | t.serverId.equals(serverId);
      if (clientMessageId != null) pred = pred | t.clientMessageId.equals(clientMessageId);
      return pred;
    });
    return q.getSingleOrNull();
  }

  /// Insert/update a confirmed (server-side) message. Preserves delivery/read
  /// flags and never overwrites a good decryption with a failure sentinel.
  Future<void> upsertServerMessage(ChatMessage m) async {
    final existing = await _findByServerOrClient(m.id, m.clientMessageId);
    if (existing == null) {
      // A disappearing message that already expired before we ever stored it
      // (e.g. re-syncing an old window) should not flash back into the UI.
      final exp = m.expiresAt;
      if (exp != null && exp.isBefore(DateTime.now())) return;
      await _db.into(_db.messages).insert(
            MessagesCompanion.insert(
              serverId: Value(m.id),
              clientMessageId: Value(m.clientMessageId),
              conversationId: m.conversationId,
              senderUserId: m.senderUserId,
              body: m.text,
              createdAt: m.createdAt.millisecondsSinceEpoch,
              isMine: Value(m.isMine),
              delivered: Value(m.deliveredToPeer),
              readByPeer: Value(m.readByPeer),
              senderLabel: Value(m.senderLabel),
              viewOnce: Value(m.viewOnce),
              expiresAt: Value(m.expiresAt?.millisecondsSinceEpoch),
            ),
          );
      return;
    }
    // A re-fetch must never resurrect a view-once message the user already
    // opened — keep it consumed (body stays wiped, viewed stays true).
    final keepBody = (_isSentinel(m.text) && !_isSentinel(existing.body)) || existing.viewed;
    await (_db.update(_db.messages)..where((t) => t.localId.equals(existing.localId))).write(
      MessagesCompanion(
        serverId: Value(m.id),
        clientMessageId: Value(m.clientMessageId ?? existing.clientMessageId),
        body: keepBody ? const Value.absent() : Value(m.text),
        // Never downgrade status / never clear flags on a re-fetch.
        delivered: m.deliveredToPeer ? const Value(true) : const Value.absent(),
        readByPeer: m.readByPeer ? const Value(true) : const Value.absent(),
        sendFailed: const Value(false),
        senderLabel: Value(m.senderLabel ?? existing.senderLabel),
        viewOnce: Value(m.viewOnce || existing.viewOnce),
        expiresAt: Value(
          m.expiresAt?.millisecondsSinceEpoch ?? existing.expiresAt,
        ),
      ),
    );
  }

  Future<void> upsertMany(List<ChatMessage> messages) async {
    for (final m in messages) {
      await upsertServerMessage(m);
    }
  }

  /// Insert an optimistic outgoing message (no server id yet).
  Future<void> insertOptimistic({
    required String clientMessageId,
    required String conversationId,
    required String senderUserId,
    required String text,
    required DateTime createdAt,
    bool viewOnce = false,
    DateTime? expiresAt,
  }) async {
    final existing = await _findByServerOrClient(null, clientMessageId);
    if (existing != null) return;
    await _db.into(_db.messages).insert(
          MessagesCompanion.insert(
            clientMessageId: Value(clientMessageId),
            conversationId: conversationId,
            senderUserId: senderUserId,
            body: text,
            createdAt: createdAt.millisecondsSinceEpoch,
            isMine: const Value(true),
            viewOnce: Value(viewOnce),
            expiresAt: Value(expiresAt?.millisecondsSinceEpoch),
          ),
        );
  }

  /// Consume a view-once message: mark it opened and wipe the plaintext from
  /// local storage so it can never be read again (or resurrected by a re-sync).
  Future<void> markViewed(ChatMessage m) async {
    final existing = await _findByServerOrClient(
      m.confirmedOnServer ? m.id : null,
      m.clientMessageId,
    );
    if (existing == null) return;
    await (_db.update(_db.messages)..where((t) => t.localId.equals(existing.localId))).write(
      const MessagesCompanion(viewed: Value(true), body: Value('')),
    );
  }

  /// Purge permanently-undecryptable junk ("🔒 Unable to decrypt") for a
  /// conversation. Called on open before a re-sync: any message still addressed
  /// to this device comes back decrypted, while truly orphaned ciphertext
  /// (encrypted to a stale/old device key) simply stops cluttering the thread.
  Future<int> deleteUndecryptable(String conversationId) {
    return (_db.delete(_db.messages)
          ..where((t) =>
              t.conversationId.equals(conversationId) &
              t.body.equals('🔒 Unable to decrypt')))
        .go();
  }

  /// Delete disappearing messages whose timer has elapsed. Driven by the
  /// thread screen's periodic sweep + lifecycle hooks (not polling the network).
  Future<int> deleteExpired() {
    final now = DateTime.now().millisecondsSinceEpoch;
    return (_db.delete(_db.messages)
          ..where((t) => t.expiresAt.isSmallerOrEqualValue(now)))
        .go();
  }

  // ---- Per-conversation disappearing-message timer ----

  Stream<int> watchDisappearing(String conversationId) {
    final q = _db.select(_db.conversationSettings)
      ..where((t) => t.conversationId.equals(conversationId))
      ..limit(1);
    return q.watch().map((rows) => rows.isEmpty ? 0 : rows.first.disappearingSeconds);
  }

  Future<int> disappearingSeconds(String conversationId) async {
    final row = await (_db.select(_db.conversationSettings)
          ..where((t) => t.conversationId.equals(conversationId))
          ..limit(1))
        .getSingleOrNull();
    return row?.disappearingSeconds ?? 0;
  }

  Future<void> setDisappearing(String conversationId, int seconds) async {
    await _db.into(_db.conversationSettings).insertOnConflictUpdate(
          ConversationSettingsCompanion.insert(
            conversationId: conversationId,
            disappearingSeconds: Value(seconds),
          ),
        );
  }

  Future<void> confirmSent(String clientMessageId, String serverId) async {
    await (_db.update(_db.messages)..where((t) => t.clientMessageId.equals(clientMessageId))).write(
      MessagesCompanion(serverId: Value(serverId), sendFailed: const Value(false)),
    );
  }

  Future<void> markFailed(String clientMessageId, bool failed) async {
    await (_db.update(_db.messages)..where((t) => t.clientMessageId.equals(clientMessageId))).write(
      MessagesCompanion(sendFailed: Value(failed)),
    );
  }

  /// Mark our outgoing messages delivered/read up to (and including) the one
  /// identified by [serverId] — matches WhatsApp's "all prior ticks fill in".
  Future<void> markStatusByServerId(
    String conversationId,
    String serverId, {
    bool delivered = false,
    bool read = false,
  }) async {
    final row = await (_db.select(_db.messages)
          ..where((t) => t.serverId.equals(serverId))
          ..limit(1))
        .getSingleOrNull();
    final cutoff = row?.createdAt;
    final update = _db.update(_db.messages)
      ..where((t) {
        var pred = t.conversationId.equals(conversationId) & t.isMine.equals(true);
        if (cutoff != null) {
          pred = pred & t.createdAt.isSmallerOrEqualValue(cutoff);
        } else {
          pred = pred & t.serverId.equals(serverId);
        }
        return pred;
      });
    await update.write(MessagesCompanion(
      delivered: (delivered || read) ? const Value(true) : const Value.absent(),
      readByPeer: read ? const Value(true) : const Value.absent(),
    ));
  }

  // ---- Conversations (offline chat list) ----

  Stream<List<ConversationSummary>> watchConversations() {
    final query = _db.select(_db.conversations)
      ..orderBy([(t) => OrderingTerm(expression: t.lastAt, mode: OrderingMode.desc)]);
    return query.watch().map((rows) => rows.map(_toSummary).toList());
  }

  ConversationSummary _toSummary(Conversation r) => ConversationSummary(
        conversationId: r.conversationId,
        peer: ChatPeer(
          userId: r.peerUserId ?? r.conversationId,
          username: r.username,
          displayName: r.title,
        ),
        lastAt: DateTime.fromMillisecondsSinceEpoch(r.lastAt),
        lastPreview: r.lastPreview,
        isGroup: r.isGroup,
        groupId: r.groupId,
      );

  Future<void> upsertConversations(List<ConversationSummary> list) async {
    await _db.batch((b) {
      for (final c in list) {
        b.insert(
          _db.conversations,
          ConversationsCompanion.insert(
            conversationId: c.conversationId,
            peerUserId: Value(c.peer.userId),
            title: Value(c.peer.displayName),
            username: Value(c.peer.username),
            isGroup: Value(c.isGroup),
            groupId: Value(c.groupId),
            lastAt: c.lastAt.millisecondsSinceEpoch,
            lastPreview: Value(c.lastPreview),
          ),
          onConflict: DoUpdate(
            (_) => ConversationsCompanion(
              peerUserId: Value(c.peer.userId),
              title: Value(c.peer.displayName),
              username: Value(c.peer.username),
              isGroup: Value(c.isGroup),
              groupId: Value(c.groupId),
              lastAt: Value(c.lastAt.millisecondsSinceEpoch),
              lastPreview: Value(c.lastPreview),
            ),
          ),
        );
      }
    });
  }

  Future<void> clearAll() async {
    await _db.delete(_db.messages).go();
    await _db.delete(_db.conversations).go();
    await _db.delete(_db.callHistoryItems).go();
    await _db.delete(_db.conversationSettings).go();
  }
}

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
            ),
          );
      return;
    }
    final keepBody = _isSentinel(m.text) && !_isSentinel(existing.body);
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
  }
}

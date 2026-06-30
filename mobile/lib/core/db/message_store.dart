import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../chat/chat_models.dart';
import '../chat/conversation_id.dart';
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

String? _waveformToString(List<int>? bars) =>
    (bars == null || bars.isEmpty) ? null : bars.join(',');

List<int>? _parseWaveform(String? s) {
  if (s == null || s.isEmpty) return null;
  return s
      .split(',')
      .map((e) => int.tryParse(e) ?? 0)
      .toList(growable: false);
}

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
        mediaType: r.mediaType,
        mediaBlobId: r.mediaBlobId,
        mediaKey: r.mediaKey,
        mediaMime: r.mediaMime,
        mediaWidth: r.mediaWidth,
        mediaHeight: r.mediaHeight,
        mediaLocalPath: r.mediaLocalPath,
        mediaFilename: r.mediaFilename,
        mediaSize: r.mediaSize,
        mediaDurationMs: r.mediaDurationMs,
        mediaWaveform: _parseWaveform(r.mediaWaveform),
        replyToId: r.replyToId,
        replySender: r.replySender,
        replyPreview: r.replyPreview,
        replyMediaType: r.replyMediaType,
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
    // Run the find-then-write atomically. Multiple concurrent ingesters (the
    // app-global incoming handler, the thread's sync, a realtime push) can race
    // on the same message; without a transaction each would read "not found"
    // and insert, producing duplicates. The transaction serialises them so the
    // second caller sees the first insert and updates instead.
    await _db.transaction(() async {
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
              mediaType: Value(m.mediaType),
              mediaBlobId: Value(m.mediaBlobId),
              mediaKey: Value(m.mediaKey),
              mediaMime: Value(m.mediaMime),
              mediaWidth: Value(m.mediaWidth),
              mediaHeight: Value(m.mediaHeight),
              mediaLocalPath: Value(m.mediaLocalPath),
              mediaFilename: Value(m.mediaFilename),
              mediaSize: Value(m.mediaSize),
              mediaDurationMs: Value(m.mediaDurationMs),
              mediaWaveform: Value(_waveformToString(m.mediaWaveform)),
              replyToId: Value(m.replyToId),
              replySender: Value(m.replySender),
              replyPreview: Value(m.replyPreview),
              replyMediaType: Value(m.replyMediaType),
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
        // Carry media metadata from the server copy, but never lose an already
        // downloaded local file (re-download is wasteful and may be offline).
        mediaType: Value(m.mediaType ?? existing.mediaType),
        mediaBlobId: Value(m.mediaBlobId ?? existing.mediaBlobId),
        mediaKey: Value(m.mediaKey ?? existing.mediaKey),
        mediaMime: Value(m.mediaMime ?? existing.mediaMime),
        mediaWidth: Value(m.mediaWidth ?? existing.mediaWidth),
        mediaHeight: Value(m.mediaHeight ?? existing.mediaHeight),
        mediaLocalPath: Value(existing.mediaLocalPath ?? m.mediaLocalPath),
        mediaFilename: Value(m.mediaFilename ?? existing.mediaFilename),
        mediaSize: Value(m.mediaSize ?? existing.mediaSize),
        mediaDurationMs: Value(m.mediaDurationMs ?? existing.mediaDurationMs),
        mediaWaveform: Value(_waveformToString(m.mediaWaveform) ?? existing.mediaWaveform),
        replyToId: Value(m.replyToId ?? existing.replyToId),
        replySender: Value(m.replySender ?? existing.replySender),
        replyPreview: Value(m.replyPreview ?? existing.replyPreview),
        replyMediaType: Value(m.replyMediaType ?? existing.replyMediaType),
      ),
    );
    });
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
    String? mediaType,
    String? mediaMime,
    int? mediaWidth,
    int? mediaHeight,
    String? mediaLocalPath,
    String? mediaFilename,
    int? mediaSize,
    int? mediaDurationMs,
    List<int>? mediaWaveform,
    String? replyToId,
    String? replySender,
    String? replyPreview,
    String? replyMediaType,
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
            mediaType: Value(mediaType),
            mediaMime: Value(mediaMime),
            mediaWidth: Value(mediaWidth),
            mediaHeight: Value(mediaHeight),
            mediaLocalPath: Value(mediaLocalPath),
            mediaFilename: Value(mediaFilename),
            mediaSize: Value(mediaSize),
            mediaDurationMs: Value(mediaDurationMs),
            mediaWaveform: Value(_waveformToString(mediaWaveform)),
            replyToId: Value(replyToId),
            replySender: Value(replySender),
            replyPreview: Value(replyPreview),
            replyMediaType: Value(replyMediaType),
          ),
        );
  }

  /// Record the uploaded blob id + key on an optimistic media message once the
  /// upload completes (so it can be re-downloaded later if the cache is gone).
  Future<void> setMediaBlob(String clientMessageId, String blobId, String key) async {
    await (_db.update(_db.messages)..where((t) => t.clientMessageId.equals(clientMessageId)))
        .write(MessagesCompanion(mediaBlobId: Value(blobId), mediaKey: Value(key)));
  }

  /// Cache the decrypted local file path for a media message (by server id).
  Future<void> setMediaLocalPath(String serverId, String path) async {
    await (_db.update(_db.messages)..where((t) => t.serverId.equals(serverId)))
        .write(MessagesCompanion(mediaLocalPath: Value(path)));
  }

  /// Consume a view-once message: mark it opened and wipe the plaintext from
  /// local storage so it can never be read again (or resurrected by a re-sync).
  Future<void> markViewed(ChatMessage m) async {
    final existing = await _findByServerOrClient(
      m.confirmedOnServer ? m.id : null,
      m.clientMessageId,
    );
    if (existing == null) return;
    // Wipe the body AND the media so a one-time view can never be reopened or
    // re-downloaded from storage.
    await (_db.update(_db.messages)..where((t) => t.localId.equals(existing.localId))).write(
      const MessagesCompanion(
        viewed: Value(true),
        body: Value(''),
        mediaBlobId: Value(null),
        mediaKey: Value(null),
        mediaLocalPath: Value(null),
      ),
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
        // Source of truth is the id prefix — never trust a possibly-stale flag,
        // so a "group:" conversation is always treated as a group.
        isGroup: isGroupConversation(r.conversationId) || r.isGroup,
        groupId: r.groupId ?? groupIdFromConversation(r.conversationId),
        leftGroup: r.leftGroup,
        avatarBlobId: r.avatarBlobId,
        avatarKey: r.avatarKey,
      );

  /// Mark a group conversation as left (read-only). The row is preserved so the
  /// chat stays in the list instead of disappearing.
  Future<void> markGroupLeft(String conversationId) async {
    final affected = await (_db.update(_db.conversations)
          ..where((t) => t.conversationId.equals(conversationId)))
        .write(const ConversationsCompanion(leftGroup: Value(true)));
    // If no row exists yet (group seen only via realtime), create a minimal one
    // so the flag persists and the chat stays in the list.
    if (affected == 0) {
      await _db.into(_db.conversations).insert(
            ConversationsCompanion.insert(
              conversationId: conversationId,
              isGroup: const Value(true),
              groupId: Value(groupIdFromConversation(conversationId)),
              lastAt: DateTime.now().millisecondsSinceEpoch,
              leftGroup: const Value(true),
            ),
            mode: InsertMode.insertOrReplace,
          );
    }
  }

  /// Reflect a just-set group avatar locally (instant, before the next
  /// /conversations sync). Creates a minimal row if none exists yet.
  Future<void> setGroupAvatarLocal(
    String conversationId,
    String? blobId,
    String? key,
  ) async {
    final affected = await (_db.update(_db.conversations)
          ..where((t) => t.conversationId.equals(conversationId)))
        .write(ConversationsCompanion(
          avatarBlobId: Value(blobId),
          avatarKey: Value(key),
        ));
    if (affected == 0) {
      await _db.into(_db.conversations).insert(
            ConversationsCompanion.insert(
              conversationId: conversationId,
              isGroup: const Value(true),
              groupId: Value(groupIdFromConversation(conversationId)),
              lastAt: DateTime.now().millisecondsSinceEpoch,
              avatarBlobId: Value(blobId),
              avatarKey: Value(key),
            ),
            mode: InsertMode.insertOrReplace,
          );
    }
  }

  Future<void> markGroupRejoined(String conversationId) async {
    await (_db.update(_db.conversations)
          ..where((t) => t.conversationId.equals(conversationId)))
        .write(const ConversationsCompanion(leftGroup: Value(false)));
  }

  Future<bool> isGroupLeft(String conversationId) async {
    final row = await (_db.select(_db.conversations)
          ..where((t) => t.conversationId.equals(conversationId))
          ..limit(1))
        .getSingleOrNull();
    return row?.leftGroup ?? false;
  }

  Stream<bool> watchGroupLeft(String conversationId) {
    final q = _db.select(_db.conversations)
      ..where((t) => t.conversationId.equals(conversationId))
      ..limit(1);
    return q.watch().map((rows) => rows.isNotEmpty && rows.first.leftGroup);
  }

  /// Fully remove a conversation locally (row + messages + reactions + settings).
  Future<void> deleteConversation(String conversationId) async {
    await _db.transaction(() async {
      await (_db.delete(_db.messages)
            ..where((t) => t.conversationId.equals(conversationId)))
          .go();
      await (_db.delete(_db.messageReactions)
            ..where((t) => t.conversationId.equals(conversationId)))
          .go();
      await (_db.delete(_db.conversationSettings)
            ..where((t) => t.conversationId.equals(conversationId)))
          .go();
      await (_db.delete(_db.conversations)
            ..where((t) => t.conversationId.equals(conversationId)))
          .go();
    });
  }

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
            avatarBlobId: Value(c.avatarBlobId),
            avatarKey: Value(c.avatarKey),
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
              avatarBlobId: Value(c.avatarBlobId),
              avatarKey: Value(c.avatarKey),
              // Server only returns groups we're still in → clear any stale
              // "left" flag (covers re-join).
              leftGroup: const Value(false),
            ),
          ),
        );
      }
    });
  }

  // ---- Reactions ----

  /// Reactive map of targetMessageId -> its reactions for a conversation.
  Stream<Map<String, List<ReactionView>>> watchReactions(
    String conversationId,
    String myUserId,
  ) {
    final q = _db.select(_db.messageReactions)
      ..where((t) => t.conversationId.equals(conversationId));
    return q.watch().map((rows) {
      final map = <String, List<ReactionView>>{};
      for (final r in rows) {
        (map[r.targetId] ??= []).add(ReactionView(
          targetId: r.targetId,
          reactorUserId: r.reactorUserId,
          emoji: r.emoji,
          isMine: r.reactorUserId == myUserId,
        ));
      }
      return map;
    });
  }

  /// Add/replace a user's reaction on a message (one emoji per user).
  Future<void> setReaction({
    required String conversationId,
    required String targetId,
    required String reactorUserId,
    required String emoji,
  }) async {
    await _db.into(_db.messageReactions).insertOnConflictUpdate(
          MessageReactionsCompanion.insert(
            targetId: targetId,
            conversationId: conversationId,
            reactorUserId: reactorUserId,
            emoji: emoji,
            updatedAt: DateTime.now().millisecondsSinceEpoch,
          ),
        );
  }

  Future<void> removeReaction({
    required String targetId,
    required String reactorUserId,
  }) async {
    await (_db.delete(_db.messageReactions)
          ..where((t) => t.targetId.equals(targetId) & t.reactorUserId.equals(reactorUserId)))
        .go();
  }

  Future<void> clearAll() async {
    await _db.delete(_db.messages).go();
    await _db.delete(_db.conversations).go();
    await _db.delete(_db.callHistoryItems).go();
    await _db.delete(_db.conversationSettings).go();
    await _db.delete(_db.messageReactions).go();
  }
}

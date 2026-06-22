import 'dart:io';
import 'dart:math';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

/// Local message store — the on-device source of truth that makes the app
/// work offline and open instantly (WhatsApp/Signal model). Server + WebSocket
/// writes are merged here; the UI renders from a reactive query on this table.
class Messages extends Table {
  IntColumn get localId => integer().autoIncrement()();

  /// Server envelope id once the message is confirmed; null while only local.
  TextColumn get serverId => text().nullable()();

  /// Links an optimistic message to its server echo + outbox entry.
  TextColumn get clientMessageId => text().nullable()();

  TextColumn get conversationId => text()();
  TextColumn get senderUserId => text()();

  /// Decrypted plaintext (or a sentinel like "🔒 Unable to decrypt").
  TextColumn get body => text()();

  /// Epoch millis — cheaper to sort/range than DateTime in SQLite.
  IntColumn get createdAt => integer()();

  BoolColumn get isMine => boolean().withDefault(const Constant(false))();
  BoolColumn get delivered => boolean().withDefault(const Constant(false))();
  BoolColumn get readByPeer => boolean().withDefault(const Constant(false))();
  BoolColumn get sendFailed => boolean().withDefault(const Constant(false))();

  TextColumn get senderLabel => text().nullable()();
}

/// Cached call log so the Calls tab renders offline / instantly.
class CallHistoryItems extends Table {
  TextColumn get id => text()();
  TextColumn get conversationId => text()();
  TextColumn get callType => text()();
  TextColumn get status => text()();
  IntColumn get startedAt => integer()();
  TextColumn get peerLabel => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Cached conversation list so the chats screen renders offline / instantly.
class Conversations extends Table {
  TextColumn get conversationId => text()();
  TextColumn get peerUserId => text().nullable()();
  TextColumn get title => text().nullable()();
  TextColumn get username => text().nullable()();
  BoolColumn get isGroup => boolean().withDefault(const Constant(false))();
  TextColumn get groupId => text().nullable()();
  IntColumn get lastAt => integer()();
  TextColumn get lastPreview => text().withDefault(const Constant(''))();

  @override
  Set<Column> get primaryKey => {conversationId};
}

@DriftDatabase(tables: [Messages, Conversations, CallHistoryItems])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_open());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onCreate: (m) async {
          await m.createAll();
          await customStatement(
            'CREATE INDEX IF NOT EXISTS idx_messages_conv ON messages (conversation_id, created_at)',
          );
          await customStatement(
            'CREATE INDEX IF NOT EXISTS idx_messages_server ON messages (server_id)',
          );
          await customStatement(
            'CREATE INDEX IF NOT EXISTS idx_messages_cmid ON messages (client_message_id)',
          );
        },
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(callHistoryItems);
          }
        },
      );
}

const _cipherKeyStorageKey = 'db_cipher_key_v1';

/// Opens the local database encrypted-at-rest (AES) using the bundled
/// SQLite3MultipleCiphers build. The 256-bit key lives only in the OS keystore
/// (flutter_secure_storage); without it the .sqlite file on disk is unreadable
/// ciphertext.
LazyDatabase _open() {
  return LazyDatabase(() async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File(p.join(dir.path, 'auratalk.sqlite'));
    const storage = FlutterSecureStorage();
    final key = await _databaseKey(storage, file);

    return NativeDatabase(
      file,
      setup: (rawDb) {
        // Fail loudly in debug if the encryption-capable build isn't active,
        // so we never silently store plaintext.
        assert(() {
          final result = rawDb.select('pragma cipher');
          if (result.isEmpty) {
            throw UnsupportedError(
              'SQLite3MultipleCiphers is not active — DB would be unencrypted.',
            );
          }
          return true;
        }());
        // Must run before any other access. PRAGMA key doesn't support bound
        // parameters, so the key is inlined (single quotes escaped).
        final escaped = key.replaceAll("'", "''");
        rawDb.execute("pragma key = '$escaped';");
        // Verify the key works (throws on mismatch / corruption).
        rawDb.execute('select count(*) from sqlite_master');
      },
    );
  });
}

Future<String> _databaseKey(FlutterSecureStorage storage, File dbFile) async {
  final existing = await storage.read(key: _cipherKeyStorageKey);
  if (existing != null && existing.isNotEmpty) return existing;

  // First run with encryption enabled: discard any pre-existing plaintext
  // database (it can't be opened with a key) and start a fresh encrypted one.
  // No data loss — messages re-sync from the server.
  if (await dbFile.exists()) {
    await dbFile.delete();
  }
  final rnd = Random.secure();
  final bytes = List<int>.generate(32, (_) => rnd.nextInt(256));
  final key = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  await storage.write(key: _cipherKeyStorageKey, value: key);
  return key;
}

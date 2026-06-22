import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// A message the user tried to send. Persisted until the server confirms it,
/// so a flaky network or app restart never loses an outgoing message.
class OutboxEntry {
  OutboxEntry({
    required this.clientMessageId,
    required this.conversationId,
    required this.plaintext,
    required this.isGroup,
    required this.createdAt,
    this.recipientUserId,
    this.groupId,
    this.attempts = 0,
  });

  final String clientMessageId;
  final String conversationId;
  final String plaintext;
  final bool isGroup;
  final DateTime createdAt;
  final String? recipientUserId;
  final String? groupId;
  int attempts;

  Map<String, dynamic> toJson() => {
        'clientMessageId': clientMessageId,
        'conversationId': conversationId,
        'plaintext': plaintext,
        'isGroup': isGroup,
        'createdAt': createdAt.toIso8601String(),
        'recipientUserId': recipientUserId,
        'groupId': groupId,
        'attempts': attempts,
      };

  factory OutboxEntry.fromJson(Map<String, dynamic> json) => OutboxEntry(
        clientMessageId: json['clientMessageId'] as String,
        conversationId: json['conversationId'] as String,
        plaintext: json['plaintext'] as String,
        isGroup: json['isGroup'] as bool? ?? false,
        createdAt: DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
        recipientUserId: json['recipientUserId'] as String?,
        groupId: json['groupId'] as String?,
        attempts: json['attempts'] as int? ?? 0,
      );
}

final outboxServiceProvider = Provider<OutboxService>((ref) => OutboxService());

/// Encrypted-at-rest outbox backed by flutter_secure_storage. Small volume
/// (only un-acked outgoing messages), serialized as a single JSON array.
class OutboxService {
  static const _storage = FlutterSecureStorage();
  static const _key = 'chat_outbox_v1';

  Future<List<OutboxEntry>> load() async {
    final raw = await _storage.read(key: _key);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return list.map((e) => OutboxEntry.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> _save(List<OutboxEntry> entries) async {
    if (entries.isEmpty) {
      await _storage.delete(key: _key);
      return;
    }
    await _storage.write(key: _key, value: jsonEncode(entries.map((e) => e.toJson()).toList()));
  }

  Future<void> add(OutboxEntry entry) async {
    final entries = await load();
    if (entries.any((e) => e.clientMessageId == entry.clientMessageId)) return;
    entries.add(entry);
    await _save(entries);
  }

  Future<void> remove(String clientMessageId) async {
    final entries = await load();
    entries.removeWhere((e) => e.clientMessageId == clientMessageId);
    await _save(entries);
  }

  Future<void> markAttempt(String clientMessageId) async {
    final entries = await load();
    final idx = entries.indexWhere((e) => e.clientMessageId == clientMessageId);
    if (idx < 0) return;
    entries[idx].attempts++;
    await _save(entries);
  }

  /// Entries for a specific conversation (used to repopulate UI on open).
  Future<List<OutboxEntry>> forConversation(String conversationId) async {
    final entries = await load();
    return entries.where((e) => e.conversationId == conversationId).toList();
  }
}

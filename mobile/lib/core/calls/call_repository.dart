import 'package:dio/dio.dart';
import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/dio_provider.dart';
import '../config/api_config.dart';
import '../db/app_database.dart';
import '../db/message_store.dart';

final callRepositoryProvider = Provider<CallRepository>((ref) {
  return CallRepository(ref.watch(dioProvider), ref.watch(appDatabaseProvider));
});

class CallSession {
  const CallSession({
    required this.callId,
    required this.roomName,
    required this.token,
    required this.livekitUrl,
    required this.callType,
    required this.conversationId,
  });

  final String callId;
  final String roomName;
  final String token;
  final String livekitUrl;
  final String callType;
  final String conversationId;
}

class CallHistoryEntry {
  const CallHistoryEntry({
    required this.id,
    required this.conversationId,
    required this.callType,
    required this.status,
    required this.startedAt,
    this.peerLabel,
  });

  final String id;
  final String conversationId;
  final String callType;
  final String status;
  final DateTime startedAt;
  final String? peerLabel;
}

class CallRepository {
  CallRepository(this._dio, this._db);

  final Dio _dio;
  final AppDatabase _db;

  CallHistoryEntry _toEntry(CallHistoryItem r) => CallHistoryEntry(
        id: r.id,
        conversationId: r.conversationId,
        callType: r.callType,
        status: r.status,
        startedAt: DateTime.fromMillisecondsSinceEpoch(r.startedAt),
        peerLabel: r.peerLabel,
      );

  /// Reactive stream of the cached call log (newest first) — renders offline.
  Stream<List<CallHistoryEntry>> watchHistory() {
    final q = _db.select(_db.callHistoryItems)
      ..orderBy([(t) => OrderingTerm(expression: t.startedAt, mode: OrderingMode.desc)]);
    return q.watch().map((rows) => rows.map(_toEntry).toList());
  }

  Future<CallSession> startCall({
    required String calleeUserId,
    required String conversationId,
    String callType = 'voice',
  }) async {
    final res = await _dio.post<Map<String, dynamic>>('/calls/start', data: {
      'calleeUserId': calleeUserId,
      'conversationId': conversationId,
      'callType': callType,
    });
    return CallSession(
      callId: res.data!['callId'] as String,
      roomName: res.data!['roomName'] as String,
      token: res.data!['token'] as String,
      livekitUrl: res.data!['livekitUrl'] as String? ?? ApiConfig.livekitWsUrl,
      callType: callType,
      conversationId: conversationId,
    );
  }

  Future<CallSession> joinCall(String callId) async {
    final res = await _dio.post<Map<String, dynamic>>('/calls/$callId/join');
    return CallSession(
      callId: callId,
      roomName: res.data!['roomName'] as String,
      token: res.data!['token'] as String,
      livekitUrl: res.data!['livekitUrl'] as String? ?? ApiConfig.livekitWsUrl,
      callType: 'voice',
      conversationId: '',
    );
  }

  Future<List<CallHistoryEntry>> fetchHistory() async {
    final res = await _dio.get<Map<String, dynamic>>('/calls/history');
    final rows = res.data!['calls'] as List<dynamic>;
    final list = rows.map((raw) {
      final r = raw as Map<String, dynamic>;
      return CallHistoryEntry(
        id: r['id'] as String,
        conversationId: r['conversation_id'] as String,
        callType: r['call_type'] as String? ?? 'voice',
        status: r['status'] as String? ?? 'ended',
        startedAt: DateTime.parse(r['started_at'] as String),
        peerLabel: r['peer_display_name'] as String? ?? r['peer_username'] as String?,
      );
    }).toList();
    // Cache for instant/offline rendering; the screen watches the store.
    await _db.batch((b) {
      for (final c in list) {
        b.insert(
          _db.callHistoryItems,
          CallHistoryItemsCompanion.insert(
            id: c.id,
            conversationId: c.conversationId,
            callType: c.callType,
            status: c.status,
            startedAt: c.startedAt.millisecondsSinceEpoch,
            peerLabel: Value(c.peerLabel),
          ),
          onConflict: DoUpdate(
            (_) => CallHistoryItemsCompanion(
              status: Value(c.status),
              peerLabel: Value(c.peerLabel),
              startedAt: Value(c.startedAt.millisecondsSinceEpoch),
            ),
          ),
        );
      }
    });
    return list;
  }
}

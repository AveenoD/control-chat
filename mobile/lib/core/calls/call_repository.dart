import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/dio_provider.dart';
import '../config/api_config.dart';

final callRepositoryProvider = Provider<CallRepository>((ref) {
  return CallRepository(ref.watch(dioProvider));
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
  CallRepository(this._dio);

  final Dio _dio;

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
    return rows.map((raw) {
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
  }
}

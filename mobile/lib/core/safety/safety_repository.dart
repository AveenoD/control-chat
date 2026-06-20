import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/dio_provider.dart';

final safetyRepositoryProvider = Provider<SafetyRepository>((ref) {
  return SafetyRepository(ref.watch(dioProvider));
});

class SafetyRepository {
  SafetyRepository(this._dio);

  final Dio _dio;

  Future<void> blockUser(String userId) async {
    await _dio.post('/blocks', data: {'userId': userId});
  }

  Future<void> unblockUser(String userId) async {
    await _dio.delete('/blocks/$userId');
  }

  Future<void> reportUser({
    required String reportedUserId,
    required String contextType,
    String? contextId,
    required String reason,
    String? details,
  }) async {
    await _dio.post('/reports', data: {
      'reportedUserId': reportedUserId,
      'contextType': contextType,
      if (contextId != null) 'contextId': contextId,
      'reason': reason,
      if (details != null) 'details': details,
    });
  }
}

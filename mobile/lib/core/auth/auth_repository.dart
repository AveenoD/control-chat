import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../api/dio_provider.dart';
import '../config/api_config.dart';
import 'auth_session.dart';

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepository(ref.watch(dioProvider));
});

class AuthRepository {
  AuthRepository(this._dio);

  final Dio _dio;
  static const _uuid = Uuid();

  String getOrCreateDeviceId(String? existing) => existing ?? _uuid.v4();

  Future<void> requestOtp(String phone) async {
    await _dio.post('/auth/request-otp', data: {'phone': phone});
  }

  Future<({String accessToken, String refreshToken, String userId})> verifyOtp({
    required String phone,
    required String otp,
    required String deviceId,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/auth/verify-otp',
      data: {'phone': phone, 'otp': otp, 'deviceId': deviceId},
    );
    final data = res.data!;
    return (
      accessToken: data['accessToken'] as String,
      refreshToken: data['refreshToken'] as String,
      userId: data['userId'] as String,
    );
  }

  Future<UserProfile> fetchMe() async {
    final res = await _dio.get<Map<String, dynamic>>('/me');
    final user = res.data!['user'] as Map<String, dynamic>;
    return UserProfile.fromJson(user);
  }

  Future<({String accessToken, String refreshToken, String userId})> refreshToken(
    String refreshToken, {
    required String userId,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/auth/refresh',
      data: {'refreshToken': refreshToken},
    );
    final data = res.data!;
    return (
      accessToken: data['accessToken'] as String,
      refreshToken: refreshToken,
      userId: userId,
    );
  }

  Future<String> completeOnboarding({
    required String username,
    required String displayName,
  }) async {
    final res = await _dio.post<Map<String, dynamic>>(
      '/me/onboarding',
      data: {'username': username.toLowerCase(), 'displayName': displayName},
    );
    return res.data!['username'] as String;
  }

  Future<bool> isUsernameAvailable(String username) async {
    final res = await _dio.get<Map<String, dynamic>>(
      '/users/username/${username.toLowerCase()}/available',
    );
    return res.data!['available'] as bool? ?? false;
  }

  Future<Map<String, dynamic>> getPrivacy() async {
    final res = await _dio.get<Map<String, dynamic>>('/me/privacy');
    return Map<String, dynamic>.from(res.data!['privacy'] as Map);
  }

  Future<void> updatePrivacy(Map<String, dynamic> patch) async {
    await _dio.put('/me/privacy', data: patch);
  }

  Future<List<dynamic>> fetchIncomingRequests() async {
    final res = await _dio.get<Map<String, dynamic>>(
      '/message-requests/incoming',
      queryParameters: {'status': 'pending'},
    );
    return res.data!['requests'] as List<dynamic>;
  }

  Future<void> acceptRequest(String requestId) async {
    // Fastify rejects empty JSON body when Content-Type is application/json.
    await _dio.post('/message-requests/$requestId/accept', data: <String, dynamic>{});
  }

  Future<void> declineRequest(String requestId) async {
    await _dio.post('/message-requests/$requestId/decline', data: <String, dynamic>{});
  }

  String get devOtp => ApiConfig.devOtp;
}

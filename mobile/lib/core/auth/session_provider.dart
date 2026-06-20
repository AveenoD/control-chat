import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'auth_repository.dart';
import 'auth_session.dart';
import '../crypto/chat_crypto_service.dart';
import '../crypto/device_keys_service.dart';
import '../realtime/chat_realtime_service.dart';

final sessionProvider = NotifierProvider<SessionNotifier, AuthSession>(SessionNotifier.new);

class SessionNotifier extends Notifier<AuthSession> {
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'access_token';
  static const _refreshKey = 'refresh_token';
  static const _userIdKey = 'user_id';
  static const _deviceIdKey = 'device_id';

  @override
  AuthSession build() {
    _restore();
    return const AuthSession(isLoading: true);
  }

  Future<void> _restore() async {
    final token = await _storage.read(key: _tokenKey);
    final refresh = await _storage.read(key: _refreshKey);
    final userId = await _storage.read(key: _userIdKey);
    final deviceId = await _storage.read(key: _deviceIdKey);

    if (token == null) {
      state = const AuthSession(isLoading: false);
      return;
    }

    state = AuthSession(
      accessToken: token,
      refreshToken: refresh,
      userId: userId,
      deviceId: deviceId,
      isLoading: true,
    );

    try {
      final profile = await ref.read(authRepositoryProvider).fetchMe();
      state = state.copyWith(profile: profile, isLoading: false);
    } catch (_) {
      final refreshed = await refreshAccessToken();
      if (!refreshed) {
        await _storage.deleteAll();
        state = const AuthSession(isLoading: false);
        return;
      }
      try {
        final profile = await ref.read(authRepositoryProvider).fetchMe();
        state = state.copyWith(profile: profile, isLoading: false);
      } catch (_) {
        await _storage.deleteAll();
        state = const AuthSession(isLoading: false);
        return;
      }
    }

    final uid = state.userId;
    final did = state.deviceId;
    if (uid != null && did != null) {
      _postLoginSetup(uid, did);
    }
  }

  /// Refresh access token using stored refresh token.
  Future<bool> refreshAccessToken() async {
    final refresh = state.refreshToken ?? await _storage.read(key: _refreshKey);
    if (refresh == null || refresh.isEmpty) return false;

    try {
      final userId = state.userId ?? await _storage.read(key: _userIdKey);
      if (userId == null || userId.isEmpty) return false;
      final res = await ref.read(authRepositoryProvider).refreshToken(
            refresh,
            userId: userId,
          );
      await _storage.write(key: _tokenKey, value: res.accessToken);
      await _storage.write(key: _refreshKey, value: res.refreshToken);
      state = state.copyWith(
        accessToken: res.accessToken,
        refreshToken: res.refreshToken,
        userId: res.userId,
      );
      return true;
    } catch (_) {
      return false;
    }
  }

  void _postLoginSetup(String userId, String deviceId) {
    _connectRealtime(userId, deviceId);
    Future(() async {
      try {
        await ref.read(deviceKeysServiceProvider).ensureRegistered(deviceId, userId: userId);
        await ChatCryptoService.publicKeyBase64();
      } catch (_) {}
    });
  }

  void _connectRealtime(String userId, String deviceId) {
    final token = state.accessToken;
    if (token == null || token.isEmpty) return;
    ref.read(chatRealtimeProvider).ensureConnected(
          userId: userId,
          deviceId: deviceId,
          accessToken: token,
        ).catchError((_) {
          ref.read(chatRealtimeProvider).scheduleReconnect(
                userId: userId,
                deviceId: deviceId,
                accessToken: token,
              );
        });
  }

  Future<void> setSession({
    required String accessToken,
    required String refreshToken,
    required String userId,
    required String deviceId,
  }) async {
    await _storage.write(key: _tokenKey, value: accessToken);
    await _storage.write(key: _refreshKey, value: refreshToken);
    await _storage.write(key: _userIdKey, value: userId);
    await _storage.write(key: _deviceIdKey, value: deviceId);

    state = AuthSession(
      accessToken: accessToken,
      refreshToken: refreshToken,
      userId: userId,
      deviceId: deviceId,
      isLoading: true,
    );

    final profile = await ref.read(authRepositoryProvider).fetchMe();
    state = state.copyWith(profile: profile, isLoading: false);
    final registeredDeviceId = state.deviceId;
    if (registeredDeviceId != null) {
      _postLoginSetup(userId, registeredDeviceId);
    } else {
      _connectRealtime(userId, deviceId);
    }
  }

  Future<void> refreshProfile() async {
    final profile = await ref.read(authRepositoryProvider).fetchMe();
    state = state.copyWith(profile: profile);
  }

  Future<void> logout() async {
    await _storage.deleteAll();
    state = const AuthSession(isLoading: false);
  }
}

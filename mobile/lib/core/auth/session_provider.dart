import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'auth_repository.dart';
import 'auth_session.dart';
import '../crypto/chat_crypto_service.dart';
import '../crypto/device_keys_service.dart';
import '../db/message_store.dart';
import '../realtime/chat_realtime_service.dart';

enum _RefreshOutcome { ok, authFailed, networkFailed }

final sessionProvider = NotifierProvider<SessionNotifier, AuthSession>(SessionNotifier.new);

class SessionNotifier extends Notifier<AuthSession> {
  static const _storage = FlutterSecureStorage();
  static const _tokenKey = 'access_token';
  static const _refreshKey = 'refresh_token';
  static const _userIdKey = 'user_id';
  static const _deviceIdKey = 'device_id';
  // Cached profile so the app can boot straight into the chats UI while offline
  // (without it, a null profile would wrongly route to onboarding).
  static const _profUsernameKey = 'profile_username';
  static const _profDisplayKey = 'profile_display_name';
  static const _profPhoneKey = 'profile_phone';
  static const _profOnboardedKey = 'profile_onboarded';

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

    // Seed from cache immediately so an offline boot lands on the chats UI.
    final cachedProfile = await _loadCachedProfile(userId);
    state = AuthSession(
      accessToken: token,
      refreshToken: refresh,
      userId: userId,
      deviceId: deviceId,
      profile: cachedProfile,
      isLoading: true,
    );

    var authFailed = false;
    try {
      final profile = await ref.read(authRepositoryProvider).fetchMe();
      await _cacheProfile(profile);
      state = state.copyWith(profile: profile, isLoading: false);
    } catch (e) {
      if (_isNetworkError(e)) {
        // Offline — stay logged in and render from the local cache.
        state = state.copyWith(isLoading: false);
      } else {
        // Online but the access token was rejected → try to refresh once.
        final outcome = await _attemptRefresh();
        if (outcome == _RefreshOutcome.ok) {
          try {
            final profile = await ref.read(authRepositoryProvider).fetchMe();
            await _cacheProfile(profile);
            state = state.copyWith(profile: profile, isLoading: false);
          } catch (e2) {
            if (_isNetworkError(e2)) {
              state = state.copyWith(isLoading: false);
            } else {
              authFailed = true;
            }
          }
        } else if (outcome == _RefreshOutcome.networkFailed) {
          state = state.copyWith(isLoading: false);
        } else {
          authFailed = true;
        }
      }
    }

    if (authFailed) {
      // Genuine auth failure only — clear credentials but KEEP the E2EE
      // identity key + deviceId so history stays decryptable on re-login.
      await _clearAuthOnly();
      state = const AuthSession(isLoading: false);
      return;
    }

    final uid = state.userId;
    final did = state.deviceId;
    if (uid != null && did != null) {
      _postLoginSetup(uid, did);
    }
  }

  /// A DioException with a real HTTP response means we reached the server, so
  /// it's an auth/server problem — not a connectivity one. Everything else
  /// (timeouts, no response, unknown) is treated as a network error so we never
  /// log the user out just because they're offline.
  bool _isNetworkError(Object e) {
    if (e is DioException) return e.response == null;
    return true;
  }

  /// Refresh access token using stored refresh token (bool API for the Dio
  /// interceptor). Returns true only when a fresh token was obtained.
  Future<bool> refreshAccessToken() async {
    return (await _attemptRefresh()) == _RefreshOutcome.ok;
  }

  /// Like [refreshAccessToken] but distinguishes an auth failure (refresh token
  /// dead → must log out) from a network failure (stay logged in, retry later).
  Future<_RefreshOutcome> _attemptRefresh() async {
    final refresh = state.refreshToken ?? await _storage.read(key: _refreshKey);
    if (refresh == null || refresh.isEmpty) return _RefreshOutcome.authFailed;
    final userId = state.userId ?? await _storage.read(key: _userIdKey);
    if (userId == null || userId.isEmpty) return _RefreshOutcome.authFailed;

    try {
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
      return _RefreshOutcome.ok;
    } catch (e) {
      return _isNetworkError(e) ? _RefreshOutcome.networkFailed : _RefreshOutcome.authFailed;
    }
  }

  Future<void> _cacheProfile(UserProfile p) async {
    await _storage.write(key: _profOnboardedKey, value: p.onboardingComplete ? '1' : '0');
    await _storage.write(key: _profUsernameKey, value: p.username ?? '');
    await _storage.write(key: _profDisplayKey, value: p.displayName ?? '');
    await _storage.write(key: _profPhoneKey, value: p.phone ?? '');
  }

  Future<UserProfile?> _loadCachedProfile(String? userId) async {
    if (userId == null) return null;
    final onboarded = await _storage.read(key: _profOnboardedKey);
    if (onboarded == null) return null;
    final username = await _storage.read(key: _profUsernameKey);
    final display = await _storage.read(key: _profDisplayKey);
    final phone = await _storage.read(key: _profPhoneKey);
    return UserProfile(
      id: userId,
      username: (username ?? '').isEmpty ? null : username,
      displayName: (display ?? '').isEmpty ? null : display,
      phone: (phone ?? '').isEmpty ? null : phone,
      onboardingComplete: onboarded == '1',
    );
  }

  Future<void> _clearAuthOnly() async {
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _refreshKey);
    await _storage.delete(key: _userIdKey);
    await _storage.delete(key: _profOnboardedKey);
    await _storage.delete(key: _profUsernameKey);
    await _storage.delete(key: _profDisplayKey);
    await _storage.delete(key: _profPhoneKey);
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
    await _cacheProfile(profile);
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
    await _cacheProfile(profile);
    state = state.copyWith(profile: profile);
  }

  /// Record acceptance of the latest legal documents, then refresh the profile
  /// so the gate advances past the consent screen.
  Future<void> acceptConsent() async {
    final p = state.profile;
    await ref.read(authRepositoryProvider).acceptConsent(
          tosVersion: p?.tosVersion ?? '',
          privacyVersion: p?.privacyVersion ?? '',
        );
    await refreshProfile();
  }

  Future<void> logout() async {
    // Keep the device's E2EE identity key + deviceId across logout so the
    // same device can still decrypt its message history on re-login (WhatsApp
    // behaviour). Only auth credentials are cleared. A new account on the same
    // device reuses the deviceId, upserting its key over the same row — so we
    // never accumulate orphaned dead keys.
    await _clearAuthOnly();
    // Clear cached chats/messages so the next account on this device can't see
    // the previous user's history. E2EE keys + deviceId are intentionally kept.
    try {
      await ref.read(messageStoreProvider).clearAll();
    } catch (_) {}
    state = const AuthSession(isLoading: false);
  }
}

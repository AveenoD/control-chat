import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final screenSecurityProvider =
    Provider<ScreenSecurityService>((ref) => ScreenSecurityService());

/// Controls Android's `FLAG_SECURE`, which blocks screenshots and screen
/// recording and blanks the app-switcher (recents) preview.
///
/// The native side enables it on launch (privacy-first), so the very first
/// recents snapshot is already protected; here we only relax/re-apply it based
/// on the user's saved preference.
class ScreenSecurityService {
  static const _channel = MethodChannel('auratalk/screen_security');
  static const _storage = FlutterSecureStorage();
  static const _key = 'screen_security_enabled_v1';

  /// Reads the saved preference. Defaults to enabled (privacy-first).
  Future<bool> isEnabled() async {
    final v = await _storage.read(key: _key);
    return v == null ? true : v == 'true';
  }

  /// Applies the saved preference to the active window. Call on app start.
  Future<void> applySaved() async {
    await _setNative(await isEnabled());
  }

  /// Persists and applies a new preference.
  Future<void> setEnabled(bool enabled) async {
    await _storage.write(key: _key, value: enabled.toString());
    await _setNative(enabled);
  }

  /// Force `FLAG_SECURE` on regardless of the saved preference. Used while a
  /// view-once message is revealed so it can never be screenshotted/recorded,
  /// even if the user has globally disabled screen security.
  Future<void> pushSecure() => _setNative(true);

  /// Restore the user's saved screen-security preference (call after a forced
  /// secure window closes).
  Future<void> restoreSaved() => applySaved();

  Future<void> _setNative(bool enabled) async {
    try {
      await _channel.invokeMethod<void>('setSecure', {'enabled': enabled});
    } on PlatformException {
      // No native handler (e.g. non-Android platforms) — ignore.
    } on MissingPluginException {
      // Channel not wired on this platform — ignore.
    }
  }
}

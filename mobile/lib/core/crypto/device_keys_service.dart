import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../api/dio_provider.dart';
import 'chat_crypto_service.dart';

typedef DeviceKeyEntry = ({String deviceId, String publicKey});

final deviceKeysServiceProvider = Provider<DeviceKeysService>((ref) {
  return DeviceKeysService(ref.watch(dioProvider));
});

class DeviceKeysService {
  DeviceKeysService(this._dio);

  final Dio _dio;
  final Map<String, DeviceKeyEntry> _cache = {};

  String _userKey(String userId, [String? deviceId]) =>
      deviceId == null ? userId : '$userId::$deviceId';

  Future<void> ensureRegistered(String deviceId, {String? userId}) async {
    final publicKey = await ChatCryptoService.publicKeyBase64();
    await _dio.post('/devices/keys', data: {
      'deviceId': deviceId,
      'identityKeyPublic': publicKey,
      'registrationId': deviceId.hashCode.abs() % 900000 + 1000,
      'preKeyBundle': {'v': 1, 'signedPreKey': publicKey},
    });
    if (userId != null) {
      registerSelf(userId, deviceId, publicKey);
    }
  }

  void registerSelf(String userId, String deviceId, String publicKey) {
    final entry = (deviceId: deviceId, publicKey: publicKey);
    _cache[userId] = entry;
    _cache[_userKey(userId, deviceId)] = entry;
  }

  void invalidate(String userId) {
    _cache.removeWhere((k, _) => k == userId || k.startsWith('$userId::'));
  }

  /// Pre-fetch all peer device keys when opening a chat (avoids send/receive delay).
  Future<void> warmPeer(String userId) async {
    await fetchAllDevices(userId, forceRefresh: true);
  }

  Future<DeviceKeyEntry?> fetchPrimaryDevice(String userId, {bool forceRefresh = false}) {
    return fetchDeviceForUser(userId, forceRefresh: forceRefresh);
  }

  Future<DeviceKeyEntry?> fetchDeviceForUser(
    String userId, {
    String? deviceId,
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh) {
      if (deviceId != null) {
        final exact = _cache[_userKey(userId, deviceId)];
        if (exact != null) return exact;
      } else {
        final primary = _cache[userId];
        if (primary != null) return primary;
      }
    }

    final devices = await fetchAllDevices(userId, forceRefresh: true);
    if (devices.isEmpty) return null;
    if (deviceId != null) {
      for (final d in devices) {
        if (d.deviceId == deviceId) return d;
      }
    }
    return devices.first;
  }

  Future<List<DeviceKeyEntry>> fetchAllDevices(String userId, {bool forceRefresh = false}) async {
    if (!forceRefresh) {
      final cached = _cache.entries
          .where((e) => e.key.startsWith('$userId::'))
          .map((e) => e.value)
          .toList();
      if (cached.isNotEmpty) return cached;
      final primary = _cache[userId];
      if (primary != null) return [primary];
    }

    final res = await _dio.get<Map<String, dynamic>>('/users/$userId/devices/keys');
    final rows = res.data!['devices'] as List<dynamic>;
    final out = <DeviceKeyEntry>[];
    for (final raw in rows) {
      final row = raw as Map<String, dynamic>;
      final entry = (
        deviceId: row['device_id'] as String,
        publicKey: row['identity_key_public'] as String,
      );
      _cache[_userKey(userId, entry.deviceId)] = entry;
      out.add(entry);
    }
    if (out.isNotEmpty) _cache[userId] = out.first;
    return out;
  }
}

import 'dart:io' show Platform;

class ApiConfig {
  /// Gateway base URL. Android emulator uses 10.0.2.2 for host machine.
  static String get baseUrl {
    try {
      if (Platform.isAndroid) return 'http://10.0.2.2:8082';
    } catch (_) {}
    return 'http://localhost:8082';
  }

  static const devOtp = '123456';

  /// Centrifugo WebSocket for instant message delivery.
  static String get centrifugoWsUrl {
    try {
      if (Platform.isAndroid) return 'ws://10.0.2.2:8000/connection/websocket';
    } catch (_) {}
    return 'ws://127.0.0.1:8000/connection/websocket';
  }

  /// LiveKit WebSocket (dev server).
  static String get livekitWsUrl {
    try {
      if (Platform.isAndroid) return 'ws://10.0.2.2:7880';
    } catch (_) {}
    return 'ws://127.0.0.1:7880';
  }
}

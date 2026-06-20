import 'dart:async';
import 'dart:convert';

import 'package:centrifuge/centrifuge.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/api_config.dart';

final chatRealtimeProvider = Provider<ChatRealtimeService>((ref) {
  final service = ChatRealtimeService();
  ref.onDispose(service.dispose);
  return service;
});

/// Centrifugo push — instant message delivery without polling.
class ChatRealtimeService {
  ChatRealtimeService() : _tokenDio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: const Duration(seconds: 8),
      receiveTimeout: const Duration(seconds: 8),
    ),
  );

  static const _reconnectDelaysSec = [1, 2, 5, 10, 30];

  final Dio _tokenDio;
  Client? _client;
  Subscription? _subscription;
  StreamSubscription<SubscriptionErrorEvent>? _errorSub;
  StreamSubscription<PublicationEvent>? _publicationSub;
  StreamSubscription<ServerPublicationEvent>? _serverPublicationSub;
  StreamSubscription<DisconnectedEvent>? _disconnectSub;
  final _events = StreamController<Map<String, dynamic>>.broadcast();
  bool _connected = false;
  String? _channel;
  String? _userId;
  String? _deviceId;
  String? _accessToken;
  Timer? _reconnectTimer;
  Future<void>? _connectFuture;
  int _reconnectAttempt = 0;

  Stream<Map<String, dynamic>> get events => _events.stream;
  bool get isConnected => _connected;

  Future<void> ensureConnected({
    required String userId,
    required String deviceId,
    required String accessToken,
  }) async {
    _userId = userId;
    _deviceId = deviceId;
    _accessToken = accessToken;

    final channel = 'user:$userId:$deviceId';
    if (_connected &&
        _channel == channel &&
        _subscription?.state == SubscriptionState.subscribed &&
        _client?.state == State.connected) {
      return;
    }

    if (_connectFuture != null) {
      await _connectFuture;
      if (_connected && _channel == channel) return;
    }

    _connectFuture = _connect(channel: channel, accessToken: accessToken);
    try {
      await _connectFuture;
      _reconnectAttempt = 0;
    } finally {
      _connectFuture = null;
    }
  }

  Future<void> _connect({
    required String channel,
    required String accessToken,
  }) async {
    _connected = false;
    await _publicationSub?.cancel();
    await _serverPublicationSub?.cancel();
    await _errorSub?.cancel();
    await _disconnectSub?.cancel();
    if (_subscription != null) {
      _client?.removeSubscription(_subscription!);
      await _subscription!.unsubscribe();
      _subscription = null;
    }
    await _client?.disconnect();

    final res = await _tokenDio.get<Map<String, dynamic>>(
      '/realtime/token',
      options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
    );
    final token = res.data!['token'] as String;
    final serverChannel = res.data!['channel'] as String;

    _client = createClient(
      ApiConfig.centrifugoWsUrl,
      ClientConfig(token: token),
    );
    _disconnectSub = _client!.disconnected.listen((_) {
      _connected = false;
      _scheduleReconnectIfNeeded();
    });
    _serverPublicationSub = _client!.publication.listen(_onServerPublication);

    await _client!.connect().timeout(const Duration(seconds: 8));

    _subscription = _client!.newSubscription(serverChannel);
    _errorSub = _subscription!.error.listen((event) {
      final msg = event.error.toString().toLowerCase();
      if (msg.contains('already subscribed') || msg.contains('105')) return;
      _connected = false;
    });
    _publicationSub = _subscription!.publication.listen(_onPublication);

    try {
      await _subscription!.subscribe();
      await _subscription!.ready().timeout(const Duration(seconds: 5));
    } catch (_) {
      if (_subscription?.state != SubscriptionState.subscribed) rethrow;
    }

    _channel = channel;
    _connected = true;
    _reconnectTimer?.cancel();
  }

  void scheduleReconnect({
    required String userId,
    required String deviceId,
    required String accessToken,
  }) {
    _userId = userId;
    _deviceId = deviceId;
    _accessToken = accessToken;
    _scheduleReconnectIfNeeded();
  }

  void _scheduleReconnectIfNeeded() {
    if (_connected) return;
    if (_userId == null || _deviceId == null || _accessToken == null) return;
    _reconnectTimer?.cancel();
    final delaySec = _reconnectDelaysSec[_reconnectAttempt.clamp(0, _reconnectDelaysSec.length - 1)];
    _reconnectAttempt++;
    _reconnectTimer = Timer(Duration(seconds: delaySec), () {
      if (_connected) return;
      ensureConnected(
        userId: _userId!,
        deviceId: _deviceId!,
        accessToken: _accessToken!,
      ).catchError((_) => _scheduleReconnectIfNeeded());
    });
  }

  void _onServerPublication(ServerPublicationEvent event) {
    _decodeAndEmit(event.data);
  }

  void _onPublication(PublicationEvent event) {
    _decodeAndEmit(event.data);
  }

  void _decodeAndEmit(dynamic raw) {
    try {
      final Map<String, dynamic> map;
      if (raw is String) {
        map = jsonDecode(raw) as Map<String, dynamic>;
      } else if (raw is List<int>) {
        map = jsonDecode(utf8.decode(raw)) as Map<String, dynamic>;
      } else if (raw is Map) {
        map = Map<String, dynamic>.from(raw);
      } else {
        return;
      }
      _events.add(map);
    } catch (_) {}
  }

  Future<void> dispose() async {
    _connected = false;
    _reconnectTimer?.cancel();
    await _publicationSub?.cancel();
    await _serverPublicationSub?.cancel();
    await _errorSub?.cancel();
    await _disconnectSub?.cancel();
    if (_subscription != null) {
      _client?.removeSubscription(_subscription!);
      await _subscription!.unsubscribe();
    }
    await _client?.disconnect();
    if (!_events.isClosed) {
      await _events.close();
    }
  }
}

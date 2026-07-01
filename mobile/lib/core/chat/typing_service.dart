import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../auth/session_provider.dart';
import '../realtime/chat_realtime_service.dart';

/// Per-conversation peer typing flags for the chat list (and thread header).
final peerTypingProvider =
    NotifierProvider<PeerTypingNotifier, Map<String, bool>>(PeerTypingNotifier.new);

class PeerTypingNotifier extends Notifier<Map<String, bool>> {
  final Map<String, Timer> _clearTimers = {};

  @override
  Map<String, bool> build() => {};

  void setTyping(String conversationId, bool isTyping) {
    _clearTimers[conversationId]?.cancel();
    if (!isTyping) {
      if (state[conversationId] != true) return;
      final next = Map<String, bool>.from(state);
      next.remove(conversationId);
      state = next;
      return;
    }
    state = {...state, conversationId: true};
    _clearTimers[conversationId] = Timer(const Duration(seconds: 4), () {
      setTyping(conversationId, false);
    });
  }

  void clear(String conversationId) => setTyping(conversationId, false);
}

final typingServiceProvider = Provider<TypingService>((ref) => TypingService(ref));

/// Listens to realtime typing events app-wide so the chat list can show
/// "typing…" even when that conversation is not open.
class TypingService {
  TypingService(this._ref);

  final Ref _ref;
  StreamSubscription<Map<String, dynamic>>? _sub;

  void start() {
    if (_sub != null) return;
    _sub = _ref.read(chatRealtimeProvider).events.listen(_onEvent);
  }

  void stop() {
    _sub?.cancel();
    _sub = null;
  }

  void _onEvent(Map<String, dynamic> data) {
    if (data['type'] != 'typing') return;
    final convId = data['conversationId'] as String?;
    final uid = data['userId'] as String?;
    final myId = _ref.read(sessionProvider).userId;
    if (convId == null || uid == null || uid == myId) return;
    _ref
        .read(peerTypingProvider.notifier)
        .setTyping(convId, data['isTyping'] as bool? ?? false);
  }
}

import 'dart:convert';

/// Control marker prefixed to the *plaintext* before encryption. Because it
/// lives inside the E2EE payload, feature metadata (view-once, disappearing
/// TTL, timer-change control) stays end-to-end encrypted and needs zero backend
/// schema changes. A leading SOH control char makes accidental collisions with
/// real user text effectively impossible.
const _kMarker = '\u0001ATW1\u0001';

/// A decoded chat payload. Plain (non-marker) bodies decode to a normal
/// [WireMessage] with just [text], so old messages keep working.
class WireMessage {
  const WireMessage({
    required this.text,
    this.viewOnce = false,
    this.ttlSeconds = 0,
    this.isTimerControl = false,
    this.timerSeconds = 0,
  });

  final String text;

  /// One-time view: consumed (body wiped locally) after the recipient opens it.
  final bool viewOnce;

  /// Auto-delete after this many seconds from send time (0 = never).
  final int ttlSeconds;

  /// This payload is a "disappearing timer changed" control, not a real message.
  final bool isTimerControl;
  final int timerSeconds;
}

/// Encodes/decodes the on-the-wire plaintext for chat features.
class ChatWire {
  /// Wraps [text] only when a feature flag is set; otherwise returns it
  /// unchanged (backward-compatible + smaller for ordinary messages).
  static String encodeText(String text, {bool viewOnce = false, int ttlSeconds = 0}) {
    if (!viewOnce && ttlSeconds <= 0) return text;
    final m = <String, dynamic>{'b': text};
    if (viewOnce) m['vo'] = true;
    if (ttlSeconds > 0) m['ttl'] = ttlSeconds;
    return '$_kMarker${jsonEncode(m)}';
  }

  /// A control payload that tells the peer the disappearing-message timer
  /// changed. Recipients apply it and never render a bubble.
  static String encodeTimerControl(int seconds) =>
      '$_kMarker${jsonEncode(<String, dynamic>{'ctl': 'timer', 'ttl': seconds})}';

  static WireMessage decode(String body) {
    if (!body.startsWith(_kMarker)) return WireMessage(text: body);
    try {
      final j = jsonDecode(body.substring(_kMarker.length)) as Map<String, dynamic>;
      if (j['ctl'] == 'timer') {
        return WireMessage(
          text: '',
          isTimerControl: true,
          timerSeconds: (j['ttl'] as num?)?.toInt() ?? 0,
        );
      }
      return WireMessage(
        text: j['b'] as String? ?? '',
        viewOnce: j['vo'] == true,
        ttlSeconds: (j['ttl'] as num?)?.toInt() ?? 0,
      );
    } catch (_) {
      // Corrupt/unknown payload — show the raw text rather than losing it.
      return WireMessage(text: body);
    }
  }
}

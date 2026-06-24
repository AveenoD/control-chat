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
    this.mediaType,
    this.mediaBlobId,
    this.mediaKey,
    this.mediaMime,
    this.mediaWidth,
    this.mediaHeight,
    this.mediaSize,
  });

  /// For media messages [text] is the (optional) caption.
  final String text;

  /// One-time view: consumed (body wiped locally) after the recipient opens it.
  final bool viewOnce;

  /// Auto-delete after this many seconds from send time (0 = never).
  final int ttlSeconds;

  /// This payload is a "disappearing timer changed" control, not a real message.
  final bool isTimerControl;
  final int timerSeconds;

  /// Attachment kind, e.g. 'image'. Null for plain text/control messages.
  final String? mediaType;

  /// Object-storage id of the encrypted blob.
  final String? mediaBlobId;

  /// Base64 AES key that decrypts the blob (travels E2EE inside this payload).
  final String? mediaKey;

  final String? mediaMime;
  final int? mediaWidth;
  final int? mediaHeight;
  final int? mediaSize;

  bool get isMedia => mediaType != null && mediaBlobId != null && mediaKey != null;
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

  /// Encodes a media (e.g. image) message. The blob key travels here and is
  /// therefore end-to-end encrypted along with the rest of the body.
  static String encodeMedia({
    required String mediaType,
    required String blobId,
    required String blobKey,
    required String mime,
    int? width,
    int? height,
    int? size,
    String caption = '',
    bool viewOnce = false,
    int ttlSeconds = 0,
  }) {
    final m = <String, dynamic>{
      'mt': mediaType,
      'bid': blobId,
      'bk': blobKey,
      'mime': mime,
    };
    if (width != null) m['w'] = width;
    if (height != null) m['h'] = height;
    if (size != null) m['sz'] = size;
    if (caption.isNotEmpty) m['b'] = caption;
    if (viewOnce) m['vo'] = true;
    if (ttlSeconds > 0) m['ttl'] = ttlSeconds;
    return '$_kMarker${jsonEncode(m)}';
  }

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
        mediaType: j['mt'] as String?,
        mediaBlobId: j['bid'] as String?,
        mediaKey: j['bk'] as String?,
        mediaMime: j['mime'] as String?,
        mediaWidth: (j['w'] as num?)?.toInt(),
        mediaHeight: (j['h'] as num?)?.toInt(),
        mediaSize: (j['sz'] as num?)?.toInt(),
      );
    } catch (_) {
      // Corrupt/unknown payload — show the raw text rather than losing it.
      return WireMessage(text: body);
    }
  }
}

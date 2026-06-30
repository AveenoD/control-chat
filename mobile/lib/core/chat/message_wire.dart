import 'dart:convert';

/// Control marker prefixed to the *plaintext* before encryption. Because it
/// lives inside the E2EE payload, feature metadata (view-once, disappearing
/// TTL, timer-change control) stays end-to-end encrypted and needs zero backend
/// schema changes. A leading SOH control char makes accidental collisions with
/// real user text effectively impossible.
const _kMarker = '\u0001ATW1\u0001';

/// A lightweight reference to the message being replied to. The preview/sender
/// travel with the reply so the recipient can render the quote even without the
/// original message stored locally.
class WireReply {
  const WireReply({required this.id, this.sender, this.preview, this.mediaType});

  final String id;
  final String? sender;
  final String? preview;
  final String? mediaType;
}

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
    this.mediaFilename,
    this.mediaDurationMs,
    this.mediaWaveform,
    this.replyToId,
    this.replySender,
    this.replyPreview,
    this.replyMediaType,
    this.isReaction = false,
    this.reactionTargetId,
    this.reactionEmoji,
    this.reactionAdd = true,
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

  /// Original filename (for 'file' attachments).
  final String? mediaFilename;

  /// Duration in milliseconds (for 'voice' attachments).
  final int? mediaDurationMs;

  /// Normalised waveform bars 0–100 (for 'voice' attachments).
  final List<int>? mediaWaveform;

  /// Reply/quote metadata (the message this one replies to).
  final String? replyToId;
  final String? replySender;
  final String? replyPreview;
  final String? replyMediaType;

  /// Reaction control: applies an emoji reaction to [reactionTargetId] rather
  /// than rendering as a bubble.
  final bool isReaction;
  final String? reactionTargetId;
  final String? reactionEmoji;
  final bool reactionAdd;

  bool get isMedia => mediaType != null && mediaBlobId != null && mediaKey != null;
}

/// Encodes/decodes the on-the-wire plaintext for chat features.
class ChatWire {
  /// Wraps [text] only when a feature flag is set; otherwise returns it
  /// unchanged (backward-compatible + smaller for ordinary messages).
  static String encodeText(String text,
      {bool viewOnce = false, int ttlSeconds = 0, WireReply? reply}) {
    if (!viewOnce && ttlSeconds <= 0 && reply == null) return text;
    final m = <String, dynamic>{'b': text};
    if (viewOnce) m['vo'] = true;
    if (ttlSeconds > 0) m['ttl'] = ttlSeconds;
    _putReply(m, reply);
    return '$_kMarker${jsonEncode(m)}';
  }

  /// Writes reply/quote keys into a payload map (no-op when [reply] is null).
  static void _putReply(Map<String, dynamic> m, WireReply? reply) {
    if (reply == null) return;
    m['rid'] = reply.id;
    if (reply.sender != null) m['rsn'] = reply.sender;
    if (reply.preview != null) m['rpv'] = reply.preview;
    if (reply.mediaType != null) m['rmt'] = reply.mediaType;
  }

  /// A reaction control payload: add/remove an emoji on a target message.
  static String encodeReaction({
    required String targetId,
    required String emoji,
    required bool add,
  }) =>
      '$_kMarker${jsonEncode(<String, dynamic>{
        'ctl': 'react',
        'tid': targetId,
        'emoji': emoji,
        'op': add ? 'add' : 'remove',
      })}';

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
    WireReply? reply,
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
    _putReply(m, reply);
    return '$_kMarker${jsonEncode(m)}';
  }

  /// Encodes a generic file (document/any) message.
  static String encodeFile({
    required String blobId,
    required String blobKey,
    required String filename,
    required String mime,
    int? size,
    String caption = '',
    bool viewOnce = false,
    int ttlSeconds = 0,
    WireReply? reply,
  }) {
    final m = <String, dynamic>{
      'mt': 'file',
      'bid': blobId,
      'bk': blobKey,
      'fn': filename,
      'mime': mime,
    };
    if (size != null) m['sz'] = size;
    if (caption.isNotEmpty) m['b'] = caption;
    if (viewOnce) m['vo'] = true;
    if (ttlSeconds > 0) m['ttl'] = ttlSeconds;
    _putReply(m, reply);
    return '$_kMarker${jsonEncode(m)}';
  }

  /// Encodes a voice note. Carries duration + a compact waveform so the
  /// recipient can render the same bars without decoding the audio first.
  static String encodeVoice({
    required String blobId,
    required String blobKey,
    required String mime,
    required int durationMs,
    List<int> waveform = const [],
    int? size,
    bool viewOnce = false,
    int ttlSeconds = 0,
    WireReply? reply,
  }) {
    final m = <String, dynamic>{
      'mt': 'voice',
      'bid': blobId,
      'bk': blobKey,
      'mime': mime,
      'dur': durationMs,
    };
    if (waveform.isNotEmpty) m['wf'] = waveform;
    if (size != null) m['sz'] = size;
    if (viewOnce) m['vo'] = true;
    if (ttlSeconds > 0) m['ttl'] = ttlSeconds;
    _putReply(m, reply);
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
      if (j['ctl'] == 'react') {
        return WireMessage(
          text: '',
          isReaction: true,
          reactionTargetId: j['tid'] as String?,
          reactionEmoji: j['emoji'] as String?,
          reactionAdd: (j['op'] as String?) != 'remove',
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
        mediaFilename: j['fn'] as String?,
        mediaDurationMs: (j['dur'] as num?)?.toInt(),
        mediaWaveform: (j['wf'] as List?)?.map((e) => (e as num).toInt()).toList(),
        replyToId: j['rid'] as String?,
        replySender: j['rsn'] as String?,
        replyPreview: j['rpv'] as String?,
        replyMediaType: j['rmt'] as String?,
      );
    } catch (_) {
      // Corrupt/unknown payload — show the raw text rather than losing it.
      return WireMessage(text: body);
    }
  }
}

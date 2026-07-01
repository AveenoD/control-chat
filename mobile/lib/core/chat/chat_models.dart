/// Marker sender id for group lifecycle system lines ("X added Y"). Such rows
/// are rendered as a centered grey notice rather than a chat bubble.
const String kSystemSenderId = '__system__';

class ChatPeer {
  const ChatPeer({
    required this.userId,
    this.username,
    this.displayName,
    this.avatarUrl,
    this.publicKey,
    this.deviceId,
  });

  final String userId;
  final String? username;
  final String? displayName;
  final String? avatarUrl;
  final String? publicKey;
  final String? deviceId;

  String get label => displayName ?? (username != null ? '@$username' : 'User');

  factory ChatPeer.fromJson(Map<String, dynamic> json) {
    final userId = json['peer_user_id'] as String? ?? json['id'] as String? ?? json['group_id'] as String? ?? '';
    return ChatPeer(
      userId: userId,
      username: json['peer_username'] as String? ?? json['username'] as String?,
      displayName: json['peer_display_name'] as String? ?? json['display_name'] as String? ?? json['title'] as String?,
    );
  }
}

class ConversationSummary {
  const ConversationSummary({
    required this.conversationId,
    required this.peer,
    required this.lastAt,
    this.lastPreview = '',
    this.isGroup = false,
    this.groupId,
    this.leftGroup = false,
    this.avatarBlobId,
    this.avatarKey,
    this.unreadCount = 0,
  });

  final String conversationId;
  final ChatPeer peer;
  final DateTime lastAt;
  final String lastPreview;
  final bool isGroup;
  final String? groupId;
  final bool leftGroup;

  /// Group avatar (encrypted blob id + AES key); null for DMs / no photo.
  final String? avatarBlobId;
  final String? avatarKey;

  /// Badge count for unread messages in this thread.
  final int unreadCount;

  bool get hasAvatar => (avatarBlobId?.isNotEmpty ?? false) && (avatarKey?.isNotEmpty ?? false);

  bool get hasUnread => unreadCount > 0;
}

class ChatMessage {
  const ChatMessage({
    required this.id,
    required this.conversationId,
    required this.senderUserId,
    required this.text,
    required this.createdAt,
    required this.isMine,
    this.deliveredToPeer = false,
    this.readByPeer = false,
    this.senderLabel,
    this.clientMessageId,
    this.sendFailed = false,
    this.viewOnce = false,
    this.viewed = false,
    this.expiresAt,
    this.mediaType,
    this.mediaBlobId,
    this.mediaKey,
    this.mediaMime,
    this.mediaWidth,
    this.mediaHeight,
    this.mediaLocalPath,
    this.mediaFilename,
    this.mediaSize,
    this.mediaDurationMs,
    this.mediaWaveform,
    this.replyToId,
    this.replySender,
    this.replyPreview,
    this.replyMediaType,
  });

  final String id;
  final String conversationId;
  final String senderUserId;
  final String text;
  final DateTime createdAt;
  final bool isMine;
  /// Recipient device received the message (double grey tick).
  final bool deliveredToPeer;
  /// Recipient opened the chat and saw the message (double blue tick).
  final bool readByPeer;
  final String? senderLabel;
  /// Links an optimistic message to its outbox entry + server echo for dedup.
  final String? clientMessageId;
  /// Send failed and the message is queued in the outbox for retry.
  final bool sendFailed;
  /// One-time view — the body is wiped locally once the recipient opens it.
  final bool viewOnce;
  /// A view-once message that has already been opened (body consumed).
  final bool viewed;
  /// Disappearing-message expiry; the message is auto-deleted after this.
  final DateTime? expiresAt;

  /// Attachment kind, e.g. 'image'. Null for plain text.
  final String? mediaType;

  /// Object-storage id of the encrypted blob.
  final String? mediaBlobId;

  /// Base64 AES key for the blob (stored only in the encrypted-at-rest DB).
  final String? mediaKey;

  final String? mediaMime;
  final int? mediaWidth;
  final int? mediaHeight;

  /// Decrypted local file path once downloaded/cached for display.
  final String? mediaLocalPath;

  /// Original filename for 'file' attachments.
  final String? mediaFilename;

  /// Attachment size in bytes (for display).
  final int? mediaSize;

  /// Voice-note duration in milliseconds.
  final int? mediaDurationMs;

  /// Voice-note waveform bars (0–100).
  final List<int>? mediaWaveform;

  /// Quote/reply: the message this one replies to (id + cached preview).
  final String? replyToId;
  final String? replySender;
  final String? replyPreview;
  final String? replyMediaType;

  bool get isMedia => mediaType != null && mediaBlobId != null;
  bool get isImage => mediaType == 'image';
  bool get isFile => mediaType == 'file';
  bool get isVoice => mediaType == 'voice';
  bool get isReply => replyToId != null;

  bool get confirmedOnServer => !id.startsWith('local-');

  ChatMessage copyWith({
    String? id,
    String? conversationId,
    String? senderUserId,
    String? text,
    DateTime? createdAt,
    bool? isMine,
    bool? deliveredToPeer,
    bool? readByPeer,
    String? senderLabel,
    String? clientMessageId,
    bool? sendFailed,
    bool? viewOnce,
    bool? viewed,
    DateTime? expiresAt,
    String? mediaType,
    String? mediaBlobId,
    String? mediaKey,
    String? mediaMime,
    int? mediaWidth,
    int? mediaHeight,
    String? mediaLocalPath,
    String? mediaFilename,
    int? mediaSize,
    int? mediaDurationMs,
    List<int>? mediaWaveform,
    String? replyToId,
    String? replySender,
    String? replyPreview,
    String? replyMediaType,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      conversationId: conversationId ?? this.conversationId,
      senderUserId: senderUserId ?? this.senderUserId,
      text: text ?? this.text,
      createdAt: createdAt ?? this.createdAt,
      isMine: isMine ?? this.isMine,
      deliveredToPeer: deliveredToPeer ?? this.deliveredToPeer,
      readByPeer: readByPeer ?? this.readByPeer,
      senderLabel: senderLabel ?? this.senderLabel,
      clientMessageId: clientMessageId ?? this.clientMessageId,
      sendFailed: sendFailed ?? this.sendFailed,
      viewOnce: viewOnce ?? this.viewOnce,
      viewed: viewed ?? this.viewed,
      expiresAt: expiresAt ?? this.expiresAt,
      mediaType: mediaType ?? this.mediaType,
      mediaBlobId: mediaBlobId ?? this.mediaBlobId,
      mediaKey: mediaKey ?? this.mediaKey,
      mediaMime: mediaMime ?? this.mediaMime,
      mediaWidth: mediaWidth ?? this.mediaWidth,
      mediaHeight: mediaHeight ?? this.mediaHeight,
      mediaLocalPath: mediaLocalPath ?? this.mediaLocalPath,
      mediaFilename: mediaFilename ?? this.mediaFilename,
      mediaSize: mediaSize ?? this.mediaSize,
      mediaDurationMs: mediaDurationMs ?? this.mediaDurationMs,
      mediaWaveform: mediaWaveform ?? this.mediaWaveform,
      replyToId: replyToId ?? this.replyToId,
      replySender: replySender ?? this.replySender,
      replyPreview: replyPreview ?? this.replyPreview,
      replyMediaType: replyMediaType ?? this.replyMediaType,
    );
  }
}

/// A single user's reaction to a message (one emoji per user).
class ReactionView {
  const ReactionView({
    required this.targetId,
    required this.reactorUserId,
    required this.emoji,
    required this.isMine,
  });

  final String targetId;
  final String reactorUserId;
  final String emoji;
  final bool isMine;
}


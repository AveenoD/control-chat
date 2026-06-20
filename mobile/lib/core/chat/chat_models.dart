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
  });

  final String conversationId;
  final ChatPeer peer;
  final DateTime lastAt;
  final String lastPreview;
  final bool isGroup;
  final String? groupId;
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
    );
  }
}

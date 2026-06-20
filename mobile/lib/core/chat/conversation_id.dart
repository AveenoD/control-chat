/// Deterministic 1:1 conversation id: dm:{lowerUuid}:{higherUuid}
String directConversationId(String userA, String userB) {
  final ids = [userA, userB]..sort();
  return 'dm:${ids[0]}:${ids[1]}';
}

String groupConversationId(String groupId) => 'group:$groupId';

bool isGroupConversation(String conversationId) => conversationId.startsWith('group:');

String? groupIdFromConversation(String conversationId) {
  if (!isGroupConversation(conversationId)) return null;
  final id = conversationId.substring('group:'.length);
  return id.isEmpty ? null : id;
}

String? peerUserIdFromConversation(String conversationId, String currentUserId) {
  final parts = conversationId.split(':');
  if (parts.length != 3 || parts[0] != 'dm') return null;
  final a = parts[1];
  final b = parts[2];
  if (a == currentUserId) return b;
  if (b == currentUserId) return a;
  return null;
}

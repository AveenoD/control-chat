import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Conversation id of the chat thread currently on screen, if any. Used to
/// suppress unread-badge increments for messages arriving in the open chat.
final activeConversationIdProvider =
    NotifierProvider<ActiveConversationNotifier, String?>(ActiveConversationNotifier.new);

class ActiveConversationNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void setActive(String? conversationId) {
    state = conversationId;
  }
}

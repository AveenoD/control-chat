import 'chat_models.dart';

/// True when a preview string carries no useful decrypted content (server
/// placeholder or empty).
bool isGenericListPreview(String preview) {
  final s = preview.trim();
  return s.isEmpty || s == '💬 Message' || s == 'Start chatting';
}

/// One-line preview for the chat list (WhatsApp-style labels for media).
String messageListPreview(ChatMessage m, {bool isGroup = false}) {
  if (m.senderUserId == kSystemSenderId) return m.text;

  String body;
  if (m.isImage) {
    body = '📷 Photo';
  } else if (m.isVoice) {
    body = '🎤 Voice note';
  } else if (m.isFile) {
    body = '📄 ${m.mediaFilename ?? 'File'}';
  } else if (m.viewOnce) {
    body = 'View once';
  } else if (m.text.startsWith('🔒')) {
    body = '💬 Message';
  } else {
    body = m.text;
  }

  if (isGroup && !m.isMine) {
    final who = m.senderLabel;
    if (who != null && who.isNotEmpty) return '$who: $body';
  }
  return body;
}

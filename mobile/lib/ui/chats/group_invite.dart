/// Shared helpers for group invite links.
///
/// A link looks like `https://auratalk.app/join/<token>`. The app has no deep
/// link handler yet, so joining is done by pasting the link (or the bare token)
/// into the "Join via link" dialog; [parseInviteToken] extracts the token from
/// either form.
const String kGroupInviteLinkBase = 'https://auratalk.app/join/';

String groupInviteLink(String token) => '$kGroupInviteLinkBase$token';

/// Pulls the invite token out of a full link or returns the trimmed input if it
/// already looks like a bare token. Returns null when nothing usable is found.
String? parseInviteToken(String raw) {
  var s = raw.trim();
  if (s.isEmpty) return null;
  // Take the last path segment of a URL-ish string.
  final slash = s.lastIndexOf('/');
  if (slash >= 0 && slash < s.length - 1) {
    s = s.substring(slash + 1);
  }
  // Strip any query/fragment.
  s = s.split('?').first.split('#').first.trim();
  if (s.isEmpty) return null;
  // Tokens are URL-safe base64 (letters, digits, - and _).
  final ok = RegExp(r'^[A-Za-z0-9_-]{8,128}$').hasMatch(s);
  return ok ? s : null;
}

class UserProfile {
  const UserProfile({
    required this.id,
    this.phone,
    this.username,
    this.displayName,
    this.onboardingComplete = false,
    this.consentRequired = false,
    this.tosVersion,
    this.privacyVersion,
  });

  final String id;
  final String? phone;
  final String? username;
  final String? displayName;
  final bool onboardingComplete;

  /// Whether the user still needs to accept the latest legal documents.
  final bool consentRequired;

  /// Current document versions to record on acceptance (from the server).
  final String? tosVersion;
  final String? privacyVersion;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      phone: json['phone'] as String?,
      username: json['username'] as String?,
      displayName: json['display_name'] as String?,
      onboardingComplete: json['onboardingComplete'] as bool? ?? json['username'] != null,
      consentRequired: json['consentRequired'] as bool? ?? false,
      tosVersion: json['tosVersion'] as String?,
      privacyVersion: json['privacyVersion'] as String?,
    );
  }
}

class AuthSession {
  const AuthSession({
    this.accessToken,
    this.refreshToken,
    this.userId,
    this.deviceId,
    this.profile,
    this.isLoading = false,
  });

  final String? accessToken;
  final String? refreshToken;
  final String? userId;
  final String? deviceId;
  final UserProfile? profile;
  final bool isLoading;

  bool get isAuthenticated => accessToken != null && accessToken!.isNotEmpty;

  bool get needsOnboarding =>
      isAuthenticated && (profile == null || !profile!.onboardingComplete);

  /// After onboarding, block on accepting the latest legal documents. Only
  /// gates when the server says so (offline boot defaults to false → no block).
  bool get needsConsent =>
      isAuthenticated && !needsOnboarding && (profile?.consentRequired ?? false);

  AuthSession copyWith({
    String? accessToken,
    String? refreshToken,
    String? userId,
    String? deviceId,
    UserProfile? profile,
    bool? isLoading,
  }) {
    return AuthSession(
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      userId: userId ?? this.userId,
      deviceId: deviceId ?? this.deviceId,
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

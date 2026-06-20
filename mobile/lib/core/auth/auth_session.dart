class UserProfile {
  const UserProfile({
    required this.id,
    this.phone,
    this.username,
    this.displayName,
    this.onboardingComplete = false,
  });

  final String id;
  final String? phone;
  final String? username;
  final String? displayName;
  final bool onboardingComplete;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String,
      phone: json['phone'] as String?,
      username: json['username'] as String?,
      displayName: json['display_name'] as String?,
      onboardingComplete: json['onboardingComplete'] as bool? ?? json['username'] != null,
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

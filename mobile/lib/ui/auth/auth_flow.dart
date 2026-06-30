import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../core/auth/session_provider.dart';
import '../legal/consent_screen.dart';
import '../onboarding/onboarding_screen.dart';
import '../shell/app_shell.dart';
import 'phone_login_screen.dart';
import 'otp_verify_screen.dart';

class AppGate extends ConsumerWidget {
  const AppGate({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);

    if (session.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!session.isAuthenticated) {
      return const PhoneLoginScreen();
    }

    if (session.needsOnboarding) {
      return const OnboardingScreen();
    }

    if (session.needsConsent) {
      return const ConsentScreen();
    }

    return const AppShell();
  }
}

/// Shown after phone entry — separate route via Navigator from login.
class AuthFlow extends StatelessWidget {
  const AuthFlow({super.key, required this.phone});

  final String phone;

  @override
  Widget build(BuildContext context) {
    return OtpVerifyScreen(phone: phone);
  }
}

class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    super.key,
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'AuraTalk',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: primary,
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const Gap(32),
              Text(title, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
              const Gap(8),
              Text(subtitle, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: const Color(0xFF6B7280))),
              const Gap(28),
              child,
            ],
          ),
        ),
      ),
    );
  }
}

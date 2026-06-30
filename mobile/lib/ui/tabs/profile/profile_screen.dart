import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../../core/auth/session_provider.dart';
import '../../legal/legal_document_screen.dart';
import '../../privacy/privacy_settings_screen.dart';
import '../../requests/message_requests_screen.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final profile = session.profile;
    final primary = Theme.of(context).colorScheme.primary;

    final displayName = profile?.displayName ?? 'Your Name';
    final subtitle = profile?.username != null ? '@${profile!.username}' : 'Complete onboarding';

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: primary.withValues(alpha: 0.12),
                    child: Icon(Icons.person, color: primary, size: 30),
                  ),
                  const Gap(12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayName,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const Gap(4),
                        Text(
                          subtitle,
                          style: Theme.of(context).textTheme.labelMedium?.copyWith(color: const Color(0xFF6B7280)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const Gap(14),
          _SettingRow(
            icon: Icons.mail_outline,
            title: 'Message requests',
            subtitle: 'People who want to reach you',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const MessageRequestsScreen()),
            ),
          ),
          const Gap(10),
          _SettingRow(
            icon: Icons.lock_outline,
            title: 'Privacy Settings',
            subtitle: 'Requests, phone visibility, downloads',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const PrivacySettingsScreen()),
            ),
          ),
          const Gap(10),
          _SettingRow(
            icon: Icons.description_outlined,
            title: 'Terms of Service',
            subtitle: 'How you may use AuraTalk',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const LegalDocumentScreen(
                  type: 'tos',
                  fallbackTitle: 'Terms of Service',
                ),
              ),
            ),
          ),
          const Gap(10),
          _SettingRow(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            subtitle: 'What we collect and how it\u2019s used',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const LegalDocumentScreen(
                  type: 'privacy',
                  fallbackTitle: 'Privacy Policy',
                ),
              ),
            ),
          ),
          const Gap(24),
          OutlinedButton(
            onPressed: () => ref.read(sessionProvider.notifier).logout(),
            child: const Text('Log out'),
          ),
        ],
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(color: primary.withValues(alpha: 0.10), shape: BoxShape.circle),
                child: Icon(icon, color: primary),
              ),
              const Gap(12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800)),
                    const Gap(2),
                    Text(subtitle, style: Theme.of(context).textTheme.labelSmall?.copyWith(color: const Color(0xFF6B7280))),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Color(0xFF9AA3B2)),
            ],
          ),
        ),
      ),
    );
  }
}

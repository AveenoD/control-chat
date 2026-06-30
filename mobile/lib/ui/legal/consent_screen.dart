import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../core/auth/session_provider.dart';
import 'legal_document_screen.dart';

/// Blocking consent gate shown after onboarding until the user accepts the
/// latest Terms of Service and Privacy Policy.
class ConsentScreen extends ConsumerStatefulWidget {
  const ConsentScreen({super.key});

  @override
  ConsumerState<ConsentScreen> createState() => _ConsentScreenState();
}

class _ConsentScreenState extends ConsumerState<ConsentScreen> {
  bool _agreed = false;
  bool _busy = false;
  String? _error;

  Future<void> _accept() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(sessionProvider.notifier).acceptConsent();
      // The gate re-renders to the app shell once the profile refreshes.
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = 'Could not save your choice. Please check your connection and try again.';
      });
    }
  }

  void _openDoc(String type, String title) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => LegalDocumentScreen(type: type, fallbackTitle: title),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final primary = Theme.of(context).colorScheme.primary;
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.verified_user_outlined, size: 40, color: primary),
              const Gap(16),
              const Text(
                'Before you start',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
              ),
              const Gap(8),
              Text(
                'To use AuraTalk, please review and accept our Terms of Service and Privacy Policy. '
                'Your chats stay end-to-end encrypted \u2014 we can\u2019t read them.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: const Color(0xFF6B7280),
                    ),
              ),
              const Gap(24),
              _DocTile(
                icon: Icons.description_outlined,
                title: 'Terms of Service',
                onTap: () => _openDoc('tos', 'Terms of Service'),
              ),
              const Gap(10),
              _DocTile(
                icon: Icons.privacy_tip_outlined,
                title: 'Privacy Policy',
                onTap: () => _openDoc('privacy', 'Privacy Policy'),
              ),
              const Spacer(),
              if (_error != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(_error!,
                      style: TextStyle(color: Theme.of(context).colorScheme.error)),
                ),
              InkWell(
                onTap: _busy ? null : () => setState(() => _agreed = !_agreed),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Checkbox(
                        value: _agreed,
                        onChanged: _busy
                            ? null
                            : (v) => setState(() => _agreed = v ?? false),
                      ),
                      const Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(top: 12),
                          child: Text(
                            'I have read and agree to the Terms of Service and Privacy Policy.',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Gap(12),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: (_agreed && !_busy) ? _accept : null,
                  child: _busy
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Agree and continue'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DocTile extends StatelessWidget {
  const _DocTile({required this.icon, required this.title, required this.onTap});

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF0F2F5),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Icon(icon, color: Theme.of(context).colorScheme.primary),
              const Gap(12),
              Expanded(
                child: Text(title,
                    style: const TextStyle(fontWeight: FontWeight.w600)),
              ),
              const Icon(Icons.chevron_right, color: Color(0xFF9AA3B2)),
            ],
          ),
        ),
      ),
    );
  }
}

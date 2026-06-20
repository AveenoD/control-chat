import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../core/auth/auth_repository.dart';
import '../../core/auth/session_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _nameController = TextEditingController();
  final _usernameController = TextEditingController();
  bool _loading = false;
  String? _usernameHint;

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _checkUsername() async {
    final u = _usernameController.text.trim().toLowerCase();
    if (u.length < 3) return;
    final ok = await ref.read(authRepositoryProvider).isUsernameAvailable(u);
    setState(() => _usernameHint = ok ? 'Available' : 'Taken or invalid');
  }

  Future<void> _submit() async {
    final name = _nameController.text.trim();
    final username = _usernameController.text.trim().toLowerCase();
    if (name.isEmpty || username.length < 3) return;

    setState(() => _loading = true);
    try {
      await ref.read(authRepositoryProvider).completeOnboarding(
            username: username,
            displayName: name,
          );
      await ref.read(sessionProvider.notifier).refreshProfile();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Set up profile')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Choose your public identity',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const Gap(8),
            const Text(
              'Your @username is shown in Zones and to non-contacts. Phone stays private.',
              style: TextStyle(color: Color(0xFF6B7280)),
            ),
            const Gap(24),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Display name',
                border: OutlineInputBorder(),
              ),
            ),
            const Gap(16),
            TextField(
              controller: _usernameController,
              onChanged: (_) => _checkUsername(),
              decoration: InputDecoration(
                labelText: 'Username',
                prefixText: '@',
                border: const OutlineInputBorder(),
                helperText: _usernameHint,
              ),
            ),
            const Spacer(),
            FilledButton(
              onPressed: _loading ? null : _submit,
              child: _loading
                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Continue'),
            ),
          ],
        ),
      ),
    );
  }
}

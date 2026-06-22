import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../core/auth/auth_repository.dart';
import '../../core/security/screen_security.dart';

class PrivacySettingsScreen extends ConsumerStatefulWidget {
  const PrivacySettingsScreen({super.key});

  @override
  ConsumerState<PrivacySettingsScreen> createState() => _PrivacySettingsScreenState();
}

class _PrivacySettingsScreenState extends ConsumerState<PrivacySettingsScreen> {
  Map<String, dynamic>? _privacy;
  bool _loading = true;
  bool _screenSecurity = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final screenSecurity =
        await ref.read(screenSecurityProvider).isEnabled();
    try {
      final p = await ref.read(authRepositoryProvider).getPrivacy();
      setState(() {
        _privacy = p;
        _screenSecurity = screenSecurity;
        _loading = false;
      });
    } catch (_) {
      setState(() {
        _screenSecurity = screenSecurity;
        _loading = false;
      });
    }
  }

  Future<void> _toggleScreenSecurity(bool value) async {
    setState(() => _screenSecurity = value);
    await ref.read(screenSecurityProvider).setEnabled(value);
  }

  Future<void> _toggle(String key, bool value) async {
    setState(() => _privacy = {...?_privacy, key: value});
    await ref.read(authRepositoryProvider).updatePrivacy({key: value});
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final p = _privacy ?? {};

    return Scaffold(
      appBar: AppBar(title: const Text('Privacy Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Who can reach you',
            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          ),
          const Gap(8),
          SwitchListTile(
            title: const Text('Require message request'),
            subtitle: const Text('Non-contacts must request before chatting'),
            value: p['requireMessageRequest'] as bool? ?? true,
            onChanged: (v) => _toggle('requireMessageRequest', v),
          ),
          SwitchListTile(
            title: const Text('Hide phone from non-contacts'),
            value: p['hidePhoneFromNonContacts'] as bool? ?? true,
            onChanged: (v) => _toggle('hidePhoneFromNonContacts', v),
          ),
          SwitchListTile(
            title: const Text('Hide phone from group members'),
            value: p['hidePhoneFromGroupMembers'] as bool? ?? true,
            onChanged: (v) => _toggle('hidePhoneFromGroupMembers', v),
          ),
          const Gap(16),
          const Text('Media', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          SwitchListTile(
            title: const Text('Allow file downloads'),
            value: p['allowDownload'] as bool? ?? true,
            onChanged: (v) => _toggle('allowDownload', v),
          ),
          SwitchListTile(
            title: const Text('Read receipts'),
            value: p['readReceipts'] as bool? ?? true,
            onChanged: (v) => _toggle('readReceipts', v),
          ),
          SwitchListTile(
            title: const Text('Typing indicators'),
            value: p['typingIndicators'] as bool? ?? true,
            onChanged: (v) => _toggle('typingIndicators', v),
          ),
          SwitchListTile(
            title: const Text('Show online status'),
            value: p['showOnlineStatus'] as bool? ?? true,
            onChanged: (v) => _toggle('showOnlineStatus', v),
          ),
          const Gap(16),
          const Text('Screen security',
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          SwitchListTile(
            title: const Text('Block screenshots & screen recording'),
            subtitle: const Text(
                'Also hides chats in the app switcher. Applies to this device.'),
            value: _screenSecurity,
            onChanged: _toggleScreenSecurity,
          ),
        ],
      ),
    );
  }
}

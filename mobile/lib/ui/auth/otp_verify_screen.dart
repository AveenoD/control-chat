import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';

import '../../core/auth/auth_repository.dart';
import '../../core/auth/session_provider.dart';
import 'auth_flow.dart';

class OtpVerifyScreen extends ConsumerStatefulWidget {
  const OtpVerifyScreen({super.key, required this.phone});

  final String phone;

  @override
  ConsumerState<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends ConsumerState<OtpVerifyScreen> {
  final _otpController = TextEditingController(text: '123456');
  bool _loading = false;
  late final String _deviceId;

  @override
  void initState() {
    super.initState();
    final existing = ref.read(sessionProvider).deviceId;
    _deviceId = ref.read(authRepositoryProvider).getOrCreateDeviceId(existing);
  }

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    setState(() => _loading = true);
    try {
      final repo = ref.read(authRepositoryProvider);
      final result = await repo.verifyOtp(
        phone: widget.phone,
        otp: _otpController.text.trim(),
        deviceId: _deviceId,
      );
      await ref.read(sessionProvider.notifier).setSession(
            accessToken: result.accessToken,
            refreshToken: result.refreshToken,
            userId: result.userId,
            deviceId: _deviceId,
          );
      if (!mounted) return;
      Navigator.of(context).popUntil((r) => r.isFirst);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Invalid OTP: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      title: 'Verify OTP',
      subtitle: 'Dev OTP is ${ref.read(authRepositoryProvider).devOtp}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _otpController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'OTP',
              border: OutlineInputBorder(),
            ),
          ),
          const Gap(20),
          FilledButton(
            onPressed: _loading ? null : _verify,
            child: _loading
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Verify & continue'),
          ),
        ],
      ),
    );
  }
}

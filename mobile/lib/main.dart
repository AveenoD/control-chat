import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app/app.dart';
import 'core/security/screen_security.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Re-apply the saved screen-security preference. The native side already
  // enabled FLAG_SECURE on launch, so this only relaxes it if the user opted
  // out previously.
  ScreenSecurityService().applySaved();
  runApp(const ProviderScope(child: _Root()));
}

class _Root extends StatelessWidget {
  const _Root();

  @override
  Widget build(BuildContext context) {
    return const AuraApp();
  }
}

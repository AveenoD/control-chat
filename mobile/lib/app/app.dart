import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../theme/aura_theme.dart';
import '../ui/auth/auth_flow.dart';

class AuraApp extends ConsumerWidget {
  const AuraApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AuraTalk',
      theme: AuraTheme.light(),
      home: const AppGate(),
    );
  }
}

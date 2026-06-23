import 'dart:ui';

import 'package:flutter/material.dart';

/// Blurs the whole app whenever it leaves the foreground (app switcher / quick
/// app switch / notification shade), so chat content can't be glanced at or
/// captured in the recents preview. Complements Android's FLAG_SECURE, and also
/// covers the brief inactive transition before the OS snapshot is taken.
class PrivacyShield extends StatefulWidget {
  const PrivacyShield({super.key, required this.child});

  final Widget child;

  @override
  State<PrivacyShield> createState() => _PrivacyShieldState();
}

class _PrivacyShieldState extends State<PrivacyShield> with WidgetsBindingObserver {
  bool _obscure = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Cover for anything that isn't a fully-foreground, interactive app.
    final shouldObscure = state != AppLifecycleState.resumed;
    if (shouldObscure != _obscure) setState(() => _obscure = shouldObscure);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_obscure)
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(
                color: const Color(0xFF4338CA).withValues(alpha: 0.55),
                alignment: Alignment.center,
                child: const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.lock_outline, color: Colors.white, size: 44),
                    SizedBox(height: 12),
                    Text(
                      'AuraTalk',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}

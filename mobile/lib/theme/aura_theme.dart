import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AuraColors {
  static const primary = Color(0xFF3B4A8F); // indigo-ish from references
  static const background = Color(0xFFF6F7FB);
  static const surface = Colors.white;
  static const divider = Color(0xFFE9ECF5);
  static const textPrimary = Color(0xFF111827);
  static const textSecondary = Color(0xFF6B7280);
}

class AuraTheme {
  static ThemeData light() {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AuraColors.primary,
        brightness: Brightness.light,
        surface: AuraColors.surface,
      ),
      scaffoldBackgroundColor: AuraColors.background,
      dividerColor: AuraColors.divider,
      textTheme: GoogleFonts.interTextTheme(),
    );

    return base.copyWith(
      appBarTheme: base.appBarTheme.copyWith(
        backgroundColor: AuraColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: base.textTheme.titleLarge?.copyWith(
          color: AuraColors.primary,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.2,
        ),
        iconTheme: const IconThemeData(color: AuraColors.textSecondary),
      ),
      cardTheme: base.cardTheme.copyWith(
        color: AuraColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        margin: EdgeInsets.zero,
      ),
    );
  }
}


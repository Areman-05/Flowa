import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'flowa_colors.dart';

/// Typography — Syne for display, Outfit for UI (premium fintech).
abstract final class FlowaTypography {
  static String get fontFamily => GoogleFonts.outfit().fontFamily ?? 'Outfit';

  static String get displayFamily => GoogleFonts.syne().fontFamily ?? 'Syne';

  static TextTheme get textTheme {
    final outfit = GoogleFonts.outfitTextTheme();
    final syne = GoogleFonts.syneTextTheme();

    return outfit.copyWith(
      displayLarge: syne.displayLarge?.copyWith(
        fontSize: 40,
        fontWeight: FontWeight.w700,
        height: 1.05,
        letterSpacing: -1.2,
        color: FlowaColors.textPrimary,
      ),
      displaySmall: syne.displaySmall?.copyWith(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        height: 1.1,
        letterSpacing: -0.8,
        color: FlowaColors.textPrimary,
      ),
      headlineLarge: syne.headlineLarge?.copyWith(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        height: 1.2,
        color: FlowaColors.textPrimary,
      ),
      headlineMedium: outfit.headlineMedium?.copyWith(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        height: 1.3,
        color: FlowaColors.textPrimary,
      ),
      titleLarge: outfit.titleLarge?.copyWith(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        height: 1.3,
        color: FlowaColors.textPrimary,
      ),
      titleMedium: outfit.titleMedium?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.35,
        color: FlowaColors.textPrimary,
      ),
      bodyLarge: outfit.bodyLarge?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.45,
        color: FlowaColors.textPrimary,
      ),
      bodyMedium: outfit.bodyMedium?.copyWith(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.45,
        color: FlowaColors.textSecondary,
      ),
      bodySmall: outfit.bodySmall?.copyWith(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.35,
        color: FlowaColors.textTertiary,
      ),
      labelLarge: outfit.labelLarge?.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        height: 1.25,
        color: FlowaColors.textOnPrimary,
      ),
      labelMedium: outfit.labelMedium?.copyWith(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        height: 1.3,
        color: FlowaColors.textSecondary,
      ),
      labelSmall: outfit.labelSmall?.copyWith(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        height: 1.3,
        color: FlowaColors.textTertiary,
      ),
    );
  }
}

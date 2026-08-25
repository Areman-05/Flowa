import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../tokens/flowa_colors.dart';
import '../tokens/flowa_spacing.dart';
import '../tokens/flowa_typography.dart';

/// Builds the [ThemeData] variants consumed by Flowa.
abstract final class FlowaTheme {
  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: FlowaColors.primary,
      brightness: Brightness.dark,
      primary: FlowaColors.primary,
      onPrimary: FlowaColors.textOnPrimary,
      secondary: FlowaColors.primarySoft,
      surface: FlowaColors.surface,
      onSurface: FlowaColors.textPrimary,
      error: FlowaColors.danger,
    );

    return _build(
      colorScheme: colorScheme,
      brightness: Brightness.dark,
      scaffoldBg: FlowaColors.background,
      surfaceColor: FlowaColors.surface,
      textPrimary: FlowaColors.textPrimary,
      textOnPrimary: FlowaColors.textOnPrimary,
      borderColor: FlowaColors.border,
      surfaceMuted: FlowaColors.surfaceMuted,
      overlayStyle: SystemUiOverlayStyle.light,
    );
  }

  static ThemeData dark() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: FlowaColors.primary,
      brightness: Brightness.dark,
      primary: FlowaColors.primary,
      onPrimary: FlowaColors.textOnPrimary,
      secondary: FlowaColors.primarySoft,
      surface: FlowaColors.surface,
      onSurface: FlowaColors.textPrimary,
      error: FlowaColors.danger,
    );

    return _build(
      colorScheme: colorScheme,
      brightness: Brightness.dark,
      scaffoldBg: FlowaColors.background,
      surfaceColor: FlowaColors.surface,
      textPrimary: FlowaColors.textPrimary,
      textOnPrimary: FlowaColors.textOnPrimary,
      borderColor: FlowaColors.border,
      surfaceMuted: FlowaColors.surfaceMuted,
      overlayStyle: SystemUiOverlayStyle.light,
    );
  }

  static ThemeData _build({
    required ColorScheme colorScheme,
    required Brightness brightness,
    required Color scaffoldBg,
    required Color surfaceColor,
    required Color textPrimary,
    required Color textOnPrimary,
    required Color borderColor,
    required Color surfaceMuted,
    required SystemUiOverlayStyle overlayStyle,
  }) {
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: scaffoldBg,
      textTheme: FlowaTypography.textTheme,
      fontFamily: FlowaTypography.fontFamily,
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        backgroundColor: surfaceColor,
        foregroundColor: textPrimary,
        systemOverlayStyle: overlayStyle,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: FlowaColors.primary,
          foregroundColor: textOnPrimary,
          minimumSize: const Size.fromHeight(56),
          shape: const RoundedRectangleBorder(borderRadius: FlowaRadii.mdAll),
          textStyle: FlowaTypography.textTheme.labelLarge,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: FlowaColors.primary,
          foregroundColor: textOnPrimary,
          minimumSize: const Size.fromHeight(56),
          shape: const RoundedRectangleBorder(borderRadius: FlowaRadii.mdAll),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textPrimary,
          minimumSize: const Size.fromHeight(56),
          side: BorderSide(color: borderColor),
          shape: const RoundedRectangleBorder(borderRadius: FlowaRadii.mdAll),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceMuted,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: FlowaSpacing.md,
          vertical: FlowaSpacing.md,
        ),
        border: const OutlineInputBorder(
          borderRadius: FlowaRadii.mdAll,
          borderSide: BorderSide.none,
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: FlowaRadii.mdAll,
          borderSide: BorderSide.none,
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: FlowaRadii.mdAll,
          borderSide: BorderSide(color: FlowaColors.primary, width: 1.5),
        ),
        hintStyle: FlowaTypography.textTheme.bodyMedium,
      ),
      dividerTheme: DividerThemeData(
        color: borderColor,
        thickness: 1,
        space: 1,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          return surfaceColor;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return FlowaColors.primary;
          }
          return borderColor;
        }),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: surfaceColor,
        selectedItemColor: FlowaColors.primary,
        unselectedItemColor: textPrimary.withValues(alpha: 0.45),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        showUnselectedLabels: true,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: textPrimary,
        contentTextStyle: FlowaTypography.textTheme.bodyMedium?.copyWith(
          color: textOnPrimary,
        ),
        shape: const RoundedRectangleBorder(borderRadius: FlowaRadii.smAll),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../tokens/flowa_colors.dart';
import '../tokens/flowa_spacing.dart';
import '../tokens/flowa_typography.dart';

/// Builds the light [ThemeData] consumed by Flowa.
abstract final class FlowaTheme {
  static ThemeData light() {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: FlowaColors.primary,
      primary: FlowaColors.primary,
      onPrimary: FlowaColors.textOnPrimary,
      secondary: FlowaColors.primarySoft,
      surface: FlowaColors.surface,
      onSurface: FlowaColors.textPrimary,
      error: FlowaColors.danger,
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: FlowaColors.background,
      textTheme: FlowaTypography.textTheme,
      fontFamily: FlowaTypography.fontFamily,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        backgroundColor: FlowaColors.surface,
        foregroundColor: FlowaColors.textPrimary,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: FlowaColors.primary,
          foregroundColor: FlowaColors.textOnPrimary,
          minimumSize: const Size.fromHeight(56),
          shape: const RoundedRectangleBorder(borderRadius: FlowaRadii.mdAll),
          textStyle: FlowaTypography.textTheme.labelLarge,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: FlowaColors.primary,
          foregroundColor: FlowaColors.textOnPrimary,
          minimumSize: const Size.fromHeight(56),
          shape: const RoundedRectangleBorder(borderRadius: FlowaRadii.mdAll),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: FlowaColors.textPrimary,
          minimumSize: const Size.fromHeight(56),
          side: const BorderSide(color: FlowaColors.border),
          shape: const RoundedRectangleBorder(borderRadius: FlowaRadii.mdAll),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: FlowaColors.surfaceMuted,
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
      dividerTheme: const DividerThemeData(
        color: FlowaColors.border,
        thickness: 1,
        space: 1,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          return FlowaColors.surface;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return FlowaColors.primary;
          }
          return FlowaColors.border;
        }),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: FlowaColors.surface,
        selectedItemColor: FlowaColors.primary,
        unselectedItemColor: FlowaColors.textTertiary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        showUnselectedLabels: true,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: FlowaColors.textPrimary,
        contentTextStyle: FlowaTypography.textTheme.bodyMedium?.copyWith(
          color: FlowaColors.textOnPrimary,
        ),
        shape: const RoundedRectangleBorder(borderRadius: FlowaRadii.smAll),
      ),
    );
  }
}

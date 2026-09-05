import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../tokens/flowa_colors.dart';
import '../tokens/flowa_spacing.dart';
import '../tokens/flowa_typography.dart';

/// Flowa is dark-only. Mint on black is the whole colour story, so [light]
/// and [dark] intentionally resolve to the same theme.
abstract final class FlowaTheme {
  static ThemeData light() => _build();

  static ThemeData dark() => _build();

  static ThemeData _build() {
    const colorScheme = ColorScheme.dark(
      primary: FlowaColors.acid,
      onPrimary: FlowaColors.acidInk,
      primaryContainer: FlowaColors.acidTintedSurface,
      onPrimaryContainer: FlowaColors.acid,
      secondary: FlowaColors.bone,
      onSecondary: FlowaColors.ink,
      surface: FlowaColors.inkSurface,
      onSurface: FlowaColors.bone,
      surfaceContainerHighest: FlowaColors.inkHigh,
      outline: FlowaColors.hairlineStrong,
      outlineVariant: FlowaColors.hairline,
      error: FlowaColors.danger,
      onError: FlowaColors.bone,
    );

    final textTheme = FlowaTypography.textTheme;

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: FlowaColors.ink,
      canvasColor: FlowaColors.ink,
      textTheme: textTheme,
      fontFamily: FlowaTypography.fontFamily,
      splashFactory: NoSplash.splashFactory,
      highlightColor: Colors.transparent,
      splashColor: Colors.transparent,
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: _FlowaPageTransition(),
          TargetPlatform.iOS: _FlowaPageTransition(),
        },
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleSpacing: FlowaSpacing.gutter,
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        foregroundColor: FlowaColors.bone,
        titleTextStyle: textTheme.titleLarge,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        iconTheme: const IconThemeData(color: FlowaColors.bone, size: 20),
      ),
      iconTheme: const IconThemeData(color: FlowaColors.boneMuted, size: 20),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          backgroundColor: FlowaColors.acid,
          foregroundColor: FlowaColors.acidInk,
          disabledBackgroundColor: FlowaColors.inkHigh,
          disabledForegroundColor: FlowaColors.boneFaint,
          minimumSize: const Size.fromHeight(56),
          shape: const RoundedRectangleBorder(borderRadius: FlowaRadii.pillAll),
          textStyle: textTheme.labelLarge,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: FlowaColors.acid,
          foregroundColor: FlowaColors.acidInk,
          disabledBackgroundColor: FlowaColors.inkHigh,
          disabledForegroundColor: FlowaColors.boneFaint,
          minimumSize: const Size.fromHeight(56),
          shape: const RoundedRectangleBorder(borderRadius: FlowaRadii.pillAll),
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: FlowaColors.bone,
          minimumSize: const Size.fromHeight(56),
          side: const BorderSide(color: FlowaColors.hairlineStrong),
          shape: const RoundedRectangleBorder(borderRadius: FlowaRadii.pillAll),
          textStyle: textTheme.labelLarge?.copyWith(color: FlowaColors.bone),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: FlowaColors.acid,
          textStyle: FlowaType.micro(color: FlowaColors.acid),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: FlowaColors.boneMuted,
          side: const BorderSide(color: FlowaColors.hairline),
          shape: const RoundedRectangleBorder(borderRadius: FlowaRadii.smAll),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: FlowaColors.inkRaised,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: FlowaSpacing.md,
          vertical: 18,
        ),
        border: const OutlineInputBorder(
          borderRadius: FlowaRadii.mdAll,
          borderSide: BorderSide(color: FlowaColors.hairline),
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: FlowaRadii.mdAll,
          borderSide: BorderSide(color: FlowaColors.hairline),
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: FlowaRadii.mdAll,
          borderSide: BorderSide(color: FlowaColors.acid, width: 1.4),
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: FlowaRadii.mdAll,
          borderSide: BorderSide(color: FlowaColors.danger),
        ),
        focusedErrorBorder: const OutlineInputBorder(
          borderRadius: FlowaRadii.mdAll,
          borderSide: BorderSide(color: FlowaColors.danger, width: 1.4),
        ),
        labelStyle: FlowaType.micro(),
        floatingLabelStyle: FlowaType.micro(color: FlowaColors.acid),
        hintStyle: FlowaType.body(color: FlowaColors.boneGhost),
        errorStyle: FlowaType.bodySm(color: FlowaColors.danger),
        prefixIconColor: FlowaColors.boneFaint,
        suffixIconColor: FlowaColors.boneFaint,
      ),
      dividerTheme: const DividerThemeData(
        color: FlowaColors.hairline,
        thickness: 1,
        space: 1,
      ),
      listTileTheme: ListTileThemeData(
        contentPadding: EdgeInsets.zero,
        iconColor: FlowaColors.boneMuted,
        titleTextStyle: textTheme.titleSmall,
        subtitleTextStyle: textTheme.bodyMedium,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? FlowaColors.acidInk
              : FlowaColors.boneMuted;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          return states.contains(WidgetState.selected)
              ? FlowaColors.acid
              : FlowaColors.inkPressed;
        }),
        trackOutlineColor: const WidgetStatePropertyAll(
          FlowaColors.hairlineStrong,
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: FlowaColors.acid,
        linearTrackColor: FlowaColors.inkPressed,
        circularTrackColor: FlowaColors.inkPressed,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: FlowaColors.inkRaised,
        surfaceTintColor: Colors.transparent,
        modalBarrierColor: Color(0xE6000000),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: FlowaColors.inkSurface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(borderRadius: FlowaRadii.lgAll),
        titleTextStyle: textTheme.titleLarge,
        contentTextStyle: textTheme.bodyLarge,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: FlowaColors.inkHigh,
        contentTextStyle: FlowaType.bodySm(color: FlowaColors.bone),
        actionTextColor: FlowaColors.acid,
        shape: const RoundedRectangleBorder(borderRadius: FlowaRadii.smAll),
        insetPadding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        selectedItemColor: FlowaColors.acid,
        unselectedItemColor: FlowaColors.boneFaint,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        showUnselectedLabels: true,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        indicatorColor: FlowaColors.acidTintedSurface,
        elevation: 0,
        labelTextStyle: WidgetStatePropertyAll(FlowaType.micro()),
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: FlowaColors.inkHigh,
          borderRadius: FlowaRadii.xsAll,
          border: Border.all(color: FlowaColors.hairline),
        ),
        textStyle: FlowaType.micro(color: FlowaColors.boneMuted),
      ),
    );
  }
}

/// Soft fade when a Material route is covered / revealed.
class _FlowaPageTransition extends PageTransitionsBuilder {
  const _FlowaPageTransition();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final entering = CurvedAnimation(
      parent: animation,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    );

    return FadeTransition(
      opacity: entering,
      child: child,
    );
  }
}

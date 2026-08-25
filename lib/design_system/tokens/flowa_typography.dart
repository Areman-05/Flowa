import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'flowa_colors.dart';

/// Flowa type system.
///
/// One family, Manrope, across the whole product. A geometric grotesk with a
/// genuinely heavy ExtraBold cut, which is what the reference leans on: the
/// money figures are set very heavy and very tight while everything around
/// them stays light and quiet. Hierarchy comes from weight and size, never
/// from switching typeface.
abstract final class FlowaType {
  static const List<FontFeature> _tabular = [FontFeature.tabularFigures()];

  // --- Figures ------------------------------------------------------------
  //
  // Always tabular so digits never jitter while a balance counts up.

  static TextStyle figureXl({Color color = FlowaColors.bone}) =>
      GoogleFonts.manrope(
        fontSize: 46,
        fontWeight: FontWeight.w800,
        height: 1.05,
        letterSpacing: -1.6,
        fontFeatures: _tabular,
        color: color,
      );

  static TextStyle figureLg({Color color = FlowaColors.bone}) =>
      GoogleFonts.manrope(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        height: 1.1,
        letterSpacing: -1,
        fontFeatures: _tabular,
        color: color,
      );

  static TextStyle figureMd({Color color = FlowaColors.bone}) =>
      GoogleFonts.manrope(
        fontSize: 22,
        fontWeight: FontWeight.w800,
        height: 1.15,
        letterSpacing: -0.6,
        fontFeatures: _tabular,
        color: color,
      );

  // --- Editorial ----------------------------------------------------------
  //
  // Brand moments: splash, onboarding, the question on each auth step.

  static TextStyle editorialXl({Color color = FlowaColors.bone}) =>
      GoogleFonts.manrope(
        fontSize: 42,
        fontWeight: FontWeight.w800,
        height: 1.08,
        letterSpacing: -1.6,
        color: color,
      );

  static TextStyle editorialLg({Color color = FlowaColors.bone}) =>
      GoogleFonts.manrope(
        fontSize: 32,
        fontWeight: FontWeight.w800,
        height: 1.15,
        letterSpacing: -1.1,
        color: color,
      );

  static TextStyle editorialMd({Color color = FlowaColors.bone}) =>
      GoogleFonts.manrope(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        height: 1.2,
        letterSpacing: -0.7,
        color: color,
      );

  static TextStyle wordmark({
    double size = 28,
    Color color = FlowaColors.bone,
  }) =>
      GoogleFonts.manrope(
        fontSize: size,
        fontWeight: FontWeight.w800,
        height: 1,
        letterSpacing: -size * 0.04,
        color: color,
      );

  // --- Amounts in lists ---------------------------------------------------

  static TextStyle amountMd({Color color = FlowaColors.bone}) =>
      GoogleFonts.manrope(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        height: 1.2,
        letterSpacing: -0.2,
        fontFeatures: _tabular,
        color: color,
      );

  static TextStyle amountSm({Color color = FlowaColors.boneMuted}) =>
      GoogleFonts.manrope(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        height: 1.2,
        fontFeatures: _tabular,
        color: color,
      );

  /// Small caption. Sentence case rather than the uppercase mono of before —
  /// the reference keeps its small labels quiet and normally capitalised.
  static TextStyle micro({Color color = FlowaColors.boneFaint}) =>
      GoogleFonts.manrope(
        fontSize: 11.5,
        fontWeight: FontWeight.w600,
        height: 1.25,
        letterSpacing: 0.2,
        color: color,
      );

  static TextStyle microLg({Color color = FlowaColors.boneMuted}) =>
      GoogleFonts.manrope(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        height: 1.3,
        letterSpacing: 0.1,
        color: color,
      );

  // --- Interface ----------------------------------------------------------

  static TextStyle titleLg({Color color = FlowaColors.bone}) =>
      GoogleFonts.manrope(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        height: 1.25,
        letterSpacing: -0.4,
        color: color,
      );

  static TextStyle titleMd({Color color = FlowaColors.bone}) =>
      GoogleFonts.manrope(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        height: 1.3,
        letterSpacing: -0.2,
        color: color,
      );

  static TextStyle titleSm({Color color = FlowaColors.bone}) =>
      GoogleFonts.manrope(
        fontSize: 14.5,
        fontWeight: FontWeight.w600,
        height: 1.3,
        color: color,
      );

  static TextStyle body({Color color = FlowaColors.boneMuted}) =>
      GoogleFonts.manrope(
        fontSize: 14.5,
        fontWeight: FontWeight.w500,
        height: 1.5,
        color: color,
      );

  static TextStyle bodySm({Color color = FlowaColors.boneMuted}) =>
      GoogleFonts.manrope(
        fontSize: 12.5,
        fontWeight: FontWeight.w500,
        height: 1.45,
        color: color,
      );

  static TextStyle label({Color color = FlowaColors.bone}) =>
      GoogleFonts.manrope(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        height: 1.2,
        letterSpacing: -0.1,
        color: color,
      );
}

/// Material [TextTheme] wiring so screens that still read from
/// `Theme.of(context).textTheme` inherit the new voice automatically.
abstract final class FlowaTypography {
  static String get fontFamily => GoogleFonts.manrope().fontFamily ?? 'Manrope';

  static String get displayFamily => fontFamily;

  static String get monoFamily => fontFamily;

  static String get editorialFamily => fontFamily;

  static TextTheme get textTheme => TextTheme(
        displayLarge: FlowaType.figureXl(),
        displayMedium: FlowaType.figureLg(),
        displaySmall: FlowaType.wordmark(),
        headlineLarge: FlowaType.editorialLg(),
        headlineMedium: FlowaType.editorialMd(),
        headlineSmall: FlowaType.titleLg(),
        titleLarge: FlowaType.titleLg(),
        titleMedium: FlowaType.titleMd(),
        titleSmall: FlowaType.titleSm(),
        bodyLarge: FlowaType.body(color: FlowaColors.bone),
        bodyMedium: FlowaType.bodySm(),
        bodySmall: FlowaType.micro(),
        labelLarge: FlowaType.label(color: FlowaColors.mintInk),
        labelMedium: FlowaType.microLg(),
        labelSmall: FlowaType.micro(),
      );
}

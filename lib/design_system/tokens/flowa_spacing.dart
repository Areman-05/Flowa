import 'package:flutter/material.dart';

import 'flowa_colors.dart';

/// 4pt grid. Every gap in the product is one of these values — nothing else.
abstract final class FlowaSpacing {
  static const double hair = 2;
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 40;
  static const double huge = 56;
  static const double giant = 80;

  /// Horizontal margin shared by every screen. Consistency here is what makes
  /// unrelated screens feel like one product.
  static const double gutter = 20;

  static const EdgeInsets screenPadding = EdgeInsets.symmetric(
    horizontal: gutter,
    vertical: md,
  );

  static const EdgeInsets cardPadding = EdgeInsets.all(lg);

  /// Clearance for the floating capsule navigation.
  static const double navClearance = 104;
}

/// Corner radii.
///
/// Generous but not bubbly. The hero payment card and the big panels sit at
/// 24, the smaller tiles at 16–18, and only genuine buttons go fully round.
abstract final class FlowaRadii {
  static const double none = 0;
  static const double xs = 10;
  static const double sm = 14;
  static const double md = 18;
  static const double lg = 22;
  static const double xl = 26;
  static const double xxl = 32;
  static const double pill = 999;

  static const BorderRadius zero = BorderRadius.zero;
  static const BorderRadius xsAll = BorderRadius.all(Radius.circular(xs));
  static const BorderRadius smAll = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius mdAll = BorderRadius.all(Radius.circular(md));
  static const BorderRadius lgAll = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius xlAll = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius xxlAll = BorderRadius.all(Radius.circular(xxl));
  static const BorderRadius pillAll = BorderRadius.all(Radius.circular(pill));
}

abstract final class FlowaShadows {
  /// On a black canvas a shadow only reads when it is layered: one tight
  /// contact shadow plus one wide ambient one.
  static const List<BoxShadow> lifted = [
    BoxShadow(color: Color(0x99000000), blurRadius: 2, offset: Offset(0, 1)),
    BoxShadow(color: Color(0x66000000), blurRadius: 24, offset: Offset(0, 12)),
  ];

  static const List<BoxShadow> soft = [
    BoxShadow(color: Color(0x59000000), blurRadius: 18, offset: Offset(0, 8)),
  ];

  static const List<BoxShadow> card = [
    BoxShadow(color: Color(0xB3000000), blurRadius: 34, offset: Offset(0, 18)),
  ];

  /// The only glow in the system, and only under mint surfaces.
  static const List<BoxShadow> mintGlow = [
    BoxShadow(
      color: FlowaColors.mintHalo,
      blurRadius: 32,
      spreadRadius: -10,
      offset: Offset(0, 14),
    ),
  ];

  static const List<BoxShadow> acidGlow = mintGlow;

  static List<BoxShadow> tinted(Color color) => [
        BoxShadow(
          color: color.withValues(alpha: 0.22),
          blurRadius: 28,
          spreadRadius: -8,
          offset: const Offset(0, 14),
        ),
      ];
}

abstract final class FlowaLayout {
  static Color get border => FlowaColors.hairline;

  static Border get hairline => Border.all(color: FlowaColors.hairline);

  static Border get hairlineSoft =>
      Border.all(color: FlowaColors.hairlineSoft);

  /// Heavier outline, for the rare element that needs to be boxed rather than
  /// merely separated.
  static Border get rule =>
      Border.all(color: FlowaColors.hairlineStrong, width: 1.5);
}

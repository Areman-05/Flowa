import 'package:flutter/material.dart';

/// Flowa color tokens — Radient-inspired (dark premium + vibrant orange).
abstract final class FlowaColors {
  // --- Brand (Radient orange) ---
  static const Color primary = Color(0xFFFF5722);
  static const Color primaryDark = Color(0xFFE64A19);
  static const Color primarySoft = Color(0xFF3D2218);
  static const Color accent = Color(0xFFFF8A50);
  static const Color ember = Color(0xFFFF7043);
  static const Color mist = Color(0xFF141414);

  /// Legacy aliases kept for call sites.
  static const Color periwinkle = accent;
  static const Color fuchsia = primary;
  static const Color fuchsiaDeep = primaryDark;

  // --- Surfaces (dark-first) ---
  static const Color background = Color(0xFF0A0A0A);
  static const Color surface = Color(0xFF141414);
  static const Color surfaceMuted = Color(0xFF1C1C1C);
  static const Color border = Color(0xFF2A2A2A);

  // --- Text ---
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFF9E9E9E);
  static const Color textTertiary = Color(0xFF6B6B6B);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnCard = Color(0xFFFFFFFF);

  // --- Semantic ---
  static const Color success = Color(0xFF00C853);
  static const Color danger = Color(0xFFFF5252);
  static const Color warning = Color(0xFFFFB300);
  static const Color warningSoft = Color(0xFF3D3218);
  static const Color income = Color(0xFF00C853);

  // --- Quick actions (muted on dark) ---
  static const Color actionSend = Color(0xFF3D2218);
  static const Color actionReceive = Color(0xFF1A2E22);
  static const Color actionTopUp = Color(0xFF3D3218);
  static const Color actionMore = Color(0xFF1A2430);

  // --- Card gradients ---
  static const Color cardPurpleStart = Color(0xFFFF5722);
  static const Color cardPurpleMid = Color(0xFFFF7043);
  static const Color cardPurpleEnd = Color(0xFFFF8A50);
  static const Color cardGoldStart = Color(0xFFE8A04A);
  static const Color cardGoldEnd = Color(0xFF3D3218);
  static const Color cardGreenStart = Color(0xFF1A3D28);
  static const Color cardGreenEnd = Color(0xFF0F1F16);

  static const LinearGradient cardPrimaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [cardPurpleStart, cardPurpleMid, cardPurpleEnd],
  );

  static const LinearGradient cardGoldGradient = LinearGradient(
    colors: [cardGoldStart, cardGoldEnd],
  );

  static const LinearGradient cardGreenGradient = LinearGradient(
    colors: [cardGreenStart, cardGreenEnd],
  );

  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [primaryDark, primary, ember],
  );

  static const LinearGradient softBackdrop = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0xFF121212),
      background,
      Color(0xFF0D0D0D),
    ],
  );

  /// Radient hero glow — orange bloom on dark canvas.
  static const LinearGradient radientHeroGlow = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Color(0x33FF5722),
      Color(0x00FF5722),
    ],
  );

  /// @Deprecated Use [softBackdrop].
  static const LinearGradient lunaBackdrop = softBackdrop;
}

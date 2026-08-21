import 'package:flutter/material.dart';

/// Flowa color tokens — LUNA: lunar white, mist gray, card fuchsia.
abstract final class FlowaColors {
  // --- Brand (fuchsia aligned with Visa card gradient) ---
  static const Color primary = Color(0xFF9B2CFF);
  static const Color primaryDark = Color(0xFF7B3AED);
  static const Color primarySoft = Color(0xFFF3E8FF);
  static const Color fuchsia = Color(0xFFD946EF);
  static const Color fuchsiaDeep = Color(0xFFA21CAF);
  static const Color mist = Color(0xFFF5F3F7);

  // --- Surfaces ---
  static const Color background = Color(0xFFFBFBFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF1F0F3);
  static const Color border = Color(0xFFE8E6EC);

  // --- Text ---
  static const Color textPrimary = Color(0xFF14121A);
  static const Color textSecondary = Color(0xFF6B6572);
  static const Color textTertiary = Color(0xFF9A94A3);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnCard = Color(0xFFFFFFFF);

  // --- Semantic ---
  static const Color success = Color(0xFF16A34A);
  static const Color danger = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningSoft = Color(0xFFFFF6DB);
  static const Color income = Color(0xFF7B3AED);

  // --- Quick actions (pastel) ---
  static const Color actionSend = Color(0xFFF3E8FF);
  static const Color actionReceive = Color(0xFFD8F5EA);
  static const Color actionTopUp = Color(0xFFFFF1C9);
  static const Color actionMore = Color(0xFFEDE4FF);

  // --- Card gradients ---
  static const Color cardPurpleStart = Color(0xFF7B3AED);
  static const Color cardPurpleEnd = Color(0xFFC4B5FD);
  static const Color cardGoldStart = Color(0xFFE8C37A);
  static const Color cardGoldEnd = Color(0xFFF7E7C3);
  static const Color cardGreenStart = Color(0xFFB7E4C7);
  static const Color cardGreenEnd = Color(0xFFE9F7EF);

  static const LinearGradient cardPrimaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [cardPurpleStart, fuchsia, cardPurpleEnd],
  );

  static const LinearGradient cardGoldGradient = LinearGradient(
    colors: [cardGoldStart, cardGoldEnd],
  );

  static const LinearGradient cardGreenGradient = LinearGradient(
    colors: [cardGreenStart, cardGreenEnd],
  );

  static const LinearGradient brandGradient = LinearGradient(
    colors: [primaryDark, primary, fuchsia],
  );

  static const LinearGradient lunaBackdrop = LinearGradient(
    colors: [
      Color(0xFFFFFFFF),
      mist,
      Color(0xFFF8F5FB),
    ],
  );
}

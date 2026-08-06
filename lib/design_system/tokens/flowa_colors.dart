import 'package:flutter/material.dart';

/// Flowa color tokens aligned with the fintech UI reference.
///
/// Keep raw [Color] values here only. Widgets should consume these tokens
/// (or [ThemeData]) instead of hard-coded hex values.
abstract final class FlowaColors {
  // --- Brand ---
  static const Color primary = Color(0xFF2F6BFF);
  static const Color primaryDark = Color(0xFF1B4ED8);
  static const Color primarySoft = Color(0xFFE8EFFF);

  // --- Surfaces ---
  static const Color background = Color(0xFFF7F8FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceMuted = Color(0xFFF2F3F7);
  static const Color border = Color(0xFFE6E8EE);

  // --- Text ---
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  static const Color textOnCard = Color(0xFFFFFFFF);

  // --- Semantic ---
  static const Color success = Color(0xFF16A34A);
  static const Color danger = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
  static const Color warningSoft = Color(0xFFFFF6DB);
  static const Color income = Color(0xFF1D4ED8);

  // --- Quick actions (pastel) ---
  static const Color actionSend = Color(0xFFEDE4FF);
  static const Color actionReceive = Color(0xFFD8F5EA);
  static const Color actionTopUp = Color(0xFFFFF1C9);
  static const Color actionMore = Color(0xFFDCE8FF);

  // --- Card gradients ---
  static const Color cardPurpleStart = Color(0xFF7B3AED);
  static const Color cardPurpleEnd = Color(0xFFC4B5FD);
  static const Color cardGoldStart = Color(0xFFE8C37A);
  static const Color cardGoldEnd = Color(0xFFF7E7C3);
  static const Color cardGreenStart = Color(0xFFB7E4C7);
  static const Color cardGreenEnd = Color(0xFFE9F7EF);

  static const LinearGradient cardPrimaryGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [cardPurpleStart, cardPurpleEnd],
  );

  static const LinearGradient cardGoldGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [cardGoldStart, cardGoldEnd],
  );

  static const LinearGradient cardGreenGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [cardGreenStart, cardGreenEnd],
  );
}

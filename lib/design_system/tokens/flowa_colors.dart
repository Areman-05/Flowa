import 'package:flutter/material.dart';

/// Flowa palette.
///
/// Black canvas, near-black surfaces, and a single mint accent — the colour
/// story taken from the Vare reference. Restraint is the point: one accent
/// means hierarchy has to come from type and space, and it means the mint
/// genuinely signals "this matters" wherever it lands.
abstract final class FlowaColors {
  // ---------------------------------------------------------------------
  // Ink — the surface ladder, from true black up to a pressed state.
  // ---------------------------------------------------------------------
  static const Color ink = Color(0xFF000000);
  static const Color inkRaised = Color(0xFF0C0C0D);
  static const Color inkSurface = Color(0xFF121213);
  static const Color inkHigh = Color(0xFF1A1A1C);
  static const Color inkPressed = Color(0xFF242427);

  static const Color hairline = Color(0xFF1F1F22);
  static const Color hairlineSoft = Color(0xFF161618);
  static const Color hairlineStrong = Color(0xFF2E2E33);

  // ---------------------------------------------------------------------
  // Text.
  // ---------------------------------------------------------------------
  static const Color bone = Color(0xFFFFFFFF);
  static const Color boneMuted = Color(0xFF9B9BA1);
  static const Color boneFaint = Color(0xFF6A6A70);
  static const Color boneGhost = Color(0xFF44444A);

  // ---------------------------------------------------------------------
  // Mint — the only accent. Black type always sits on top of it; mint on
  // black is bright enough that white would vibrate.
  // ---------------------------------------------------------------------
  static const Color mint = Color(0xFF00E6A6);
  static const Color mintBright = Color(0xFF2BF5BE);
  static const Color mintDeep = Color(0xFF00B583);
  static const Color mintInk = Color(0xFF001A12);
  static const Color mintVeil = Color(0x1F00E6A6);
  static const Color mintHalo = Color(0x3300E6A6);
  static const Color mintTintedSurface = Color(0xFF06231A);

  // ---------------------------------------------------------------------
  // Semantics. Income is mint, spending is plain white: colouring every
  // outgoing payment red would make an ordinary month look like a crisis.
  // ---------------------------------------------------------------------
  static const Color positive = mint;
  static const Color neutral = bone;
  static const Color danger = Color(0xFFFF5C5C);
  static const Color dangerSurface = Color(0xFF2A0F0F);
  static const Color warning = Color(0xFFFFB020);
  static const Color warningSurface = Color(0xFF2A1E06);
  static const Color info = Color(0xFF6AA8FF);
  static const Color infoSurface = Color(0xFF0C1729);

  // ---------------------------------------------------------------------
  // Gradients. Only the payment card and the primary fill get one, and both
  // stay inside a single hue so nothing reads as a stock "fintech gradient".
  // ---------------------------------------------------------------------

  static const LinearGradient mintFill = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [mintBright, mint],
  );

  /// The hero payment card: mint with a brighter sweep across the top-left,
  /// echoing the light falling across the reference card.
  static const LinearGradient cardFace = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF3DFFCB), mint, mintDeep],
    stops: [0, 0.55, 1],
  );

  /// Secondary card — graphite, so two cards never compete.
  static const LinearGradient cardVault = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1C1C20), Color(0xFF101012)],
  );

  static const LinearGradient canvasWash = LinearGradient(
    colors: [ink, ink],
  );

  static const RadialGradient mintBloom = RadialGradient(
    colors: [Color(0x0000E6A6), Color(0x0000E6A6)],
  );

  // ---------------------------------------------------------------------
  // Legacy aliases. Screens still on older naming resolve to this palette so
  // nothing renders off-brand while they are migrated one by one.
  // ---------------------------------------------------------------------
  static const Color acid = mint;
  static const Color acidDeep = mintDeep;
  static const Color acidInk = mintInk;
  static const Color acidVeil = mintVeil;
  static const Color acidHalo = mintHalo;
  static const Color acidTintedSurface = mintTintedSurface;

  static const Color blaze = mint;
  static const Color blazeDeep = mintDeep;
  static const Color blazeInk = mintInk;
  static const Color blazeVeil = mintVeil;
  static const Color blazeHalo = mintHalo;
  static const Color blazeTintedSurface = mintTintedSurface;

  static const Color primary = mint;
  static const Color primaryDark = mintDeep;
  static const Color primarySoft = mintTintedSurface;
  static const Color accent = mint;
  static const Color ember = mintDeep;
  static const Color mist = inkSurface;
  static const Color periwinkle = mint;
  static const Color fuchsia = mint;
  static const Color fuchsiaDeep = mintDeep;

  static const Color background = ink;
  static const Color surface = inkSurface;
  static const Color surfaceMuted = inkHigh;
  static const Color border = hairline;

  static const Color textPrimary = bone;
  static const Color textSecondary = boneMuted;
  static const Color textTertiary = boneFaint;
  static const Color textOnPrimary = mintInk;
  static const Color textOnCard = mintInk;

  static const Color success = mint;
  static const Color income = mint;
  static const Color warningSoft = warningSurface;

  static const Color actionSend = inkSurface;
  static const Color actionReceive = inkSurface;
  static const Color actionTopUp = inkSurface;
  static const Color actionMore = inkSurface;

  static const Color cardPurpleStart = Color(0xFF1C1C20);
  static const Color cardPurpleMid = Color(0xFF161619);
  static const Color cardPurpleEnd = Color(0xFF101012);
  static const Color cardGoldStart = Color(0xFF1C1C20);
  static const Color cardGoldEnd = Color(0xFF101012);
  static const Color cardGreenStart = mint;
  static const Color cardGreenEnd = mintDeep;

  static const LinearGradient cardPrimaryGradient = cardFace;
  static const LinearGradient cardGoldGradient = cardVault;
  static const LinearGradient cardGreenGradient = cardFace;
}

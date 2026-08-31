import 'package:flutter/material.dart';

import 'flowa_colors.dart';

/// Muted per-category tones — dark orb, soft icon, gradient progress.
class CategoryTone {
  const CategoryTone({
    required this.orbBackground,
    required this.icon,
    required this.progressStart,
    required this.progressEnd,
  });

  final Color orbBackground;
  final Color icon;
  final Color progressStart;
  final Color progressEnd;
}

abstract final class FlowaCategoryColors {
  static const income = CategoryTone(
    orbBackground: FlowaColors.mintTintedSurface,
    icon: FlowaColors.mint,
    progressStart: Color(0xFF065A42),
    progressEnd: Color(0xFF00B583),
  );

  static const fallback = CategoryTone(
    orbBackground: Color(0xFF1C1C20),
    icon: Color(0xFF8E8E96),
    progressStart: Color(0xFF3A3A40),
    progressEnd: Color(0xFF6A6A72),
  );

  /// One distinct muted tone per known category (demo + producción).
  static const _byName = <String, CategoryTone>{
    'alimentación': CategoryTone(
      orbBackground: Color(0xFF121F18),
      icon: Color(0xFF6DB892),
      progressStart: Color(0xFF264A38),
      progressEnd: Color(0xFF4A9468),
    ),
    'software': CategoryTone(
      orbBackground: Color(0xFF151A28),
      icon: Color(0xFF7A94D4),
      progressStart: Color(0xFF2E3F66),
      progressEnd: Color(0xFF5578BF),
    ),
    'servicios': CategoryTone(
      orbBackground: Color(0xFF1A1428),
      icon: Color(0xFF9A7EC8),
      progressStart: Color(0xFF3E3058),
      progressEnd: Color(0xFF7058A0),
    ),
    'ocio': CategoryTone(
      orbBackground: Color(0xFF221610),
      icon: Color(0xFFCC9168),
      progressStart: Color(0xFF5A3824),
      progressEnd: Color(0xFFA86A42),
    ),
    'material': CategoryTone(
      orbBackground: Color(0xFF231912),
      icon: Color(0xFFC4A060),
      progressStart: Color(0xFF5C4828),
      progressEnd: Color(0xFF987840),
    ),
    'transporte': CategoryTone(
      orbBackground: Color(0xFF101E22),
      icon: Color(0xFF5FA4B2),
      progressStart: Color(0xFF234650),
      progressEnd: Color(0xFF4A8898),
    ),
    'vivienda': CategoryTone(
      orbBackground: Color(0xFF201612),
      icon: Color(0xFFA07058),
      progressStart: Color(0xFF4A3028),
      progressEnd: Color(0xFF805048),
    ),
    'espacio': CategoryTone(
      orbBackground: Color(0xFF121820),
      icon: Color(0xFF6890B8),
      progressStart: Color(0xFF283848),
      progressEnd: Color(0xFF4E7090),
    ),
    'salud': CategoryTone(
      orbBackground: Color(0xFF221318),
      icon: Color(0xFFCC7888),
      progressStart: Color(0xFF523038),
      progressEnd: Color(0xFF985060),
    ),
    'impuestos': CategoryTone(
      orbBackground: Color(0xFF201A10),
      icon: Color(0xFFBA9860),
      progressStart: Color(0xFF4A3C22),
      progressEnd: Color(0xFF887040),
    ),
    'ingresos': income,
    'ingreso': income,
    'recarga': CategoryTone(
      orbBackground: Color(0xFF0E221C),
      icon: Color(0xFF52C49A),
      progressStart: Color(0xFF1E5040),
      progressEnd: Color(0xFF3A9070),
    ),
    'transferencia': CategoryTone(
      orbBackground: Color(0xFF181820),
      icon: Color(0xFF8888A0),
      progressStart: Color(0xFF343440),
      progressEnd: Color(0xFF585868),
    ),
    'general': CategoryTone(
      orbBackground: Color(0xFF1A1A1E),
      icon: Color(0xFF7A7A84),
      progressStart: Color(0xFF363640),
      progressEnd: Color(0xFF52525C),
    ),
  };

  static CategoryTone forCategory(String category) {
    final key = category.trim().toLowerCase();
    final exact = _byName[key];
    if (exact != null) {
      return exact;
    }

    // Fallback por palabras clave (categorías nuevas).
    if (key.contains('ingreso')) {
      return income;
    }
    if (key.contains('aliment') || key.contains('comida')) {
      return _byName['alimentación']!;
    }
    if (key.contains('software') || key.contains('figma')) {
      return _byName['software']!;
    }
    if (key.contains('servic')) {
      return _byName['servicios']!;
    }
    if (key.contains('ocio') || key.contains('cine')) {
      return _byName['ocio']!;
    }
    if (key.contains('material') || key.contains('amazon')) {
      return _byName['material']!;
    }
    if (key.contains('transport') || key.contains('renfe')) {
      return _byName['transporte']!;
    }
    if (key.contains('viviend')) {
      return _byName['vivienda']!;
    }
    if (key.contains('espacio') || key.contains('cowork')) {
      return _byName['espacio']!;
    }
    if (key.contains('salud')) {
      return _byName['salud']!;
    }
    if (key.contains('impuest')) {
      return _byName['impuestos']!;
    }

    return fallback;
  }
}

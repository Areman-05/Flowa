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
  /// Dark orbs + soft icons: azul, rojo, naranja, fucsia, blanco — legible on black.
  static const _byName = <String, CategoryTone>{
    'alimentación': CategoryTone(
      orbBackground: Color(0xFF1A1210),
      icon: Color(0xFFE08A6A),
      progressStart: Color(0xFF5A3020),
      progressEnd: Color(0xFFB86848),
    ),
    'software': CategoryTone(
      orbBackground: Color(0xFF101828),
      icon: Color(0xFF7A9AD4),
      progressStart: Color(0xFF2A4068),
      progressEnd: Color(0xFF5578BF),
    ),
    'servicios': CategoryTone(
      orbBackground: Color(0xFF1A1020),
      icon: Color(0xFFC07AD4),
      progressStart: Color(0xFF4A2860),
      progressEnd: Color(0xFF8A58B0),
    ),
    'ocio': CategoryTone(
      orbBackground: Color(0xFF221408),
      icon: Color(0xFFE0A060),
      progressStart: Color(0xFF5A3818),
      progressEnd: Color(0xFFC88840),
    ),
    'material': CategoryTone(
      orbBackground: Color(0xFF1C1810),
      icon: Color(0xFFD4C4A0),
      progressStart: Color(0xFF4A4030),
      progressEnd: Color(0xFFA09070),
    ),
    'transporte': CategoryTone(
      orbBackground: Color(0xFF0C1A22),
      icon: Color(0xFF5EB0C8),
      progressStart: Color(0xFF204858),
      progressEnd: Color(0xFF4A98B0),
    ),
    'vivienda': CategoryTone(
      orbBackground: Color(0xFF1E1014),
      icon: Color(0xFFE07890),
      progressStart: Color(0xFF582838),
      progressEnd: Color(0xFFB05068),
    ),
    'espacio': CategoryTone(
      orbBackground: Color(0xFF101820),
      icon: Color(0xFF6898C8),
      progressStart: Color(0xFF283848),
      progressEnd: Color(0xFF4E7090),
    ),
    'salud': CategoryTone(
      orbBackground: Color(0xFF221018),
      icon: Color(0xFFE07088),
      progressStart: Color(0xFF523038),
      progressEnd: Color(0xFFB04860),
    ),
    'impuestos': CategoryTone(
      orbBackground: Color(0xFF1C1408),
      icon: Color(0xFFD4A050),
      progressStart: Color(0xFF4A3C18),
      progressEnd: Color(0xFFA08038),
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
      orbBackground: Color(0xFF16161C),
      icon: Color(0xFFB0B0BC),
      progressStart: Color(0xFF343440),
      progressEnd: Color(0xFF686878),
    ),
    'general': CategoryTone(
      orbBackground: Color(0xFF18181C),
      icon: Color(0xFFC8C8D0),
      progressStart: Color(0xFF363640),
      progressEnd: Color(0xFF6A6A74),
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

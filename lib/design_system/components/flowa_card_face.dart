import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../tokens/flowa_colors.dart';

/// Face colours available when personalising a card.
enum FlowaCardTint {
  turquoise,
  black,
  white,
  gray,
  softOrange,
  navy,
  softYellow,
  softPurple;

  String get label => switch (this) {
        FlowaCardTint.turquoise => 'Turquesa',
        FlowaCardTint.black => 'Negro',
        FlowaCardTint.white => 'Blanco',
        FlowaCardTint.gray => 'Gris',
        FlowaCardTint.softOrange => 'Naranja',
        FlowaCardTint.navy => 'Azul marino',
        FlowaCardTint.softYellow => 'Amarillo',
        FlowaCardTint.softPurple => 'Morado',
      };

  /// Flat fill — no soft colour bleed.
  Color get fill => switch (this) {
        FlowaCardTint.turquoise => FlowaColors.mint,
        FlowaCardTint.black => const Color(0xFF000000),
        FlowaCardTint.white => const Color(0xFFF4F4F5),
        FlowaCardTint.gray => const Color(0xFF2A2A2E),
        FlowaCardTint.softOrange => const Color(0xFFFFB07A),
        FlowaCardTint.navy => const Color(0xFF0F2744),
        FlowaCardTint.softYellow => const Color(0xFFF5E6A3),
        FlowaCardTint.softPurple => const Color(0xFFB8A4E8),
      };

  /// Optional soft sheen for light cards only (mint/yellow/etc).
  Color? get sheen => switch (this) {
        FlowaCardTint.turquoise => const Color(0xFF3DFFCB),
        FlowaCardTint.softOrange => const Color(0xFFFFC9A0),
        FlowaCardTint.softYellow => const Color(0xFFFFF3C4),
        FlowaCardTint.softPurple => const Color(0xFFD0C2F2),
        FlowaCardTint.white => const Color(0xFFFFFFFF),
        _ => null,
      };

  bool get isLight => switch (this) {
        FlowaCardTint.turquoise ||
        FlowaCardTint.white ||
        FlowaCardTint.softOrange ||
        FlowaCardTint.softYellow ||
        FlowaCardTint.softPurple =>
          true,
        _ => false,
      };

  Color get foreground =>
      isLight ? FlowaColors.mintInk : FlowaColors.bone;

  /// Clean edge so black/navy cards don’t melt into the canvas.
  bool get needsEdge => !isLight;

  Color get edge => switch (this) {
        FlowaCardTint.black => const Color(0xFF3A3A40),
        FlowaCardTint.navy => const Color(0xFF2A3F5C),
        FlowaCardTint.gray => const Color(0xFF4A4A52),
        _ => FlowaColors.hairlineStrong,
      };

  /// Legacy aliases used while older call sites migrate.
  static const FlowaCardTint primary = FlowaCardTint.turquoise;
  static const FlowaCardTint gold = FlowaCardTint.black;
  static const FlowaCardTint green = FlowaCardTint.turquoise;
}

/// Geometric / artistic overlays inspired by Revolut-style faces.
enum FlowaCardPattern {
  none,
  lines,
  dots,
  mesh,
  arcs,
  chevron;

  String get label => switch (this) {
        FlowaCardPattern.none => 'Liso',
        FlowaCardPattern.lines => 'Líneas',
        FlowaCardPattern.dots => 'Puntos',
        FlowaCardPattern.mesh => 'Malla',
        FlowaCardPattern.arcs => 'Arcos',
        FlowaCardPattern.chevron => 'Chevron',
      };
}

/// Paints a Revolut-like geometric overlay on top of a solid card face.
class FlowaCardPatternPainter extends CustomPainter {
  const FlowaCardPatternPainter({
    required this.pattern,
    required this.ink,
  });

  final FlowaCardPattern pattern;
  final Color ink;

  @override
  void paint(Canvas canvas, Size size) {
    if (pattern == FlowaCardPattern.none) {
      return;
    }
    final paint = Paint()
      ..color = ink
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1
      ..isAntiAlias = true;

    switch (pattern) {
      case FlowaCardPattern.none:
        break;
      case FlowaCardPattern.lines:
        const gap = 14.0;
        for (var x = -size.height; x < size.width + size.height; x += gap) {
          canvas.drawLine(
            Offset(x, size.height),
            Offset(x + size.height, 0),
            paint,
          );
        }
      case FlowaCardPattern.dots:
        paint.style = PaintingStyle.fill;
        const step = 16.0;
        for (var y = 10.0; y < size.height; y += step) {
          for (var x = 10.0; x < size.width; x += step) {
            canvas.drawCircle(Offset(x, y), 1.4, paint);
          }
        }
      case FlowaCardPattern.mesh:
        const step = 22.0;
        for (var x = 0.0; x <= size.width; x += step) {
          canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
        }
        for (var y = 0.0; y <= size.height; y += step) {
          canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
        }
      case FlowaCardPattern.arcs:
        paint.style = PaintingStyle.stroke;
        paint.strokeWidth = 1.4;
        for (var i = 1; i <= 6; i++) {
          final r = size.width * 0.18 * i;
          canvas.drawArc(
            Rect.fromCircle(
              center: Offset(size.width * 1.05, size.height * 1.1),
              radius: r,
            ),
            math.pi,
            math.pi / 2,
            false,
            paint,
          );
        }
      case FlowaCardPattern.chevron:
        const step = 18.0;
        for (var y = -size.width; y < size.height + size.width; y += step) {
          final path = Path()
            ..moveTo(0, y)
            ..lineTo(size.width / 2, y + 12)
            ..lineTo(size.width, y);
          canvas.drawPath(path, paint);
        }
    }
  }

  @override
  bool shouldRepaint(covariant FlowaCardPatternPainter oldDelegate) =>
      oldDelegate.pattern != pattern || oldDelegate.ink != ink;
}

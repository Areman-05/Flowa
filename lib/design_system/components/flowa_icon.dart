import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../tokens/flowa_colors.dart';

/// Flowa glyph set — thin geometric outlines (Privat / SF-Symbols feel).
///
/// One stroke weight, round caps, 24×24 box. No filled “AI blob” shapes.
enum FlowaGlyph {
  home,
  chart,
  transfer,
  card,
  person,
  arrowDown,
  arrowUp,
  arrowRight,
  arrowLeft,
  plus,
  bell,
  search,
  receipt,
  vault,
  more,
  eye,
  eyeOff,
  check,
  clock,
  lock,
  logout,
  settings,
  spark,
  pin,
}

class FlowaIcon extends StatelessWidget {
  const FlowaIcon(
    this.glyph, {
    super.key,
    this.size = 26,
    this.color = FlowaColors.bone,
    this.strokeWidth,
  });

  final FlowaGlyph glyph;
  final double size;
  final Color color;
  final double? strokeWidth;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _GlyphPainter(
          glyph: glyph,
          color: color,
          strokeWidth: strokeWidth ?? size * 0.072,
        ),
      ),
    );
  }
}

class _GlyphPainter extends CustomPainter {
  const _GlyphPainter({
    required this.glyph,
    required this.color,
    required this.strokeWidth,
  });

  final FlowaGlyph glyph;
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 24;
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;

    final fill = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    Offset o(double x, double y) => Offset(x * s, y * s);

    void line(double x1, double y1, double x2, double y2) =>
        canvas.drawLine(o(x1, y1), o(x2, y2), paint);

    void circle(double x, double y, double r, {bool filled = false}) =>
        canvas.drawCircle(o(x, y), r * s, filled ? fill : paint);

    void rrect(double l, double t, double r, double b, double radius) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTRB(l * s, t * s, r * s, b * s),
          Radius.circular(radius * s),
        ),
        paint,
      );
    }

    void poly(List<Offset> pts, {bool close = false}) {
      final path = Path()..moveTo(pts.first.dx, pts.first.dy);
      for (final p in pts.skip(1)) {
        path.lineTo(p.dx, p.dy);
      }
      if (close) {
        path.close();
      }
      canvas.drawPath(path, paint);
    }

    switch (glyph) {
      case FlowaGlyph.home:
        // Simple house — roof + open base (no door fill).
        poly([o(4, 11), o(12, 4), o(20, 11)]);
        poly([o(6.5, 10.5), o(6.5, 20), o(17.5, 20), o(17.5, 10.5)]);
        rrect(10, 14.5, 14, 20, 1.2);

      case FlowaGlyph.chart:
        // Rising polyline — cleaner than thick bars.
        poly([o(4, 17), o(9, 12), o(13, 14.5), o(20, 6.5)]);
        line(4, 20, 20, 20);

      case FlowaGlyph.transfer:
        // Two opposing chevrons (send / receive).
        poly([o(8, 7), o(12, 3.5), o(16, 7)]);
        line(12, 3.5, 12, 11);
        poly([o(8, 17), o(12, 20.5), o(16, 17)]);
        line(12, 13, 12, 20.5);

      case FlowaGlyph.card:
        rrect(3.5, 6.5, 20.5, 17.5, 2.8);
        line(3.5, 10.5, 20.5, 10.5);
        line(7, 14.2, 11.5, 14.2);

      case FlowaGlyph.person:
        circle(12, 8, 3.4);
        canvas.drawArc(
          Rect.fromCenter(center: o(12, 20.5), width: 13 * s, height: 10 * s),
          math.pi,
          math.pi,
          false,
          paint,
        );

      case FlowaGlyph.arrowDown:
        line(12, 5, 12, 18.5);
        poly([o(7.5, 14), o(12, 18.5), o(16.5, 14)]);

      case FlowaGlyph.arrowUp:
        line(12, 19, 12, 5.5);
        poly([o(7.5, 10), o(12, 5.5), o(16.5, 10)]);

      case FlowaGlyph.arrowRight:
        line(5, 12, 18.5, 12);
        poly([o(14, 7.5), o(18.5, 12), o(14, 16.5)]);

      case FlowaGlyph.arrowLeft:
        line(19, 12, 5.5, 12);
        poly([o(10, 7.5), o(5.5, 12), o(10, 16.5)]);

      case FlowaGlyph.plus:
        line(12, 6, 12, 18);
        line(6, 12, 18, 12);

      case FlowaGlyph.bell:
        // Classic alert bell — dome + base + clapper.
        final bell = Path()
          ..moveTo(o(7, 15).dx, o(7, 15).dy)
          ..cubicTo(
            o(7, 9).dx,
            o(7, 9).dy,
            o(9, 5.5).dx,
            o(9, 5.5).dy,
            o(12, 5.5).dx,
            o(12, 5.5).dy,
          )
          ..cubicTo(
            o(15, 5.5).dx,
            o(15, 5.5).dy,
            o(17, 9).dx,
            o(17, 9).dy,
            o(17, 15).dx,
            o(17, 15).dy,
          );
        canvas.drawPath(bell, paint);
        line(5.5, 15.5, 18.5, 15.5);
        canvas.drawArc(
          Rect.fromCenter(center: o(12, 15.5), width: 4.5 * s, height: 3.5 * s),
          0,
          math.pi,
          false,
          paint,
        );

      case FlowaGlyph.search:
        // Loupe — thinner ring, longer handle.
        circle(10, 10, 5.8);
        line(14.3, 14.3, 20, 20);

      case FlowaGlyph.receipt:
        // Clean document, not serrated ticket.
        rrect(6, 3.5, 18, 20.5, 2.2);
        line(9, 9, 15, 9);
        line(9, 12.5, 15, 12.5);
        line(9, 16, 13, 16);

      case FlowaGlyph.vault:
        // Piggy bank / hucha.
        final body = Path()
          ..addOval(
            Rect.fromCenter(
              center: o(11.5, 13),
              width: 14 * s,
              height: 11 * s,
            ),
          );
        canvas.drawPath(body, paint);
        // Ear
        canvas.drawOval(
          Rect.fromCenter(center: o(16.5, 7.5), width: 4.5 * s, height: 4 * s),
          paint,
        );
        // Snout
        rrect(16, 12, 21, 16, 1.6);
        // Legs
        line(7, 18.5, 7, 20.5);
        line(14, 18.5, 14, 20.5);
        // Coin slot
        line(9, 9.5, 13.5, 9.5);

      case FlowaGlyph.more:
        circle(6, 12, 1.15, filled: true);
        circle(12, 12, 1.15, filled: true);
        circle(18, 12, 1.15, filled: true);

      case FlowaGlyph.eye:
        poly([
          o(3, 12),
          o(7.5, 7.5),
          o(12, 6.5),
          o(16.5, 7.5),
          o(21, 12),
          o(16.5, 16.5),
          o(12, 17.5),
          o(7.5, 16.5),
        ], close: true);
        circle(12, 12, 2.6);

      case FlowaGlyph.eyeOff:
        poly([o(4, 9), o(8, 14), o(12, 15.5), o(16, 14), o(20, 9)]);
        line(5, 18, 19, 6);

      case FlowaGlyph.check:
        poly([o(5.5, 12.5), o(10, 17), o(18.5, 7.5)]);

      case FlowaGlyph.clock:
        circle(12, 12, 7.5);
        poly([o(12, 7.5), o(12, 12), o(15.5, 14)]);

      case FlowaGlyph.lock:
        rrect(6, 11, 18, 20, 2.4);
        poly([o(8.5, 11), o(8.5, 8), o(12, 5.5), o(15.5, 8), o(15.5, 11)]);

      case FlowaGlyph.logout:
        rrect(4.5, 5, 13.5, 19, 2.2);
        line(11, 12, 19.5, 12);
        poly([o(16, 8.5), o(19.5, 12), o(16, 15.5)]);

      case FlowaGlyph.settings:
        circle(12, 12, 2.8);
        for (var i = 0; i < 6; i++) {
          final a = (i * 60) * math.pi / 180;
          final x1 = 12 + math.cos(a) * 5.2;
          final y1 = 12 + math.sin(a) * 5.2;
          final x2 = 12 + math.cos(a) * 8.2;
          final y2 = 12 + math.sin(a) * 8.2;
          line(x1, y1, x2, y2);
        }

      case FlowaGlyph.spark:
        // Soft 4-point spark (AI) — not a heavy star blob.
        poly([
          o(12, 3.5),
          o(13.4, 10.6),
          o(20.5, 12),
          o(13.4, 13.4),
          o(12, 20.5),
          o(10.6, 13.4),
          o(3.5, 12),
          o(10.6, 10.6),
        ], close: true);

      case FlowaGlyph.pin:
        // Four PIN dots.
        circle(6.5, 12, 1.6);
        circle(10.5, 12, 1.6);
        circle(14.5, 12, 1.6);
        circle(18.5, 12, 1.6);
    }
  }

  @override
  bool shouldRepaint(covariant _GlyphPainter old) =>
      old.glyph != glyph ||
      old.color != color ||
      old.strokeWidth != strokeWidth;
}

class FlowaIconOrb extends StatelessWidget {
  const FlowaIconOrb({
    required this.glyph,
    super.key,
    this.size = 48,
    this.background = FlowaColors.inkSurface,
    this.foreground = FlowaColors.bone,
    this.borderColor,
  });

  final FlowaGlyph glyph;
  final double size;
  final Color background;
  final Color foreground;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background,
        shape: BoxShape.circle,
        border: borderColor == null ? null : Border.all(color: borderColor!),
      ),
      alignment: Alignment.center,
      child: FlowaIcon(glyph, size: size * 0.5, color: foreground),
    );
  }
}

class FlowaIconRotated extends StatelessWidget {
  const FlowaIconRotated({
    required this.glyph,
    required this.turns,
    super.key,
    this.size = 22,
    this.color = FlowaColors.bone,
  });

  final FlowaGlyph glyph;
  final double turns;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: turns * 2 * math.pi,
      child: FlowaIcon(glyph, size: size, color: color),
    );
  }
}

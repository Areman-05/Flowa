import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../tokens/flowa_colors.dart';

/// The Flowa icon set.
///
/// Drawn rather than imported. Material's icons carry their own personality —
/// varying optical weights, filled counters, a specific corner treatment — and
/// dropping them into a considered layout is the fastest way to make it look
/// unfinished.
///
/// Every glyph here obeys the same three rules: a single uniform stroke, round
/// caps and joins, and a 24×24 design box. That consistency is most of what
/// makes an icon set read as designed instead of collected.
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
}

class FlowaIcon extends StatelessWidget {
  const FlowaIcon(
    this.glyph, {
    super.key,
    this.size = 22,
    this.color = FlowaColors.bone,
    this.strokeWidth,
  });

  final FlowaGlyph glyph;
  final double size;
  final Color color;

  /// Defaults to a stroke that scales with the glyph, so a 16px icon does not
  /// look like a fattened version of the 28px one.
  final double? strokeWidth;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: CustomPaint(
        painter: _GlyphPainter(
          glyph: glyph,
          color: color,
          strokeWidth: strokeWidth ?? size * 0.085,
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
    // Everything below is authored on a 24×24 grid and scaled to fit, which
    // keeps proportions identical at every size we render at.
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

    Offset p(double x, double y) => Offset(x * s, y * s);

    void line(double x1, double y1, double x2, double y2) =>
        canvas.drawLine(p(x1, y1), p(x2, y2), paint);

    void path(List<Offset> points, {bool close = false}) {
      final route = Path()..moveTo(points.first.dx, points.first.dy);
      for (final point in points.skip(1)) {
        route.lineTo(point.dx, point.dy);
      }
      if (close) {
        route.close();
      }
      canvas.drawPath(route, paint);
    }

    void roundRect(double l, double t, double r, double b, double radius) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTRB(l * s, t * s, r * s, b * s),
          Radius.circular(radius * s),
        ),
        paint,
      );
    }

    switch (glyph) {
      case FlowaGlyph.home:
        path([p(3.5, 10), p(12, 3.5), p(20.5, 10), p(20.5, 20), p(3.5, 20)],
            close: true);
        line(9.5, 20, 9.5, 14.5);
        line(14.5, 20, 14.5, 14.5);
        line(9.5, 14.5, 14.5, 14.5);

      case FlowaGlyph.chart:
        line(4, 20, 20, 20);
        line(7.5, 20, 7.5, 12);
        line(12, 20, 12, 6.5);
        line(16.5, 20, 16.5, 15);

      case FlowaGlyph.transfer:
        path([p(7, 4.5), p(7, 19)]);
        path([p(3.5, 8), p(7, 4.5), p(10.5, 8)]);
        path([p(17, 19.5), p(17, 5)]);
        path([p(13.5, 16), p(17, 19.5), p(20.5, 16)]);

      case FlowaGlyph.card:
        roundRect(3, 5.5, 21, 18.5, 3.5);
        line(3, 10, 21, 10);
        line(7, 14.5, 11, 14.5);

      case FlowaGlyph.person:
        canvas.drawCircle(p(12, 8.5), 4 * s, paint);
        path([p(4.5, 20), p(4.5, 18.5), p(12, 14.5), p(19.5, 18.5), p(19.5, 20)]);

      case FlowaGlyph.arrowDown:
        line(12, 4.5, 12, 19);
        path([p(6.5, 13.5), p(12, 19), p(17.5, 13.5)]);

      case FlowaGlyph.arrowUp:
        line(12, 19.5, 12, 5);
        path([p(6.5, 10.5), p(12, 5), p(17.5, 10.5)]);

      case FlowaGlyph.arrowRight:
        line(4.5, 12, 19, 12);
        path([p(13.5, 6.5), p(19, 12), p(13.5, 17.5)]);

      case FlowaGlyph.arrowLeft:
        line(19.5, 12, 5, 12);
        path([p(10.5, 6.5), p(5, 12), p(10.5, 17.5)]);

      case FlowaGlyph.plus:
        line(12, 5, 12, 19);
        line(5, 12, 19, 12);

      case FlowaGlyph.bell:
        path([
          p(6, 17),
          p(6, 10.5),
          p(12, 4.5),
          p(18, 10.5),
          p(18, 17),
        ]);
        line(4, 17, 20, 17);
        path([p(10, 19.5), p(12, 21), p(14, 19.5)]);

      case FlowaGlyph.search:
        canvas.drawCircle(p(10.5, 10.5), 6 * s, paint);
        line(15, 15, 20, 20);

      case FlowaGlyph.receipt:
        path([
          p(5, 21),
          p(5, 3),
          p(19, 3),
          p(19, 21),
          p(16, 19),
          p(13.5, 21),
          p(10.5, 19),
          p(8, 21),
        ], close: true);
        line(9, 8.5, 15, 8.5);
        line(9, 13, 13, 13);

      case FlowaGlyph.vault:
        roundRect(3.5, 4.5, 20.5, 19.5, 3.5);
        canvas.drawCircle(p(12, 12), 4 * s, paint);
        line(12, 4.5, 12, 8);

      case FlowaGlyph.more:
        canvas.drawCircle(p(5.5, 12), strokeWidth * 0.85, fill);
        canvas.drawCircle(p(12, 12), strokeWidth * 0.85, fill);
        canvas.drawCircle(p(18.5, 12), strokeWidth * 0.85, fill);

      case FlowaGlyph.eye:
        path([
          p(2.5, 12),
          p(6, 7.5),
          p(12, 6),
          p(18, 7.5),
          p(21.5, 12),
          p(18, 16.5),
          p(12, 18),
          p(6, 16.5),
        ], close: true);
        canvas.drawCircle(p(12, 12), 3 * s, paint);

      case FlowaGlyph.eyeOff:
        path([p(3.5, 9.5), p(7, 14), p(12, 15.5), p(17, 14), p(20.5, 9.5)]);
        line(12, 15.5, 12, 19.5);
        line(6, 14.5, 3.5, 18);
        line(18, 14.5, 20.5, 18);

      case FlowaGlyph.check:
        path([p(5, 12.5), p(10, 17.5), p(19, 7)]);

      case FlowaGlyph.clock:
        canvas.drawCircle(p(12, 12), 8 * s, paint);
        path([p(12, 7), p(12, 12), p(15.5, 14)]);

      case FlowaGlyph.lock:
        roundRect(4.5, 10.5, 19.5, 20.5, 3);
        path([p(8, 10.5), p(8, 7.5), p(12, 4), p(16, 7.5), p(16, 10.5)]);

      case FlowaGlyph.logout:
        path([p(14, 4.5), p(5, 4.5), p(5, 19.5), p(14, 19.5)]);
        line(10, 12, 20, 12);
        path([p(16.5, 8.5), p(20, 12), p(16.5, 15.5)]);

      case FlowaGlyph.settings:
        canvas.drawCircle(p(12, 12), 3.2 * s, paint);
        canvas.drawCircle(p(12, 12), 8 * s, paint);
        line(12, 2.8, 12, 5.4);
        line(12, 18.6, 12, 21.2);
        line(2.8, 12, 5.4, 12);
        line(18.6, 12, 21.2, 12);

      case FlowaGlyph.spark:
        path([
          p(12, 2.5),
          p(14.2, 9.8),
          p(21.5, 12),
          p(14.2, 14.2),
          p(12, 21.5),
          p(9.8, 14.2),
          p(2.5, 12),
          p(9.8, 9.8),
        ], close: true);
    }
  }

  @override
  bool shouldRepaint(covariant _GlyphPainter old) =>
      old.glyph != glyph ||
      old.color != color ||
      old.strokeWidth != strokeWidth;
}

/// Circular container for a glyph, as used for transaction categories and
/// avatars in the reference.
class FlowaIconOrb extends StatelessWidget {
  const FlowaIconOrb({
    required this.glyph,
    super.key,
    this.size = 44,
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
      child: FlowaIcon(glyph, size: size * 0.48, color: foreground),
    );
  }
}

/// Rotates a glyph, used for the diagonal in/out arrows on transaction rows.
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

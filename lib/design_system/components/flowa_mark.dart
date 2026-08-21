import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../tokens/flowa_colors.dart';

/// Brand mark: crescent moon + soft orbit — LUNA identity.
class FlowaMark extends StatelessWidget {
  const FlowaMark({
    super.key,
    this.size = 72,
    this.showWordmark = true,
    this.wordmarkSize = 36,
  });

  final double size;
  final bool showWordmark;
  final double wordmarkSize;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _LunaGlyph(size: size),
        if (showWordmark) ...[
          SizedBox(height: size * 0.22),
          Text(
            'Flowa',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontSize: wordmarkSize,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -1.4,
                  height: 1,
                  color: FlowaColors.textPrimary,
                ),
          ),
        ],
      ],
    );
  }
}

class _LunaGlyph extends StatefulWidget {
  const _LunaGlyph({required this.size});

  final double size;

  @override
  State<_LunaGlyph> createState() => _LunaGlyphState();
}

class _LunaGlyphState extends State<_LunaGlyph>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final glow = 0.35 + (_controller.value * 0.25);
        return Container(
          width: widget.size,
          height: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: FlowaColors.fuchsia.withValues(alpha: glow * 0.35),
                blurRadius: 28,
                spreadRadius: 2,
              ),
            ],
          ),
          child: child,
        );
      },
      child: CustomPaint(
        size: Size.square(widget.size),
        painter: const _LunaMarkPainter(),
      ),
    );
  }
}

class _LunaMarkPainter extends CustomPainter {
  const _LunaMarkPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final center = rect.center;
    final radius = size.shortestSide / 2;

    final disc = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          FlowaColors.primaryDark,
          FlowaColors.primary,
          FlowaColors.fuchsia,
        ],
      ).createShader(rect);

    final moon = Path()
      ..addOval(Rect.fromCircle(center: center, radius: radius));
    final cut = Path()
      ..addOval(
        Rect.fromCircle(
          center: center.translate(radius * 0.42, -radius * 0.06),
          radius: radius * 0.82,
        ),
      );
    final crescent = Path.combine(PathOperation.difference, moon, cut);
    canvas.drawPath(crescent, disc);

    final highlight = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.55, -0.35),
        radius: 0.9,
        colors: [
          Colors.white.withValues(alpha: 0.4),
          Colors.white.withValues(alpha: 0),
        ],
      ).createShader(rect);
    canvas.drawPath(crescent, highlight);

    final arcPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.shortestSide * 0.05
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius * 0.7),
      -math.pi * 0.2,
      math.pi * 1.1,
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

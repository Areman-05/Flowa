import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../tokens/flowa_colors.dart';

/// Brand mark: continuous flow loop + optional wordmark.
class FlowaMark extends StatelessWidget {
  const FlowaMark({
    super.key,
    this.size = 72,
    this.showWordmark = true,
    this.wordmarkSize = 36,
    this.animated = true,
  });

  final double size;
  final bool showWordmark;
  final double wordmarkSize;
  final bool animated;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FlowaFlowGlyph(size: size, animated: animated),
        if (showWordmark) ...[
          SizedBox(height: size * 0.22),
          Text(
            'Flowa',
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  fontSize: wordmarkSize,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -1.2,
                  height: 1,
                  color: FlowaColors.textPrimary,
                ),
          ),
        ],
      ],
    );
  }
}

/// Open triangular flow mark — flat Radient orange, no glow.
class FlowaFlowGlyph extends StatefulWidget {
  const FlowaFlowGlyph({
    required this.size,
    super.key,
    this.animated = true,
    this.progress,
  });

  final double size;
  final bool animated;
  final double? progress;

  @override
  State<FlowaFlowGlyph> createState() => _FlowaFlowGlyphState();
}

class _FlowaFlowGlyphState extends State<FlowaFlowGlyph>
    with SingleTickerProviderStateMixin {
  late final AnimationController _breath;

  @override
  void initState() {
    super.initState();
    _breath = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4200),
    );
    _syncMotion(widget.animated);
  }

  @override
  void didUpdateWidget(covariant FlowaFlowGlyph oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.animated != widget.animated) {
      _syncMotion(widget.animated);
    }
  }

  void _syncMotion(bool animated) {
    if (animated && !_isWidgetTest) {
      if (!_breath.isAnimating) {
        _breath.repeat(reverse: true);
      }
    } else {
      _breath
        ..stop()
        ..value = 0.35;
    }
  }

  bool get _isWidgetTest {
    return WidgetsBinding.instance.runtimeType
        .toString()
        .contains('TestWidgetsFlutterBinding');
  }

  @override
  void dispose() {
    _breath.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final draw = widget.progress ?? 1.0;

    return AnimatedBuilder(
      animation: _breath,
      builder: (context, child) {
        // Barely-there breathe — no glow, no shadow halo.
        final t = Curves.easeInOut.transform(_breath.value);
        final scale = 1 + (t * 0.008);

        return Transform.scale(
          scale: scale,
          child: CustomPaint(
            size: Size.square(widget.size),
            painter: _FlowRibbonPainter(progress: draw),
          ),
        );
      },
    );
  }
}

/// Three open ribbons — flat Radient orange, same tone on every blade.
class _FlowRibbonPainter extends CustomPainter {
  const _FlowRibbonPainter({required this.progress});

  final double progress;

  static final _fill = Paint()
    ..color = FlowaColors.primary
    ..isAntiAlias = true;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    final c = Offset(size.width / 2, size.height / 2);
    final p = progress.clamp(0.0, 1.0);
    if (p <= 0) {
      return;
    }

    for (var i = 0; i < 3; i++) {
      final reveal = ((p * 3) - i).clamp(0.0, 1.0);
      if (reveal <= 0.02) {
        continue;
      }

      canvas.save();
      canvas.translate(c.dx, c.dy);
      canvas.rotate(-math.pi / 2 + i * 2 * math.pi / 3);
      canvas.translate(0, -s * 0.06);

      final ribbon = _blade(s, reveal);
      canvas.drawPath(ribbon, _fill);

      canvas.restore();
    }
  }

  Path _blade(double s, double reveal) {
    final full = Path();
    final k = s / 100;

    full.moveTo(-6 * k, -36 * k);
    full.cubicTo(
      10 * k,
      -40 * k,
      28 * k,
      -28 * k,
      32 * k,
      -8 * k,
    );
    full.cubicTo(
      35 * k,
      10 * k,
      26 * k,
      28 * k,
      8 * k,
      36 * k,
    );
    full.cubicTo(
      14 * k,
      24 * k,
      18 * k,
      10 * k,
      16 * k,
      -4 * k,
    );
    full.cubicTo(
      14 * k,
      -16 * k,
      4 * k,
      -26 * k,
      -6 * k,
      -28 * k,
    );
    full.cubicTo(
      -10 * k,
      -30 * k,
      -10 * k,
      -34 * k,
      -6 * k,
      -36 * k,
    );
    full.close();

    if (reveal >= 0.995) {
      return full;
    }

    final metrics = full.computeMetrics(forceClosed: true);
    final m = metrics.isEmpty ? null : metrics.first;
    if (m == null) {
      return full;
    }
    final len = m.length * reveal.clamp(0.08, 1.0);
    final drawn = m.extractPath(0, len);
    return Path()
      ..addPath(drawn, Offset.zero)
      ..close();
  }

  @override
  bool shouldRepaint(covariant _FlowRibbonPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

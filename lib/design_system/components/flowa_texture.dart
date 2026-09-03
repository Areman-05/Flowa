import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../core/utils/flowa_runtime.dart';
import '../tokens/flowa_colors.dart';

/// Photocopy grit.
class FlowaGrain extends StatefulWidget {
  const FlowaGrain({super.key, this.intensity = 0.055});

  final double intensity;

  @override
  State<FlowaGrain> createState() => _FlowaGrainState();
}

class _FlowaGrainState extends State<FlowaGrain> {
  static const int _tile = 160;
  static final Map<int, Future<ui.Image>> _cache = {};

  ui.Image? _noise;

  @override
  void initState() {
    super.initState();
    unawaited(_loadNoise());
  }

  Future<void> _loadNoise() async {
    final key = (widget.intensity * 1000).round();
    final future = _cache.putIfAbsent(key, () => _buildNoise(widget.intensity));
    final image = await future;
    if (mounted) {
      setState(() => _noise = image);
    }
  }

  static Future<ui.Image> _buildNoise(double intensity) {
    final random = math.Random(1312);
    final pixels = Uint8List(_tile * _tile * 4);
    final peak = (intensity * 255).clamp(0, 255).toInt();

    for (var i = 0; i < _tile * _tile; i++) {
      final alpha = (random.nextDouble() * random.nextDouble() * peak).round();
      final scale = alpha / 255;
      final o = i * 4;
      pixels[o] = (0xED * scale).round();
      pixels[o + 1] = (0xE8 * scale).round();
      pixels[o + 2] = (0xDC * scale).round();
      pixels[o + 3] = alpha;
    }

    final completer = Completer<ui.Image>();
    ui.decodeImageFromPixels(
      pixels,
      _tile,
      _tile,
      ui.PixelFormat.rgba8888,
      completer.complete,
    );
    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    final noise = _noise;
    if (noise == null) {
      return const SizedBox.shrink();
    }
    return IgnorePointer(
      child: CustomPaint(painter: _GrainPainter(noise), size: Size.infinite),
    );
  }
}

class _GrainPainter extends CustomPainter {
  const _GrainPainter(this.noise);

  final ui.Image noise;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = ui.ImageShader(
        noise,
        TileMode.repeated,
        TileMode.repeated,
        Matrix4.identity().storage,
      )
      ..filterQuality = FilterQuality.none;
    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(covariant _GrainPainter oldDelegate) =>
      oldDelegate.noise != noise;
}

/// Full-screen top mist — same curve as the original shader (`exp(-3.2y) * 0.52`)
/// but drawn with a multi-stop [LinearGradient] instead of a fragment shader.
///
/// The shader + grain banded and blurred when the emulator window was resized;
/// this stays stable because Flutter paints the gradient in logical pixels.
class FlowaTopMist extends StatelessWidget {
  const FlowaTopMist({super.key});

  static const _strength = 0.52;
  static const _decay = 3.2;
  static const _steps = 20;

  static final LinearGradient _gradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: List.generate(
      _steps + 1,
      (i) {
        final y = i / _steps;
        final alpha = _strength * math.exp(-_decay * y);
        return FlowaColors.mint.withValues(alpha: alpha.clamp(0.0, 1.0));
      },
    ),
    stops: List.generate(_steps + 1, (i) => i / _steps),
  );

  @override
  Widget build(BuildContext context) {
    if (FlowaRuntime.isWidgetTest) {
      return const _MistTestFallback();
    }

    return RepaintBoundary(
      child: DecoratedBox(
        decoration: BoxDecoration(gradient: FlowaTopMist._gradient),
      ),
    );
  }
}

/// Lightweight fallback for widget tests.
class _MistTestFallback extends StatelessWidget {
  const _MistTestFallback();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(gradient: FlowaTopMist._gradient),
    );
  }
}

/// Flat canvas — soft black by default, optional mist for legacy screens.
class FlowaCanvas extends StatelessWidget {
  const FlowaCanvas({
    required this.child,
    super.key,
    this.grain = false,
    this.mist = false,
    this.color,
  });

  final Widget child;
  final bool grain;
  final bool mist;
  final Color? color;

  static double mistHeightFor(double viewportHeight) => viewportHeight;

  @override
  Widget build(BuildContext context) {
    if (context.findAncestorWidgetOfExactType<FlowaCanvas>() != null) {
      return child;
    }

    return ColoredBox(
      color: color ?? FlowaColors.inkSurface,
      child: Stack(
        clipBehavior: Clip.hardEdge,
        fit: StackFit.expand,
        children: [
          if (mist)
            const Positioned.fill(
              child: IgnorePointer(child: FlowaTopMist()),
            ),
          child,
          if (grain)
            const Positioned.fill(
              child: IgnorePointer(child: FlowaGrain()),
            ),
        ],
      ),
    );
  }
}

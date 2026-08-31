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
      );
    canvas.drawRect(Offset.zero & size, paint);
  }

  @override
  bool shouldRepaint(covariant _GrainPainter oldDelegate) =>
      oldDelegate.noise != noise;
}

/// Top mist — GPU shader: linear turquoise wash + fine grain (no radial).
class FlowaTopMist extends StatefulWidget {
  const FlowaTopMist({super.key});

  @override
  State<FlowaTopMist> createState() => _FlowaTopMistState();
}

class _FlowaTopMistState extends State<FlowaTopMist> {
  static Future<ui.FragmentProgram>? _programFuture;
  ui.FragmentShader? _shader;

  @override
  void initState() {
    super.initState();
    if (FlowaRuntime.isWidgetTest) {
      return;
    }
    _programFuture ??= ui.FragmentProgram.fromAsset('shaders/top_mist.frag');
    unawaited(_loadShader());
  }

  Future<void> _loadShader() async {
    final program = await _programFuture!;
    if (!mounted) {
      return;
    }
    setState(() => _shader = program.fragmentShader());
  }

  @override
  Widget build(BuildContext context) {
    if (FlowaRuntime.isWidgetTest) {
      return const _MistTestFallback();
    }

    final shader = _shader;
    if (shader == null) {
      return const SizedBox.shrink();
    }

    return CustomPaint(
      painter: _MistShaderPainter(shader),
      size: Size.infinite,
    );
  }
}

class _MistShaderPainter extends CustomPainter {
  const _MistShaderPainter(this.shader);

  final ui.FragmentShader shader;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) {
      return;
    }

    shader
      ..setFloat(0, size.width)
      ..setFloat(1, size.height)
      ..setFloat(2, 0.52);

    canvas.drawRect(Offset.zero & size, Paint()..shader = shader);
  }

  @override
  bool shouldRepaint(covariant _MistShaderPainter oldDelegate) => false;
}

/// Lightweight fallback for widget tests (no shader asset).
class _MistTestFallback extends StatelessWidget {
  const _MistTestFallback();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            FlowaColors.mint.withValues(alpha: 0.18),
            FlowaColors.mint.withValues(alpha: 0.0),
          ],
        ),
      ),
    );
  }
}

/// Flat black canvas with optional top mist.
class FlowaCanvas extends StatelessWidget {
  const FlowaCanvas({
    required this.child,
    super.key,
    this.grain = false,
    this.mist = true,
    this.color,
  });

  final Widget child;
  final bool grain;
  final bool mist;
  final Color? color;

  /// Kept for layout helpers; mist now covers the full canvas.
  static double mistHeightFor(double viewportHeight) => viewportHeight;

  @override
  Widget build(BuildContext context) {
    if (context.findAncestorWidgetOfExactType<FlowaCanvas>() != null) {
      return child;
    }

    return Material(
      color: color ?? FlowaColors.ink,
      child: Stack(
        clipBehavior: Clip.none,
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

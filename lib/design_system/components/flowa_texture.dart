import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../tokens/flowa_colors.dart';

/// Photocopy grit.
///
/// Flat black reads as "screen off". The same black with a faint tooth reads
/// as paper. It is static on purpose: animated grain strobes on OLED and, more
/// importantly, a zine is printed once — it does not shimmer.
class FlowaGrain extends StatefulWidget {
  const FlowaGrain({super.key, this.intensity = 0.055});

  /// Peak alpha of a speck, 0–1.
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
      // Squaring a uniform random makes most specks invisible and a few
      // pronounced, which is how real grain is distributed.
      final alpha = (random.nextDouble() * random.nextDouble() * peak).round();

      // rgba8888 is premultiplied. Storing the full bone colour beside a low
      // alpha resolves every speck to opaque white and fogs the whole screen.
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

/// The standard Flowa backdrop: flat black paper with a little tooth.
///
/// There is no bloom, wash or gradient here by design. The previous version
/// carried a tinted radial glow and it read as a half-loaded image rather than
/// as atmosphere.
class FlowaCanvas extends StatelessWidget {
  const FlowaCanvas({
    required this.child,
    super.key,
    this.grain = true,
    this.color,
  });

  final Widget child;
  final bool grain;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    if (context.findAncestorWidgetOfExactType<FlowaCanvas>() != null) {
      return child;
    }
    return Material(
      color: color ?? FlowaColors.ink,
      child: Stack(
        fit: StackFit.expand,
        children: [
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

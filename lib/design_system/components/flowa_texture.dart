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

/// Soft teal dust at the top — blurred cloud, not a hard semicircle.
class FlowaTopMist extends StatelessWidget {
  const FlowaTopMist({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Soft blurred cloud — depth comes from blur, not a sharp radial edge.
          ImageFiltered(
            imageFilter: ui.ImageFilter.blur(sigmaX: 48, sigmaY: 56),
            child: Align(
              alignment: Alignment.topCenter,
              child: Container(
                height: 140,
                margin: const EdgeInsets.symmetric(horizontal: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(90),
                  gradient: RadialGradient(
                    center: const Alignment(0, -0.2),
                    radius: 0.95,
                    colors: [
                      const Color(0xFF1F6B5C).withValues(alpha: 0.55),
                      const Color(0xFF0E3D34).withValues(alpha: 0.28),
                      const Color(0x00000000),
                    ],
                    stops: const [0, 0.55, 1],
                  ),
                ),
              ),
            ),
          ),
          // Feathered linear falloff so it dissolves into black.
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF123D36).withValues(alpha: 0.42),
                  const Color(0xFF0A2823).withValues(alpha: 0.16),
                  const Color(0x00000000),
                ],
                stops: const [0, 0.38, 1],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// The standard Flowa backdrop: flat black with optional top mist.
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

  @override
  Widget build(BuildContext context) {
    if (context.findAncestorWidgetOfExactType<FlowaCanvas>() != null) {
      return child;
    }

    final layers = <Widget>[
      if (mist)
        const Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 260,
          child: FlowaTopMist(),
        ),
      child,
      if (grain)
        const Positioned.fill(
          child: IgnorePointer(child: FlowaGrain()),
        ),
    ];

    if (layers.length == 1) {
      return Material(color: color ?? FlowaColors.ink, child: child);
    }

    return Material(
      color: color ?? FlowaColors.ink,
      child: Stack(fit: StackFit.expand, children: layers),
    );
  }
}

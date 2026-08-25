import 'package:flutter/material.dart';

import '../tokens/flowa_colors.dart';

/// Dark Radient backdrop — drifting orange embers behind auth + splash.
class FlowaAtmosphere extends StatefulWidget {
  const FlowaAtmosphere({super.key, this.animated = true});

  final bool animated;

  @override
  State<FlowaAtmosphere> createState() => _FlowaAtmosphereState();
}

class _FlowaAtmosphereState extends State<FlowaAtmosphere>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 9000),
    );
    if (widget.animated && !_isWidgetTest) {
      _controller.repeat(reverse: true);
    } else {
      _controller.value = 0.35;
    }
  }

  bool get _isWidgetTest {
    return WidgetsBinding.instance.runtimeType
        .toString()
        .contains('TestWidgetsFlutterBinding');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: FlowaColors.softBackdrop),
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final t = widget.animated ? _controller.value : 0.35;
          return Stack(
            children: [
              Positioned(
                top: -80 + (t * 20),
                left: -40,
                right: -40,
                height: 320,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: Alignment.topCenter,
                      radius: 0.85,
                      colors: [
                        FlowaColors.primary.withValues(alpha: 0.28 + t * 0.08),
                        Colors.transparent,
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 120 - (t * 18),
                right: -90 + (t * 24),
                child: _Orb(
                  diameter: 260,
                  color: FlowaColors.primary.withValues(alpha: 0.14),
                ),
              ),
              Positioned(
                bottom: 80 + (t * 30),
                left: -100 + (t * 16),
                child: _Orb(
                  diameter: 220,
                  color: FlowaColors.ember.withValues(alpha: 0.1),
                ),
              ),
              Positioned(
                bottom: 220 - (t * 12),
                right: 20,
                child: _Orb(
                  diameter: 120,
                  color: FlowaColors.accent.withValues(alpha: 0.08),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Orb extends StatelessWidget {
  const _Orb({required this.diameter, required this.color});

  final double diameter;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: diameter,
        height: diameter,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color, color.withValues(alpha: 0)],
          ),
        ),
      ),
    );
  }
}

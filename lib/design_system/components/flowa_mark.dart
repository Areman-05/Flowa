import 'package:flutter/material.dart';

import '../../core/utils/flowa_runtime.dart';
import '../tokens/flowa_colors.dart';
import '../tokens/flowa_motion_tokens.dart';

/// Rounded mint tile with a geometric cut — Vare's mark language, Flowa's name.
class FlowaFlowGlyph extends StatefulWidget {
  const FlowaFlowGlyph({
    required this.size,
    super.key,
    this.animated = true,
    this.progress,
    this.monochrome = false,
  });

  final double size;
  final bool animated;
  final double? progress;
  final bool monochrome;

  @override
  State<FlowaFlowGlyph> createState() => _FlowaFlowGlyphState();
}

class _FlowaFlowGlyphState extends State<FlowaFlowGlyph>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entrance;

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: FlowaMotion.cinematic,
    );
    if (widget.progress == null) {
      if (FlowaRuntime.isWidgetTest) {
        _entrance.value = 1;
      } else {
        _entrance.forward();
      }
    }
  }

  @override
  void dispose() {
    _entrance.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _entrance,
      builder: (context, _) {
        final value = widget.progress ?? _entrance.value;
        return Opacity(
          opacity: value.clamp(0, 1),
          child: Transform.scale(
            scale: 0.86 + (0.14 * value.clamp(0, 1)),
            child: _Mark(
              size: widget.size,
              monochrome: widget.monochrome,
            ),
          ),
        );
      },
    );
  }
}

class _Mark extends StatelessWidget {
  const _Mark({required this.size, required this.monochrome});

  final double size;
  final bool monochrome;

  @override
  Widget build(BuildContext context) {
    final fill = monochrome ? FlowaColors.mintInk : FlowaColors.mint;
    final cut = monochrome ? FlowaColors.mint : FlowaColors.ink;
    return SizedBox.square(
      dimension: size,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(size * 0.28),
        ),
        child: Center(
          child: SizedBox.square(
            dimension: size * 0.38,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: cut,
                borderRadius: BorderRadius.circular(size * 0.1),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

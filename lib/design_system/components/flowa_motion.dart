import 'package:flutter/material.dart';

import '../../core/constants/flowa_constants.dart';
import '../../core/utils/flowa_haptics.dart';
import '../tokens/flowa_colors.dart';
import '../tokens/flowa_spacing.dart';

/// Soft shimmer block used while dashboard data loads.
class FlowaSkeleton extends StatefulWidget {
  const FlowaSkeleton({
    super.key,
    this.height = 16,
    this.width = double.infinity,
    this.borderRadius = FlowaRadii.mdAll,
  });

  final double height;
  final double width;
  final BorderRadius borderRadius;

  @override
  State<FlowaSkeleton> createState() => _FlowaSkeletonState();
}

class _FlowaSkeletonState extends State<FlowaSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat();
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
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius: widget.borderRadius,
            gradient: LinearGradient(
              begin: Alignment(-1 + _controller.value * 2, 0),
              end: Alignment(1 + _controller.value * 2, 0),
              colors: const [
                FlowaColors.surfaceMuted,
                Color(0xFFF8F9FC),
                FlowaColors.surfaceMuted,
              ],
            ),
          ),
        );
      },
    );
  }
}

class FlowaHomeSkeleton extends StatelessWidget {
  const FlowaHomeSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: FlowaSpacing.screenPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FlowaSkeleton(height: 44, width: 180),
          SizedBox(height: FlowaSpacing.lg),
          FlowaSkeleton(height: 180),
          SizedBox(height: FlowaSpacing.xl),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FlowaSkeleton(height: 56, width: 56),
              FlowaSkeleton(height: 56, width: 56),
              FlowaSkeleton(height: 56, width: 56),
              FlowaSkeleton(height: 56, width: 56),
            ],
          ),
        ],
      ),
    );
  }
}

class FlowaListSkeleton extends StatelessWidget {
  const FlowaListSkeleton({super.key, this.itemCount = 4});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < itemCount; i++) ...[
          if (i > 0) const SizedBox(height: FlowaSpacing.sm),
          const FlowaSkeleton(height: 72),
        ],
      ],
    );
  }
}

/// Staggered fade+slide entrance for list items.
class FlowaStaggeredList extends StatelessWidget {
  const FlowaStaggeredList({
    required this.itemCount,
    required this.itemBuilder,
    super.key,
    this.staggerDelay = const Duration(milliseconds: 60),
  });

  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;
  final Duration staggerDelay;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(itemCount, (index) {
        return _StaggeredItem(
          delay: staggerDelay * index,
          child: itemBuilder(context, index),
        );
      }),
    );
  }
}

class _StaggeredItem extends StatefulWidget {
  const _StaggeredItem({required this.delay, required this.child});

  final Duration delay;
  final Widget child;

  @override
  State<_StaggeredItem> createState() => _StaggeredItemState();
}

class _StaggeredItemState extends State<_StaggeredItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: FlowaConstants.defaultAnimationDuration,
    );
    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}

/// Fade + soft rise entrance (auth, sheets, hero blocks).
class FlowaFadeSlide extends StatefulWidget {
  const FlowaFadeSlide({
    required this.child,
    super.key,
    this.delay = Duration.zero,
    this.duration = const Duration(milliseconds: 520),
    this.offset = const Offset(0, 0.06),
  });

  final Widget child;
  final Duration delay;
  final Duration duration;
  final Offset offset;

  @override
  State<FlowaFadeSlide> createState() => _FlowaFadeSlideState();
}

class _FlowaFadeSlideState extends State<FlowaFadeSlide>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic);
    _slide = Tween<Offset>(
      begin: widget.offset,
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    Future<void>.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}

/// Scale-on-press wrapper for quick action tiles.
class FlowaPressable extends StatefulWidget {
  const FlowaPressable({required this.child, required this.onTap, super.key});

  final Widget child;
  final VoidCallback onTap;

  @override
  State<FlowaPressable> createState() => _FlowaPressableState();
}

class _FlowaPressableState extends State<FlowaPressable> {
  double _scale = 1;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        await FlowaHaptics.selection();
        widget.onTap();
      },
      onTapDown: (_) => setState(() => _scale = 0.94),
      onTapCancel: () => setState(() => _scale = 1),
      onTapUp: (_) => setState(() => _scale = 1),
      child: AnimatedScale(
        scale: _scale,
        duration: FlowaConstants.defaultAnimationDuration,
        curve: Curves.easeOutCubic,
        child: widget.child,
      ),
    );
  }
}

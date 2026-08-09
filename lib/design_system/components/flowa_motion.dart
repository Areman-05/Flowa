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

/// Scale-on-press wrapper for quick action tiles.
class FlowaPressable extends StatefulWidget {
  const FlowaPressable({
    required this.child,
    required this.onTap,
    super.key,
  });

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

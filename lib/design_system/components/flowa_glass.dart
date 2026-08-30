import 'dart:ui';

import 'package:flutter/material.dart';

import '../tokens/flowa_colors.dart';
import '../tokens/flowa_spacing.dart';

/// Solid dark sheet surface — no mint halo, no frosted green cast.
class FlowaGlass extends StatelessWidget {
  const FlowaGlass({
    required this.child,
    super.key,
    this.padding,
    this.borderRadius,
    this.blur = 0,
    this.tint,
    this.dark = false,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final BorderRadius? borderRadius;
  final double blur;
  final Color? tint;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? FlowaRadii.xlAll;
    final fill = tint ?? (dark ? FlowaColors.inkHigh : FlowaColors.inkSurface);

    Widget panel = DecoratedBox(
      decoration: BoxDecoration(
        color: fill,
        borderRadius: radius,
        border: Border.all(color: FlowaColors.hairlineStrong),
      ),
      child: Padding(
        padding: padding ?? const EdgeInsets.all(FlowaSpacing.lg),
        child: child,
      ),
    );

    if (blur > 0) {
      panel = ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: panel,
        ),
      );
    } else {
      panel = ClipRRect(borderRadius: radius, child: panel);
    }

    return panel;
  }
}

Future<T?> showFlowaGlassSheet<T>({
  required BuildContext context,
  required WidgetBuilder builder,
  bool isScrollControlled = false,
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.72),
    builder: (context) {
      return Padding(
        padding: const EdgeInsets.fromLTRB(
          FlowaSpacing.md,
          0,
          FlowaSpacing.md,
          FlowaSpacing.md,
        ),
        child: FlowaGlass(
          dark: true,
          borderRadius: const BorderRadius.all(Radius.circular(28)),
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 8),
          child: builder(context),
        ),
      );
    },
  );
}

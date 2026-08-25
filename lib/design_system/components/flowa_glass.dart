import 'dart:ui';

import 'package:flutter/material.dart';

import '../tokens/flowa_colors.dart';
import '../tokens/flowa_spacing.dart';

/// Frosted surface — dark Radient tint for splash/footer; light elsewhere.
class FlowaGlass extends StatelessWidget {
  const FlowaGlass({
    required this.child,
    super.key,
    this.padding,
    this.borderRadius,
    this.blur = 28,
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
    final baseTint = tint ?? (dark ? FlowaColors.surface : Colors.white);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: radius,
        boxShadow: [
          BoxShadow(
            color: FlowaColors.primary.withValues(alpha: dark ? 0.18 : 0.1),
            blurRadius: 32,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: radius,
              border: Border.all(
                color: dark
                    ? FlowaColors.border.withValues(alpha: 0.9)
                    : Colors.white.withValues(alpha: 0.72),
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: dark
                    ? [
                        baseTint.withValues(alpha: 0.92),
                        baseTint.withValues(alpha: 0.78),
                      ]
                    : [
                        baseTint.withValues(alpha: 0.56),
                        baseTint.withValues(alpha: 0.2),
                      ],
              ),
            ),
            child: Padding(
              padding: padding ?? const EdgeInsets.all(FlowaSpacing.lg),
              child: child,
            ),
          ),
        ),
      ),
    );
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
    barrierColor: Colors.black.withValues(alpha: 0.55),
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

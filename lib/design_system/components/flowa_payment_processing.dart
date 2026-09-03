import 'dart:async';

import 'package:flutter/material.dart';

import '../tokens/flowa_colors.dart';
import '../tokens/flowa_motion_tokens.dart';
import '../tokens/flowa_spacing.dart';
import '../tokens/flowa_typography.dart';
import 'flowa_icon.dart';

/// Full-screen payment processing overlay with pulse + spinner.
class FlowaPaymentProcessingOverlay extends StatefulWidget {
  const FlowaPaymentProcessingOverlay({
    required this.label,
    super.key,
    this.subtitle,
  });

  final String label;
  final String? subtitle;

  @override
  State<FlowaPaymentProcessingOverlay> createState() =>
      _FlowaPaymentProcessingOverlayState();
}

class _FlowaPaymentProcessingOverlayState
    extends State<FlowaPaymentProcessingOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _pulse;
  late final AnimationController _enter;
  late final Animation<double> _contentFade;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _enter = AnimationController(
      vsync: this,
      duration: FlowaMotion.quick,
    )..forward();
    _contentFade = CurvedAnimation(parent: _enter, curve: FlowaMotion.expoOut);
  }

  @override
  void dispose() {
    _pulse.dispose();
    _enter.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: FlowaColors.inkSurface,
      child: FadeTransition(
        opacity: _contentFade,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedBuilder(
                animation: _pulse,
                builder: (context, child) {
                  final scale = 1 + (_pulse.value * 0.06);
                  return Transform.scale(scale: scale, child: child);
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 88,
                      height: 88,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: FlowaColors.mint.withValues(alpha: 0.35),
                      ),
                    ),
                    const FlowaIconOrb(
                      glyph: FlowaGlyph.card,
                      size: 56,
                      background: FlowaColors.inkHigh,
                      foreground: FlowaColors.mint,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: FlowaSpacing.xl),
              Text(widget.label, style: FlowaType.titleMd()),
              if (widget.subtitle != null) ...[
                const SizedBox(height: FlowaSpacing.xs),
                Text(
                  widget.subtitle!,
                  style: FlowaType.body(color: FlowaColors.boneMuted),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Shows [FlowaPaymentProcessingOverlay] and resolves when [task] completes.
Future<T> runFlowaPaymentProcessing<T>({
  required BuildContext context,
  required String label,
  required Future<T> Function() task,
  String? subtitle,
  Duration minimumVisible = const Duration(milliseconds: 1200),
}) async {
  final started = DateTime.now();
  final navigator = Navigator.of(context, rootNavigator: true);

  unawaited(
    showGeneralDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: FlowaColors.inkSurface,
      transitionDuration: Duration.zero,
      pageBuilder: (_, _, _) => FlowaPaymentProcessingOverlay(
        label: label,
        subtitle: subtitle,
      ),
    ),
  );

  await Future<void>.delayed(const Duration(milliseconds: 80));

  try {
    final result = await task();
    final elapsed = DateTime.now().difference(started);
    if (elapsed < minimumVisible) {
      await Future<void>.delayed(minimumVisible - elapsed);
    }
    if (navigator.mounted) {
      navigator.pop();
    }
    return result;
  } catch (error) {
    if (navigator.mounted) {
      navigator.pop();
    }
    rethrow;
  }
}

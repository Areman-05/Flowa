import 'package:flutter/material.dart';

import '../../design_system/components/flowa_actions.dart';
import '../../design_system/components/flowa_icon.dart';
import '../../design_system/tokens/flowa_colors.dart';
import '../../design_system/tokens/flowa_spacing.dart';
import '../../design_system/tokens/flowa_typography.dart';

class FlowaEmptyState extends StatelessWidget {
  const FlowaEmptyState({
    required this.title,
    required this.message,
    super.key,
    this.actionLabel,
    this.onAction,
    this.icon = Icons.inbox_outlined,
    this.glyph,
  });

  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;
  final IconData icon;
  final FlowaGlyph? glyph;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: FlowaSpacing.xxl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FlowaIconOrb(
              glyph: glyph ?? FlowaGlyph.more,
              size: 64,
              background: FlowaColors.inkHigh,
              foreground: FlowaColors.mint,
            ),
            const SizedBox(height: FlowaSpacing.lg),
            Text(title, style: FlowaType.titleLg(), textAlign: TextAlign.center),
            const SizedBox(height: FlowaSpacing.xs),
            Text(
              message,
              textAlign: TextAlign.center,
              style: FlowaType.body(),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: FlowaSpacing.xl),
              FlowaAcidButton(
                label: actionLabel!,
                onPressed: onAction,
                expand: false,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class FlowaErrorState extends StatelessWidget {
  const FlowaErrorState({
    required this.message,
    super.key,
    this.onRetry,
  });

  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return FlowaEmptyState(
      title: 'Algo salió mal',
      message: message,
      glyph: FlowaGlyph.more,
      actionLabel: onRetry == null ? null : 'Reintentar',
      onAction: onRetry,
    );
  }
}

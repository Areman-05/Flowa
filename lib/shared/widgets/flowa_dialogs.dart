import 'package:flutter/material.dart';

import '../../design_system/tokens/flowa_colors.dart';
import '../../design_system/tokens/flowa_spacing.dart';
import 'flowa_buttons.dart';

/// Modal used before irreversible money actions (esp. Top-Up vs Send).
Future<bool> showFlowaConfirmationDialog({
  required BuildContext context,
  required String title,
  required String message,
  required String confirmLabel,
  String cancelLabel = 'No, Go Back',
}) async {
  final result = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return Dialog(
        shape: const RoundedRectangleBorder(borderRadius: FlowaRadii.lgAll),
        insetPadding: const EdgeInsets.symmetric(horizontal: FlowaSpacing.xl),
        child: Padding(
          padding: const EdgeInsets.all(FlowaSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: FlowaSpacing.sm),
              Text(message, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: FlowaSpacing.xl),
              FlowaPrimaryButton(
                label: confirmLabel,
                onPressed: () => Navigator.of(context).pop(true),
              ),
              const SizedBox(height: FlowaSpacing.sm),
              FlowaSecondaryButton(
                label: cancelLabel,
                onPressed: () => Navigator.of(context).pop(false),
              ),
            ],
          ),
        ),
      );
    },
  );

  return result ?? false;
}

Future<bool> showFlowaPreviewDialog({
  required BuildContext context,
  required String title,
  required String message,
  required String confirmLabel,
  String cancelLabel = 'Cancel',
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (context) {
      return Dialog(
        shape: const RoundedRectangleBorder(borderRadius: FlowaRadii.lgAll),
        insetPadding: const EdgeInsets.symmetric(horizontal: FlowaSpacing.xl),
        child: Padding(
          padding: const EdgeInsets.all(FlowaSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.headlineMedium),
              const SizedBox(height: FlowaSpacing.sm),
              Text(message, style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: FlowaSpacing.xl),
              FlowaPrimaryButton(
                label: confirmLabel,
                onPressed: () => Navigator.of(context).pop(true),
              ),
              const SizedBox(height: FlowaSpacing.sm),
              FlowaSecondaryButton(
                label: cancelLabel,
                onPressed: () => Navigator.of(context).pop(false),
              ),
            ],
          ),
        ),
      );
    },
  );

  return result ?? false;
}

/// Compact warning banner (e.g. limit exceeded).
class FlowaInlineAlert extends StatelessWidget {
  const FlowaInlineAlert({
    required this.message,
    super.key,
    this.actionLabel,
    this.onAction,
  });

  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(FlowaSpacing.sm),
      decoration: const BoxDecoration(
        color: FlowaColors.warningSoft,
        borderRadius: FlowaRadii.smAll,
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: FlowaColors.warning, size: 18),
          const SizedBox(width: FlowaSpacing.xs),
          Expanded(
            child: Text(
              message,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: FlowaColors.textPrimary),
            ),
          ),
          if (actionLabel != null)
            TextButton(onPressed: onAction, child: Text(actionLabel!)),
        ],
      ),
    );
  }
}

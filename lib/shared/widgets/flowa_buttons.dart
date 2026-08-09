import 'package:flutter/material.dart';

import '../../design_system/components/flowa_motion.dart';
import '../../design_system/tokens/flowa_colors.dart';
import '../../design_system/tokens/flowa_spacing.dart';

/// Primary full-width CTA used across money flows.
class FlowaPrimaryButton extends StatelessWidget {
  const FlowaPrimaryButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: FilledButton(
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(
                  strokeWidth: 2.4,
                  color: FlowaColors.textOnPrimary,
                ),
              )
            : Text(label),
      ),
    );
  }
}

/// Secondary full-width action (e.g. "No, Go Back").
class FlowaSecondaryButton extends StatelessWidget {
  const FlowaSecondaryButton({
    required this.label,
    required this.onPressed,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: FlowaColors.surfaceMuted,
          foregroundColor: FlowaColors.textPrimary,
        ),
        child: Text(label),
      ),
    );
  }
}

/// Soft pastel quick-action tile (Send / Receive / Top-Up / More).
class FlowaQuickAction extends StatelessWidget {
  const FlowaQuickAction({
    required this.label,
    required this.icon,
    required this.background,
    required this.onTap,
    super.key,
  });

  final String label;
  final IconData icon;
  final Color background;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FlowaPressable(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: background,
              borderRadius: FlowaRadii.mdAll,
              boxShadow: FlowaShadows.soft,
            ),
            child: Icon(icon, color: FlowaColors.textPrimary),
          ),
          const SizedBox(height: FlowaSpacing.xs),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: FlowaColors.textPrimary,
                ),
          ),
        ],
      ),
    );
  }
}

/// Lightweight page scaffold with consistent horizontal padding.
class FlowaPage extends StatelessWidget {
  const FlowaPage({
    required this.child,
    super.key,
    this.title,
    this.actions,
    this.floatingActionButton,
  });

  final Widget child;
  final String? title;
  final List<Widget>? actions;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: title == null
          ? null
          : AppBar(
              title: Text(title!),
              actions: actions,
            ),
      floatingActionButton: floatingActionButton,
      body: SafeArea(
        child: Padding(
          padding: FlowaSpacing.screenPadding,
          child: child,
        ),
      ),
    );
  }
}

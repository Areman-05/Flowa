import 'package:flutter/material.dart';

import '../../design_system/components/flowa_actions.dart';

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
    return FlowaAcidButton(
      label: label,
      onPressed: onPressed,
      loading: isLoading,
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
    return FlowaGhostButton(label: label, onPressed: onPressed);
  }
}

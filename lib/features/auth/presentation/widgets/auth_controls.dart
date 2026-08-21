import 'package:flutter/material.dart';

import '../../../../design_system/tokens/flowa_colors.dart';
import '../../../../design_system/tokens/flowa_spacing.dart';

/// Fuchsia gradient CTA for auth screens.
class AuthPrimaryButton extends StatelessWidget {
  const AuthPrimaryButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.loading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !loading;
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: FlowaRadii.mdAll,
          gradient: enabled ? FlowaColors.brandGradient : null,
          color: enabled ? null : FlowaColors.border,
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: FlowaColors.primary.withValues(alpha: 0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ]
              : null,
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: FlowaRadii.mdAll,
            onTap: enabled ? onPressed : null,
            child: Center(
              child: loading
                  ? SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.4,
                        color: FlowaColors.textOnPrimary,
                      ),
                    )
                  : Text(
                      label,
                      style: Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: enabled
                                ? FlowaColors.textOnPrimary
                                : FlowaColors.textTertiary,
                            letterSpacing: 0.2,
                          ),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

InputDecoration authFieldDecoration({
  required String label,
  Widget? prefixIcon,
  Widget? suffixIcon,
  String? errorText,
}) {
  return InputDecoration(
    labelText: label,
    errorText: errorText,
    prefixIcon: prefixIcon,
    suffixIcon: suffixIcon,
    filled: true,
    fillColor: FlowaColors.surface.withValues(alpha: 0.82),
    labelStyle: const TextStyle(color: FlowaColors.textSecondary),
    contentPadding: const EdgeInsets.symmetric(
      horizontal: FlowaSpacing.md,
      vertical: FlowaSpacing.md + 2,
    ),
    border: const OutlineInputBorder(
      borderRadius: FlowaRadii.mdAll,
      borderSide: BorderSide(color: FlowaColors.border),
    ),
    enabledBorder: const OutlineInputBorder(
      borderRadius: FlowaRadii.mdAll,
      borderSide: BorderSide(color: FlowaColors.border),
    ),
    focusedBorder: const OutlineInputBorder(
      borderRadius: FlowaRadii.mdAll,
      borderSide: BorderSide(color: FlowaColors.primary, width: 1.6),
    ),
  );
}

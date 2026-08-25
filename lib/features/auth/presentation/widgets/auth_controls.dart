import 'package:flutter/material.dart';

import '../../../../core/utils/flowa_haptics.dart';
import '../../../../design_system/tokens/flowa_colors.dart';
import '../../../../design_system/tokens/flowa_spacing.dart';

/// Radient orange CTA — solid pill with soft glow.
class AuthPrimaryButton extends StatefulWidget {
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
  State<AuthPrimaryButton> createState() => _AuthPrimaryButtonState();
}

class _AuthPrimaryButtonState extends State<AuthPrimaryButton> {
  double _scale = 1;

  bool get _enabled => widget.onPressed != null && !widget.loading;

  Future<void> _onTap() async {
    if (!_enabled) {
      return;
    }
    await FlowaHaptics.selection();
    widget.onPressed?.call();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _scale,
      duration: const Duration(milliseconds: 140),
      curve: Curves.easeOutCubic,
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(FlowaRadii.pill),
            gradient: _enabled ? FlowaColors.brandGradient : null,
            color: _enabled ? null : FlowaColors.surfaceMuted,
            boxShadow: _enabled
                ? [
                    BoxShadow(
                      color: FlowaColors.primary.withValues(alpha: 0.35),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ]
                : null,
          ),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              borderRadius: BorderRadius.circular(FlowaRadii.pill),
              onTap: _enabled ? _onTap : null,
              onTapDown: _enabled ? (_) => setState(() => _scale = 0.97) : null,
              onTapCancel: () => setState(() => _scale = 1),
              onTapUp: (_) => setState(() => _scale = 1),
              child: Center(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 220),
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  child: widget.loading
                      ? const SizedBox(
                          key: ValueKey('loading'),
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            color: FlowaColors.textOnPrimary,
                          ),
                        )
                      : Text(
                          widget.label,
                          key: ValueKey(widget.label),
                          style:
                              Theme.of(context).textTheme.labelLarge?.copyWith(
                                    color: _enabled
                                        ? FlowaColors.textOnPrimary
                                        : FlowaColors.textTertiary,
                                    letterSpacing: 0.15,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
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
    fillColor: FlowaColors.surfaceMuted,
    labelStyle: const TextStyle(color: FlowaColors.textSecondary),
    floatingLabelStyle: const TextStyle(color: FlowaColors.primary),
    contentPadding: const EdgeInsets.symmetric(
      horizontal: FlowaSpacing.md,
      vertical: FlowaSpacing.md + 2,
    ),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(FlowaRadii.lg),
      borderSide: const BorderSide(color: FlowaColors.border),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(FlowaRadii.lg),
      borderSide: const BorderSide(color: FlowaColors.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(FlowaRadii.lg),
      borderSide: const BorderSide(color: FlowaColors.primary, width: 1.5),
    ),
  );
}

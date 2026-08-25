import 'package:flutter/material.dart';

import '../tokens/flowa_colors.dart';
import '../tokens/flowa_motion_tokens.dart';
import '../tokens/flowa_spacing.dart';
import '../tokens/flowa_typography.dart';

/// Borderless oversized input.
///
/// A boxed Material field makes every form look like every other app. Here the
/// value is set large on the canvas over a single rule that lights up acid on
/// focus, so typing feels like writing rather than filling in a form.
class FlowaBigField extends StatefulWidget {
  const FlowaBigField({
    required this.controller,
    required this.label,
    super.key,
    this.hint,
    this.keyboardType,
    this.obscure = false,
    this.autofocus = false,
    this.textCapitalization = TextCapitalization.none,
    this.textInputAction = TextInputAction.next,
    this.onSubmitted,
    this.onChanged,
    this.error,
    this.trailing,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;
  final TextInputType? keyboardType;
  final bool obscure;
  final bool autofocus;
  final TextCapitalization textCapitalization;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onSubmitted;
  final ValueChanged<String>? onChanged;
  final String? error;
  final Widget? trailing;

  @override
  State<FlowaBigField> createState() => _FlowaBigFieldState();
}

class _FlowaBigFieldState extends State<FlowaBigField> {
  final FocusNode _focus = FocusNode();

  @override
  void initState() {
    super.initState();
    _focus.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _focus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasError = widget.error != null;
    final ruleColor = hasError
        ? FlowaColors.danger
        : _focus.hasFocus
            ? FlowaColors.acid
            : FlowaColors.hairlineStrong;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label.toUpperCase(),
          style: FlowaType.micro(
            color: _focus.hasFocus ? FlowaColors.acid : FlowaColors.boneFaint,
          ),
        ),
        const SizedBox(height: FlowaSpacing.sm),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: widget.controller,
                focusNode: _focus,
                autofocus: widget.autofocus,
                obscureText: widget.obscure,
                keyboardType: widget.keyboardType,
                textCapitalization: widget.textCapitalization,
                textInputAction: widget.textInputAction,
                onSubmitted: widget.onSubmitted,
                onChanged: widget.onChanged,
                cursorColor: FlowaColors.acid,
                cursorRadius: Radius.zero,
                style: FlowaType.titleLg().copyWith(fontSize: 26),
                decoration: InputDecoration(
                  isDense: true,
                  filled: false,
                  contentPadding: const EdgeInsets.only(bottom: 10),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  hintText: widget.hint,
                  hintStyle: FlowaType.titleLg(color: FlowaColors.boneGhost)
                      .copyWith(fontSize: 26),
                ),
              ),
            ),
            if (widget.trailing != null) widget.trailing!,
          ],
        ),
        AnimatedContainer(
          duration: FlowaMotion.quick,
          curve: FlowaMotion.swiftOut,
          height: _focus.hasFocus || hasError ? 2 : 1,
          color: ruleColor,
        ),
        AnimatedSize(
          duration: FlowaMotion.quick,
          curve: FlowaMotion.swiftOut,
          alignment: Alignment.topLeft,
          child: hasError
              ? Padding(
                  padding: const EdgeInsets.only(top: FlowaSpacing.xs),
                  child: Text(
                    widget.error!,
                    style: FlowaType.bodySm(color: FlowaColors.danger),
                  ),
                )
              : const SizedBox(width: double.infinity),
        ),
      ],
    );
  }
}

/// Password strength as four hairline segments plus a one-word verdict.
class FlowaStrengthMeter extends StatelessWidget {
  const FlowaStrengthMeter({required this.score, super.key});

  /// 0–4.
  final int score;

  static int scoreFor(String password) {
    var score = 0;
    if (password.length >= 8) {
      score++;
    }
    if (password.length >= 12) {
      score++;
    }
    if (RegExp(r'[A-Za-z]').hasMatch(password) &&
        RegExp(r'\d').hasMatch(password)) {
      score++;
    }
    if (RegExp(r'[^A-Za-z0-9]').hasMatch(password)) {
      score++;
    }
    return score;
  }

  String get _verdict => switch (score) {
        0 => 'Sin fuerza',
        1 => 'Débil',
        2 => 'Aceptable',
        3 => 'Buena',
        _ => 'Excelente',
      };

  Color get _tone => switch (score) {
        0 || 1 => FlowaColors.danger,
        2 => FlowaColors.warning,
        _ => FlowaColors.acid,
      };

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < 4; i++) ...[
          if (i > 0) const SizedBox(width: 4),
          Expanded(
            child: AnimatedContainer(
              duration: FlowaMotion.quick,
              height: 2,
              color: i < score ? _tone : FlowaColors.hairline,
            ),
          ),
        ],
        const SizedBox(width: FlowaSpacing.sm),
        SizedBox(
          width: 74,
          child: Text(
            _verdict.toUpperCase(),
            textAlign: TextAlign.right,
            style: FlowaType.micro(color: _tone),
          ),
        ),
      ],
    );
  }
}

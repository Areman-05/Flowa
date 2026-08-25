import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../design_system/components/flowa_actions.dart';
import '../../../../design_system/components/flowa_icon.dart';
import '../../../../design_system/components/flowa_primitives.dart';
import '../../../../design_system/components/flowa_texture.dart';
import '../../../../design_system/tokens/flowa_colors.dart';
import '../../../../design_system/tokens/flowa_motion_tokens.dart';
import '../../../../design_system/tokens/flowa_spacing.dart';
import '../../../../design_system/tokens/flowa_typography.dart';

/// Shared frame for every authentication screen.
///
/// One question per screen, asked in the editorial serif, with the answer
/// field sitting directly underneath. Signing up should read like a short
/// conversation, not a form with four boxes stacked on it.
class AuthScaffold extends StatelessWidget {
  const AuthScaffold({
    required this.question,
    required this.child,
    required this.actions,
    super.key,
    this.kicker,
    this.step,
    this.stepCount,
    this.onBack,
    this.footer,
  });

  final String question;
  final Widget child;
  final Widget actions;
  final String? kicker;
  final int? step;
  final int? stepCount;
  final VoidCallback? onBack;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final showProgress = step != null && stepCount != null;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: FlowaColors.ink,
        body: FlowaCanvas(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: FlowaSpacing.gutter,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: FlowaSpacing.sm),
                  SizedBox(
                    height: 44,
                    child: Row(
                      children: [
                        if (onBack != null)
                          FlowaIconAction(
                            glyph: FlowaGlyph.arrowLeft,
                            onTap: onBack,
                            size: 40,
                          ),
                        const Spacer(),
                        if (showProgress)
                          FlowaMicroLabel(
                            '${step! + 1} / $stepCount',
                            color: FlowaColors.boneFaint,
                          ),
                      ],
                    ),
                  ),
                  if (showProgress) ...[
                    const SizedBox(height: FlowaSpacing.sm),
                    _StepRule(step: step!, count: stepCount!),
                  ],
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) => SingleChildScrollView(
                        physics: const ClampingScrollPhysics(),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: constraints.maxHeight,
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (kicker != null) ...[
                                FlowaMicroLabel(kicker!, dot: true),
                                const SizedBox(height: FlowaSpacing.md),
                              ],
                              Text(question, style: FlowaType.editorialLg()),
                              const SizedBox(height: FlowaSpacing.xxl),
                              child,
                              // Bias the block above the optical centre so the
                              // question sits where the eye lands first.
                              SizedBox(height: constraints.maxHeight * 0.18),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  actions,
                  if (footer != null) ...[
                    const SizedBox(height: FlowaSpacing.md),
                    footer!,
                  ],
                  const SizedBox(height: FlowaSpacing.lg),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StepRule extends StatelessWidget {
  const _StepRule({required this.step, required this.count});

  final int step;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < count; i++) ...[
          if (i > 0) const SizedBox(width: 5),
          Expanded(
            child: AnimatedContainer(
              duration: FlowaMotion.base,
              curve: FlowaMotion.swiftOut,
              height: 2,
              color: i <= step ? FlowaColors.acid : FlowaColors.hairline,
            ),
          ),
        ],
      ],
    );
  }
}

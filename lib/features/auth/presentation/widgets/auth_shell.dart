import 'package:flutter/material.dart';

import '../../../../design_system/components/flowa_mark.dart';
import '../../../../design_system/tokens/flowa_colors.dart';
import '../../../../design_system/tokens/flowa_spacing.dart';

/// LUNA auth layout: brand on top, form + actions as one centered cluster.
class AuthShell extends StatelessWidget {
  const AuthShell({
    required this.form,
    required this.actions,
    super.key,
    this.tagline,
    this.showBack = false,
    this.markSize = 96,
  });

  final Widget form;
  final Widget actions;
  final String? tagline;
  final bool showBack;
  final double markSize;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FlowaColors.background,
      resizeToAvoidBottomInset: true,
      body: Stack(
        children: [
          const Positioned.fill(child: _LunaAtmosphere()),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: FlowaSpacing.lg),
              child: Column(
                children: [
                  SizedBox(
                    height: 44,
                    child: showBack
                        ? Align(
                            alignment: Alignment.centerLeft,
                            child: IconButton(
                              onPressed: () =>
                                  Navigator.of(context).maybePop(),
                              icon: const Icon(
                                Icons.arrow_back_ios_new_rounded,
                              ),
                              color: FlowaColors.textPrimary,
                            ),
                          )
                        : null,
                  ),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          physics: const ClampingScrollPhysics(),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: constraints.maxHeight,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: FlowaSpacing.md,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  TweenAnimationBuilder<double>(
                                    tween: Tween(begin: 0, end: 1),
                                    duration: const Duration(milliseconds: 650),
                                    curve: Curves.easeOutCubic,
                                    builder: (context, value, child) {
                                      return Opacity(
                                        opacity: value,
                                        child: Transform.translate(
                                          offset: Offset(0, 14 * (1 - value)),
                                          child: child,
                                        ),
                                      );
                                    },
                                    child: Column(
                                      children: [
                                        FlowaMark(
                                          size: markSize,
                                          wordmarkSize:
                                              markSize > 80 ? 40 : 32,
                                        ),
                                        if (tagline != null) ...[
                                          const SizedBox(
                                            height: FlowaSpacing.md,
                                          ),
                                          Text(
                                            tagline!,
                                            textAlign: TextAlign.center,
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyLarge
                                                ?.copyWith(
                                                  color: FlowaColors
                                                      .textSecondary,
                                                  height: 1.45,
                                                ),
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: FlowaSpacing.xxl + 8),
                                  TweenAnimationBuilder<double>(
                                    tween: Tween(begin: 0, end: 1),
                                    duration: const Duration(milliseconds: 800),
                                    curve: Curves.easeOutCubic,
                                    builder: (context, value, child) {
                                      return Opacity(
                                        opacity: value,
                                        child: Transform.translate(
                                          offset: Offset(0, 18 * (1 - value)),
                                          child: child,
                                        ),
                                      );
                                    },
                                    child: form,
                                  ),
                                  const SizedBox(height: FlowaSpacing.xl),
                                  TweenAnimationBuilder<double>(
                                    tween: Tween(begin: 0, end: 1),
                                    duration: const Duration(milliseconds: 900),
                                    curve: Curves.easeOutCubic,
                                    builder: (context, value, child) {
                                      return Opacity(
                                        opacity: value,
                                        child: Transform.translate(
                                          offset: Offset(0, 12 * (1 - value)),
                                          child: child,
                                        ),
                                      );
                                    },
                                    child: actions,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LunaAtmosphere extends StatelessWidget {
  const _LunaAtmosphere();

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(gradient: FlowaColors.lunaBackdrop),
      child: Stack(
        children: [
          Positioned(
            top: -80,
            right: -60,
            child: _GlowOrb(
              diameter: 280,
              color: FlowaColors.fuchsia.withValues(alpha: 0.2),
            ),
          ),
          Positioned(
            top: 160,
            left: -100,
            child: _GlowOrb(
              diameter: 240,
              color: FlowaColors.primaryDark.withValues(alpha: 0.14),
            ),
          ),
          Positioned(
            bottom: -20,
            right: 20,
            child: _GlowOrb(
              diameter: 200,
              color: FlowaColors.primarySoft.withValues(alpha: 0.95),
            ),
          ),
        ],
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.diameter, required this.color});

  final double diameter;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: diameter,
        height: diameter,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              color,
              color.withValues(alpha: 0),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../design_system/components/flowa_atmosphere.dart';
import '../../../../design_system/components/flowa_mark.dart';
import '../../../../design_system/components/flowa_motion.dart';
import '../../../../design_system/tokens/flowa_colors.dart';
import '../../../../design_system/tokens/flowa_spacing.dart';

/// Radient auth layout — dark canvas, orange hero band, clean form card.
class AuthShell extends StatelessWidget {
  const AuthShell({
    required this.form,
    required this.actions,
    super.key,
    this.tagline,
    this.title,
    this.showBack = false,
    this.markSize = 64,
    this.showWordmark = true,
    this.footer,
  });

  final Widget form;
  final Widget actions;
  final String? tagline;
  final String? title;
  final bool showBack;
  final double markSize;
  final bool showWordmark;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: FlowaColors.background,
        resizeToAvoidBottomInset: true,
        body: Stack(
          children: [
            const Positioned.fill(child: FlowaAtmosphere()),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: FlowaSpacing.xl),
                child: Column(
                  children: [
                    SizedBox(
                      height: 48,
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
                            physics: const BouncingScrollPhysics(
                              parent: AlwaysScrollableScrollPhysics(),
                            ),
                            child: ConstrainedBox(
                              constraints: BoxConstraints(
                                minHeight: constraints.maxHeight,
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  bottom: FlowaSpacing.lg,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    FlowaFadeSlide(
                                      child: Column(
                                        children: [
                                          FlowaMark(
                                            size: markSize,
                                            showWordmark: showWordmark,
                                            wordmarkSize:
                                                markSize > 60 ? 34 : 28,
                                          ),
                                          if (title != null) ...[
                                            const SizedBox(
                                              height: FlowaSpacing.lg,
                                            ),
                                            Text(
                                              title!,
                                              textAlign: TextAlign.center,
                                              style: textTheme.headlineLarge
                                                  ?.copyWith(
                                                letterSpacing: -0.5,
                                                color: FlowaColors.textPrimary,
                                              ),
                                            ),
                                          ],
                                          if (tagline != null) ...[
                                            const SizedBox(
                                              height: FlowaSpacing.sm,
                                            ),
                                            Text(
                                              tagline!,
                                              textAlign: TextAlign.center,
                                              style: textTheme.bodyLarge
                                                  ?.copyWith(
                                                color:
                                                    FlowaColors.textSecondary,
                                                height: 1.5,
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    const SizedBox(height: FlowaSpacing.xxl),
                                    FlowaFadeSlide(
                                      delay: const Duration(milliseconds: 80),
                                      offset: const Offset(0, 0.05),
                                      child: DecoratedBox(
                                        decoration: BoxDecoration(
                                          color: FlowaColors.surface
                                              .withValues(alpha: 0.72),
                                          borderRadius: FlowaRadii.xlAll,
                                          border: Border.all(
                                            color: FlowaColors.border,
                                          ),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(
                                            FlowaSpacing.lg,
                                          ),
                                          child: form,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: FlowaSpacing.xl),
                                    FlowaFadeSlide(
                                      delay:
                                          const Duration(milliseconds: 140),
                                      offset: const Offset(0, 0.05),
                                      child: actions,
                                    ),
                                    if (footer != null) ...[
                                      const SizedBox(height: FlowaSpacing.md),
                                      FlowaFadeSlide(
                                        delay: const Duration(
                                          milliseconds: 200,
                                        ),
                                        child: footer!,
                                      ),
                                    ],
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
      ),
    );
  }
}

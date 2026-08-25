import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../tokens/flowa_colors.dart';
import '../tokens/flowa_spacing.dart';
import '../tokens/flowa_typography.dart';
import 'flowa_actions.dart';
import 'flowa_icon.dart';
import 'flowa_texture.dart';

/// Shared inner screen: canvas, circular back, centred title.
///
/// On a tab (nothing to pop) the header has no back button and the body sits
/// inside the shell canvas. On a pushed route it paints its own canvas.
class FlowaScreen extends StatelessWidget {
  const FlowaScreen({
    required this.title,
    required this.child,
    super.key,
    this.onBack,
    this.actions = const [],
    this.padding,
    this.footer,
    this.embedded,
    this.showBack,
  });

  final String title;
  final Widget child;
  final VoidCallback? onBack;
  final List<Widget> actions;
  final EdgeInsetsGeometry? padding;
  final Widget? footer;
  final bool? embedded;
  final bool? showBack;

  @override
  Widget build(BuildContext context) {
    final isEmbedded = embedded ?? false;
    final back = showBack ?? (onBack != null || Navigator.of(context).canPop());

    final content = Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            FlowaSpacing.gutter,
            FlowaSpacing.sm,
            FlowaSpacing.gutter,
            FlowaSpacing.md,
          ),
          child: Row(
            children: [
              if (back)
                FlowaIconAction(
                  glyph: FlowaGlyph.arrowLeft,
                  onTap: onBack ?? () => Navigator.of(context).pop(),
                )
              else
                const SizedBox(width: 44),
              Expanded(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: FlowaType.titleMd(),
                ),
              ),
              if (actions.isEmpty)
                const SizedBox(width: 44)
              else
                Row(mainAxisSize: MainAxisSize.min, children: actions),
            ],
          ),
        ),
        Expanded(
          child: Padding(
            padding: padding ??
                const EdgeInsets.symmetric(horizontal: FlowaSpacing.gutter),
            child: child,
          ),
        ),
        if (footer != null)
          Padding(
            padding: EdgeInsets.fromLTRB(
              FlowaSpacing.gutter,
              FlowaSpacing.sm,
              FlowaSpacing.gutter,
              isEmbedded ? FlowaSpacing.navClearance : FlowaSpacing.lg,
            ),
            child: footer,
          ),
      ],
    );

    if (isEmbedded) {
      return SafeArea(bottom: false, child: content);
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: FlowaColors.ink,
        body: FlowaCanvas(
          child: SafeArea(child: content),
        ),
      ),
    );
  }
}

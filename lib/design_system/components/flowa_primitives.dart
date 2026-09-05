import 'package:flutter/material.dart';

import '../../core/utils/flowa_runtime.dart';
import '../tokens/flowa_colors.dart';
import '../tokens/flowa_motion_tokens.dart';
import '../tokens/flowa_spacing.dart';
import '../tokens/flowa_typography.dart';

/// Fade plus a short rise, on the house curve. The single entrance used
/// everywhere; staggering it down a list is what makes a screen feel composed
/// rather than dumped.
class FlowaEntrance extends StatefulWidget {
  const FlowaEntrance({
    required this.child,
    super.key,
    this.delay = Duration.zero,
    this.duration = FlowaMotion.slow,
    this.rise = 16,
    this.scaleFrom = 1,
  });

  final Widget child;
  final Duration delay;
  final Duration duration;
  final double rise;

  /// Optional grow-in (e.g. `0.96`). Keep at `1` for lists that should only rise.
  final double scaleFrom;

  @override
  State<FlowaEntrance> createState() => _FlowaEntranceState();
}

class _FlowaEntranceState extends State<FlowaEntrance>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);

    if (FlowaRuntime.isWidgetTest) {
      _controller.value = 1;
      return;
    }
    Future<void>.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(
      parent: _controller,
      curve: FlowaMotion.expoOut,
    );

    return AnimatedBuilder(
      animation: curved,
      builder: (context, child) {
        final t = curved.value.clamp(0.0, 1.0);
        final scale = widget.scaleFrom + (1 - widget.scaleFrom) * t;
        return Opacity(
          opacity: t,
          child: Transform.translate(
            offset: Offset(0, widget.rise * (1 - t)),
            child: Transform.scale(
              scale: scale,
              alignment: Alignment.topCenter,
              child: child,
            ),
          ),
        );
      },
      child: widget.child,
    );
  }
}

/// Show/hide with the same rise+fade, so a list can expand and collapse
/// with matching stagger (pass reverse delays when collapsing).
class FlowaReveal extends StatefulWidget {
  const FlowaReveal({
    required this.visible,
    required this.child,
    super.key,
    this.delay = Duration.zero,
    this.duration = FlowaMotion.slow,
    this.rise = 16,
  });

  final bool visible;
  final Widget child;
  final Duration delay;
  final Duration duration;
  final double rise;

  @override
  State<FlowaReveal> createState() => _FlowaRevealState();
}

class _FlowaRevealState extends State<FlowaReveal>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  int _gen = 0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
    if (FlowaRuntime.isWidgetTest) {
      _controller.value = widget.visible ? 1 : 0;
      return;
    }
    if (widget.visible) {
      _schedule(() => _controller.forward());
    }
  }

  @override
  void didUpdateWidget(covariant FlowaReveal oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.visible == widget.visible) {
      return;
    }
    if (FlowaRuntime.isWidgetTest) {
      _controller.value = widget.visible ? 1 : 0;
      return;
    }
    if (widget.visible) {
      _schedule(() => _controller.forward());
    } else {
      _schedule(() => _controller.reverse());
    }
  }

  void _schedule(VoidCallback action) {
    final gen = ++_gen;
    Future<void>.delayed(widget.delay, () {
      if (!mounted || gen != _gen) {
        return;
      }
      action();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final curved = CurvedAnimation(
      parent: _controller,
      curve: FlowaMotion.expoOut,
      reverseCurve: FlowaMotion.exit,
    );

    return AnimatedBuilder(
      animation: curved,
      builder: (context, child) {
        final t = curved.value.clamp(0.0, 1.0);
        if (t == 0) {
          return const SizedBox.shrink();
        }
        return ClipRect(
          child: Align(
            alignment: Alignment.topCenter,
            heightFactor: t,
            child: Opacity(
              opacity: t,
              child: Transform.translate(
                offset: Offset(0, widget.rise * (1 - t)),
                child: child,
              ),
            ),
          ),
        );
      },
      child: widget.child,
    );
  }
}

/// A 1px hairline. This replaces cards as the primary way of separating
/// content: rules structure a layout without adding a box around everything.
class FlowaRule extends StatelessWidget {
  const FlowaRule({
    super.key,
    this.color,
    this.thickness = 1,
    this.indent = 0,
    this.endIndent = 0,
  });

  const FlowaRule.strong({super.key})
      : color = FlowaColors.hairlineStrong,
        thickness = 1,
        indent = 0,
        endIndent = 0;

  final Color? color;
  final double thickness;
  final double indent;
  final double endIndent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: indent, right: endIndent),
      child: SizedBox(
        height: thickness,
        width: double.infinity,
        child: ColoredBox(color: color ?? FlowaColors.hairline),
      ),
    );
  }
}

/// Uppercase monospaced caption.
///
/// Sections are announced by one of these rather than by a bold heading, which
/// keeps every heavy weight on the screen available for the numbers.
class FlowaMicroLabel extends StatelessWidget {
  const FlowaMicroLabel(
    this.text, {
    super.key,
    this.color,
    this.dot = false,
    this.large = false,
  });

  final String text;
  final Color? color;

  /// Small acid marker before the text, for the one label that matters most on
  /// a screen.
  final bool dot;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final style = large
        ? FlowaType.microLg(color: color ?? FlowaColors.boneMuted)
        : FlowaType.micro(color: color ?? FlowaColors.boneFaint);

    final label = Text(text, style: style);
    if (!dot) {
      return label;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const ColoredBox(
          color: FlowaColors.mint,
          child: SizedBox(width: 6, height: 6),
        ),
        const SizedBox(width: FlowaSpacing.xs),
        label,
      ],
    );
  }
}

/// Inverted caption block: bone slab, black type.
///
/// The signature device of the reference — a label that looks stuck onto the
/// page rather than drawn in it. Reserved for the one thing on a screen that
/// must be read before anything else.
class FlowaStamp extends StatelessWidget {
  const FlowaStamp(
    this.text, {
    super.key,
    this.background = FlowaColors.bone,
    this.foreground = FlowaColors.ink,
  });

  const FlowaStamp.blaze(this.text, {super.key})
      : background = FlowaColors.blaze,
        foreground = FlowaColors.blazeInk;

  final String text;
  final Color background;
  final Color foreground;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: background,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(7, 4, 7, 4),
        child: Text(
          text.toUpperCase(),
          style: FlowaType.micro(color: foreground),
        ),
      ),
    );
  }
}

/// Micro label on the left, optional quiet action on the right.
class FlowaSectionHeader extends StatelessWidget {
  const FlowaSectionHeader({
    required this.label,
    super.key,
    this.actionLabel,
    this.onAction,
    this.dot = false,
  });

  final String label;
  final String? actionLabel;
  final VoidCallback? onAction;
  final bool dot;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        FlowaMicroLabel(label, dot: dot),
        const Spacer(),
        if (actionLabel != null)
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: onAction,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  actionLabel!,
                  style: FlowaType.micro(color: FlowaColors.mint),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Dark panel with a hairline edge. Used only when content genuinely needs to
/// be grouped — most lists should sit directly on the canvas.
class FlowaSurface extends StatelessWidget {
  const FlowaSurface({
    required this.child,
    super.key,
    this.padding = const EdgeInsets.all(FlowaSpacing.lg),
    this.radius = FlowaRadii.lg,
    this.color,
    this.borderColor,
    this.gradient,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  final Color? color;
  final Color? borderColor;
  final Gradient? gradient;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final surface = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: gradient == null ? (color ?? FlowaColors.inkHigh) : null,
        gradient: gradient,
        borderRadius: BorderRadius.circular(radius),
        border: borderColor == null
            ? null
            : Border.all(color: borderColor!),
      ),
      child: child,
    );

    if (onTap == null) {
      return surface;
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: surface,
    );
  }
}

/// Small status pill. Text is always uppercase mono so tags never compete with
/// real content.
class FlowaTag extends StatelessWidget {
  const FlowaTag(
    this.text, {
    super.key,
    this.color = FlowaColors.boneMuted,
    this.background,
    this.filled = false,
  });

  const FlowaTag.acid(this.text, {super.key})
      : color = FlowaColors.blazeInk,
        background = FlowaColors.blaze,
        filled = true;

  /// Outlined in the spot colour rather than filled: loud enough for an
  /// overdue invoice without turning the row into a solid red block.
  const FlowaTag.blaze(this.text, {super.key})
      : color = FlowaColors.blaze,
        background = null,
        filled = false;

  final String text;
  final Color color;
  final Color? background;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: filled ? (background ?? FlowaColors.mint) : background,
        borderRadius: FlowaRadii.pillAll,
        border: filled ? null : Border.all(color: color),
      ),
      child: Text(text.toUpperCase(), style: FlowaType.micro(color: color)),
    );
  }
}

/// One line of a statement-style block: caption on the left, figure on the
/// right, hairline underneath. Lifted straight from print financial tables.
class FlowaLedgerRow extends StatelessWidget {
  const FlowaLedgerRow({
    required this.label,
    required this.value,
    super.key,
    this.valueColor,
    this.caption,
    this.onTap,
    this.showRule = true,
  });

  final String label;
  final String value;
  final Color? valueColor;
  final String? caption;
  final VoidCallback? onTap;
  final bool showRule;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: FlowaSpacing.md),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      FlowaMicroLabel(label),
                      if (caption != null) ...[
                        const SizedBox(height: 6),
                        Text(caption!, style: FlowaType.bodySm()),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: FlowaSpacing.md),
                Text(
                  value,
                  style: FlowaType.figureMd(
                    color: valueColor ?? FlowaColors.bone,
                  ),
                ),
              ],
            ),
          ),
          if (showRule) const FlowaRule(),
        ],
      ),
    );
  }
}

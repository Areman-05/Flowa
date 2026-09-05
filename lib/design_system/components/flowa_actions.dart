import 'package:flutter/material.dart';

import '../../core/utils/flowa_haptics.dart';
import '../tokens/flowa_colors.dart';
import '../tokens/flowa_motion_tokens.dart';
import '../tokens/flowa_spacing.dart';
import '../tokens/flowa_typography.dart';
import 'flowa_icon.dart';

/// Physical press wrapper: everything tappable in Flowa compresses slightly
/// and fires a haptic. Consistent touch feedback is most of what "expensive"
/// feels like on a phone.
class FlowaPressScale extends StatefulWidget {
  const FlowaPressScale({
    required this.child,
    required this.onTap,
    super.key,
    this.scale = 0.97,
    this.haptic = true,
    this.enabled = true,
  });

  final Widget child;
  final VoidCallback? onTap;
  final double scale;
  final bool haptic;
  final bool enabled;

  @override
  State<FlowaPressScale> createState() => _FlowaPressScaleState();
}

class _FlowaPressScaleState extends State<FlowaPressScale> {
  bool _down = false;

  bool get _active => widget.enabled && widget.onTap != null;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: _active ? (_) => setState(() => _down = true) : null,
      onTapCancel: _active ? () => setState(() => _down = false) : null,
      onTapUp: _active ? (_) => setState(() => _down = false) : null,
      onTap: _active
          ? () {
              if (widget.haptic) {
                FlowaHaptics.selection();
              }
              widget.onTap!.call();
            }
          : null,
      child: AnimatedScale(
        scale: _down ? widget.scale : 1,
        duration: FlowaMotion.instant,
        curve: FlowaMotion.press,
        child: widget.child,
      ),
    );
  }
}

/// The one loud element allowed on a screen.
class FlowaAcidButton extends StatelessWidget {
  const FlowaAcidButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.icon,
    this.glyph,
    this.loading = false,
    this.expand = true,
    this.compact = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final FlowaGlyph? glyph;
  final bool loading;
  final bool expand;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !loading;
    final height = compact ? 48.0 : 56.0;

    final content = loading
        ? const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.2,
              color: FlowaColors.mintInk,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: FlowaType.label(
                  color: enabled ? FlowaColors.mintInk : FlowaColors.boneFaint,
                ),
              ),
              if (glyph != null) ...[
                const SizedBox(width: FlowaSpacing.xs),
                FlowaIcon(
                  glyph!,
                  size: compact ? 16 : 18,
                  color: enabled ? FlowaColors.mintInk : FlowaColors.boneFaint,
                ),
              ] else if (icon != null) ...[
                const SizedBox(width: FlowaSpacing.xs),
                Icon(
                  icon,
                  size: compact ? 16 : 18,
                  color: enabled ? FlowaColors.mintInk : FlowaColors.boneFaint,
                ),
              ],
            ],
          );

    return FlowaPressScale(
      onTap: enabled ? onPressed : null,
      child: AnimatedContainer(
        duration: FlowaMotion.quick,
        curve: FlowaMotion.swiftOut,
        height: height,
        width: expand ? double.infinity : null,
        padding: expand
            ? null
            : const EdgeInsets.symmetric(horizontal: FlowaSpacing.xl),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: enabled ? FlowaColors.mint : FlowaColors.inkHigh,
          borderRadius: FlowaRadii.pillAll,
        ),
        child: content,
      ),
    );
  }
}

/// Quiet counterpart to [FlowaAcidButton]: hairline outline, bone text.
class FlowaGhostButton extends StatelessWidget {
  const FlowaGhostButton({
    required this.label,
    required this.onPressed,
    super.key,
    this.icon,
    this.expand = true,
    this.compact = false,
    this.destructive = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expand;
  final bool compact;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final tone = destructive ? FlowaColors.danger : FlowaColors.bone;

    return FlowaPressScale(
      onTap: onPressed,
      child: Container(
        height: compact ? 48 : 56,
        width: expand ? double.infinity : null,
        padding: expand
            ? null
            : const EdgeInsets.symmetric(horizontal: FlowaSpacing.xl),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: FlowaColors.inkHigh,
          borderRadius: FlowaRadii.pillAll,
          border: Border.all(
            color: destructive ? FlowaColors.danger : FlowaColors.hairlineStrong,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: compact ? 16 : 18, color: tone),
              const SizedBox(width: FlowaSpacing.xs),
            ],
            Text(label, style: FlowaType.label(color: tone)),
          ],
        ),
      ),
    );
  }
}

/// Square icon action used in headers and toolbars.
class FlowaIconAction extends StatelessWidget {
  const FlowaIconAction({
    required this.onTap,
    super.key,
    this.icon,
    this.glyph,
    this.badge = false,
    this.tooltip,
    this.size = 44,
  });

  final IconData? icon;
  final FlowaGlyph? glyph;
  final VoidCallback? onTap;
  final bool badge;
  final String? tooltip;
  final double size;

  @override
  Widget build(BuildContext context) {
    final button = FlowaPressScale(
      onTap: onTap,
      scale: 0.92,
      child: Container(
        width: size,
        height: size,
        decoration: const BoxDecoration(
          color: FlowaColors.inkHigh,
          shape: BoxShape.circle,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            if (glyph != null)
              FlowaIcon(glyph!, size: 22, color: FlowaColors.boneMuted)
            else
              Icon(icon, size: 22, color: FlowaColors.boneMuted),
            if (badge)
              const Positioned(
                top: 10,
                right: 10,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: FlowaColors.mint,
                    shape: BoxShape.circle,
                  ),
                  child: SizedBox(width: 7, height: 7),
                ),
              ),
          ],
        ),
      ),
    );

    if (tooltip == null) {
      return button;
    }
    return Tooltip(message: tooltip!, child: button);
  }
}

/// Profile / settings row: circular glyph, title, optional caption, chevron.
class FlowaMenuRow extends StatelessWidget {
  const FlowaMenuRow({
    required this.title,
    required this.onTap,
    super.key,
    this.subtitle,
    this.glyph = FlowaGlyph.arrowRight,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final FlowaGlyph glyph;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return FlowaPressScale(
      onTap: onTap,
      haptic: false,
      scale: 0.985,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            FlowaIconOrb(
              glyph: glyph,
              size: 48,
              background: FlowaColors.inkHigh,
              foreground: FlowaColors.bone,
            ),
            const SizedBox(width: FlowaSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: FlowaType.titleSm()),
                  if (subtitle != null) ...[
                    const SizedBox(height: 3),
                    Text(subtitle!, style: FlowaType.bodySm()),
                  ],
                ],
              ),
            ),
            trailing ??
                const FlowaIcon(
                  FlowaGlyph.arrowRight,
                  size: 20,
                  color: FlowaColors.boneFaint,
                ),
          ],
        ),
      ),
    );
  }
}

/// Mint/grey filter pill, used on history and insights.
class FlowaFilterChip extends StatelessWidget {
  const FlowaFilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
    super.key,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FlowaPressScale(
      onTap: onTap,
      scale: 0.96,
      haptic: false,
      child: AnimatedContainer(
        duration: FlowaMotion.quick,
        curve: FlowaMotion.swiftOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? FlowaColors.mint : FlowaColors.inkHigh,
          borderRadius: FlowaRadii.pillAll,
        ),
        child: Text(
          label,
          style: FlowaType.microLg(
            color: selected ? FlowaColors.mintInk : FlowaColors.boneMuted,
          ),
        ),
      ),
    );
  }
}

/// Squircle action used in the Home rail: dark tile plus caption.
class FlowaRailAction extends StatelessWidget {
  const FlowaRailAction({
    required this.label,
    required this.onTap,
    super.key,
    this.icon,
    this.glyph,
    this.emphasised = false,
  });

  final String label;
  final IconData? icon;
  final FlowaGlyph? glyph;
  final VoidCallback onTap;
  final bool emphasised;

  @override
  Widget build(BuildContext context) {
    final fg = emphasised ? FlowaColors.mintInk : FlowaColors.bone;
    return FlowaPressScale(
      onTap: onTap,
      scale: 0.96,
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: emphasised ? FlowaColors.mint : FlowaColors.inkHigh,
              borderRadius: FlowaRadii.lgAll,
            ),
            alignment: Alignment.center,
            child: glyph != null
                ? FlowaIcon(glyph!, color: fg, size: 26)
                : Icon(icon, size: 26, color: fg),
          ),
          const SizedBox(height: FlowaSpacing.xs),
          Text(
            label,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: FlowaType.micro(color: FlowaColors.boneMuted),
          ),
        ],
      ),
    );
  }
}

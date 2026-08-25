import 'package:flutter/material.dart';

import '../../core/utils/flowa_haptics.dart';
import '../tokens/flowa_colors.dart';
import '../tokens/flowa_motion_tokens.dart';
import '../tokens/flowa_spacing.dart';
import 'flowa_icon.dart';

class FlowaNavItem {
  const FlowaNavItem({
    required this.glyph,
    required this.label,
    this.badge = false,
    this.icon,
  });

  final FlowaGlyph glyph;
  final String label;
  final bool badge;

  /// Kept so older call sites still compile while they migrate to [glyph].
  final IconData? icon;
}

/// Floating island nav — Privat silhouette, Vare mint active state.
class FlowaCapsuleNav extends StatelessWidget {
  const FlowaCapsuleNav({
    required this.items,
    required this.index,
    required this.onSelected,
    super.key,
  });

  final List<FlowaNavItem> items;
  final int index;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        FlowaSpacing.gutter,
        0,
        FlowaSpacing.gutter,
        10 + MediaQuery.paddingOf(context).bottom,
      ),
      child: Container(
        height: 68,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: FlowaColors.inkHigh,
          borderRadius: FlowaRadii.pillAll,
          border: Border.all(color: FlowaColors.hairlineStrong),
          boxShadow: FlowaShadows.card,
        ),
        child: Row(
          children: [
            for (var i = 0; i < items.length; i++)
              _NavCell(
                item: items[i],
                selected: i == index,
                onTap: () {
                  if (i != index) {
                    FlowaHaptics.selection();
                  }
                  onSelected(i);
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _NavCell extends StatelessWidget {
  const _NavCell({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final FlowaNavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Semantics(
          label: item.label,
          button: true,
          child: AnimatedContainer(
            duration: FlowaMotion.base,
            curve: FlowaMotion.swiftOut,
            width: selected ? 46 : 40,
            height: selected ? 46 : 40,
            decoration: BoxDecoration(
              color: selected ? FlowaColors.mint : Colors.transparent,
              shape: BoxShape.circle,
            ),
            child: Stack(
              alignment: Alignment.center,
              clipBehavior: Clip.none,
              children: [
                FlowaIcon(
                  item.glyph,
                  size: 21,
                  color: selected ? FlowaColors.mintInk : FlowaColors.boneFaint,
                ),
                if (item.badge && !selected)
                  const Positioned(
                    top: 6,
                    right: 6,
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
        ),
      ),
    );
  }
}

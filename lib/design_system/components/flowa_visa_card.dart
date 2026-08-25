import 'package:flutter/material.dart';

import '../../core/utils/flowa_formatters.dart';
import '../../domain/entities/finance_entities.dart';
import '../tokens/flowa_colors.dart';
import '../tokens/flowa_spacing.dart';
import '../tokens/flowa_typography.dart';
import 'flowa_icon.dart';

enum FlowaCardStyle { primary, gold, green }

/// Hero payment card — Privat layout, Vare mint face.
class FlowaVisaCard extends StatelessWidget {
  const FlowaVisaCard({
    required this.account,
    required this.balanceVisible,
    required this.onToggleVisibility,
    super.key,
    this.style = FlowaCardStyle.primary,
    this.height = 196,
    this.isFrozen = false,
    this.onToggleFreeze,
    this.caption = 'Disponible de verdad',
    this.amount,
  });

  final Account account;
  final bool balanceVisible;
  final VoidCallback onToggleVisibility;
  final FlowaCardStyle style;
  final double height;
  final bool isFrozen;
  final VoidCallback? onToggleFreeze;
  final String caption;
  final double? amount;

  LinearGradient get _gradient {
    switch (style) {
      case FlowaCardStyle.primary:
        return FlowaColors.cardFace;
      case FlowaCardStyle.gold:
        return FlowaColors.cardVault;
      case FlowaCardStyle.green:
        return FlowaColors.cardFace;
    }
  }

  Color get _fg {
    switch (style) {
      case FlowaCardStyle.primary:
      case FlowaCardStyle.green:
        return FlowaColors.mintInk;
      case FlowaCardStyle.gold:
        return FlowaColors.bone;
    }
  }

  @override
  Widget build(BuildContext context) {
    final fg = _fg;
    final value = amount ?? account.availableBalance;

    return Semantics(
      label: '${account.displayName} ${account.brand} card',
      child: Container(
        height: height,
        decoration: BoxDecoration(
          gradient: _gradient,
          borderRadius: FlowaRadii.xlAll,
          boxShadow: style == FlowaCardStyle.primary
              ? FlowaShadows.mintGlow
              : FlowaShadows.soft,
        ),
        padding: const EdgeInsets.fromLTRB(22, 18, 22, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Flowa',
                  style: FlowaType.titleSm(color: fg).copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
                const Spacer(),
                FlowaIcon(FlowaGlyph.card, color: fg),
              ],
            ),
            const SizedBox(height: FlowaSpacing.sm),
            _Chip(color: fg),
            const Spacer(),
            Text(
              isFrozen ? 'Tarjeta congelada' : caption,
              style: FlowaType.micro(color: fg.withValues(alpha: 0.7)),
            ),
            const SizedBox(height: 4),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Expanded(
                  child: Text(
                    FlowaFormatters.maskedBalance(
                      amount: value,
                      visible: balanceVisible,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: FlowaType.figureLg(color: fg),
                  ),
                ),
                GestureDetector(
                  onTap: onToggleVisibility,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8, bottom: 4),
                    child: FlowaIcon(
                      balanceVisible ? FlowaGlyph.eye : FlowaGlyph.eyeOff,
                      size: 18,
                      color: fg.withValues(alpha: 0.8),
                    ),
                  ),
                ),
                const SizedBox(width: FlowaSpacing.md),
                Text(
                  account.brand,
                  style: FlowaType.titleMd(color: fg).copyWith(
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.6,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 28,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.55),
            color.withValues(alpha: 0.22),
          ],
        ),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../core/utils/flowa_formatters.dart';
import '../../domain/entities/finance_entities.dart';
import '../tokens/flowa_colors.dart';
import '../tokens/flowa_spacing.dart';

enum FlowaCardStyle { primary, gold, green }

/// Premium gradient account card used on Home and money flows.
class FlowaVisaCard extends StatelessWidget {
  const FlowaVisaCard({
    required this.account,
    required this.balanceVisible,
    required this.onToggleVisibility,
    super.key,
    this.style = FlowaCardStyle.primary,
    this.height = 180,
    this.isFrozen = false,
    this.onToggleFreeze,
  });

  final Account account;
  final bool balanceVisible;
  final VoidCallback onToggleVisibility;
  final FlowaCardStyle style;
  final double height;
  final bool isFrozen;
  final VoidCallback? onToggleFreeze;

  LinearGradient get _gradient {
    switch (style) {
      case FlowaCardStyle.primary:
        return FlowaColors.cardPrimaryGradient;
      case FlowaCardStyle.gold:
        return FlowaColors.cardGoldGradient;
      case FlowaCardStyle.green:
        return FlowaColors.cardGreenGradient;
    }
  }

  Color get _foreground {
    switch (style) {
      case FlowaCardStyle.primary:
        return FlowaColors.textOnCard;
      case FlowaCardStyle.gold:
      case FlowaCardStyle.green:
        return FlowaColors.textPrimary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final fg = _foreground;

    return Semantics(
      label: '${account.displayName} ${account.brand} card',
      child: Container(
        height: height,
        decoration: BoxDecoration(
          gradient: _gradient,
          borderRadius: FlowaRadii.xlAll,
          boxShadow: style == FlowaCardStyle.primary
              ? FlowaShadows.card
              : FlowaShadows.soft,
        ),
        padding: FlowaSpacing.cardPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Número de cuenta',
                  style: textTheme.labelMedium?.copyWith(
                    color: fg.withValues(alpha: 0.85),
                  ),
                ),
                const Spacer(),
                if (onToggleFreeze != null)
                  Semantics(
                    button: true,
                    label: isFrozen ? 'Descongelar tarjeta' : 'Congelar tarjeta',
                    child: TextButton(
                      onPressed: onToggleFreeze,
                      style: TextButton.styleFrom(
                        foregroundColor: fg,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Text(isFrozen ? 'Descongelar' : 'Congelar'),
                    ),
                  ),
                Text(
                  account.brand,
                  style: textTheme.titleMedium?.copyWith(
                    color: fg,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                  ),
                ),
              ],
            ),
            const SizedBox(height: FlowaSpacing.xs),
            Text(
              account.maskedNumber,
              style: textTheme.titleMedium?.copyWith(color: fg),
            ),
            if (isFrozen) ...[
              const SizedBox(height: FlowaSpacing.xs),
              Text(
                'Tarjeta congelada — pagos salientes en pausa.',
                style: textTheme.labelSmall?.copyWith(color: fg),
              ),
            ],
            const Spacer(),
            Text(
              'Saldo disponible',
              style: textTheme.labelMedium?.copyWith(
                color: fg.withValues(alpha: 0.85),
              ),
            ),
            Row(
              children: [
                Text(
                  FlowaFormatters.maskedBalance(
                    amount: account.availableBalance,
                    visible: balanceVisible,
                  ),
                  style: textTheme.headlineMedium?.copyWith(color: fg),
                ),
                const SizedBox(width: FlowaSpacing.xs),
                Semantics(
                  button: true,
                  label: balanceVisible ? 'Hide balance' : 'Show balance',
                  child: InkWell(
                    onTap: onToggleVisibility,
                    borderRadius: BorderRadius.circular(FlowaRadii.pill),
                    child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                        balanceVisible
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        size: 18,
                        color: fg.withValues(alpha: 0.9),
                      ),
                    ),
                  ),
                ),
                const Spacer(),
                Text(
                  '${account.expiryLabel} Expire Date',
                  style: textTheme.labelSmall?.copyWith(
                    color: fg.withValues(alpha: 0.9),
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

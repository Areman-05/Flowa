import 'package:flutter/material.dart';

import '../../core/utils/flowa_formatters.dart';
import '../../domain/entities/finance_entities.dart';
import '../tokens/flowa_colors.dart';
import '../tokens/flowa_spacing.dart';

/// Single row in Recent Transaction / full history lists.
class FlowaTransactionTile extends StatelessWidget {
  const FlowaTransactionTile({
    required this.item,
    super.key,
    this.onTap,
  });

  final TransactionItem item;
  final VoidCallback? onTap;

  IconData get _fallbackIcon {
    switch (item.merchant.toLowerCase()) {
      case 'apple':
        return Icons.apple;
      case 'spotify':
        return Icons.music_note_rounded;
      case 'dribbble pro':
        return Icons.sports_basketball_outlined;
      case 'paypal payment':
        return Icons.account_balance_wallet_outlined;
      default:
        return Icons.storefront_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final amountColor =
        item.isIncome ? FlowaColors.income : FlowaColors.textPrimary;

    return ListTile(
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: FlowaColors.surfaceMuted,
        child: Icon(_fallbackIcon, color: FlowaColors.textPrimary, size: 22),
      ),
      title: Text(item.merchant, style: textTheme.titleMedium),
      subtitle: Text(
        FlowaFormatters.transactionStamp(item.occurredAt),
        style: textTheme.bodySmall,
      ),
      trailing: Text(
        FlowaFormatters.signedCurrency(item.signedAmount),
        style: textTheme.titleMedium?.copyWith(color: amountColor),
      ),
    );
  }
}

/// Vertical list of transaction tiles with consistent separators.
class FlowaTransactionList extends StatelessWidget {
  const FlowaTransactionList({
    required this.items,
    super.key,
    this.shrinkWrap = true,
    this.physics,
    this.onItemTap,
  });

  final List<TransactionItem> items;
  final bool shrinkWrap;
  final ScrollPhysics? physics;
  final ValueChanged<TransactionItem>? onItemTap;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: FlowaSpacing.lg),
        child: Text('No transactions yet.'),
      );
    }

    return ListView.separated(
      shrinkWrap: shrinkWrap,
      physics: physics ?? const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (_, _) => const Divider(height: FlowaSpacing.sm),
      itemBuilder: (context, index) {
        final item = items[index];
        return FlowaTransactionTile(
          key: ValueKey(item.id),
          item: item,
          onTap: onItemTap == null ? null : () => onItemTap!(item),
        );
      },
    );
  }
}

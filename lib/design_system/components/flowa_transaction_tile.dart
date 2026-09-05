import 'package:flutter/material.dart';

import '../../core/utils/flowa_formatters.dart';
import '../../domain/entities/finance_entities.dart';
import '../tokens/flowa_category_colors.dart';
import '../tokens/flowa_spacing.dart';
import '../tokens/flowa_typography.dart';
import '../icons/flowa_lucide_icons.dart';
import 'flowa_actions.dart';
import 'flowa_icon.dart';
import 'flowa_money_text.dart';

class FlowaTransactionTile extends StatelessWidget {
  const FlowaTransactionTile({
    required this.item,
    super.key,
    this.onTap,
    this.masked = false,
    this.orbBackground,
  });

  final TransactionItem item;
  final VoidCallback? onTap;
  final bool masked;

  /// Override orb fill. When null, uses muted category tone.
  final Color? orbBackground;

  static IconData iconFor(TransactionItem item) {
    if (item.isIncome) {
      return categoryLucideIcon('Ingresos');
    }
    return categoryLucideIcon(item.category ?? 'General');
  }

  CategoryTone get _tone {
    if (item.isIncome) {
      return FlowaCategoryColors.income;
    }
    return FlowaCategoryColors.forCategory(item.category ?? 'General');
  }

  @override
  Widget build(BuildContext context) {
    final tone = _tone;

    return FlowaPressScale(
      onTap: onTap,
      scale: 0.985,
      haptic: false,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            FlowaLucideOrb(
              icon: iconFor(item),
              size: 44,
              background: orbBackground ?? tone.orbBackground,
              foreground: tone.icon,
            ),
            const SizedBox(width: FlowaSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.merchant,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: FlowaType.titleSm(),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    [
                      FlowaFormatters.transactionStamp(item.occurredAt),
                      if ((item.category ?? '').isNotEmpty) item.category!,
                    ].join(' · '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: FlowaType.bodySm(),
                  ),
                ],
              ),
            ),
            const SizedBox(width: FlowaSpacing.sm),
            FlowaAmountText(
              signedAmount: item.signedAmount,
              masked: masked,
              expenseColor: tone.icon,
            ),
          ],
        ),
      ),
    );
  }
}

class FlowaTransactionList extends StatelessWidget {
  const FlowaTransactionList({
    required this.items,
    super.key,
    this.onItemTap,
    this.masked = false,
    this.physics,
    this.shrinkWrap = true,
    this.orbBackground,
  });

  final List<TransactionItem> items;
  final ValueChanged<TransactionItem>? onItemTap;
  final bool masked;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final Color? orbBackground;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      shrinkWrap: shrinkWrap,
      physics: physics ?? const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 2),
      itemBuilder: (context, index) {
        final item = items[index];
        return FlowaTransactionTile(
          item: item,
          masked: masked,
          orbBackground: orbBackground,
          onTap: onItemTap == null ? null : () => onItemTap!(item),
        );
      },
    );
  }
}

class FlowaGroupedTransactionList extends StatelessWidget {
  const FlowaGroupedTransactionList({
    required this.items,
    super.key,
    this.onItemTap,
    this.masked = false,
    this.physics,
    this.shrinkWrap = true,
    this.bottomPadding = 0,
    this.orbBackground,
  });

  final List<TransactionItem> items;
  final ValueChanged<TransactionItem>? onItemTap;
  final bool masked;
  final ScrollPhysics? physics;
  final bool shrinkWrap;
  final double bottomPadding;
  final Color? orbBackground;

  @override
  Widget build(BuildContext context) {
    final groups = <String, List<TransactionItem>>{};
    for (final item in items) {
      groups
          .putIfAbsent(FlowaFormatters.dayHeading(item.occurredAt), () => [])
          .add(item);
    }

    final headers = groups.keys.toList();
    return ListView.builder(
      shrinkWrap: shrinkWrap,
      physics: physics ?? const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.only(bottom: bottomPadding),
      itemCount: headers.length,
      itemBuilder: (context, index) {
        final header = headers[index];
        final rows = groups[header]!;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 8, bottom: 4),
              child: Text(header, style: FlowaType.micro()),
            ),
            for (final item in rows)
              FlowaTransactionTile(
                item: item,
                masked: masked,
                orbBackground: orbBackground,
                onTap: onItemTap == null ? null : () => onItemTap!(item),
              ),
          ],
        );
      },
    );
  }
}

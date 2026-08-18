import '../../../domain/entities/finance_entities.dart';
import '../../transactions/domain/transaction_filters.dart';

/// Category totals for Insights charts.
class CategorySpend {
  const CategorySpend({required this.category, required this.amount});

  final String category;
  final double amount;
}

/// Compact monthly insight used on Home and Insights.
class SpendingSnapshot {
  const SpendingSnapshot({
    required this.incoming,
    required this.outgoing,
    required this.net,
    required this.topMerchant,
    required this.transactionCount,
    this.categories = const [],
  });

  final double incoming;
  final double outgoing;
  final double net;
  final String topMerchant;
  final int transactionCount;
  final List<CategorySpend> categories;

  bool get isPositive => net >= 0;
}

abstract final class SpendingInsights {
  static SpendingSnapshot from(List<TransactionItem> items, {DateTime? month}) {
    final scoped = month == null
        ? items
        : items
              .where(
                (item) =>
                    item.occurredAt.year == month.year &&
                    item.occurredAt.month == month.month,
              )
              .toList(growable: false);

    if (scoped.isEmpty) {
      return const SpendingSnapshot(
        incoming: 0,
        outgoing: 0,
        net: 0,
        topMerchant: '—',
        transactionCount: 0,
      );
    }

    final incoming = TransactionFilters.totalIncoming(scoped);
    final outgoing = TransactionFilters.totalOutgoing(scoped);
    final totals = <String, double>{};
    final categoryTotals = <String, double>{};
    for (final item in scoped.where((item) => !item.isIncome)) {
      totals.update(
        item.merchant,
        (value) => value + item.amount.abs(),
        ifAbsent: item.amount.abs,
      );
      final category = item.category ?? 'General';
      categoryTotals.update(
        category,
        (value) => value + item.amount.abs(),
        ifAbsent: item.amount.abs,
      );
    }
    var topMerchant = '—';
    var topAmount = 0.0;
    totals.forEach((merchant, amount) {
      if (amount > topAmount) {
        topMerchant = merchant;
        topAmount = amount;
      }
    });

    final categories =
        categoryTotals.entries
            .map(
              (entry) =>
                  CategorySpend(category: entry.key, amount: entry.value),
            )
            .toList()
          ..sort((a, b) => b.amount.compareTo(a.amount));

    return SpendingSnapshot(
      incoming: incoming,
      outgoing: outgoing,
      net: incoming - outgoing,
      topMerchant: topMerchant,
      transactionCount: scoped.length,
      categories: categories,
    );
  }
}

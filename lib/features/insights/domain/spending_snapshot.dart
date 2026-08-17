import '../../../domain/entities/finance_entities.dart';
import '../../transactions/domain/transaction_filters.dart';

/// Compact monthly insight used on Home and Insights.
class SpendingSnapshot {
  const SpendingSnapshot({
    required this.incoming,
    required this.outgoing,
    required this.net,
    required this.topMerchant,
    required this.transactionCount,
  });

  final double incoming;
  final double outgoing;
  final double net;
  final String topMerchant;
  final int transactionCount;

  bool get isPositive => net >= 0;
}

abstract final class SpendingInsights {
  static SpendingSnapshot from(List<TransactionItem> items) {
    if (items.isEmpty) {
      return const SpendingSnapshot(
        incoming: 0,
        outgoing: 0,
        net: 0,
        topMerchant: '—',
        transactionCount: 0,
      );
    }

    final incoming = TransactionFilters.totalIncoming(items);
    final outgoing = TransactionFilters.totalOutgoing(items);
    final totals = <String, double>{};
    for (final item in items.where((item) => !item.isIncome)) {
      totals.update(
        item.merchant,
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

    return SpendingSnapshot(
      incoming: incoming,
      outgoing: outgoing,
      net: incoming - outgoing,
      topMerchant: topMerchant,
      transactionCount: items.length,
    );
  }
}

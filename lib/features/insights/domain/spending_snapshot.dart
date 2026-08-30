import '../../../domain/entities/finance_entities.dart';
import '../../transactions/domain/transaction_filters.dart';

/// Category totals for Insights charts.
class CategorySpend {
  const CategorySpend({required this.category, required this.amount});

  final String category;
  final double amount;
}

/// One bar in the spending chart.
class SpendBar {
  const SpendBar({
    required this.label,
    required this.amount,
    required this.bucketStart,
  });

  final String label;
  final double amount;
  final DateTime bucketStart;
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
    this.bars = const [],
    this.previousOutgoing = 0,
  });

  final double incoming;
  final double outgoing;
  final double net;
  final String topMerchant;
  final int transactionCount;
  final List<CategorySpend> categories;
  final List<SpendBar> bars;
  final double previousOutgoing;

  bool get isPositive => net >= 0;

  /// Positive = spending up vs previous period.
  double? get outgoingDeltaPct {
    if (previousOutgoing <= 0) {
      return outgoing > 0 ? 100 : null;
    }
    return ((outgoing - previousOutgoing) / previousOutgoing) * 100;
  }
}

enum InsightRange { week, month, quarter, year }

abstract final class SpendingInsights {
  static SpendingSnapshot from(
    List<TransactionItem> items, {
    DateTime? month,
    InsightRange range = InsightRange.week,
  }) {
    final now = DateTime.now();

    // Legacy / tests: no month → all transactions (no date window).
    if (month == null) {
      return _snapshotFor(
        scoped: items,
        previous: const [],
        range: range,
        barStart: DateTime(now.year, now.month, now.day)
            .subtract(const Duration(days: 6)),
      );
    }

    final (start, end, prevStart, prevEnd) = _window(
      anchor: month,
      range: range,
      now: now,
    );

    final scoped = items
        .where(
          (item) =>
              !item.occurredAt.isBefore(start) && item.occurredAt.isBefore(end),
        )
        .toList(growable: false);

    final previous = items
        .where(
          (item) =>
              !item.occurredAt.isBefore(prevStart) &&
              item.occurredAt.isBefore(prevEnd),
        )
        .toList(growable: false);

    return _snapshotFor(
      scoped: scoped,
      previous: previous,
      range: range,
      barStart: start,
    );
  }

  static SpendingSnapshot _snapshotFor({
    required List<TransactionItem> scoped,
    required List<TransactionItem> previous,
    required InsightRange range,
    required DateTime barStart,
  }) {
    if (scoped.isEmpty) {
      return SpendingSnapshot(
        incoming: 0,
        outgoing: 0,
        net: 0,
        topMerchant: '—',
        transactionCount: 0,
        bars: _barsFor(const [], range: range, start: barStart),
        previousOutgoing: TransactionFilters.totalOutgoing(previous),
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

    final categories = categoryTotals.entries
        .map((entry) => CategorySpend(category: entry.key, amount: entry.value))
        .toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));

    return SpendingSnapshot(
      incoming: incoming,
      outgoing: outgoing,
      net: incoming - outgoing,
      topMerchant: topMerchant,
      transactionCount: scoped.length,
      categories: categories,
      bars: _barsFor(scoped, range: range, start: barStart),
      previousOutgoing: TransactionFilters.totalOutgoing(previous),
    );
  }

  static (DateTime, DateTime, DateTime, DateTime) _window({
    required DateTime anchor,
    required InsightRange range,
    required DateTime now,
  }) {
    switch (range) {
      case InsightRange.week:
        final end = DateTime(now.year, now.month, now.day).add(
          const Duration(days: 1),
        );
        final start = end.subtract(const Duration(days: 7));
        return (
          start,
          end,
          start.subtract(const Duration(days: 7)),
          start,
        );
      case InsightRange.month:
        final start = DateTime(anchor.year, anchor.month);
        final end = DateTime(anchor.year, anchor.month + 1);
        final prevStart = DateTime(anchor.year, anchor.month - 1);
        return (start, end, prevStart, start);
      case InsightRange.quarter:
        final start = DateTime(anchor.year, anchor.month - 2);
        final end = DateTime(anchor.year, anchor.month + 1);
        final prevStart = DateTime(anchor.year, anchor.month - 5);
        return (start, end, prevStart, start);
      case InsightRange.year:
        final start = DateTime(anchor.year, 1);
        final end = DateTime(anchor.year + 1, 1);
        final prevStart = DateTime(anchor.year - 1, 1);
        return (start, end, prevStart, start);
    }
  }

  static List<SpendBar> _barsFor(
    List<TransactionItem> items, {
    required InsightRange range,
    required DateTime start,
  }) {
    const weekdays = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];
    const monthsShort = [
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic',
    ];

    switch (range) {
      case InsightRange.week:
        return [
          for (var i = 0; i < 7; i++)
            () {
              final day = DateTime(start.year, start.month, start.day + i);
              final next = day.add(const Duration(days: 1));
              final sum = items
                  .where(
                    (t) =>
                        !t.isIncome &&
                        !t.occurredAt.isBefore(day) &&
                        t.occurredAt.isBefore(next),
                  )
                  .fold<double>(0, (s, t) => s + t.amount.abs());
              return SpendBar(
                label: weekdays[(day.weekday - 1) % 7],
                amount: sum,
                bucketStart: day,
              );
            }(),
        ];
      case InsightRange.month:
        return [
          for (var i = 0; i < 4; i++)
            () {
              final weekStart = start.add(Duration(days: i * 7));
              final weekEnd = weekStart.add(const Duration(days: 7));
              final sum = items
                  .where(
                    (t) =>
                        !t.isIncome &&
                        !t.occurredAt.isBefore(weekStart) &&
                        t.occurredAt.isBefore(weekEnd),
                  )
                  .fold<double>(0, (s, t) => s + t.amount.abs());
              return SpendBar(
                label: 'S${i + 1}',
                amount: sum,
                bucketStart: weekStart,
              );
            }(),
        ];
      case InsightRange.quarter:
      case InsightRange.year:
        final count = range == InsightRange.quarter ? 3 : 12;
        return [
          for (var i = 0; i < count; i++)
            () {
              final monthStart = DateTime(start.year, start.month + i);
              final monthEnd = DateTime(start.year, start.month + i + 1);
              final sum = items
                  .where(
                    (t) =>
                        !t.isIncome &&
                        !t.occurredAt.isBefore(monthStart) &&
                        t.occurredAt.isBefore(monthEnd),
                  )
                  .fold<double>(0, (s, t) => s + t.amount.abs());
              return SpendBar(
                label: monthsShort[monthStart.month - 1],
                amount: sum,
                bucketStart: monthStart,
              );
            }(),
        ];
    }
  }
}

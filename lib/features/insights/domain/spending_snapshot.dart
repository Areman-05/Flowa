import 'dart:math' as math;

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

enum InsightRange { day, week, month, quarter, year }

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
    final monthStart = DateTime(anchor.year, anchor.month);
    final monthEnd = DateTime(anchor.year, anchor.month + 1);
    final isCurrentMonth =
        anchor.year == now.year && anchor.month == now.month;
    final today = DateTime(now.year, now.month, now.day);
    final lastDayOfMonth = DateTime(anchor.year, anchor.month + 1, 0);

    switch (range) {
      case InsightRange.day:
        final focusDay = isCurrentMonth ? today : lastDayOfMonth;
        final start = focusDay;
        final end = focusDay.add(const Duration(days: 1));
        final prevStart = focusDay.subtract(const Duration(days: 1));
        return (start, end, prevStart, start);
      case InsightRange.week:
        final end = isCurrentMonth
            ? today.add(const Duration(days: 1))
            : monthEnd;
        var start = end.subtract(const Duration(days: 7));
        if (start.isBefore(monthStart)) {
          start = monthStart;
        }
        final prevEnd = start;
        final prevStart = prevEnd.subtract(const Duration(days: 7));
        return (start, end, prevStart, prevEnd);
      case InsightRange.month:
        final start = monthStart;
        final end = monthEnd;
        final prevStart = DateTime(anchor.year, anchor.month - 1);
        return (start, end, prevStart, start);
      case InsightRange.quarter:
        final start = DateTime(anchor.year, anchor.month - 2);
        final end = monthEnd;
        final prevStart = DateTime(anchor.year, anchor.month - 5);
        return (start, end, prevStart, start);
      case InsightRange.year:
        final start = DateTime(anchor.year, 1);
        final end = DateTime(anchor.year + 1, 1);
        final prevStart = DateTime(anchor.year - 1, 1);
        return (start, end, prevStart, start);
    }
  }

  /// Human-readable label for the active insight window.
  static String periodLabel({
    required DateTime anchor,
    required InsightRange range,
    required DateTime now,
  }) {
    final monthName = _monthsShort[anchor.month - 1];
    final isCurrentMonth =
        anchor.year == now.year && anchor.month == now.month;

    switch (range) {
      case InsightRange.day:
        final day = isCurrentMonth
            ? now.day
            : DateTime(anchor.year, anchor.month + 1, 0).day;
        return 'Hoy · $day $monthName ${anchor.year}';
      case InsightRange.week:
        if (isCurrentMonth) {
          return 'Últimos 7 días · $monthName ${anchor.year}';
        }
        return 'Última semana · $monthName ${anchor.year}';
      case InsightRange.month:
        return '$monthName ${anchor.year}';
      case InsightRange.quarter:
        return 'Trimestre · $monthName ${anchor.year}';
      case InsightRange.year:
        return 'Año ${anchor.year}';
    }
  }

  static const _monthsShort = [
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
      case InsightRange.day:
        final dayStart = DateTime(start.year, start.month, start.day);
        const franjas = <(int, int, String)>[
          (0, 4, '0–4'),
          (4, 8, '4–8'),
          (8, 12, '8–12'),
          (12, 16, '12–16'),
          (16, 20, '16–20'),
          (20, 24, '20–24'),
        ];
        return [
          for (final franja in franjas)
            () {
              final from = dayStart.add(Duration(hours: franja.$1));
              final to = dayStart.add(Duration(hours: franja.$2));
              final sum = items
                  .where(
                    (t) =>
                        !t.isIncome &&
                        !t.occurredAt.isBefore(from) &&
                        t.occurredAt.isBefore(to),
                  )
                  .fold<double>(0, (s, t) => s + t.amount.abs());
              return SpendBar(
                label: franja.$3,
                amount: sum,
                bucketStart: from,
              );
            }(),
        ];
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
        final daysInMonth = DateTime(start.year, start.month + 1, 0).day;
        return [
          for (var i = 0; i < 4; i++)
            () {
              final fromDay = 1 + i * 7;
              if (fromDay > daysInMonth) {
                return SpendBar(
                  label: '',
                  amount: 0,
                  bucketStart: DateTime(start.year, start.month, daysInMonth),
                );
              }
              final toDay = i == 3 ? daysInMonth : math.min(fromDay + 6, daysInMonth);
              final weekStart = DateTime(start.year, start.month, fromDay);
              final weekEnd = DateTime(start.year, start.month, toDay).add(
                const Duration(days: 1),
              );
              final sum = items
                  .where(
                    (t) =>
                        !t.isIncome &&
                        !t.occurredAt.isBefore(weekStart) &&
                        t.occurredAt.isBefore(weekEnd),
                  )
                  .fold<double>(0, (s, t) => s + t.amount.abs());
              return SpendBar(
                label: '$fromDay–$toDay',
                amount: sum,
                bucketStart: weekStart,
              );
            }(),
        ].where((bar) => bar.label.isNotEmpty).toList(growable: false);
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

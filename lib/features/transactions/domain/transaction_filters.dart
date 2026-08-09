import '../../../domain/entities/finance_entities.dart';

enum TransactionFilter {
  all,
  income,
  expense,
}

/// Pure helpers for searching and filtering money movements.
abstract final class TransactionFilters {
  static List<TransactionItem> apply({
    required List<TransactionItem> items,
    required TransactionFilter filter,
    String query = '',
  }) {
    final normalized = query.trim().toLowerCase();
    return items.where((item) {
      final matchesFilter = switch (filter) {
        TransactionFilter.all => true,
        TransactionFilter.income => item.isIncome,
        TransactionFilter.expense => !item.isIncome,
      };
      if (!matchesFilter) {
        return false;
      }
      if (normalized.isEmpty) {
        return true;
      }
      return item.merchant.toLowerCase().contains(normalized) ||
          (item.category?.toLowerCase().contains(normalized) ?? false);
    }).toList(growable: false);
  }

  static double totalOutgoing(List<TransactionItem> items) {
    return items
        .where((item) => !item.isIncome)
        .fold<double>(0, (sum, item) => sum + item.amount.abs());
  }

  static double totalIncoming(List<TransactionItem> items) {
    return items
        .where((item) => item.isIncome)
        .fold<double>(0, (sum, item) => sum + item.amount.abs());
  }
}

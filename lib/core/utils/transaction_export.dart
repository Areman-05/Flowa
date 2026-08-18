import '../../domain/entities/finance_entities.dart';
import 'flowa_formatters.dart';

/// CSV helpers for exporting transaction history.
abstract final class TransactionExport {
  static const header = 'Date,Merchant,Category,Direction,Amount';

  static String toCsv(List<TransactionItem> items) {
    final rows = items.map(_rowFor).join('\n');
    return '$header\n$rows';
  }

  static String receiptFor(TransactionItem item) {
    return 'Flowa receipt\n'
        'Merchant: ${item.merchant}\n'
        'Amount: ${FlowaFormatters.signedCurrency(item.signedAmount)}\n'
        'Date: ${FlowaFormatters.transactionStamp(item.occurredAt)}\n'
        'Category: ${item.category ?? 'General'}\n'
        'Reference: ${item.id}';
  }

  static String _rowFor(TransactionItem item) {
    final date = FlowaFormatters.transactionStamp(item.occurredAt);
    final direction = item.isIncome ? 'Incoming' : 'Outgoing';
    final category = item.category ?? 'General';
    return '$date,${item.merchant},$category,$direction,${item.amount}';
  }
}

import '../../domain/entities/finance_entities.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../datasources/mock_finance_data.dart';

class MockTransactionRepository implements TransactionRepository {
  const MockTransactionRepository();

  @override
  Future<List<TransactionItem>> getAll() async {
    final items = List<TransactionItem>.from(MockFinanceData.transactions)
      ..sort((a, b) => b.occurredAt.compareTo(a.occurredAt));
    return items;
  }

  @override
  Future<List<TransactionItem>> getRecent({int limit = 4}) async {
    final all = await getAll();
    if (all.length <= limit) {
      return all;
    }
    return all.take(limit).toList(growable: false);
  }
}

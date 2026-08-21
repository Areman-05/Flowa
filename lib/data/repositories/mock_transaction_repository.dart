import '../../domain/entities/finance_entities.dart';
import '../../domain/repositories/transaction_repository.dart';

class MockTransactionRepository implements TransactionRepository {
  MockTransactionRepository({List<TransactionItem>? seed})
      : _items = List<TransactionItem>.from(seed ?? const []);

  final List<TransactionItem> _items;

  @override
  Future<List<TransactionItem>> getAll() async {
    final items = List<TransactionItem>.from(_items)
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

  @override
  Future<TransactionItem> add(TransactionItem item) async {
    _items.insert(0, item);
    return item;
  }
}

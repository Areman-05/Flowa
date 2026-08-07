import '../entities/finance_entities.dart';

/// Contract for listing and filtering money movements.
abstract class TransactionRepository {
  Future<List<TransactionItem>> getRecent({int limit = 4});

  Future<List<TransactionItem>> getAll();
}

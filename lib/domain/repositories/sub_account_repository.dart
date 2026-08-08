import '../entities/finance_entities.dart';

/// Contract for listing and creating business/family sub-accounts.
abstract class SubAccountRepository {
  Future<List<SubAccount>> getAll();

  Future<SubAccount> create({
    required String name,
    required AccountKind purpose,
    required AccessLevel accessLevel,
    required String iconKey,
    String? linkedEmail,
  });
}

import '../../domain/entities/finance_entities.dart';
import '../../domain/repositories/account_repository.dart';
import '../datasources/mock_finance_data.dart';

class MockAccountRepository implements AccountRepository {
  const MockAccountRepository();

  @override
  Future<Account> getPrimaryAccount() async => MockFinanceData.primaryAccount;

  @override
  Future<UserProfile> getCurrentUser() async => MockFinanceData.currentUser;
}

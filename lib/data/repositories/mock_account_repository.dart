import '../../domain/entities/finance_entities.dart';
import '../../domain/repositories/account_repository.dart';
import '../datasources/mock_finance_data.dart';

class MockAccountRepository implements AccountRepository {
  MockAccountRepository() : _user = MockFinanceData.currentUser;

  UserProfile _user;

  @override
  Future<Account> getPrimaryAccount() async => MockFinanceData.primaryAccount;

  @override
  Future<UserProfile> getCurrentUser() async => _user;

  @override
  Future<void> updateDisplayName(String fullName) async {
    _user = UserProfile(
      id: _user.id,
      fullName: fullName,
      avatarUrl: _user.avatarUrl,
      email: _user.email,
    );
  }
}

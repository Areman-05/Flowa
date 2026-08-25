import '../../domain/entities/finance_entities.dart';
import '../../domain/repositories/account_repository.dart';
import '../datasources/mock_finance_data.dart';

class MockAccountRepository implements AccountRepository {
  MockAccountRepository({
    Account? account,
    UserProfile? user,
  })  : _account = account ?? MockFinanceData.emptyPrimaryAccount,
        _user = user ?? MockFinanceData.guestUser;

  Account _account;
  UserProfile _user;

  void bootstrapUser(UserProfile user, {Account? account}) {
    _user = user;
    _account = account ?? MockFinanceData.accountForUser(user);
  }

  @override
  Future<Account> getPrimaryAccount() async => _account;

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

  @override
  Future<void> applyBalanceDelta(double delta) async {
    _account = _account.copyWith(
      availableBalance: _account.availableBalance + delta,
    );
  }
}

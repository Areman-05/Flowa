import '../../domain/entities/finance_entities.dart';

/// Empty defaults + helpers to bootstrap a real local user account.
abstract final class MockFinanceData {
  static const Account emptyPrimaryAccount = Account(
    id: 'acc-primary',
    displayName: 'Cuenta principal',
    maskedNumber: '**** **** **** 0000',
    availableBalance: 0,
    expiryLabel: '12/30',
  );

  static const UserProfile guestUser = UserProfile(
    id: 'user-guest',
    fullName: 'Invitado',
  );

  static final List<SubAccount> subAccounts = <SubAccount>[];

  static final List<TransactionItem> transactions = <TransactionItem>[];

  static Account accountForUser(UserProfile user) {
    final seed = user.id.hashCode.abs() % 10000;
    final lastFour = seed.toString().padLeft(4, '0');
    return Account(
      id: 'acc-${user.id}',
      displayName: 'Cuenta principal',
      maskedNumber: '**** **** **** $lastFour',
      availableBalance: 0,
      expiryLabel: '12/30',
    );
  }

  static UserProfile profileFromAuth({
    required String id,
    required String fullName,
    required String email,
  }) {
    return UserProfile(id: id, fullName: fullName, email: email);
  }
}

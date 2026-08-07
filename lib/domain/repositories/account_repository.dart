import '../entities/finance_entities.dart';

/// Contract for reading the user's primary and linked accounts.
abstract class AccountRepository {
  Future<Account> getPrimaryAccount();

  Future<UserProfile> getCurrentUser();
}

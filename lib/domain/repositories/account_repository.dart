import '../entities/finance_entities.dart';

/// Contract for reading the user's primary and linked accounts.
abstract class AccountRepository {
  Future<Account> getPrimaryAccount();

  Future<UserProfile> getCurrentUser();

  Future<void> updateDisplayName(String fullName);

  Future<void> updateProfile(UserProfile profile);

  /// Adjusts available balance after send / receive / top-up.
  Future<void> applyBalanceDelta(double delta);
}

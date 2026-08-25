import '../entities/auth_user.dart';

/// Local email/password auth for portfolio demos.
abstract class AuthRepository {
  Future<bool> isLoggedIn();

  Future<bool> hasRegisteredAccount();

  Future<AuthUser?> currentUser();

  Future<AuthUser> register({
    required String fullName,
    required String email,
    required String password,
  });

  Future<AuthUser> login({
    required String email,
    required String password,
  });

  /// Unlock for returning users — email read from stored account.
  Future<AuthUser> unlockWithPassword(String password);

  Future<void> logout();
}

class AuthException implements Exception {
  AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

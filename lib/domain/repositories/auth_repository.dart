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

  Future<void> updateAccount({
    String? fullName,
    String? email,
  });

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  Future<UserProfileExtras> getProfileExtras();

  Future<void> saveProfileExtras(UserProfileExtras extras);

  Future<void> logout();
}

class UserProfileExtras {
  const UserProfileExtras({
    this.username,
    this.avatarPath,
    this.dateOfBirth,
  });

  final String? username;
  final String? avatarPath;
  final DateTime? dateOfBirth;
}

class AuthException implements Exception {
  AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}

import '../../core/utils/flowa_password.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/local_auth_data_source.dart';

/// In-memory auth for widget/unit tests.
class InMemoryAuthRepository implements AuthRepository {
  AuthUser? _user;
  String? _passwordHash;
  bool _loggedIn = false;
  UserProfileExtras _extras = const UserProfileExtras();

  @override
  Future<bool> isLoggedIn() async => _loggedIn;

  @override
  Future<bool> hasRegisteredAccount() async => _user != null;

  @override
  Future<AuthUser?> currentUser() async => _loggedIn ? _user : null;

  @override
  Future<AuthUser> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    final trimmedName = fullName.trim();
    final trimmedEmail = email.trim().toLowerCase();
    if (trimmedName.isEmpty) {
      throw AuthException('El nombre es obligatorio');
    }
    if (!FlowaPassword.isStrong(password)) {
      throw AuthException(
        FlowaPassword.validationMessage(password) ??
            'La contraseña no cumple los requisitos',
      );
    }
    if (_user != null && _user!.email == trimmedEmail) {
      throw AuthException('Ya existe una cuenta con este email');
    }
    _user = AuthUser(
      id: 'user-test',
      fullName: trimmedName,
      email: trimmedEmail,
    );
    _passwordHash = LocalAuthDataSource.hashPassword(password);
    _loggedIn = true;
    return _user!;
  }

  @override
  Future<AuthUser> login({
    required String email,
    required String password,
  }) async {
    if (_user == null) {
      throw AuthException('No hay ninguna cuenta. Regístrate primero.');
    }
    if (_user!.email != email.trim().toLowerCase() ||
        _passwordHash != LocalAuthDataSource.hashPassword(password)) {
      throw AuthException('Email o contraseña incorrectos');
    }
    _loggedIn = true;
    return _user!;
  }

  @override
  Future<AuthUser> unlockWithPassword(String password) async {
    if (_user == null) {
      throw AuthException('No hay ninguna cuenta. Regístrate primero.');
    }
    if (_passwordHash != LocalAuthDataSource.hashPassword(password)) {
      throw AuthException('Contraseña incorrecta');
    }
    _loggedIn = true;
    return _user!;
  }

  @override
  Future<void> updateAccount({
    String? fullName,
    String? email,
  }) async {
    final current = _user;
    if (current == null) {
      throw AuthException('No hay ninguna cuenta.');
    }
    _user = AuthUser(
      id: current.id,
      fullName: fullName?.trim().isNotEmpty == true
          ? fullName!.trim()
          : current.fullName,
      email: email?.trim().isNotEmpty == true
          ? email!.trim().toLowerCase()
          : current.email,
    );
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (_passwordHash != LocalAuthDataSource.hashPassword(currentPassword)) {
      throw AuthException('La contraseña actual no es correcta');
    }
    if (!FlowaPassword.isStrong(newPassword)) {
      throw AuthException(
        FlowaPassword.validationMessage(newPassword) ??
            'La contraseña no cumple los requisitos',
      );
    }
    _passwordHash = LocalAuthDataSource.hashPassword(newPassword);
  }

  @override
  Future<UserProfileExtras> getProfileExtras() async => _extras;

  @override
  Future<void> saveProfileExtras(UserProfileExtras extras) async {
    _extras = extras;
  }

  @override
  Future<void> logout() async {
    _loggedIn = false;
  }

  void reset() {
    _user = null;
    _passwordHash = null;
    _loggedIn = false;
    _extras = const UserProfileExtras();
  }
}

import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/local_auth_data_source.dart';

/// In-memory auth for widget/unit tests.
class InMemoryAuthRepository implements AuthRepository {
  AuthUser? _user;
  String? _passwordHash;
  bool _loggedIn = false;

  @override
  Future<bool> isLoggedIn() async => _loggedIn;

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
    if (password.length < 4) {
      throw AuthException('La contraseña debe tener al menos 4 caracteres');
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
  Future<void> logout() async {
    _loggedIn = false;
  }

  void reset() {
    _user = null;
    _passwordHash = null;
    _loggedIn = false;
  }
}

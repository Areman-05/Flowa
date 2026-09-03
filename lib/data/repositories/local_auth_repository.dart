import '../../core/utils/flowa_password.dart';
import '../../domain/entities/auth_user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/local_auth_data_source.dart';

class LocalAuthRepository implements AuthRepository {
  LocalAuthRepository(this._source);

  final LocalAuthDataSource _source;

  @override
  Future<bool> isLoggedIn() async => _source.isLoggedIn;

  @override
  Future<bool> hasRegisteredAccount() async => _source.hasRegisteredAccount;

  @override
  Future<AuthUser?> currentUser() async {
    if (!_source.hasRegisteredAccount) {
      return null;
    }
    final id = _source.userId;
    final name = _source.userName;
    final email = _source.userEmail;
    if (id == null || name == null || email == null) {
      return null;
    }
    return AuthUser(id: id, fullName: name, email: email);
  }

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
    if (!_isValidEmail(trimmedEmail)) {
      throw AuthException('Introduce un email válido');
    }
    if (!FlowaPassword.isStrong(password)) {
      throw AuthException(
        FlowaPassword.validationMessage(password) ??
            'La contraseña no cumple los requisitos',
      );
    }
    if (_source.hasRegisteredAccount &&
        _source.userEmail == trimmedEmail) {
      throw AuthException('Ya existe una cuenta con este email');
    }

    final id = 'user-${DateTime.now().millisecondsSinceEpoch}';
    await _source.saveRegisteredUser(
      id: id,
      fullName: trimmedName,
      email: trimmedEmail,
      password: password,
    );
    return AuthUser(id: id, fullName: trimmedName, email: trimmedEmail);
  }

  @override
  Future<AuthUser> login({
    required String email,
    required String password,
  }) async {
    final trimmedEmail = email.trim().toLowerCase();
    if (!_source.hasRegisteredAccount) {
      throw AuthException('No hay ninguna cuenta. Regístrate primero.');
    }
    if (_source.userEmail != trimmedEmail) {
      throw AuthException('Email o contraseña incorrectos');
    }
    if (!_source.verifyPassword(password)) {
      throw AuthException('Email o contraseña incorrectos');
    }
    await _source.setLoggedIn(true);
    final user = await currentUser();
    if (user == null) {
      throw AuthException('No se pudo cargar el usuario');
    }
    return user;
  }

  @override
  Future<AuthUser> unlockWithPassword(String password) async {
    if (!_source.hasRegisteredAccount) {
      throw AuthException('No hay ninguna cuenta. Regístrate primero.');
    }
    if (!_source.verifyPassword(password)) {
      throw AuthException('Contraseña incorrecta');
    }
    await _source.setLoggedIn(true);
    final user = await currentUser();
    if (user == null) {
      throw AuthException('No se pudo cargar el usuario');
    }
    return user;
  }

  @override
  Future<void> updateAccount({
    String? fullName,
    String? email,
  }) async {
    if (fullName != null) {
      final trimmed = fullName.trim();
      if (trimmed.isEmpty) {
        throw AuthException('El nombre es obligatorio');
      }
      await _source.updateFullName(trimmed);
    }
    if (email != null) {
      final trimmed = email.trim().toLowerCase();
      if (!_isValidEmail(trimmed)) {
        throw AuthException('Introduce un email válido');
      }
      await _source.updateEmail(trimmed);
    }
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    if (!_source.verifyPassword(currentPassword)) {
      throw AuthException('La contraseña actual no es correcta');
    }
    if (!FlowaPassword.isStrong(newPassword)) {
      throw AuthException(
        FlowaPassword.validationMessage(newPassword) ??
            'La contraseña no cumple los requisitos',
      );
    }
    if (currentPassword == newPassword) {
      throw AuthException('La nueva contraseña debe ser distinta');
    }
    await _source.updatePassword(newPassword);
  }

  @override
  Future<UserProfileExtras> getProfileExtras() async {
    return UserProfileExtras(
      username: _source.username,
      avatarPath: _source.avatarPath,
      dateOfBirth: _source.dateOfBirth,
    );
  }

  @override
  Future<void> saveProfileExtras(UserProfileExtras extras) {
    return _source.saveProfileExtras(
      username: extras.username,
      avatarPath: extras.avatarPath,
      dateOfBirth: extras.dateOfBirth,
    );
  }

  @override
  Future<void> logout() => _source.clearSession();

  static bool _isValidEmail(String email) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
  }
}

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Keys for local auth persistence.
abstract final class AuthKeys {
  static const sessionLoggedIn = 'auth_session_logged_in';
  static const userId = 'auth_user_id';
  static const userName = 'auth_user_name';
  static const userEmail = 'auth_user_email';
  static const passwordHash = 'auth_password_hash';
  static const registered = 'auth_registered';
}

/// Thin SharedPreferences wrapper for email/password auth.
class LocalAuthDataSource {
  LocalAuthDataSource(this._prefs);

  final SharedPreferences _prefs;

  static Future<LocalAuthDataSource> create() async {
    final prefs = await SharedPreferences.getInstance();
    return LocalAuthDataSource(prefs);
  }

  bool get isLoggedIn => _prefs.getBool(AuthKeys.sessionLoggedIn) ?? false;

  bool get hasRegisteredAccount =>
      _prefs.getBool(AuthKeys.registered) ?? false;

  String? get userId => _prefs.getString(AuthKeys.userId);

  String? get userName => _prefs.getString(AuthKeys.userName);

  String? get userEmail => _prefs.getString(AuthKeys.userEmail);

  String? get passwordHash => _prefs.getString(AuthKeys.passwordHash);

  Future<void> saveRegisteredUser({
    required String id,
    required String fullName,
    required String email,
    required String password,
  }) async {
    await _prefs.setString(AuthKeys.userId, id);
    await _prefs.setString(AuthKeys.userName, fullName);
    await _prefs.setString(AuthKeys.userEmail, email.toLowerCase().trim());
    await _prefs.setString(AuthKeys.passwordHash, hashPassword(password));
    await _prefs.setBool(AuthKeys.registered, true);
    await _prefs.setBool(AuthKeys.sessionLoggedIn, true);
  }

  Future<void> setLoggedIn(bool value) =>
      _prefs.setBool(AuthKeys.sessionLoggedIn, value);

  Future<void> clearSession() => setLoggedIn(false);

  static String hashPassword(String password) {
    final salted = utf8.encode('flowa.local::$password');
    return base64UrlEncode(salted);
  }

  bool verifyPassword(String password) {
    final stored = passwordHash;
    if (stored == null) {
      return false;
    }
    return stored == hashPassword(password);
  }
}

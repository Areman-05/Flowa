/// Shared password rules for register and unlock.
abstract final class FlowaPassword {
  static const minLength = 8;

  static bool isStrong(String password) {
    if (password.length < minLength) {
      return false;
    }
    final hasLetter = RegExp(r'[A-Za-z]').hasMatch(password);
    final hasDigit = RegExp(r'\d').hasMatch(password);
    return hasLetter && hasDigit;
  }

  static String? validationMessage(String password) {
    if (password.length < minLength) {
      return 'Mínimo $minLength caracteres';
    }
    if (!RegExp(r'[A-Za-z]').hasMatch(password)) {
      return 'Incluye al menos una letra';
    }
    if (!RegExp(r'\d').hasMatch(password)) {
      return 'Incluye al menos un número';
    }
    return null;
  }
}

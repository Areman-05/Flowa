/// PIN helpers for the lightweight app lock.
abstract final class FlowaPin {
  static const length = 4;

  static String? validate(String? value) {
    final digits = (value ?? '').trim();
    if (digits.length != length) {
      return 'El PIN debe tener $length dígitos';
    }
    if (!RegExp(r'^\d{4}$').hasMatch(digits)) {
      return 'El PIN solo puede contener números';
    }
    return null;
  }

  static bool matches({required String stored, required String attempt}) {
    return stored == attempt;
  }
}

/// Form validators shared by money and account flows.
abstract final class FlowaValidators {
  static final RegExp _email = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  static String? requiredLabel(String? value, {required String field}) {
    if (value == null || value.trim().isEmpty) {
      return '$field is required';
    }
    return null;
  }

  static String? email(String? value) {
    final required = requiredLabel(value, field: 'Email');
    if (required != null) {
      return required;
    }
    if (!_email.hasMatch(value!.trim())) {
      return 'Enter a valid email';
    }
    return null;
  }

  static String? optionalEmail(String? value) {
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    return email(value);
  }

  static String? positiveAmount(String? value, {String field = 'Amount'}) {
    final required = requiredLabel(value, field: field);
    if (required != null) {
      return required;
    }
    final parsed = double.tryParse(value!.trim());
    if (parsed == null) {
      return '$field must be a number';
    }
    if (parsed <= 0) {
      return '$field must be greater than zero';
    }
    return null;
  }

  static String? accountNumber(String? value) {
    final required = requiredLabel(value, field: 'Account number');
    if (required != null) {
      return required;
    }
    final digits = value!.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 8) {
      return 'Account number looks too short';
    }
    return null;
  }
}

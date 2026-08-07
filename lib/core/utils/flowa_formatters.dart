import 'package:intl/intl.dart';

import '../constants/flowa_constants.dart';

/// Shared money and date formatting helpers.
abstract final class FlowaFormatters {
  static final NumberFormat _currency = NumberFormat.currency(
    symbol: FlowaConstants.currencySymbol,
    decimalDigits: 2,
  );

  static final DateFormat _transactionStamp = DateFormat('MMM d · hh:mm a');

  static String currency(double amount) => _currency.format(amount);

  static String signedCurrency(double signedAmount) {
    final absolute = currency(signedAmount.abs());
    if (signedAmount > 0) {
      return '+$absolute';
    }
    if (signedAmount < 0) {
      return '-$absolute';
    }
    return absolute;
  }

  static String transactionStamp(DateTime value) {
    return _transactionStamp.format(value.toLocal());
  }

  static String maskedBalance({
    required double amount,
    required bool visible,
  }) {
    if (visible) {
      return currency(amount);
    }
    return '******';
  }
}

/// Time-based greeting used on the Home header.
abstract final class FlowaGreeting {
  static String forDateTime(DateTime now) {
    final hour = now.hour;
    if (hour < 12) {
      return 'Good Morning,';
    }
    if (hour < 18) {
      return 'Good Afternoon,';
    }
    return 'Good Evening,';
  }
}

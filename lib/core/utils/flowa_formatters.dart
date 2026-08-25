import 'package:intl/intl.dart';

import '../constants/flowa_constants.dart';

/// Shared money and date formatting helpers (es_ES / EUR).
abstract final class FlowaFormatters {
  static final NumberFormat _currency = NumberFormat.currency(
    locale: 'es_ES',
    symbol: FlowaConstants.currencySymbol,
    decimalDigits: 2,
  );

  static final DateFormat _transactionStamp =
      DateFormat('d MMM · HH:mm', 'es_ES');

  static String currency(double amount, {String? locale}) {
    if (locale != null) {
      return NumberFormat.currency(
        locale: locale,
        symbol: FlowaConstants.currencySymbol,
        decimalDigits: 2,
      ).format(amount);
    }
    return _currency.format(amount);
  }

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

  static String dayHeading(DateTime value) {
    final local = value.toLocal();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(local.year, local.month, local.day);
    final diff = today.difference(day).inDays;
    if (diff == 0) {
      return 'Hoy';
    }
    if (diff == 1) {
      return 'Ayer';
    }
    return DateFormat('d MMMM', 'es_ES').format(local);
  }

  static final NumberFormat _plain = NumberFormat('#,##0.00', 'es_ES');

  /// Splits an amount into its integer and fractional halves so the hero
  /// figure can typeset them at different sizes.
  static ({String integer, String fraction}) amountParts(double amount) {
    final formatted = _plain.format(amount.abs());
    final separator = formatted.lastIndexOf(',');
    if (separator < 0) {
      return (integer: formatted, fraction: '00');
    }
    return (
      integer: formatted.substring(0, separator),
      fraction: formatted.substring(separator + 1),
    );
  }

  /// Whole-euro rendering for dense statement rows.
  static String compact(double amount) =>
      '${NumberFormat('#,##0', 'es_ES').format(amount.abs())} '
      '${FlowaConstants.currencySymbol}';

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
      return 'Buenos días,';
    }
    if (hour < 18) {
      return 'Buenas tardes,';
    }
    return 'Buenas noches,';
  }
}

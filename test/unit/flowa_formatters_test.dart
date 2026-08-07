import 'package:flowa/core/utils/flowa_formatters.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FlowaFormatters', () {
    test('formats currency with two decimals', () {
      expect(FlowaFormatters.currency(2150), r'$2,150.00');
    });

    test('signedCurrency prefixes income and expenses', () {
      expect(FlowaFormatters.signedCurrency(255), r'+$255.00');
      expect(FlowaFormatters.signedCurrency(-14.99), r'-$14.99');
    });

    test('maskedBalance hides or reveals amount', () {
      expect(
        FlowaFormatters.maskedBalance(amount: 100, visible: false),
        '******',
      );
      expect(
        FlowaFormatters.maskedBalance(amount: 100, visible: true),
        r'$100.00',
      );
    });
  });

  group('FlowaGreeting', () {
    test('returns morning before noon', () {
      expect(
        FlowaGreeting.forDateTime(DateTime(2026, 8, 7, 9)),
        'Good Morning,',
      );
    });

    test('returns afternoon and evening windows', () {
      expect(
        FlowaGreeting.forDateTime(DateTime(2026, 8, 7, 15)),
        'Good Afternoon,',
      );
      expect(
        FlowaGreeting.forDateTime(DateTime(2026, 8, 7, 20)),
        'Good Evening,',
      );
    });
  });
}

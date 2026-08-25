import 'package:flowa/design_system/tokens/flowa_colors.dart';
import 'package:flowa/domain/entities/finance_entities.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FlowaColors', () {
    test('primary brand color stays Radient orange', () {
      expect(FlowaColors.primary, const Color(0xFFFF5722));
    });

    test('card gradient exposes multiple stops', () {
      expect(FlowaColors.cardPrimaryGradient.colors.length, greaterThan(1));
    });
  });

  group('TransactionItem', () {
    test('signedAmount is negative for debits', () {
      final item = TransactionItem(
        id: '1',
        merchant: 'Apple',
        amount: 343.81,
        occurredAt: DateTime.utc(2026, 3, 1, 15, 43),
        direction: TransactionDirection.debit,
      );

      expect(item.isIncome, isFalse);
      expect(item.signedAmount, -343.81);
    });

    test('signedAmount is positive for credits', () {
      final item = TransactionItem(
        id: '2',
        merchant: 'PayPal Payment',
        amount: 255,
        occurredAt: DateTime.utc(2026, 3, 2, 10),
        direction: TransactionDirection.credit,
      );

      expect(item.isIncome, isTrue);
      expect(item.signedAmount, 255);
    });
  });

  group('Account', () {
    test('lastFour extracts trailing digits', () {
      const account = Account(
        id: 'acc-1',
        displayName: 'Main',
        maskedNumber: '**** **** **** 6457',
        availableBalance: 2150,
        expiryLabel: '12/28',
      );

      expect(account.lastFour, '6457');
    });
  });

  group('UserProfile', () {
    test('firstName uses the leading token', () {
      const user = UserProfile(id: 'u1', fullName: 'John Doe');
      expect(user.firstName, 'John');
    });
  });
}

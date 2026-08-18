import 'package:flowa/core/extensions/finance_labels.dart';
import 'package:flowa/core/utils/debouncer.dart';
import 'package:flowa/data/repositories/in_memory_preferences_repository.dart';
import 'package:flowa/domain/entities/finance_entities.dart';
import 'package:flowa/domain/repositories/preferences_repository.dart';
import 'package:flowa/features/transactions/domain/transaction_filters.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TransactionFilters', () {
    final items = [
      TransactionItem(
        id: '1',
        merchant: 'Apple',
        amount: 10,
        occurredAt: DateTime(2026),
        direction: TransactionDirection.debit,
        category: 'Shopping',
      ),
      TransactionItem(
        id: '2',
        merchant: 'PayPal Payment',
        amount: 20,
        occurredAt: DateTime(2026, 1, 2),
        direction: TransactionDirection.credit,
        category: 'Transfer',
      ),
    ];

    test('filters income and expense', () {
      expect(
        TransactionFilters.apply(
          items: items,
          filter: TransactionFilter.income,
        ),
        hasLength(1),
      );
      expect(
        TransactionFilters.apply(
          items: items,
          filter: TransactionFilter.expense,
        ).first.merchant,
        'Apple',
      );
    });

    test('searches by merchant and totals', () {
      final found = TransactionFilters.apply(
        items: items,
        filter: TransactionFilter.all,
        query: 'pay',
      );
      expect(found, hasLength(1));
      expect(TransactionFilters.totalOutgoing(items), 10);
      expect(TransactionFilters.totalIncoming(items), 20);
    });

    test('searches by amount', () {
      final found = TransactionFilters.apply(
        items: items,
        filter: TransactionFilter.all,
        query: '10',
      );
      expect(found, hasLength(1));
      expect(found.first.merchant, 'Apple');
    });
  });

  group('InMemoryPreferencesRepository', () {
    test('persists onboarding and notification prefs', () async {
      final repo = InMemoryPreferencesRepository();
      expect(await repo.isOnboardingComplete(), isFalse);
      await repo.completeOnboarding();
      expect(await repo.isOnboardingComplete(), isTrue);

      await repo.saveNotificationPreferences(
        const NotificationPreferences(
          allowNotifications: true,
          transactionNotifications: true,
          marketingNotifications: true,
        ),
      );
      final prefs = await repo.getNotificationPreferences();
      expect(prefs.marketingNotifications, isTrue);
    });
  });

  group('Debouncer', () {
    test('runs only the latest callback', () async {
      final debouncer = Debouncer(delay: const Duration(milliseconds: 40));
      var value = 0;
      debouncer.run(() => value = 1);
      debouncer.run(() => value = 2);
      await Future<void>.delayed(const Duration(milliseconds: 80));
      expect(value, 2);
      debouncer.dispose();
    });
  });

  group('finance labels', () {
    test('maps purpose and access enums', () {
      expect(AccountKind.business.label, 'Business');
      expect(AccessLevel.limited.label, 'Limited');
    });
  });
}

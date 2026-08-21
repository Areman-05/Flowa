import 'package:flowa/core/utils/receive_request.dart';
import 'package:flowa/core/utils/transaction_export.dart';
import 'package:flowa/data/repositories/mock_account_repository.dart';
import 'package:flowa/data/repositories/mock_scheduled_transfer_repository.dart';
import 'package:flowa/domain/entities/budget_goal.dart';
import 'package:flowa/domain/entities/finance_entities.dart';
import 'package:flowa/domain/entities/scheduled_transfer.dart';
import 'package:flowa/features/insights/domain/spending_snapshot.dart';
import 'package:flowa/features/transactions/domain/transaction_filters.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('es_ES');
  });

  group('ReceiveRequest', () {
    test('includes optional note in share copy', () {
      const account = Account(
        id: 'acc',
        displayName: 'Main Visa',
        maskedNumber: '**** 6457',
        availableBalance: 100,
        expiryLabel: '12/28',
      );
      final message = ReceiveRequest.build(
        account: account,
        amount: 25,
        note: 'Dinner',
      );
      expect(message, contains('Dinner'));
      expect(message, contains('25,00\u00a0€'));
      expect(message, startsWith('Paga '));
      expect(message, contains('Nota:'));
    });
  });

  group('TransactionExport', () {
    test('builds CSV header and receipt text', () {
      final item = TransactionItem(
        id: 'tx-1',
        merchant: 'Apple',
        amount: 10,
        occurredAt: DateTime(2026, 3, 1),
        direction: TransactionDirection.debit,
        category: 'Shopping',
      );
      expect(TransactionExport.toCsv([item]), contains('Apple'));
      expect(TransactionExport.receiptFor(item), contains('Flowa receipt'));
    });
  });

  group('BudgetGoal', () {
    test('tracks progress and over-budget state', () {
      const goal = BudgetGoal(monthlyLimit: 100, enabled: true);
      expect(goal.progressFor(50), 0.5);
      expect(goal.isOverBudget(120), isTrue);
    });
  });

  group('TransactionFilters amount search', () {
    test('matches exact expense amounts', () {
      final items = [
        TransactionItem(
          id: '1',
          merchant: 'Apple',
          amount: 14.99,
          occurredAt: DateTime(2026, 3),
          direction: TransactionDirection.debit,
        ),
      ];
      final found = TransactionFilters.apply(
        items: items,
        filter: TransactionFilter.all,
        query: '14.99',
      );
      expect(found, hasLength(1));
    });
  });

  group('SpendingInsights categories', () {
    test('groups outgoing totals by category', () {
      final snapshot = SpendingInsights.from([
        TransactionItem(
          id: '1',
          merchant: 'Apple',
          amount: 100,
          occurredAt: DateTime(2026, 3),
          direction: TransactionDirection.debit,
          category: 'Shopping',
        ),
        TransactionItem(
          id: '2',
          merchant: 'Spotify',
          amount: 10,
          occurredAt: DateTime(2026, 3, 2),
          direction: TransactionDirection.debit,
          category: 'Entertainment',
        ),
      ]);
      expect(snapshot.categories, hasLength(2));
      expect(snapshot.categories.first.category, 'Shopping');
    });
  });

  group('MockScheduledTransferRepository', () {
    test('returns seeded scheduled transfers', () async {
      final repo = MockScheduledTransferRepository(
        seed: [
          ScheduledTransfer(
            id: 's1',
            recipientName: 'Emma Parker',
            accountNumber: '1476584951012345',
            amount: 50,
            scheduledFor: DateTime(2026, 4, 1),
            frequency: ScheduledTransferFrequency.monthly,
          ),
        ],
      );
      final items = await repo.getAll();
      expect(items, isNotEmpty);
      expect(
        items.any((item) => item.recipientName == 'Emma Parker'),
        isTrue,
      );
      expect(items.first.frequencyLabel, 'Mensual');
    });
  });

  group('MockAccountRepository', () {
    test('updates display name', () async {
      final repo = MockAccountRepository();
      await repo.updateDisplayName('Jane Doe');
      expect((await repo.getCurrentUser()).fullName, 'Jane Doe');
    });
  });
}

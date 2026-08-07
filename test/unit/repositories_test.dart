import 'package:flowa/data/repositories/mock_account_repository.dart';
import 'package:flowa/data/repositories/mock_transaction_repository.dart';
import 'package:flowa/domain/entities/money_flow_kind.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MockAccountRepository', () {
    const repository = MockAccountRepository();

    test('returns primary Visa account', () async {
      final account = await repository.getPrimaryAccount();
      expect(account.lastFour, '6457');
      expect(account.brand, 'VISA');
    });

    test('returns current user profile', () async {
      final user = await repository.getCurrentUser();
      expect(user.fullName, 'John Doe');
      expect(user.firstName, 'John');
    });
  });

  group('MockTransactionRepository', () {
    const repository = MockTransactionRepository();

    test('getRecent respects limit and newest-first order', () async {
      final recent = await repository.getRecent(limit: 3);
      expect(recent, hasLength(3));
      expect(
        recent.first.occurredAt.isAfter(recent.last.occurredAt) ||
            recent.first.occurredAt.isAtSameMomentAs(recent.last.occurredAt),
        isTrue,
      );
    });

    test('getAll returns the full seeded history', () async {
      final all = await repository.getAll();
      expect(all.length, greaterThanOrEqualTo(4));
    });
  });

  group('MoneyFlowKind', () {
    test('keeps Send and Top-Up visually/logically distinct', () {
      expect(MoneyFlowKind.send.title, 'Send Money');
      expect(MoneyFlowKind.topUp.title, 'Top-Up');
      expect(MoneyFlowKind.send.clarification, isNot(MoneyFlowKind.topUp.clarification));
      expect(MoneyFlowKind.topUp.requiresDestructiveConfirmation, isTrue);
      expect(MoneyFlowKind.send.requiresDestructiveConfirmation, isFalse);
    });
  });
}

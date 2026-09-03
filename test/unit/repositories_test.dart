import 'package:flowa/data/repositories/mock_account_repository.dart';
import 'package:flowa/data/repositories/mock_transaction_repository.dart';
import 'package:flowa/domain/entities/finance_entities.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('MockAccountRepository', () {
    test('starts empty and bootstraps user account', () async {
      final repository = MockAccountRepository();
      final guest = await repository.getCurrentUser();
      expect(guest.fullName, 'Invitado');

      repository.bootstrapUser(
        const UserProfile(
          id: 'user-1',
          fullName: 'Ana López',
          email: 'ana@mail.com',
        ),
      );
      final user = await repository.getCurrentUser();
      expect(user.fullName, 'Ana López');
      final account = await repository.getPrimaryAccount();
      expect(account.availableBalance, 0);
      expect(account.brand, 'VISA');
    });

    test('applyBalanceDelta updates available balance', () async {
      final repository = MockAccountRepository();
      await repository.applyBalanceDelta(50);
      final account = await repository.getPrimaryAccount();
      expect(account.availableBalance, 50);
    });
  });

  group('MockTransactionRepository', () {
    test('starts empty and accepts new movements', () async {
      final repository = MockTransactionRepository();
      expect(await repository.getAll(), isEmpty);

      await repository.add(
        TransactionItem(
          id: 'tx-1',
          merchant: 'Café',
          amount: 3.5,
          occurredAt: DateTime(2026, 3, 1),
          direction: TransactionDirection.debit,
        ),
      );
      final all = await repository.getAll();
      expect(all, hasLength(1));
      expect(all.first.merchant, 'Café');
    });
  });
}

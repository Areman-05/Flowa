import 'package:flowa/core/utils/flowa_pin.dart';
import 'package:flowa/data/repositories/mock_inbox_repository.dart';
import 'package:flowa/domain/entities/finance_entities.dart';
import 'package:flowa/domain/entities/inbox_notification.dart';
import 'package:flowa/features/insights/domain/spending_snapshot.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FlowaPin', () {
    test('rejects short or non-digit values', () {
      expect(FlowaPin.validate('12'), isNotNull);
      expect(FlowaPin.validate('12ab'), isNotNull);
      expect(FlowaPin.validate('1234'), isNull);
    });

    test('matches stored PIN', () {
      expect(FlowaPin.matches(stored: '1234', attempt: '1234'), isTrue);
      expect(FlowaPin.matches(stored: '1234', attempt: '0000'), isFalse);
    });
  });

  group('MockInboxRepository', () {
    test('counts unread and marks items read', () async {
      final repo = MockInboxRepository(
        seed: [
          InboxNotification(
            id: 'n1',
            title: 'Money request from Emma',
            body: 'Emma asked for 25 €',
            kind: InboxNotificationKind.moneyRequest,
            createdAt: DateTime(2026, 3, 1),
            actionLabel: 'Review',
          ),
          InboxNotification(
            id: 'n2',
            title: 'Security tip',
            body: 'Enable PIN',
            kind: InboxNotificationKind.security,
            createdAt: DateTime(2026, 3, 2),
            isRead: true,
          ),
        ],
      );
      expect(await repo.unreadCount(), greaterThan(0));
      await repo.markRead('n1');
      final items = await repo.getAll();
      expect(items.firstWhere((item) => item.id == 'n1').isRead, isTrue);
      await repo.markAllRead();
      expect(await repo.unreadCount(), 0);
    });

    test('money requests stay actionable', () {
      final item = InboxNotification(
        id: 'x',
        title: 'Request',
        body: 'Pay me',
        kind: InboxNotificationKind.moneyRequest,
        createdAt: DateTime(2026, 3),
        actionLabel: 'Review',
      );
      expect(item.isActionable, isTrue);
    });
  });

  group('SpendingInsights', () {
    test('computes net and top merchant from expenses', () {
      final snapshot = SpendingInsights.from([
        TransactionItem(
          id: '1',
          merchant: 'Apple',
          amount: 100,
          occurredAt: DateTime(2026, 3),
          direction: TransactionDirection.debit,
        ),
        TransactionItem(
          id: '2',
          merchant: 'Spotify',
          amount: 10,
          occurredAt: DateTime(2026, 3, 2),
          direction: TransactionDirection.debit,
        ),
        TransactionItem(
          id: '3',
          merchant: 'PayPal Payment',
          amount: 80,
          occurredAt: DateTime(2026, 3, 3),
          direction: TransactionDirection.credit,
        ),
      ]);

      expect(snapshot.outgoing, 110);
      expect(snapshot.incoming, 80);
      expect(snapshot.net, -30);
      expect(snapshot.topMerchant, 'Apple');
      expect(snapshot.isPositive, isFalse);
    });
  });
}

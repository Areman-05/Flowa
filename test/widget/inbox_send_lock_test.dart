import 'package:flowa/core/utils/flowa_services.dart';
import 'package:flowa/data/repositories/mock_inbox_repository.dart';
import 'package:flowa/domain/entities/inbox_notification.dart';
import 'package:flowa/features/lock/presentation/pin_lock_pages.dart';
import 'package:flowa/features/notifications/presentation/notification_inbox_page.dart';
import 'package:flowa/features/send_money/presentation/send_review_page.dart';
import 'package:flowa/features/wallets/presentation/wallets_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('es_ES');
  });

  setUp(FlowaServices.resetToMocks);

  testWidgets('inbox lists actionable money request', (tester) async {
    FlowaServices.inboxRepository = MockInboxRepository(
      seed: [
        InboxNotification(
          id: 'n1',
          title: 'Money request from Emma',
          body: 'Emma asked for 25 €',
          kind: InboxNotificationKind.moneyRequest,
          createdAt: DateTime(2026, 3, 1),
          actionLabel: 'Review',
        ),
      ],
    );

    await tester.pumpWidget(const MaterialApp(home: NotificationInboxPage()));
    await tester.pumpAndSettle();

    expect(find.text('Avisos'), findsOneWidget);
    expect(find.text('Money request from Emma'), findsOneWidget);
    expect(find.byTooltip('Marcar todas'), findsOneWidget);
  });

  testWidgets('send review confirms bank transfer copy', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: SendReviewPage(
          recipientName: 'Emma Parker',
          accountNumber: '1476584951012345',
          amount: 25,
          note: 'Dinner',
        ),
      ),
    );

    expect(find.text('Revisar'), findsOneWidget);
    expect(find.text('Emma Parker'), findsOneWidget);
    expect(find.text('Enviar ahora'), findsOneWidget);
  });

  testWidgets('wallets page shows PayPal connect CTA', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: WalletsPage()));
    await tester.pumpAndSettle();

    expect(find.text('Monederos'), findsOneWidget);
    expect(find.textContaining('PayPal'), findsWidgets);
  });

  testWidgets('PIN setup exposes lock toggle', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: PinSetupPage()));
    await tester.pumpAndSettle();

    expect(find.text('Bloqueo'), findsOneWidget);
    expect(find.text('Require PIN on launch'), findsOneWidget);
  });
}

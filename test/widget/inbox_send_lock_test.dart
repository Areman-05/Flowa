import 'package:flowa/features/lock/presentation/pin_lock_pages.dart';
import 'package:flowa/features/notifications/presentation/notification_inbox_page.dart';
import 'package:flowa/features/send_money/presentation/send_review_page.dart';
import 'package:flowa/features/wallets/presentation/wallets_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('inbox lists actionable money request', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: NotificationInboxPage()));
    await tester.pumpAndSettle();

    expect(find.text('Notifications'), findsOneWidget);
    expect(find.text('Money request from Emma'), findsOneWidget);
    expect(find.text('Mark all'), findsOneWidget);
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

    expect(find.text('Review Send'), findsOneWidget);
    expect(find.textContaining('not a Top-Up'), findsOneWidget);
    expect(find.text('Emma Parker'), findsOneWidget);
    expect(find.text('Send now'), findsOneWidget);
  });

  testWidgets('wallets page shows PayPal connect CTA', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: WalletsPage()));
    await tester.pumpAndSettle();

    expect(find.text('Wallets'), findsOneWidget);
    expect(find.text('Connect PayPal'), findsOneWidget);
  });

  testWidgets('PIN setup exposes lock toggle', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: PinSetupPage()));
    await tester.pumpAndSettle();

    expect(find.text('App lock'), findsOneWidget);
    expect(find.text('Require PIN on launch'), findsOneWidget);
  });
}

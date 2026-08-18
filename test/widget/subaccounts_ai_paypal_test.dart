import 'package:flowa/core/utils/flowa_services.dart';
import 'package:flowa/features/ai_assistant/presentation/ai_assistant_page.dart';
import 'package:flowa/features/sub_accounts/presentation/create_sub_account_page.dart';
import 'package:flowa/features/wallets/presentation/connect_paypal_page.dart';
import 'package:flowa/shared/widgets/flowa_more_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(FlowaServices.resetToMocks);

  testWidgets('create sub-account form validates and saves', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: CreateSubAccountPage()));

    await tester.enterText(find.byType(TextField).first, "Emma's College Fund");
    final createButton = find.text('Create Sub-Account').last;
    await tester.scrollUntilVisible(
      createButton,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(createButton);
    await tester.pumpAndSettle();

    final items = await FlowaServices.subAccountRepository.getAll();
    expect(items.any((item) => item.name == "Emma's College Fund"), isTrue);
  });

  testWidgets('PayPal connect screen shows secure login copy', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ConnectPayPalPage()));

    expect(find.text('Connect PayPal'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Secure login handled by PayPal.'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Secure login handled by PayPal.'), findsOneWidget);
    expect(find.text('Log In'), findsOneWidget);
  });

  testWidgets('AI assistant starts chat from quick action', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: AiAssistantPage()));
    await tester.pumpAndSettle();

    expect(find.text('What Can I Help You?'), findsOneWidget);
    await tester.tap(find.text('Top-Up'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Top-Up'), findsWidgets);
  });

  testWidgets('more sheet exposes sub-accounts and extra tools', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: ElevatedButton(
                onPressed: () => showFlowaMoreActionsSheet(context),
                child: const Text('Open more'),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Open more'));
    await tester.pumpAndSettle();

    expect(find.text('Sub-Accounts'), findsOneWidget);
    expect(find.text('Wallets'), findsOneWidget);
    expect(find.text('Insights'), findsOneWidget);
  });
}

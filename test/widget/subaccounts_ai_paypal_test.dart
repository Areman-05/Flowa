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
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'Emma College Fund');
    await tester.pump();
    await tester.tap(find.text('Crear subcuenta'));
    await tester.pumpAndSettle();

    final items = await FlowaServices.subAccountRepository.getAll();
    expect(items.any((item) => item.name == 'Emma College Fund'), isTrue);
  });

  testWidgets('PayPal connect screen shows secure login copy', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ConnectPayPalPage()));

    expect(find.text('Conectar PayPal'), findsOneWidget);
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

    expect(find.text('¿En qué te ayudo?'), findsOneWidget);
    await tester.tap(find.text('Recargar'));
    await tester.pumpAndSettle();

    expect(find.text('Recargar desde'), findsOneWidget);
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

    expect(find.text('Subcuentas'), findsOneWidget);
    expect(find.text('Monederos'), findsOneWidget);
    expect(find.text('Resumen'), findsOneWidget);
    expect(find.text('Contactos'), findsOneWidget);
  });
}

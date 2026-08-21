import 'package:flowa/app/flowa_app.dart';
import 'package:flowa/core/utils/flowa_services.dart';
import 'package:flowa/data/repositories/in_memory_auth_repository.dart';
import 'package:flowa/data/repositories/in_memory_preferences_repository.dart';
import 'package:flowa/data/repositories/mock_transaction_repository.dart';
import 'package:flowa/domain/entities/finance_entities.dart';
import 'package:flowa/features/notifications/presentation/notification_settings_page.dart';
import 'package:flowa/features/top_up/presentation/top_up_page.dart';
import 'package:flowa/shared/widgets/flowa_dialogs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('es_ES');
  });

  setUp(() async {
    final prefs = InMemoryPreferencesRepository();
    await prefs.completeOnboarding();
    final auth = InMemoryAuthRepository();
    await auth.register(
      fullName: 'Ana López',
      email: 'ana@mail.com',
      password: '1234',
    );
    FlowaServices.resetToMocks(preferences: prefs, auth: auth);
    FlowaServices.transactionRepository = MockTransactionRepository(
      seed: [
        TransactionItem(
          id: 'tx-apple',
          merchant: 'Apple',
          amount: 14.99,
          occurredAt: DateTime(2026, 3, 1),
          direction: TransactionDirection.debit,
          category: 'Shopping',
        ),
      ],
    );
  });

  testWidgets('home loads account and recent merchants', (tester) async {
    await tester.pumpWidget(const FlowaApp());
    await tester.pumpAndSettle();

    expect(find.text('Ana López'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Apple'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Apple'), findsWidgets);
    expect(find.text('Enviar'), findsOneWidget);
    expect(find.text('Recargar'), findsOneWidget);
  });

  testWidgets('top-up page uses gold flow and confirmation copy', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: TopUpPage()),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Recargar'), findsOneWidget);
    expect(find.text('Recargar desde'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Continuar'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Continuar'), findsOneWidget);

    await tester.enterText(find.byType(TextField).first, '600123456');
    await tester.enterText(find.byType(TextField).at(1), '20');
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();

    expect(find.text('¿Confirmas que es una recarga?'), findsOneWidget);
    expect(find.text('Recargar ahora'), findsOneWidget);
    expect(find.text('No, Go Back'), findsOneWidget);
  });

  testWidgets('notification settings default marketing off', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: NotificationSettingsPage()),
    );
    await tester.pumpAndSettle();

    final marketing = find.widgetWithText(
      SwitchListTile,
      'Marketing and Promotions',
    );
    expect(marketing, findsOneWidget);

    final tile = tester.widget<SwitchListTile>(marketing);
    expect(tile.value, isFalse);
  });

  testWidgets('confirmation dialog returns false on cancel', (tester) async {
    var confirmed = true;

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: ElevatedButton(
                onPressed: () async {
                  confirmed = await showFlowaConfirmationDialog(
                    context: context,
                    title: '¿Confirmas que es una recarga?',
                    message: 'Check again.',
                    confirmLabel: 'Recargar ahora',
                  );
                },
                child: const Text('Open'),
              ),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('No, Go Back'));
    await tester.pumpAndSettle();

    expect(confirmed, isFalse);
  });
}

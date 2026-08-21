import 'package:flowa/app/flowa_app.dart';
import 'package:flowa/core/utils/flowa_services.dart';
import 'package:flowa/data/repositories/in_memory_auth_repository.dart';
import 'package:flowa/data/repositories/in_memory_preferences_repository.dart';
import 'package:flowa/domain/entities/finance_entities.dart';
import 'package:flowa/features/onboarding/presentation/onboarding_page.dart';
import 'package:flowa/features/support/presentation/support_center_page.dart';
import 'package:flowa/features/transactions/presentation/transaction_detail_page.dart';
import 'package:flowa/features/transfers/presentation/transfer_success_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('es_ES');
  });

  setUp(() async {
    final prefs = InMemoryPreferencesRepository();
    final auth = InMemoryAuthRepository();
    await auth.register(
      fullName: 'Ana López',
      email: 'ana@mail.com',
      password: '1234',
    );
    FlowaServices.resetToMocks(preferences: prefs, auth: auth);
  });

  testWidgets('onboarding appears until completed', (tester) async {
    await tester.pumpWidget(const FlowaApp());
    await tester.pumpAndSettle();

    expect(find.byType(OnboardingPage), findsOneWidget);
    expect(find.text('Claridad primero'), findsOneWidget);

    await tester.tap(find.text('Saltar'));
    await tester.pumpAndSettle();

    expect(find.text('Ana López'), findsOneWidget);
  });

  testWidgets('support center filters articles', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: SupportCenterPage()),
    );

    expect(find.textContaining('Send, not Top-Up'), findsOneWidget);
    await tester.enterText(find.byType(TextField), 'paypal');
    await tester.pumpAndSettle();
    expect(find.textContaining('PayPal'), findsWidgets);
  });

  testWidgets('transaction detail shows merchant amount', (tester) async {
    final item = TransactionItem(
      id: 'tx-1',
      merchant: 'Apple',
      amount: 343.81,
      occurredAt: DateTime(2026, 3, 1, 15, 43),
      direction: TransactionDirection.debit,
      category: 'Shopping',
    );

    await tester.pumpWidget(
      MaterialApp(home: TransactionDetailPage(item: item)),
    );

    expect(find.text('Apple'), findsOneWidget);
    expect(find.textContaining('Need help'), findsOneWidget);
  });

  testWidgets('transfer success shows amount and done', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: TransferSuccessPage(
          title: 'Money sent',
          amount: 25,
          subtitle: 'Delivered to Alex',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Money sent'), findsOneWidget);
    expect(find.text('Done'), findsOneWidget);
  });
}

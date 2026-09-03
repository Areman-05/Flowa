import 'package:flowa/core/utils/flowa_services.dart';
import 'package:flowa/data/repositories/in_memory_auth_repository.dart';
import 'package:flowa/data/repositories/in_memory_preferences_repository.dart';
import 'package:flowa/data/repositories/mock_account_repository.dart';
import 'package:flowa/domain/entities/finance_entities.dart';
import 'package:flowa/features/home/presentation/card_wallet_store.dart';
import 'package:flowa/features/more/presentation/more_payment_review_page.dart';
import 'package:flowa/features/profile/presentation/profile_edit_page.dart';
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
      fullName: 'John Doe',
      email: 'john@gmail.com',
      password: 'Flowa1234',
    );
    FlowaServices.resetToMocks(preferences: prefs, auth: auth);
    CardWalletStore.instance.clear();
  });

  testWidgets('profile edit save updates account repository', (tester) async {
    final user = UserProfile(
      id: 'user-1',
      fullName: 'John Doe',
      username: 'john',
      email: 'john@gmail.com',
      dateOfBirth: DateTime(1995, 5, 4),
    );
    final accountRepo = FlowaServices.accountRepository;
    if (accountRepo is MockAccountRepository) {
      accountRepo.bootstrapUser(user);
    }

    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) {
            return Scaffold(
              body: TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<bool>(
                      builder: (_) => ProfileEditPage(user: user),
                    ),
                  );
                },
                child: const Text('Abrir'),
              ),
            );
          },
        ),
      ),
    );
    await tester.tap(find.text('Abrir'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField).first, 'Jane Roe');
    await tester.tap(find.text('Guardar'));
    await tester.pumpAndSettle();

    final saved = await FlowaServices.accountRepository.getCurrentUser();
    expect(saved.fullName, 'Jane Roe');
    expect(saved.username, 'john');
    expect(saved.email, 'john@gmail.com');
  });

  testWidgets('payment review shows pay-from card', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MorePaymentReviewPage(
          merchant: 'Movistar',
          amount: 12.5,
          category: 'Móvil',
          successTitle: 'Pagado',
          successSubtitle: 'Recibo listo',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Pagar con'), findsWidgets);
    expect(find.text('Movistar'), findsWidgets);
  });
}

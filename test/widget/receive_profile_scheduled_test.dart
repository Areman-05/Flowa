import 'package:flowa/core/utils/flowa_services.dart';
import 'package:flowa/data/repositories/in_memory_preferences_repository.dart';
import 'package:flowa/data/repositories/mock_scheduled_transfer_repository.dart';
import 'package:flowa/domain/entities/scheduled_transfer.dart';
import 'package:flowa/features/profile/presentation/profile_edit_page.dart';
import 'package:flowa/features/receive/presentation/receive_page.dart';
import 'package:flowa/features/send_money/presentation/scheduled_transfers_page.dart';
import 'package:flowa/domain/entities/finance_entities.dart';
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
    FlowaServices.resetToMocks(preferences: prefs);
    FlowaServices.scheduledTransferRepository =
        MockScheduledTransferRepository(
      seed: [
        ScheduledTransfer(
          id: 's1',
          recipientName: 'Emma Parker',
          accountNumber: '1476584951012345',
          amount: 50,
          scheduledFor: DateTime(2026, 4, 1),
          frequency: ScheduledTransferFrequency.monthly,
        ),
      ],
    );
  });

  testWidgets('receive page exposes copy account action', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ReceivePage()));
    await tester.pumpAndSettle();

    expect(find.text('Copiar número'), findsOneWidget);
  });

  testWidgets('scheduled transfers lists Emma Parker', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ScheduledTransfersPage()));
    await tester.pumpAndSettle();

    expect(find.text('Emma Parker'), findsOneWidget);
  });

  testWidgets('profile edit exposes display name field', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ProfileEditPage(
          user: const UserProfile(
            id: 'user-1',
            fullName: 'John Doe',
            email: 'john@gmail.com',
          ),
        ),
      ),
    );

    expect(find.text('Nombre'), findsOneWidget);
    expect(find.text('Nombre de usuario'), findsOneWidget);
    expect(find.text('Correo'), findsOneWidget);
    expect(find.text('Guardar'), findsOneWidget);
  });
}

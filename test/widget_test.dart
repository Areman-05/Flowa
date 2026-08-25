import 'package:flowa/app/flowa_app.dart';
import 'package:flowa/core/utils/flowa_services.dart';
import 'package:flowa/data/repositories/in_memory_auth_repository.dart';
import 'package:flowa/data/repositories/in_memory_preferences_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() async {
    final prefs = InMemoryPreferencesRepository();
    await prefs.completeOnboarding();
    final auth = InMemoryAuthRepository();
    await auth.register(
      fullName: 'Ana López',
      email: 'ana@mail.com',
      password: 'Flowa1234',
    );
    FlowaServices.resetToMocks(preferences: prefs, auth: auth);
  });

  testWidgets('Flowa boots into the main shell', (tester) async {
    await tester.pumpWidget(
      const FlowaApp(
        splashDuration: Duration.zero,
        skipColdStartUnlock: true,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Ana'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Historial'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Historial'), findsOneWidget);
  });
}

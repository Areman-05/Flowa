import 'package:flowa/app/flowa_app.dart';
import 'package:flowa/core/utils/flowa_services.dart';
import 'package:flowa/data/repositories/in_memory_auth_repository.dart';
import 'package:flowa/data/repositories/in_memory_preferences_repository.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _bootstrapAuthenticatedApp() async {
  final prefs = InMemoryPreferencesRepository();
  await prefs.completeOnboarding();
  final auth = InMemoryAuthRepository();
  await auth.register(
    fullName: 'Ana López',
    email: 'ana@mail.com',
    password: 'Flowa1234',
  );
  FlowaServices.resetToMocks(preferences: prefs, auth: auth);
}

void main() {
  setUp(_bootstrapAuthenticatedApp);

  testWidgets('FlowaApp renders home shell destinations', (tester) async {
    await tester.pumpWidget(
      const FlowaApp(
        splashDuration: Duration.zero,
        skipColdStartUnlock: true,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Ana'), findsOneWidget);
    expect(find.text('Enviar'), findsOneWidget);
    expect(find.bySemanticsLabel('Inicio'), findsOneWidget);
    expect(find.bySemanticsLabel('Más'), findsOneWidget);

    await tester.tap(find.bySemanticsLabel('Más'));
    await tester.pumpAndSettle();

    expect(find.text('Servicios'), findsOneWidget);
  });
}

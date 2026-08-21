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
    password: '1234',
  );
  FlowaServices.resetToMocks(preferences: prefs, auth: auth);
}

void main() {
  setUp(_bootstrapAuthenticatedApp);

  testWidgets('FlowaApp renders home shell destinations', (tester) async {
    await tester.pumpWidget(const FlowaApp());
    await tester.pumpAndSettle();

    expect(find.text('Ana López'), findsOneWidget);
    expect(find.text('Enviar'), findsOneWidget);
    expect(find.text('Inicio'), findsOneWidget);
    expect(find.text('IA'), findsOneWidget);

    await tester.tap(find.text('IA'));
    await tester.pumpAndSettle();

    expect(find.text('What Can I Help You?'), findsOneWidget);
  });
}

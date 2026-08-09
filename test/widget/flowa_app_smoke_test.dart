import 'package:flowa/app/flowa_app.dart';
import 'package:flowa/core/utils/flowa_services.dart';
import 'package:flowa/data/repositories/in_memory_preferences_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUp(() async {
    final prefs = InMemoryPreferencesRepository();
    await prefs.completeOnboarding();
    FlowaServices.resetToMocks(preferences: prefs);
  });

  testWidgets('FlowaApp renders home shell destinations', (tester) async {
    await tester.pumpWidget(const FlowaApp());
    await tester.pumpAndSettle();

    expect(find.text('John Doe'), findsOneWidget);
    expect(find.text('Send'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('AI'), findsOneWidget);

    await tester.tap(find.text('AI'));
    await tester.pumpAndSettle();

    expect(find.text('What Can I Help You?'), findsOneWidget);
  });
}

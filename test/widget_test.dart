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

  testWidgets('Flowa boots into the main shell', (tester) async {
    await tester.pumpWidget(const FlowaApp());
    await tester.pumpAndSettle();

    expect(find.text('John Doe'), findsOneWidget);
    expect(find.text('Recent Transaction'), findsOneWidget);
  });
}

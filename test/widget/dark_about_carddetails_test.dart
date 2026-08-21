import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flowa/core/utils/flowa_services.dart';
import 'package:flowa/data/repositories/in_memory_preferences_repository.dart';
import 'package:flowa/features/settings/presentation/about_page.dart';
import 'package:flowa/features/settings/presentation/app_settings_page.dart';
import 'package:flowa/features/support/presentation/support_center_page.dart';

void main() {
  setUp(() async {
    final prefs = InMemoryPreferencesRepository();
    await prefs.completeOnboarding();
    FlowaServices.resetToMocks(preferences: prefs);
  });

  testWidgets('about page shows version and branding', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: AboutPage()));
    expect(find.text('Flowa'), findsOneWidget);
    expect(find.text('1.0.0'), findsOneWidget);
    expect(find.text('MIT'), findsOneWidget);
  });

  testWidgets('settings exposes dark mode toggle', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: AppSettingsPage()));
    await tester.pumpAndSettle();
    expect(find.text('Modo oscuro'), findsOneWidget);
    expect(find.text('Acerca de Flowa'), findsOneWidget);
  });

  testWidgets('support page shows contact section', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: SupportCenterPage()));
    await tester.pumpAndSettle();
    expect(find.text('Contact us'), findsOneWidget);
    expect(find.text('Rate app'), findsOneWidget);
  });
}

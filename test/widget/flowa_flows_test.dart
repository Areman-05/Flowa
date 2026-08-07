import 'package:flowa/app/flowa_app.dart';
import 'package:flowa/features/notifications/presentation/notification_settings_page.dart';
import 'package:flowa/features/top_up/presentation/top_up_page.dart';
import 'package:flowa/shared/widgets/flowa_dialogs.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('home loads account and recent merchants', (tester) async {
    await tester.pumpWidget(const FlowaApp());
    await tester.pumpAndSettle();

    expect(find.text('John Doe'), findsOneWidget);
    expect(find.text('Apple'), findsWidgets);
    expect(find.text('Send'), findsOneWidget);
    expect(find.text('Top-Up'), findsOneWidget);
  });

  testWidgets('top-up page uses gold flow and confirmation copy', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: TopUpPage()),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Top-Up'), findsOneWidget);
    expect(find.text('Top Up From'), findsOneWidget);

    await tester.scrollUntilVisible(
      find.text('Continue'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('Continue'), findsOneWidget);

    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    expect(find.text('Are you sure this is a Top-Up?'), findsOneWidget);
    expect(find.text('Top Up Now'), findsOneWidget);
    expect(find.text('No, Go Back'), findsOneWidget);
  });

  testWidgets('notification settings default marketing off', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: NotificationSettingsPage()),
    );

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
                    title: 'Are you sure this is a Top-Up?',
                    message: 'Check again.',
                    confirmLabel: 'Top Up Now',
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

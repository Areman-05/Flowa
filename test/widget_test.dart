import 'package:flowa/app/flowa_app.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Flowa boots into the main shell', (tester) async {
    await tester.pumpWidget(const FlowaApp());
    await tester.pumpAndSettle();

    expect(find.text('Good Morning,'), findsOneWidget);
    expect(find.text('Recent Transaction'), findsOneWidget);
  });
}

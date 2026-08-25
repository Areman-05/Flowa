import 'package:flutter/widgets.dart';

/// Runtime probes used to keep infinite animations out of widget tests, where
/// they would stall `pumpAndSettle`.
abstract final class FlowaRuntime {
  static bool get isWidgetTest => WidgetsBinding.instance.runtimeType
      .toString()
      .contains('TestWidgetsFlutterBinding');
}

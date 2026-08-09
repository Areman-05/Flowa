import 'package:flutter/services.dart';

/// Light haptic helpers for premium micro-interactions.
abstract final class FlowaHaptics {
  static Future<void> selection() => HapticFeedback.selectionClick();

  static Future<void> light() => HapticFeedback.lightImpact();

  static Future<void> success() => HapticFeedback.mediumImpact();
}

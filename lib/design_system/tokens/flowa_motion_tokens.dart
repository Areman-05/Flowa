import 'package:flutter/animation.dart';

/// Motion vocabulary.
///
/// Everything decelerates hard and never bounces on the way out. The house
/// curve is an exponential ease-out: fast start, long settle. That is what
/// makes an interface feel physical rather than animated.
abstract final class FlowaMotion {
  static const Duration instant = Duration(milliseconds: 110);
  static const Duration quick = Duration(milliseconds: 200);
  static const Duration base = Duration(milliseconds: 320);
  static const Duration slow = Duration(milliseconds: 520);
  static const Duration cinematic = Duration(milliseconds: 900);
  static const Duration epic = Duration(milliseconds: 1600);

  /// House curve. Use for anything entering the screen.
  static const Curve expoOut = Cubic(0.16, 1, 0.3, 1);

  /// Slightly softer, for layout changes and resizes.
  static const Curve swiftOut = Cubic(0.22, 1, 0.36, 1);

  /// For anything leaving: accelerate away, do not linger.
  static const Curve exit = Cubic(0.4, 0, 1, 1);

  /// One controlled overshoot. Reserved for confirmations and toggles.
  static const Curve overshoot = Cubic(0.34, 1.42, 0.64, 1);

  /// Press-down feel on tappable surfaces.
  static const Curve press = Cubic(0.3, 0, 0.2, 1);

  /// Delay for the nth item of a staggered list, capped so long lists never
  /// keep the user waiting.
  static Duration stagger(int index, {int stepMs = 55, int maxMs = 440}) {
    final ms = index * stepMs;
    return Duration(milliseconds: ms > maxMs ? maxMs : ms);
  }
}

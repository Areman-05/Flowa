import 'package:flutter/material.dart';

/// Hooks from [MainShell] so deep links (avisos, etc.) can switch tabs
/// without pushing a second Por cobrar screen without the nav bar.
abstract final class FlowaShellNav {
  static VoidCallback? openPorCobrar;
  static VoidCallback? openMovimientos;
  static VoidCallback? openHome;
}

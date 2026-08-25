import 'package:flutter/material.dart';

/// Cross-screen fade + soft rise (splash → auth → shell).
Widget flowaScreenTransition(Widget child, Animation<double> animation) {
  final curved = CurvedAnimation(
    parent: animation,
    curve: Curves.easeOutCubic,
    reverseCurve: Curves.easeInCubic,
  );
  return FadeTransition(
    opacity: curved,
    child: SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 0.028),
        end: Offset.zero,
      ).animate(curved),
      child: child,
    ),
  );
}

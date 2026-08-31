import 'package:flutter/material.dart';

import '../../design_system/tokens/flowa_motion_tokens.dart';

/// Shared push helper with a soft premium transition.
Future<T?> pushFlowaRoute<T>(BuildContext context, Widget page) {
  return Navigator.of(context).push<T>(
    PageRouteBuilder<T>(
      transitionDuration: FlowaMotion.base,
      reverseTransitionDuration: FlowaMotion.quick,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: FlowaMotion.expoOut,
          reverseCurve: FlowaMotion.exit,
        );
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.03),
              end: Offset.zero,
            ).animate(curved),
            child: ScaleTransition(
              scale: Tween<double>(begin: 0.98, end: 1).animate(curved),
              child: child,
            ),
          ),
        );
      },
    ),
  );
}

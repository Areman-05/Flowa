import 'package:flutter/material.dart';

import '../../core/constants/flowa_constants.dart';

/// Shared push helper with a soft premium transition.
Future<T?> pushFlowaRoute<T>(BuildContext context, Widget page) {
  return Navigator.of(context).push<T>(
    PageRouteBuilder<T>(
      transitionDuration: FlowaConstants.defaultAnimationDuration,
      reverseTransitionDuration: FlowaConstants.defaultAnimationDuration,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        return FadeTransition(
          opacity: curved,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.04, 0),
              end: Offset.zero,
            ).animate(curved),
            child: child,
          ),
        );
      },
    ),
  );
}

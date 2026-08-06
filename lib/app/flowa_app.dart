import 'package:flutter/material.dart';

import '../core/constants/flowa_constants.dart';
import '../design_system/theme/flowa_theme.dart';
import 'main_shell.dart';

/// Application root widget.
class FlowaApp extends StatelessWidget {
  const FlowaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: FlowaConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: FlowaTheme.light(),
      home: const MainShell(),
    );
  }
}

import 'package:flutter/material.dart';

import '../core/constants/flowa_constants.dart';
import '../core/utils/flowa_services.dart';
import '../design_system/theme/flowa_theme.dart';
import '../features/onboarding/presentation/onboarding_page.dart';
import 'main_shell.dart';

/// Application root widget with onboarding gate.
class FlowaApp extends StatefulWidget {
  const FlowaApp({super.key});

  @override
  State<FlowaApp> createState() => _FlowaAppState();
}

class _FlowaAppState extends State<FlowaApp> {
  bool _loading = true;
  bool _onboardingComplete = false;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final complete =
        await FlowaServices.preferencesRepository.isOnboardingComplete();
    if (!mounted) {
      return;
    }
    setState(() {
      _onboardingComplete = complete;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: FlowaConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: FlowaTheme.light(),
      home: _loading
          ? const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            )
          : _onboardingComplete
              ? const MainShell()
              : OnboardingPage(
                  onFinished: () {
                    setState(() => _onboardingComplete = true);
                  },
                ),
    );
  }
}

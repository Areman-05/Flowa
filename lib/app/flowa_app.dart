import 'package:flutter/material.dart';

import '../core/constants/flowa_constants.dart';
import '../core/utils/flowa_services.dart';
import '../design_system/theme/flowa_theme.dart';
import '../features/lock/presentation/pin_lock_pages.dart';
import '../features/onboarding/presentation/onboarding_page.dart';
import 'main_shell.dart';

/// Application root widget with onboarding and optional PIN gates.
class FlowaApp extends StatefulWidget {
  const FlowaApp({super.key});

  @override
  State<FlowaApp> createState() => _FlowaAppState();
}

class _FlowaAppState extends State<FlowaApp> {
  bool _loading = true;
  bool _onboardingComplete = false;
  bool _pinEnabled = false;
  bool _unlocked = false;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final complete = await FlowaServices.preferencesRepository
        .isOnboardingComplete();
    final pinEnabled = await FlowaServices.preferencesRepository.isPinEnabled();
    if (!mounted) {
      return;
    }
    setState(() {
      _onboardingComplete = complete;
      _pinEnabled = pinEnabled;
      _unlocked = !pinEnabled;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget home;
    if (_loading) {
      home = const Scaffold(body: Center(child: CircularProgressIndicator()));
    } else if (!_onboardingComplete) {
      home = OnboardingPage(
        onFinished: () {
          setState(() {
            _onboardingComplete = true;
            _unlocked = !_pinEnabled;
          });
        },
      );
    } else if (_pinEnabled && !_unlocked) {
      home = PinUnlockPage(onUnlocked: () => setState(() => _unlocked = true));
    } else {
      home = const MainShell();
    }

    return MaterialApp(
      title: FlowaConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: FlowaTheme.light(),
      home: home,
    );
  }
}

import 'package:flutter/material.dart';

import '../core/constants/flowa_constants.dart';
import '../core/utils/flowa_services.dart';
import '../core/utils/flowa_session.dart';
import '../design_system/components/flowa_motion.dart';
import '../design_system/theme/flowa_theme.dart';
import '../design_system/tokens/flowa_colors.dart';
import '../features/auth/presentation/register_page.dart';
import '../features/auth/presentation/return_login_page.dart';
import '../features/lock/presentation/pin_lock_pages.dart';
import '../features/onboarding/presentation/onboarding_page.dart';
import '../features/splash/presentation/splash_page.dart';
import 'main_shell.dart';

/// Application root: splash → register/login → onboarding → optional PIN → shell.
class FlowaApp extends StatefulWidget {
  const FlowaApp({
    super.key,
    this.splashDuration = const Duration(seconds: 3),
    this.skipColdStartUnlock = false,
  });

  /// Minimum splash time while session prefs load. Tests pass [Duration.zero].
  final Duration splashDuration;

  /// When true, skips password unlock on cold start (widget tests only).
  final bool skipColdStartUnlock;

  @override
  State<FlowaApp> createState() => _FlowaAppState();
}

class _FlowaAppState extends State<FlowaApp> {
  bool _loading = true;
  bool _loggedIn = false;
  bool _hasAccount = false;
  bool _onboardingComplete = false;
  bool _pinEnabled = false;
  bool _unlocked = false;
  bool _darkMode = false;

  @override
  void initState() {
    super.initState();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    final started = DateTime.now();
    final hasAccount =
        await FlowaServices.authRepository.hasRegisteredAccount();
    final sessionActive = await FlowaServices.authRepository.isLoggedIn();
    // Cold start: account exists → always ask for password unlock.
    final loggedIn =
        sessionActive && (!hasAccount || widget.skipColdStartUnlock);
    final complete =
        await FlowaServices.preferencesRepository.isOnboardingComplete();
    final pinEnabled = await FlowaServices.preferencesRepository.isPinEnabled();
    final dark =
        await FlowaServices.preferencesRepository.isDarkModeEnabled();

    if (loggedIn) {
      await FlowaSession.hydrate();
    }

    final elapsed = DateTime.now().difference(started);
    final remaining = widget.splashDuration - elapsed;
    if (remaining > Duration.zero) {
      await Future<void>.delayed(remaining);
    }

    if (!mounted) {
      return;
    }
    setState(() {
      _loggedIn = loggedIn;
      _hasAccount = hasAccount;
      _onboardingComplete = complete;
      _pinEnabled = pinEnabled;
      _unlocked = !pinEnabled;
      _darkMode = dark;
      _loading = false;
    });
  }

  Future<void> _onAuthenticated() async {
    await FlowaSession.hydrate();
    if (!mounted) {
      return;
    }
    setState(() {
      _loggedIn = true;
      _unlocked = !_pinEnabled;
    });
  }

  Future<void> logout() async {
    await FlowaServices.authRepository.logout();
    if (!mounted) {
      return;
    }
    setState(() {
      _loggedIn = false;
      _unlocked = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget home;
    if (_loading) {
      home = widget.splashDuration <= Duration.zero
          ? const Scaffold(backgroundColor: FlowaColors.ink)
          : SplashPage(duration: widget.splashDuration);
    } else if (!_loggedIn && !_hasAccount) {
      home = RegisterPage(onAuthenticated: _onAuthenticated);
    } else if (!_loggedIn && _hasAccount) {
      home = ReturnLoginPage(onAuthenticated: _onAuthenticated);
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
      home = PinUnlockPage(
        onUnlocked: () => setState(() => _unlocked = true),
      );
    } else {
      home = MainShell(onLogout: logout);
    }

    return MaterialApp(
      title: FlowaConstants.appName,
      debugShowCheckedModeBanner: false,
      locale: const Locale('es', 'ES'),
      theme: FlowaTheme.light(),
      darkTheme: FlowaTheme.dark(),
      themeMode: _darkMode ? ThemeMode.dark : ThemeMode.light,
      home: AnimatedSwitcher(
        duration: const Duration(milliseconds: 620),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        transitionBuilder: flowaScreenTransition,
        layoutBuilder: (currentChild, previousChildren) {
          return Stack(
            alignment: Alignment.center,
            children: [
              ...previousChildren,
              if (currentChild != null) currentChild,
            ],
          );
        },
        child: KeyedSubtree(
          key: ValueKey<String>(_loading
              ? 'splash'
              : !_loggedIn && !_hasAccount
                  ? 'register'
                  : !_loggedIn
                      ? 'unlock'
                      : !_onboardingComplete
                          ? 'onboarding'
                          : (_pinEnabled && !_unlocked)
                              ? 'pin'
                              : 'shell'),
          child: home,
        ),
      ),
    );
  }
}

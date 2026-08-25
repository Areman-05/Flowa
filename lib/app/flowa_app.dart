import 'package:flutter/material.dart';

import '../core/constants/flowa_constants.dart';
import '../core/utils/flowa_services.dart';
import '../data/datasources/mock_finance_data.dart';
import '../data/repositories/mock_account_repository.dart';
import '../design_system/theme/flowa_theme.dart';
import '../features/auth/presentation/login_page.dart';
import '../features/lock/presentation/pin_lock_pages.dart';
import '../features/onboarding/presentation/onboarding_page.dart';
import '../features/splash/presentation/splash_page.dart';
import 'main_shell.dart';

/// Application root: splash → auth → onboarding → optional PIN → shell.
class FlowaApp extends StatefulWidget {
  const FlowaApp({
    super.key,
    this.splashDuration = const Duration(seconds: 3),
  });

  /// Minimum splash time while session prefs load. Tests pass [Duration.zero].
  final Duration splashDuration;

  @override
  State<FlowaApp> createState() => _FlowaAppState();
}

class _FlowaAppState extends State<FlowaApp> {
  bool _loading = true;
  bool _loggedIn = false;
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
    final loggedIn = await FlowaServices.authRepository.isLoggedIn();
    final complete =
        await FlowaServices.preferencesRepository.isOnboardingComplete();
    final pinEnabled = await FlowaServices.preferencesRepository.isPinEnabled();
    final dark =
        await FlowaServices.preferencesRepository.isDarkModeEnabled();

    if (loggedIn) {
      final authUser = await FlowaServices.authRepository.currentUser();
      final accountRepo = FlowaServices.accountRepository;
      if (authUser != null && accountRepo is MockAccountRepository) {
        accountRepo.bootstrapUser(
          MockFinanceData.profileFromAuth(
            id: authUser.id,
            fullName: authUser.fullName,
            email: authUser.email,
          ),
        );
      }
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
      _onboardingComplete = complete;
      _pinEnabled = pinEnabled;
      _unlocked = !pinEnabled;
      _darkMode = dark;
      _loading = false;
    });
  }

  void _onAuthenticated() {
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
          ? const Scaffold(backgroundColor: Color(0xFF0A0A0A))
          : SplashPage(duration: widget.splashDuration);
    } else if (!_loggedIn) {
      home = LoginPage(onAuthenticated: _onAuthenticated);
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
        duration: const Duration(milliseconds: 480),
        switchInCurve: Curves.easeOutCubic,
        child: KeyedSubtree(
          key: ValueKey<String>(_loading
              ? 'splash'
              : !_loggedIn
                  ? 'login'
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

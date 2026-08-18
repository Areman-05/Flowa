import '../../domain/repositories/preferences_repository.dart';

/// Fast in-memory preferences for tests and pre-bootstrap fallback.
class InMemoryPreferencesRepository implements PreferencesRepository {
  bool _onboardingComplete = false;
  bool _balanceHiddenByDefault = true;
  NotificationPreferences _notifications = const NotificationPreferences(
    allowNotifications: true,
    transactionNotifications: true,
    marketingNotifications: false,
  );
  bool _pinEnabled = false;
  String _pinCode = '';
  double _monthlyBudgetLimit = 500;
  bool _budgetEnabled = false;
  bool _biometricEnabled = false;

  @override
  Future<bool> isOnboardingComplete() async => _onboardingComplete;

  @override
  Future<void> completeOnboarding() async {
    _onboardingComplete = true;
  }

  @override
  Future<bool> isBalanceHiddenByDefault() async => _balanceHiddenByDefault;

  @override
  Future<void> setBalanceHiddenByDefault(bool value) async {
    _balanceHiddenByDefault = value;
  }

  @override
  Future<NotificationPreferences> getNotificationPreferences() async =>
      _notifications;

  @override
  Future<void> saveNotificationPreferences(
    NotificationPreferences value,
  ) async {
    _notifications = value;
  }

  @override
  Future<bool> isPinEnabled() async => _pinEnabled;

  @override
  Future<void> setPinEnabled(bool value) async {
    _pinEnabled = value;
  }

  @override
  Future<String> getPinCode() async => _pinCode;

  @override
  Future<void> setPinCode(String value) async {
    _pinCode = value;
  }

  @override
  Future<double> getMonthlyBudgetLimit() async => _monthlyBudgetLimit;

  @override
  Future<void> setMonthlyBudgetLimit(double value) async {
    _monthlyBudgetLimit = value;
  }

  @override
  Future<bool> isBudgetEnabled() async => _budgetEnabled;

  @override
  Future<void> setBudgetEnabled(bool value) async {
    _budgetEnabled = value;
  }

  @override
  Future<bool> isBiometricEnabled() async => _biometricEnabled;

  @override
  Future<void> setBiometricEnabled(bool value) async {
    _biometricEnabled = value;
  }

  void reset() {
    _onboardingComplete = false;
    _balanceHiddenByDefault = true;
    _pinEnabled = false;
    _pinCode = '';
    _monthlyBudgetLimit = 500;
    _budgetEnabled = false;
    _biometricEnabled = false;
    _notifications = const NotificationPreferences(
      allowNotifications: true,
      transactionNotifications: true,
      marketingNotifications: false,
    );
  }
}

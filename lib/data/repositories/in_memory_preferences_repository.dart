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

  void reset() {
    _onboardingComplete = false;
    _balanceHiddenByDefault = true;
    _pinEnabled = false;
    _pinCode = '';
    _notifications = const NotificationPreferences(
      allowNotifications: true,
      transactionNotifications: true,
      marketingNotifications: false,
    );
  }
}

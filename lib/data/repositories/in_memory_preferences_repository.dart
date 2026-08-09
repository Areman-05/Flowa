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

  void reset() {
    _onboardingComplete = false;
    _balanceHiddenByDefault = true;
    _notifications = const NotificationPreferences(
      allowNotifications: true,
      transactionNotifications: true,
      marketingNotifications: false,
    );
  }
}

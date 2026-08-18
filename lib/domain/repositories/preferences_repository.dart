/// Contract for reading and writing durable user preferences.
abstract class PreferencesRepository {
  Future<bool> isOnboardingComplete();

  Future<void> completeOnboarding();

  Future<bool> isBalanceHiddenByDefault();

  Future<void> setBalanceHiddenByDefault(bool value);

  Future<NotificationPreferences> getNotificationPreferences();

  Future<void> saveNotificationPreferences(NotificationPreferences value);

  Future<bool> isPinEnabled();

  Future<void> setPinEnabled(bool value);

  Future<String> getPinCode();

  Future<void> setPinCode(String value);

  Future<double> getMonthlyBudgetLimit();

  Future<void> setMonthlyBudgetLimit(double value);

  Future<bool> isBudgetEnabled();

  Future<void> setBudgetEnabled(bool value);

  Future<bool> isBiometricEnabled();

  Future<void> setBiometricEnabled(bool value);
}

class NotificationPreferences {
  const NotificationPreferences({
    required this.allowNotifications,
    required this.transactionNotifications,
    required this.marketingNotifications,
  });

  final bool allowNotifications;
  final bool transactionNotifications;
  final bool marketingNotifications;

  NotificationPreferences copyWith({
    bool? allowNotifications,
    bool? transactionNotifications,
    bool? marketingNotifications,
  }) {
    return NotificationPreferences(
      allowNotifications: allowNotifications ?? this.allowNotifications,
      transactionNotifications:
          transactionNotifications ?? this.transactionNotifications,
      marketingNotifications:
          marketingNotifications ?? this.marketingNotifications,
    );
  }
}

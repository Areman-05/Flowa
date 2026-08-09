import '../../domain/repositories/preferences_repository.dart';
import '../datasources/local_preferences_data_source.dart';

class LocalPreferencesRepository implements PreferencesRepository {
  LocalPreferencesRepository(this._source);

  final LocalPreferencesDataSource _source;

  @override
  Future<bool> isOnboardingComplete() async => _source.onboardingComplete;

  @override
  Future<void> completeOnboarding() => _source.setOnboardingComplete(true);

  @override
  Future<bool> isBalanceHiddenByDefault() async =>
      _source.balanceHiddenByDefault;

  @override
  Future<void> setBalanceHiddenByDefault(bool value) =>
      _source.setBalanceHiddenByDefault(value);

  @override
  Future<NotificationPreferences> getNotificationPreferences() async {
    return NotificationPreferences(
      allowNotifications: _source.allowNotifications,
      transactionNotifications: _source.transactionNotifications,
      marketingNotifications: _source.marketingNotifications,
    );
  }

  @override
  Future<void> saveNotificationPreferences(
    NotificationPreferences value,
  ) async {
    await _source.setAllowNotifications(value.allowNotifications);
    await _source.setTransactionNotifications(value.transactionNotifications);
    await _source.setMarketingNotifications(value.marketingNotifications);
  }
}

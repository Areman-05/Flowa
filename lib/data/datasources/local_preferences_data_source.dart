import 'package:shared_preferences/shared_preferences.dart';

/// Keys used by Flowa local preferences.
abstract final class PreferenceKeys {
  static const onboardingComplete = 'onboarding_complete';
  static const balanceHiddenByDefault = 'balance_hidden_by_default';
  static const allowNotifications = 'allow_notifications';
  static const transactionNotifications = 'transaction_notifications';
  static const marketingNotifications = 'marketing_notifications';
}

/// Thin wrapper over [SharedPreferences] for app settings.
class LocalPreferencesDataSource {
  LocalPreferencesDataSource(this._prefs);

  final SharedPreferences _prefs;

  static Future<LocalPreferencesDataSource> create() async {
    final prefs = await SharedPreferences.getInstance();
    return LocalPreferencesDataSource(prefs);
  }

  bool get onboardingComplete =>
      _prefs.getBool(PreferenceKeys.onboardingComplete) ?? false;

  Future<void> setOnboardingComplete(bool value) =>
      _prefs.setBool(PreferenceKeys.onboardingComplete, value);

  bool get balanceHiddenByDefault =>
      _prefs.getBool(PreferenceKeys.balanceHiddenByDefault) ?? true;

  Future<void> setBalanceHiddenByDefault(bool value) =>
      _prefs.setBool(PreferenceKeys.balanceHiddenByDefault, value);

  bool get allowNotifications =>
      _prefs.getBool(PreferenceKeys.allowNotifications) ?? true;

  Future<void> setAllowNotifications(bool value) =>
      _prefs.setBool(PreferenceKeys.allowNotifications, value);

  bool get transactionNotifications =>
      _prefs.getBool(PreferenceKeys.transactionNotifications) ?? true;

  Future<void> setTransactionNotifications(bool value) =>
      _prefs.setBool(PreferenceKeys.transactionNotifications, value);

  bool get marketingNotifications =>
      _prefs.getBool(PreferenceKeys.marketingNotifications) ?? false;

  Future<void> setMarketingNotifications(bool value) =>
      _prefs.setBool(PreferenceKeys.marketingNotifications, value);
}

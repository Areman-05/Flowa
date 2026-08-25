import 'package:shared_preferences/shared_preferences.dart';

/// Keys used by Flowa local preferences.
abstract final class PreferenceKeys {
  static const onboardingComplete = 'onboarding_complete';
  static const balanceHiddenByDefault = 'balance_hidden_by_default';
  static const allowNotifications = 'allow_notifications';
  static const transactionNotifications = 'transaction_notifications';
  static const marketingNotifications = 'marketing_notifications';
  static const pinEnabled = 'pin_enabled';
  static const pinCode = 'pin_code';
  static const monthlyBudgetLimit = 'monthly_budget_limit';
  static const budgetEnabled = 'budget_enabled';
  static const biometricEnabled = 'biometric_enabled';
  static const darkModeEnabled = 'dark_mode_enabled';
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
      _prefs.getBool(PreferenceKeys.balanceHiddenByDefault) ?? false;

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

  bool get pinEnabled => _prefs.getBool(PreferenceKeys.pinEnabled) ?? false;

  Future<void> setPinEnabled(bool value) =>
      _prefs.setBool(PreferenceKeys.pinEnabled, value);

  String get pinCode => _prefs.getString(PreferenceKeys.pinCode) ?? '';

  Future<void> setPinCode(String value) =>
      _prefs.setString(PreferenceKeys.pinCode, value);

  double get monthlyBudgetLimit =>
      _prefs.getDouble(PreferenceKeys.monthlyBudgetLimit) ?? 500;

  Future<void> setMonthlyBudgetLimit(double value) =>
      _prefs.setDouble(PreferenceKeys.monthlyBudgetLimit, value);

  bool get budgetEnabled =>
      _prefs.getBool(PreferenceKeys.budgetEnabled) ?? false;

  Future<void> setBudgetEnabled(bool value) =>
      _prefs.setBool(PreferenceKeys.budgetEnabled, value);

  bool get biometricEnabled =>
      _prefs.getBool(PreferenceKeys.biometricEnabled) ?? false;

  Future<void> setBiometricEnabled(bool value) =>
      _prefs.setBool(PreferenceKeys.biometricEnabled, value);

  bool get darkModeEnabled =>
      _prefs.getBool(PreferenceKeys.darkModeEnabled) ?? false;

  Future<void> setDarkModeEnabled(bool value) =>
      _prefs.setBool(PreferenceKeys.darkModeEnabled, value);
}

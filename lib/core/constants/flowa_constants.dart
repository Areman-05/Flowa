/// App-wide constants that are not visual tokens.
abstract final class FlowaConstants {
  static const String appName = 'Flowa';
  static const String appTagline =
      'Claridad, control y confianza para tu dinero.';

  static const String currencyCode = 'EUR';
  static const String currencySymbol = '€';

  static const int maxRecentTransactions = 8;
  static const Duration defaultAnimationDuration = Duration(milliseconds: 280);
  static const Duration confirmationUndoWindow = Duration(seconds: 5);
}

/// Lightweight environment flags for local development.
abstract final class FlowaEnv {
  static const bool useMockData = true;
  static const bool enableAiAssistant = true;
  static const bool enableAnalytics = false;
}

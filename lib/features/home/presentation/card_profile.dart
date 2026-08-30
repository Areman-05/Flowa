import '../../../design_system/components/flowa_card_face.dart';
import '../../../domain/entities/finance_entities.dart';

/// Per-card identity so details are never generic across the wallet.
class CardProfile {
  const CardProfile({
    required this.account,
    required this.style,
    required this.caption,
    required this.pan,
    required this.cvv,
    required this.cardPin,
    required this.dailyLimit,
    required this.monthlyLimit,
    required this.onlineEnabled,
    required this.contactlessEnabled,
    this.pattern = FlowaCardPattern.none,
  });

  final Account account;
  final FlowaCardTint style;
  final FlowaCardPattern pattern;
  final String caption;
  final String pan;
  final String cvv;
  final String cardPin;
  final double dailyLimit;
  final double monthlyLimit;
  final bool onlineEnabled;
  final bool contactlessEnabled;

  String get formattedPan {
    final digits = pan.replaceAll(RegExp(r'\D'), '');
    final buf = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && i % 4 == 0) {
        buf.write(' ');
      }
      buf.write(digits[i]);
    }
    return buf.toString();
  }

  CardProfile copyWith({
    Account? account,
    FlowaCardTint? style,
    FlowaCardPattern? pattern,
    String? caption,
    String? pan,
    String? cvv,
    String? cardPin,
    double? dailyLimit,
    double? monthlyLimit,
    bool? onlineEnabled,
    bool? contactlessEnabled,
  }) {
    return CardProfile(
      account: account ?? this.account,
      style: style ?? this.style,
      pattern: pattern ?? this.pattern,
      caption: caption ?? this.caption,
      pan: pan ?? this.pan,
      cvv: cvv ?? this.cvv,
      cardPin: cardPin ?? this.cardPin,
      dailyLimit: dailyLimit ?? this.dailyLimit,
      monthlyLimit: monthlyLimit ?? this.monthlyLimit,
      onlineEnabled: onlineEnabled ?? this.onlineEnabled,
      contactlessEnabled: contactlessEnabled ?? this.contactlessEnabled,
    );
  }

  /// Stable fake PAN / CVV / PIN derived from the account id.
  factory CardProfile.fromAccount({
    required Account account,
    required FlowaCardTint style,
    required String caption,
    FlowaCardPattern pattern = FlowaCardPattern.none,
    double? amount,
  }) {
    final seed = account.id.hashCode.abs();
    final bin = switch (style) {
      FlowaCardTint.turquoise => 4532,
      FlowaCardTint.black => 5412,
      FlowaCardTint.navy => 4024,
      _ => 4000 + (seed % 500),
    };
    final mid = (seed % 90000000 + 10000000).toString();
    final last = account.lastFour.padLeft(4, '0');
    final pan = '$bin$mid$last'.substring(0, 16);
    final cvv = ((seed % 900) + 100).toString();
    final pin = ((seed % 9000) + 1000).toString();
    final daily = switch (style) {
      FlowaCardTint.turquoise => 1500.0,
      FlowaCardTint.black => 800.0,
      _ => 600.0,
    };
    final monthly = daily * 8;

    final resolved = amount == null
        ? account
        : account.copyWith(availableBalance: amount);

    return CardProfile(
      account: resolved,
      style: style,
      pattern: pattern,
      caption: caption,
      pan: pan,
      cvv: cvv,
      cardPin: pin,
      dailyLimit: daily,
      monthlyLimit: monthly,
      onlineEnabled: true,
      contactlessEnabled: style != FlowaCardTint.black,
    );
  }
}

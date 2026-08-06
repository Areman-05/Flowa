import 'package:equatable/equatable.dart';

/// High-level account kinds supported by Flowa.
enum AccountKind {
  personal,
  family,
  business,
}

/// Access level when a sub-account is shared.
enum AccessLevel {
  limited,
  full,
}

/// Payment card / wallet account shown on Home and money flows.
class Account extends Equatable {
  const Account({
    required this.id,
    required this.displayName,
    required this.maskedNumber,
    required this.availableBalance,
    required this.expiryLabel,
    this.brand = 'VISA',
    this.kind = AccountKind.personal,
    this.currencyCode = 'USD',
  });

  final String id;
  final String displayName;
  final String maskedNumber;
  final double availableBalance;
  final String expiryLabel;
  final String brand;
  final AccountKind kind;
  final String currencyCode;

  String get lastFour {
    final digits = maskedNumber.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 4) {
      return digits;
    }
    return digits.substring(digits.length - 4);
  }

  @override
  List<Object?> get props => [
        id,
        displayName,
        maskedNumber,
        availableBalance,
        expiryLabel,
        brand,
        kind,
        currencyCode,
      ];
}

/// Transaction direction for UI formatting.
enum TransactionDirection {
  debit,
  credit,
}

class TransactionItem extends Equatable {
  const TransactionItem({
    required this.id,
    required this.merchant,
    required this.amount,
    required this.occurredAt,
    required this.direction,
    this.logoAsset,
    this.category,
  });

  final String id;
  final String merchant;
  final double amount;
  final DateTime occurredAt;
  final TransactionDirection direction;
  final String? logoAsset;
  final String? category;

  bool get isIncome => direction == TransactionDirection.credit;

  double get signedAmount =>
      isIncome ? amount.abs() : -amount.abs();

  @override
  List<Object?> get props => [
        id,
        merchant,
        amount,
        occurredAt,
        direction,
        logoAsset,
        category,
      ];
}

class SubAccount extends Equatable {
  const SubAccount({
    required this.id,
    required this.name,
    required this.accountNumber,
    required this.purpose,
    required this.accessLevel,
    this.iconKey = 'briefcase',
    this.linkedEmail,
  });

  final String id;
  final String name;
  final String accountNumber;
  final AccountKind purpose;
  final AccessLevel accessLevel;
  final String iconKey;
  final String? linkedEmail;

  @override
  List<Object?> get props => [
        id,
        name,
        accountNumber,
        purpose,
        accessLevel,
        iconKey,
        linkedEmail,
      ];
}

class UserProfile extends Equatable {
  const UserProfile({
    required this.id,
    required this.fullName,
    this.avatarUrl,
    this.email,
  });

  final String id;
  final String fullName;
  final String? avatarUrl;
  final String? email;

  String get firstName {
    final parts = fullName.trim().split(RegExp(r'\s+'));
    return parts.isEmpty ? fullName : parts.first;
  }

  @override
  List<Object?> get props => [id, fullName, avatarUrl, email];
}

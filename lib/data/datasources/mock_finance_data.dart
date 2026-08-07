import '../../domain/entities/finance_entities.dart';

/// Deterministic seed data for local/mock development.
abstract final class MockFinanceData {
  static const Account primaryAccount = Account(
    id: 'acc-primary',
    displayName: 'Main Visa',
    maskedNumber: '**** **** **** 6457',
    availableBalance: 2150,
    expiryLabel: '12/28',
  );

  static const UserProfile currentUser = UserProfile(
    id: 'user-1',
    fullName: 'John Doe',
    email: 'john@gmail.com',
  );

  static final List<TransactionItem> transactions = [
    TransactionItem(
      id: 'tx-1',
      merchant: 'Apple',
      amount: 343.81,
      occurredAt: DateTime(2026, 3, 1, 15, 43),
      direction: TransactionDirection.debit,
      category: 'Shopping',
    ),
    TransactionItem(
      id: 'tx-2',
      merchant: 'Spotify',
      amount: 14.99,
      occurredAt: DateTime(2026, 3, 1, 12, 18),
      direction: TransactionDirection.debit,
      category: 'Entertainment',
    ),
    TransactionItem(
      id: 'tx-3',
      merchant: 'Dribbble Pro',
      amount: 42.41,
      occurredAt: DateTime(2026, 2, 28, 9, 5),
      direction: TransactionDirection.debit,
      category: 'Subscriptions',
    ),
    TransactionItem(
      id: 'tx-4',
      merchant: 'PayPal Payment',
      amount: 255,
      occurredAt: DateTime(2026, 2, 27, 16, 22),
      direction: TransactionDirection.credit,
      category: 'Transfer',
    ),
    TransactionItem(
      id: 'tx-5',
      merchant: 'Amazon',
      amount: 67.2,
      occurredAt: DateTime(2026, 2, 26, 11, 10),
      direction: TransactionDirection.debit,
      category: 'Shopping',
    ),
    TransactionItem(
      id: 'tx-6',
      merchant: 'Salary Top-Up',
      amount: 1800,
      occurredAt: DateTime(2026, 2, 25, 8),
      direction: TransactionDirection.credit,
    ),
  ];
}

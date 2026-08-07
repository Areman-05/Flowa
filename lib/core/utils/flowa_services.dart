import '../../data/repositories/mock_account_repository.dart';
import '../../data/repositories/mock_transaction_repository.dart';
import '../../domain/repositories/account_repository.dart';
import '../../domain/repositories/transaction_repository.dart';

/// Tiny manual service locator — keeps dependencies explicit for portfolio demos.
abstract final class FlowaServices {
  static AccountRepository accountRepository = const MockAccountRepository();
  static TransactionRepository transactionRepository =
      const MockTransactionRepository();

  static void resetToMocks() {
    accountRepository = const MockAccountRepository();
    transactionRepository = const MockTransactionRepository();
  }
}

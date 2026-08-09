import '../../data/repositories/in_memory_preferences_repository.dart';
import '../../data/repositories/mock_account_repository.dart';
import '../../data/repositories/mock_sub_account_repository.dart';
import '../../data/repositories/mock_transaction_repository.dart';
import '../../data/repositories/mock_wallet_repository.dart';
import '../../data/services/mock_ai_assistant_service.dart';
import '../../domain/repositories/account_repository.dart';
import '../../domain/repositories/preferences_repository.dart';
import '../../domain/repositories/sub_account_repository.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../../domain/repositories/wallet_repository.dart';

/// Tiny manual service locator — keeps dependencies explicit for portfolio demos.
abstract final class FlowaServices {
  static AccountRepository accountRepository = const MockAccountRepository();
  static TransactionRepository transactionRepository =
      const MockTransactionRepository();
  static SubAccountRepository subAccountRepository = MockSubAccountRepository();
  static WalletRepository walletRepository = MockWalletRepository();
  static MockAiAssistantService aiAssistant = MockAiAssistantService();
  static PreferencesRepository preferencesRepository =
      InMemoryPreferencesRepository();

  static void resetToMocks({PreferencesRepository? preferences}) {
    accountRepository = const MockAccountRepository();
    transactionRepository = const MockTransactionRepository();
    subAccountRepository = MockSubAccountRepository();
    walletRepository = MockWalletRepository();
    aiAssistant = MockAiAssistantService();
    preferencesRepository =
        preferences ?? InMemoryPreferencesRepository();
  }
}

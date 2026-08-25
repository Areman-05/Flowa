import '../../data/repositories/in_memory_auth_repository.dart';
import '../../data/repositories/in_memory_contact_repository.dart';
import '../../data/repositories/in_memory_preferences_repository.dart';
import '../../data/repositories/mock_account_repository.dart';
import '../../data/repositories/mock_freelance_repository.dart';
import '../../data/repositories/mock_inbox_repository.dart';
import '../../data/repositories/mock_scheduled_transfer_repository.dart';
import '../../data/repositories/mock_sub_account_repository.dart';
import '../../data/repositories/mock_transaction_repository.dart';
import '../../data/repositories/mock_wallet_repository.dart';
import '../../data/services/mock_ai_assistant_service.dart';
import '../../domain/repositories/account_repository.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/contact_repository.dart';
import '../../domain/repositories/freelance_repository.dart';
import '../../domain/repositories/inbox_repository.dart';
import '../../domain/repositories/preferences_repository.dart';
import '../../domain/repositories/scheduled_transfer_repository.dart';
import '../../domain/repositories/sub_account_repository.dart';
import '../../domain/repositories/transaction_repository.dart';
import '../../domain/repositories/wallet_repository.dart';

/// Tiny manual service locator — keeps dependencies explicit for portfolio demos.
abstract final class FlowaServices {
  static AuthRepository authRepository = InMemoryAuthRepository();
  static AccountRepository accountRepository = MockAccountRepository();
  static TransactionRepository transactionRepository =
      MockTransactionRepository();
  static SubAccountRepository subAccountRepository = MockSubAccountRepository();
  static WalletRepository walletRepository = MockWalletRepository();
  static MockAiAssistantService aiAssistant = MockAiAssistantService();
  static PreferencesRepository preferencesRepository =
      InMemoryPreferencesRepository();
  static InboxRepository inboxRepository = MockInboxRepository();
  static ScheduledTransferRepository scheduledTransferRepository =
      MockScheduledTransferRepository();
  static ContactRepository contactRepository = InMemoryContactRepository();
  static FreelanceRepository freelanceRepository = MockFreelanceRepository();

  /// Guard so demo data is only injected once per session.
  static bool demoSeeded = false;

  /// Clears financial data while keeping auth/prefs as provided.
  static void resetUserData() {
    demoSeeded = false;
    accountRepository = MockAccountRepository();
    transactionRepository = MockTransactionRepository();
    freelanceRepository = MockFreelanceRepository();
    subAccountRepository = MockSubAccountRepository();
    walletRepository = MockWalletRepository();
    aiAssistant = MockAiAssistantService();
    inboxRepository = MockInboxRepository();
    scheduledTransferRepository = MockScheduledTransferRepository();
    contactRepository = InMemoryContactRepository();
  }

  static void resetToMocks({
    PreferencesRepository? preferences,
    AuthRepository? auth,
  }) {
    authRepository = auth ?? InMemoryAuthRepository();
    preferencesRepository = preferences ?? InMemoryPreferencesRepository();
    resetUserData();
  }
}

import '../../data/datasources/flowa_demo_seed.dart';
import '../../data/datasources/mock_finance_data.dart';
import '../../data/repositories/mock_account_repository.dart';
import '../../data/repositories/mock_freelance_repository.dart';
import '../../data/repositories/mock_transaction_repository.dart';
import '../../domain/entities/finance_entities.dart';
import 'flowa_services.dart';

/// Brings the signed-in user's financial world into memory.
///
/// Called on cold start and immediately after authentication, so registering
/// and re-opening the app land on the same populated state.
abstract final class FlowaSession {
  static Future<UserProfile?> hydrate() async {
    final authUser = await FlowaServices.authRepository.currentUser();
    if (authUser == null) {
      return null;
    }

    final extras = await FlowaServices.authRepository.getProfileExtras();
    final profile = MockFinanceData.profileFromAuth(
      id: authUser.id,
      fullName: authUser.fullName,
      email: authUser.email,
    ).copyWith(
      username: extras.username,
      avatarPath: extras.avatarPath,
      dateOfBirth: extras.dateOfBirth,
    );

    final shouldSeed = FlowaDemoSeed.enabled && !FlowaServices.demoSeeded;
    final accountRepository = FlowaServices.accountRepository;
    if (accountRepository is MockAccountRepository) {
      accountRepository.bootstrapUser(
        profile,
        account: shouldSeed ? FlowaDemoSeed.account(profile) : null,
      );
    }

    if (shouldSeed) {
      final now = DateTime.now();
      FlowaServices.transactionRepository = MockTransactionRepository(
        seed: FlowaDemoSeed.transactions(now),
      );
      FlowaServices.freelanceRepository = MockFreelanceRepository(
        vault: FlowaDemoSeed.vault(now),
        invoices: FlowaDemoSeed.invoices(now),
        commitments: FlowaDemoSeed.commitments(now),
      );
      FlowaServices.demoSeeded = true;
    }

    return profile;
  }
}

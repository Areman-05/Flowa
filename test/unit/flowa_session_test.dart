import 'package:flowa/core/utils/flowa_services.dart';
import 'package:flowa/core/utils/flowa_session.dart';
import 'package:flowa/data/datasources/flowa_demo_seed.dart';
import 'package:flowa/data/repositories/in_memory_auth_repository.dart';
import 'package:flowa/domain/entities/finance_entities.dart';
import 'package:flowa/domain/entities/freelance_entities.dart';
import 'package:flowa/features/home/presentation/card_wallet_store.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    FlowaServices.resetToMocks();
    FlowaDemoSeed.overrideEnabled = false;
  });

  tearDown(() {
    FlowaDemoSeed.overrideEnabled = null;
    CardWalletStore.instance.clear();
  });

  Future<InMemoryAuthRepository> _signedInAuth() async {
    final auth = InMemoryAuthRepository();
    await auth.register(
      fullName: 'Ana López',
      email: 'ana@mail.com',
      password: 'Flowa1234',
    );
    return auth;
  }

  test('hydrate empty account in widget tests', () async {
    final auth = await _signedInAuth();
    FlowaServices.resetToMocks(auth: auth);

    final profile = await FlowaSession.hydrate();
    expect(profile?.fullName, 'Ana López');

    final account = await FlowaServices.accountRepository.getPrimaryAccount();
    expect(account.availableBalance, 0);
    expect(await FlowaServices.transactionRepository.getAll(), isEmpty);
    expect(await FlowaServices.contactRepository.getAll(), isEmpty);
    expect(FlowaServices.demoSeeded, isFalse);
  });

  test('hydrate seeds demo world when override is on', () async {
    final auth = await _signedInAuth();
    FlowaServices.resetToMocks(auth: auth);
    FlowaDemoSeed.overrideEnabled = true;

    await FlowaSession.hydrate();

    final account = await FlowaServices.accountRepository.getPrimaryAccount();
    expect(account.availableBalance, FlowaDemoSeed.startingBalance);
    expect(await FlowaServices.transactionRepository.getAll(), isNotEmpty);
    expect(await FlowaServices.contactRepository.getAll(), hasLength(3));
    expect(FlowaServices.demoSeeded, isTrue);

    await FlowaSession.hydrate();
    expect(await FlowaServices.contactRepository.getAll(), hasLength(3));
  });

  test('resetUserData clears wallet leftover after demo seed', () async {
    final auth = await _signedInAuth();
    FlowaServices.resetToMocks(auth: auth);
    FlowaDemoSeed.overrideEnabled = true;
    await FlowaSession.hydrate();

    final account = await FlowaServices.accountRepository.getPrimaryAccount();
    final vault = await FlowaServices.freelanceRepository.getVault();
    CardWalletStore.instance.ensureSeeded(
      primary: account,
      vault: vault,
      trulyAvailable: 400,
    );
    expect(CardWalletStore.instance.cards, isNotEmpty);

    FlowaServices.resetUserData();
    expect(CardWalletStore.instance.cards, isEmpty);
    expect(FlowaServices.demoSeeded, isFalse);
    expect(await FlowaServices.transactionRepository.getAll(), isEmpty);
    expect(await FlowaServices.contactRepository.getAll(), isEmpty);

    FlowaDemoSeed.overrideEnabled = true;
    FlowaServices.authRepository = auth;
    await FlowaSession.hydrate();
    final again = await FlowaServices.accountRepository.getPrimaryAccount();
    expect(again.availableBalance, FlowaDemoSeed.startingBalance);
  });

  test('CardWalletStore ensureSeeded then clear', () {
    const primary = Account(
      id: 'acc-test',
      displayName: 'Cuenta',
      maskedNumber: '**** 1111',
      availableBalance: 200,
      expiryLabel: '12/30',
    );
    CardWalletStore.instance.ensureSeeded(
      primary: primary,
      vault: const TaxVault(reserved: 80, rate: 0.25),
      trulyAvailable: 120,
    );
    expect(CardWalletStore.instance.cards.length, 3);

    CardWalletStore.instance.clear();
    expect(CardWalletStore.instance.cards, isEmpty);
  });
}

import 'package:flowa/core/utils/flowa_validators.dart';
import 'package:flowa/data/repositories/mock_sub_account_repository.dart';
import 'package:flowa/data/repositories/mock_wallet_repository.dart';
import 'package:flowa/data/services/mock_ai_assistant_service.dart';
import 'package:flowa/domain/entities/finance_entities.dart';
import 'package:flowa/domain/entities/wallet_entities.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('FlowaValidators', () {
    test('requires labels and positive amounts', () {
      expect(FlowaValidators.requiredLabel('', field: 'Name'), isNotNull);
      expect(FlowaValidators.positiveAmount('0'), isNotNull);
      expect(FlowaValidators.positiveAmount('12.5'), isNull);
    });

    test('validates emails', () {
      expect(FlowaValidators.email('bad'), isNotNull);
      expect(FlowaValidators.email('john@gmail.com'), isNull);
      expect(FlowaValidators.optionalEmail(''), isNull);
    });
  });

  group('MockSubAccountRepository', () {
    test('creates and lists sub-accounts', () async {
      final repository = MockSubAccountRepository(seed: const []);
      expect(await repository.getAll(), isEmpty);

      final created = await repository.create(
        name: 'Shop Float',
        purpose: AccountKind.business,
        accessLevel: AccessLevel.full,
        iconKey: 'briefcase',
      );

      final all = await repository.getAll();
      expect(all, hasLength(1));
      expect(created.name, 'Shop Float');
      expect(created.accountNumber, isNotEmpty);
    });
  });

  group('MockWalletRepository', () {
    test('connects PayPal with email', () async {
      final repository = MockWalletRepository();
      final wallet = await repository.connectPayPal(
        email: 'john@gmail.com',
        password: 'secret',
      );
      expect(wallet.isConnected, isTrue);
      expect(wallet.provider, WalletProvider.paypal);
      expect(wallet.email, 'john@gmail.com');
    });
  });

  group('MockAiAssistantService', () {
    test('replies with top-up guidance and amount chips', () async {
      final ai = MockAiAssistantService();
      final messages = await ai.sendUserMessage('I need a Top-Up');
      final last = messages.last;
      expect(last.isUser, isFalse);
      expect(last.text.toLowerCase(), contains('top-up'));
      expect(last.quickAmounts, isNotEmpty);
    });
  });
}

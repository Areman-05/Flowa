import '../entities/wallet_entities.dart';

abstract class WalletRepository {
  Future<List<LinkedWallet>> getWallets();

  Future<LinkedWallet> connectPayPal({
    required String email,
    required String password,
  });

  Future<LinkedWallet> disconnect(String walletId);
}

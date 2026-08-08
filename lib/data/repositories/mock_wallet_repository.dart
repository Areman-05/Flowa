import '../../domain/entities/wallet_entities.dart';
import '../../domain/repositories/wallet_repository.dart';

class MockWalletRepository implements WalletRepository {
  MockWalletRepository()
      : _wallets = [
          const LinkedWallet(
            id: 'wallet-paypal',
            provider: WalletProvider.paypal,
            status: WalletConnectionStatus.disconnected,
          ),
        ];

  final List<LinkedWallet> _wallets;

  @override
  Future<List<LinkedWallet>> getWallets() async {
    return List<LinkedWallet>.unmodifiable(_wallets);
  }

  @override
  Future<LinkedWallet> connectPayPal({
    required String email,
    required String password,
  }) async {
    if (email.trim().isEmpty || password.trim().isEmpty) {
      throw ArgumentError('Email and password are required');
    }
    final index = _wallets.indexWhere((w) => w.provider == WalletProvider.paypal);
    final connected = LinkedWallet(
      id: 'wallet-paypal',
      provider: WalletProvider.paypal,
      status: WalletConnectionStatus.connected,
      email: email.trim(),
      displayName: 'PayPal',
    );
    if (index >= 0) {
      _wallets[index] = connected;
    } else {
      _wallets.add(connected);
    }
    return connected;
  }

  @override
  Future<LinkedWallet> disconnect(String walletId) async {
    final index = _wallets.indexWhere((w) => w.id == walletId);
    if (index < 0) {
      throw StateError('Wallet not found');
    }
    final updated = LinkedWallet(
      id: _wallets[index].id,
      provider: _wallets[index].provider,
      status: WalletConnectionStatus.disconnected,
    );
    _wallets[index] = updated;
    return updated;
  }
}

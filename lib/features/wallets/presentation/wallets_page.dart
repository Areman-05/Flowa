import 'package:flutter/material.dart';

import '../../../core/utils/flowa_services.dart';
import '../../../design_system/tokens/flowa_colors.dart';
import '../../../design_system/tokens/flowa_spacing.dart';
import '../../../domain/entities/wallet_entities.dart';
import '../../../shared/navigation/flowa_routes.dart';
import '../../../shared/widgets/flowa_buttons.dart';
import '../../../shared/widgets/flowa_states.dart';
import 'connect_paypal_page.dart';

class WalletsPage extends StatefulWidget {
  const WalletsPage({super.key});

  @override
  State<WalletsPage> createState() => _WalletsPageState();
}

class _WalletsPageState extends State<WalletsPage> {
  List<LinkedWallet> _wallets = const [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final wallets = await FlowaServices.walletRepository.getWallets();
      if (!mounted) {
        return;
      }
      setState(() {
        _wallets = wallets;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loading = false;
        _error = error.toString();
      });
    }
  }

  Future<void> _connect() async {
    await pushFlowaRoute<void>(context, const ConnectPayPalPage());
    await _load();
  }

  Future<void> _disconnect(LinkedWallet wallet) async {
    await FlowaServices.walletRepository.disconnect(wallet.id);
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Disconnected ${wallet.displayName ?? 'wallet'}.'),
      ),
    );
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Wallets')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? FlowaErrorState(message: _error!, onRetry: _load)
          : _wallets.isEmpty
          ? FlowaEmptyState(
              title: 'No wallets linked',
              message: 'Connect PayPal to send and receive outside Flowa.',
              actionLabel: 'Connect PayPal',
              onAction: _connect,
            )
          : ListView(
              padding: FlowaSpacing.screenPadding,
              children: [
                for (final wallet in _wallets)
                  ListTile(
                    shape: const RoundedRectangleBorder(
                      borderRadius: FlowaRadii.mdAll,
                      side: BorderSide(color: FlowaColors.border),
                    ),
                    leading: const CircleAvatar(
                      backgroundColor: FlowaColors.primarySoft,
                      child: Icon(Icons.account_balance_wallet_outlined),
                    ),
                    title: Text(wallet.displayName ?? 'PayPal'),
                    subtitle: Text(
                      wallet.isConnected
                          ? wallet.email ?? 'Connected'
                          : 'Not connected',
                    ),
                    trailing: wallet.isConnected
                        ? TextButton(
                            onPressed: () => _disconnect(wallet),
                            child: const Text('Disconnect'),
                          )
                        : const Text(
                            'Connect',
                            style: TextStyle(color: FlowaColors.primary),
                          ),
                    onTap: wallet.isConnected ? null : _connect,
                  ),
                const SizedBox(height: FlowaSpacing.xl),
                FlowaPrimaryButton(
                  label: 'Connect PayPal',
                  onPressed: _connect,
                ),
              ],
            ),
    );
  }
}

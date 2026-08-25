import 'package:flutter/material.dart';

import '../../../core/utils/flowa_services.dart';
import '../../../design_system/components/flowa_actions.dart';
import '../../../design_system/components/flowa_icon.dart';
import '../../../design_system/components/flowa_screen.dart';
import '../../../design_system/tokens/flowa_colors.dart';
import '../../../domain/entities/wallet_entities.dart';
import '../../../shared/navigation/flowa_routes.dart';
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
        content: Text('Desconectado ${wallet.displayName ?? 'monedero'}.'),
      ),
    );
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    return FlowaScreen(
      title: 'Monederos',
      footer: FlowaAcidButton(label: 'Conectar PayPal', onPressed: _connect),
      child: _loading
          ? const Center(
              child: CircularProgressIndicator(color: FlowaColors.mint),
            )
          : _error != null
              ? FlowaErrorState(message: _error!, onRetry: _load)
              : _wallets.isEmpty
                  ? FlowaEmptyState(
                      title: 'Sin monederos',
                      message:
                          'Conecta PayPal para enviar y recibir fuera de Flowa.',
                      glyph: FlowaGlyph.card,
                    )
                  : ListView(
                      children: [
                        for (final wallet in _wallets)
                          FlowaMenuRow(
                            glyph: FlowaGlyph.card,
                            title: wallet.displayName ?? 'PayPal',
                            subtitle: wallet.isConnected
                                ? wallet.email ?? 'Conectado'
                                : 'Sin conectar',
                            onTap: wallet.isConnected
                                ? () => _disconnect(wallet)
                                : _connect,
                          ),
                      ],
                    ),
    );
  }
}

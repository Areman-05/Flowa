import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/utils/flowa_formatters.dart';
import '../../../core/utils/flowa_haptics.dart';
import '../../../core/utils/flowa_services.dart';
import '../../../core/utils/receive_request.dart';
import '../../../design_system/components/flowa_actions.dart';
import '../../../design_system/components/flowa_icon.dart';
import '../../../design_system/components/flowa_money_keypad.dart';
import '../../../design_system/components/flowa_screen.dart';
import '../../../design_system/tokens/flowa_colors.dart';
import '../../../design_system/tokens/flowa_spacing.dart';
import '../../../design_system/tokens/flowa_typography.dart';
import '../../../domain/entities/finance_entities.dart';
import '../../../shared/widgets/flowa_dialogs.dart';

/// Receive / request money — hero amount + keypad + account share.
class ReceivePage extends StatefulWidget {
  const ReceivePage({super.key});

  @override
  State<ReceivePage> createState() => _ReceivePageState();
}

class _ReceivePageState extends State<ReceivePage> {
  Account? _account;
  int _cents = 0;
  final _noteController = TextEditingController();

  double get _amount => _cents / 100.0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final account = await FlowaServices.accountRepository.getPrimaryAccount();
    if (!mounted) {
      return;
    }
    setState(() => _account = account);
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  void _digit(String key) {
    FlowaHaptics.selection();
    setState(() {
      if (key == '<') {
        _cents = _cents ~/ 10;
        return;
      }
      if (key == '00') {
        if (_cents >= 1000000) {
          return;
        }
        _cents = _cents * 100;
        return;
      }
      if (_cents >= 99999999) {
        return;
      }
      _cents = _cents * 10 + int.parse(key);
    });
  }

  Future<void> _copyAccountNumber(Account account) async {
    await Clipboard.setData(ClipboardData(text: account.maskedNumber));
    await FlowaHaptics.selection();
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Número de cuenta copiado.')),
    );
  }

  Future<void> _shareRequest() async {
    final account = _account;
    if (_amount <= 0 || account == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Introduce un importe para solicitar.')),
      );
      return;
    }

    final message = ReceiveRequest.build(
      account: account,
      amount: _amount,
      note: _noteController.text,
    );

    final confirmed = await showFlowaPreviewDialog(
      context: context,
      title: 'Vista previa',
      message: message,
      confirmLabel: 'Copiar solicitud',
    );
    if (!confirmed || !mounted) {
      return;
    }

    await Clipboard.setData(ClipboardData(text: message));
    await FlowaHaptics.light();
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Solicitud de ${FlowaFormatters.currency(_amount)} copiada.',
        ),
      ),
    );
  }

  Future<void> _registerIncoming() async {
    if (_amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Introduce un importe válido.')),
      );
      return;
    }
    final note = _noteController.text.trim();
    await FlowaServices.transactionRepository.add(
      TransactionItem(
        id: 'tx-${DateTime.now().millisecondsSinceEpoch}',
        merchant: note.isEmpty ? 'Ingreso' : note,
        amount: _amount,
        occurredAt: DateTime.now(),
        direction: TransactionDirection.credit,
        category: 'Ingreso',
      ),
    );
    await FlowaServices.accountRepository.applyBalanceDelta(_amount);
    await FlowaHaptics.success();
    final labelled = FlowaFormatters.currency(_amount);
    await _load();
    if (!mounted) {
      return;
    }
    setState(() => _cents = 0);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Ingreso de $labelled registrado.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final account = _account;

    return FlowaScreen(
      title: 'Ingresar',
      footer: account == null
          ? null
          : Column(
              children: [
                FlowaAcidButton(
                  label: 'Crear solicitud',
                  onPressed: _shareRequest,
                ),
                const SizedBox(height: FlowaSpacing.sm),
                FlowaGhostButton(
                  label: 'Registrar ingreso',
                  onPressed: _registerIncoming,
                ),
              ],
            ),
      child: account == null
          ? const Center(
              child: CircularProgressIndicator(color: FlowaColors.mint),
            )
          : ListView(
              children: [
                _AccountShareCard(
                  account: account,
                  onCopy: () => _copyAccountNumber(account),
                ),
                const SizedBox(height: FlowaSpacing.xl),
                Text('Importe', style: FlowaType.micro()),
                const SizedBox(height: 6),
                Text(
                  FlowaFormatters.currency(_amount),
                  style: FlowaType.figureXl(),
                ),
                const SizedBox(height: FlowaSpacing.md),
                FlowaQuickAmounts(
                  values: const [20, 50, 100, 250],
                  activeCents: _cents,
                  onSelected: (euros) => setState(() => _cents = euros * 100),
                ),
                const SizedBox(height: FlowaSpacing.md),
                TextField(
                  controller: _noteController,
                  style: FlowaType.body(),
                  decoration: InputDecoration(
                    hintText: 'Nota (opcional)',
                    filled: true,
                    fillColor: FlowaColors.inkHigh,
                    border: OutlineInputBorder(
                      borderRadius: FlowaRadii.lgAll,
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
                const SizedBox(height: FlowaSpacing.md),
                FlowaMoneyKeypad(onKey: _digit),
                const SizedBox(height: FlowaSpacing.sm),
              ],
            ),
    );
  }
}

class _AccountShareCard extends StatelessWidget {
  const _AccountShareCard({required this.account, required this.onCopy});

  final Account account;
  final VoidCallback onCopy;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(FlowaSpacing.lg),
      decoration: const BoxDecoration(
        color: FlowaColors.inkHigh,
        borderRadius: FlowaRadii.xxlAll,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: FlowaColors.mint,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const FlowaIcon(
              FlowaGlyph.arrowDown,
              size: 20,
              color: FlowaColors.mintInk,
            ),
          ),
          const SizedBox(width: FlowaSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Tu cuenta', style: FlowaType.micro()),
                const SizedBox(height: 2),
                Text(
                  account.maskedNumber,
                  style: FlowaType.titleSm(),
                ),
              ],
            ),
          ),
          FlowaIconAction(
            glyph: FlowaGlyph.receipt,
            tooltip: 'Copiar',
            size: 40,
            onTap: onCopy,
          ),
        ],
      ),
    );
  }
}

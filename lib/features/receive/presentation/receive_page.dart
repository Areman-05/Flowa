import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/utils/flowa_formatters.dart';
import '../../../core/utils/flowa_haptics.dart';
import '../../../core/utils/flowa_services.dart';
import '../../../core/utils/receive_request.dart';
import '../../../design_system/components/flowa_actions.dart';
import '../../../design_system/components/flowa_icon.dart';
import '../../../design_system/components/flowa_primitives.dart';
import '../../../design_system/components/flowa_screen.dart';
import '../../../design_system/tokens/flowa_colors.dart';
import '../../../design_system/tokens/flowa_spacing.dart';
import '../../../design_system/tokens/flowa_typography.dart';
import '../../../domain/entities/finance_entities.dart';
import '../../../shared/widgets/flowa_dialogs.dart';

/// Receive / request money screen.
class ReceivePage extends StatefulWidget {
  const ReceivePage({super.key});

  @override
  State<ReceivePage> createState() => _ReceivePageState();
}

class _ReceivePageState extends State<ReceivePage> {
  Account? _account;
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

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
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
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
    final amount = double.tryParse(_amountController.text) ?? 0;
    final account = _account;
    if (amount <= 0 || account == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Introduce un importe para solicitar.')),
      );
      return;
    }

    final message = ReceiveRequest.build(
      account: account,
      amount: amount,
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
          'Solicitud de ${FlowaFormatters.currency(amount)} copiada.',
        ),
      ),
    );
  }

  Future<void> _registerIncoming() async {
    final amount = double.tryParse(_amountController.text) ?? 0;
    if (amount <= 0) {
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
        amount: amount,
        occurredAt: DateTime.now(),
        direction: TransactionDirection.credit,
        category: 'Ingreso',
      ),
    );
    await FlowaServices.accountRepository.applyBalanceDelta(amount);
    await _load();
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Ingreso de ${FlowaFormatters.currency(amount)} registrado.',
        ),
      ),
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
                FlowaSurface(
                  color: FlowaColors.mint,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tu cuenta',
                        style: FlowaType.micro(color: FlowaColors.mintInk),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        account.maskedNumber,
                        style: FlowaType.editorialMd(color: FlowaColors.mintInk),
                      ),
                      const SizedBox(height: FlowaSpacing.sm),
                      Text(
                        'Compártela para que te paguen más rápido.',
                        style: FlowaType.bodySm(color: FlowaColors.mintInk),
                      ),
                      const SizedBox(height: FlowaSpacing.md),
                      FlowaPressScale(
                        onTap: () => _copyAccountNumber(account),
                        child: Row(
                          children: [
                            const FlowaIcon(
                              FlowaGlyph.receipt,
                              size: 16,
                              color: FlowaColors.mintInk,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Copiar número',
                              style: FlowaType.label(color: FlowaColors.mintInk),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: FlowaSpacing.xl),
                TextField(
                  controller: _amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(
                      RegExp(r'^\d+\.?\d{0,2}'),
                    ),
                  ],
                  decoration: const InputDecoration(
                    labelText: 'Importe',
                    prefixText: '€ ',
                  ),
                ),
                const SizedBox(height: FlowaSpacing.sm),
                TextField(
                  controller: _noteController,
                  decoration: const InputDecoration(
                    labelText: 'Nota (opcional)',
                  ),
                ),
              ],
            ),
    );
  }
}

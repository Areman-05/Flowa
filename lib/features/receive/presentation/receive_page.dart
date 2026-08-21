import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/utils/flowa_formatters.dart';
import '../../../core/utils/flowa_haptics.dart';
import '../../../core/utils/flowa_services.dart';
import '../../../core/utils/receive_request.dart';
import '../../../design_system/components/flowa_motion.dart';
import '../../../design_system/tokens/flowa_colors.dart';
import '../../../design_system/tokens/flowa_spacing.dart';
import '../../../domain/entities/finance_entities.dart';
import '../../../shared/widgets/flowa_buttons.dart';
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

    return Scaffold(
      appBar: AppBar(title: const Text('Recibir')),
      body: SafeArea(
        child: account == null
            ? const Padding(
                padding: FlowaSpacing.screenPadding,
                child: FlowaListSkeleton(itemCount: 3),
              )
            : ListView(
                padding: FlowaSpacing.screenPadding,
                children: [
                  Container(
                    padding: FlowaSpacing.cardPadding,
                    decoration: const BoxDecoration(
                      color: FlowaColors.actionReceive,
                      borderRadius: FlowaRadii.lgAll,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tu cuenta para recibir',
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                        const SizedBox(height: FlowaSpacing.xs),
                        Text(
                          account.maskedNumber,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: FlowaSpacing.xs),
                        Text(
                          'Comparte esta cuenta para que te paguen más rápido.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: FlowaSpacing.sm),
                        TextButton.icon(
                          onPressed: () => _copyAccountNumber(account),
                          icon: const Icon(Icons.copy_outlined, size: 18),
                          label: const Text('Copiar número de cuenta'),
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
                  const SizedBox(height: FlowaSpacing.xxl),
                  FlowaPrimaryButton(
                    label: 'Crear solicitud',
                    onPressed: _shareRequest,
                  ),
                  const SizedBox(height: FlowaSpacing.sm),
                  FlowaSecondaryButton(
                    label: 'Registrar ingreso',
                    onPressed: _registerIncoming,
                  ),
                ],
              ),
      ),
    );
  }
}

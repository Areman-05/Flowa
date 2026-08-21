import 'package:flutter/material.dart';

import '../../../core/utils/flowa_formatters.dart';
import '../../../core/utils/flowa_services.dart';
import '../../../design_system/tokens/flowa_spacing.dart';
import '../../../domain/entities/finance_entities.dart';
import '../../../shared/navigation/flowa_routes.dart';
import '../../../shared/widgets/flowa_buttons.dart';
import '../../transfers/presentation/transfer_success_page.dart';

class SendReviewPage extends StatelessWidget {
  const SendReviewPage({
    required this.recipientName,
    required this.accountNumber,
    required this.amount,
    this.note,
    super.key,
  });

  final String recipientName;
  final String accountNumber;
  final double amount;
  final String? note;

  Future<void> _confirm(BuildContext context) async {
    await FlowaServices.transactionRepository.add(
      TransactionItem(
        id: 'tx-${DateTime.now().millisecondsSinceEpoch}',
        merchant: recipientName,
        amount: amount,
        occurredAt: DateTime.now(),
        direction: TransactionDirection.debit,
        category: 'Transferencia',
      ),
    );
    await FlowaServices.accountRepository.applyBalanceDelta(-amount);

    if (!context.mounted) {
      return;
    }
    await pushFlowaRoute<void>(
      context,
      TransferSuccessPage(
        title: 'Dinero enviado',
        amount: amount,
        subtitle: 'Enviado a $recipientName',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Revisar envío')),
      body: SafeArea(
        child: Padding(
          padding: FlowaSpacing.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Confirma que es una transferencia bancaria, no una recarga.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: FlowaSpacing.xl),
              _ReviewRow(label: 'Para', value: recipientName),
              _ReviewRow(label: 'Cuenta', value: accountNumber),
              _ReviewRow(
                label: 'Importe',
                value: FlowaFormatters.currency(amount),
              ),
              if (note != null && note!.trim().isNotEmpty)
                _ReviewRow(label: 'Nota', value: note!.trim()),
              const Spacer(),
              FlowaPrimaryButton(
                label: 'Enviar ahora',
                onPressed: () => _confirm(context),
              ),
              const SizedBox(height: FlowaSpacing.sm),
              FlowaSecondaryButton(
                label: 'Volver',
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReviewRow extends StatelessWidget {
  const _ReviewRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: FlowaSpacing.md),
      child: Row(
        children: [
          SizedBox(
            width: 88,
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.titleMedium),
          ),
        ],
      ),
    );
  }
}

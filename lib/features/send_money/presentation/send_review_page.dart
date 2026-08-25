import 'package:flutter/material.dart';

import '../../../core/utils/flowa_formatters.dart';
import '../../../core/utils/flowa_services.dart';
import '../../../design_system/components/flowa_actions.dart';
import '../../../design_system/components/flowa_primitives.dart';
import '../../../design_system/components/flowa_screen.dart';
import '../../../design_system/tokens/flowa_colors.dart';
import '../../../design_system/tokens/flowa_spacing.dart';
import '../../../design_system/tokens/flowa_typography.dart';
import '../../../domain/entities/finance_entities.dart';
import '../../../shared/navigation/flowa_routes.dart';
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
        title: 'Has enviado',
        amount: amount,
        subtitle: recipientName,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FlowaScreen(
      title: 'Revisar',
      footer: Column(
        children: [
          FlowaAcidButton(
            label: 'Enviar ahora',
            onPressed: () => _confirm(context),
          ),
          const SizedBox(height: FlowaSpacing.sm),
          FlowaGhostButton(
            label: 'Volver',
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      child: ListView(
        children: [
          const SizedBox(height: FlowaSpacing.lg),
          Text(
            FlowaFormatters.currency(amount),
            textAlign: TextAlign.center,
            style: FlowaType.figureXl(),
          ),
          const SizedBox(height: 6),
          Text(
            'a $recipientName',
            textAlign: TextAlign.center,
            style: FlowaType.body(color: FlowaColors.mint),
          ),
          const SizedBox(height: FlowaSpacing.xxl),
          FlowaLedgerRow(label: 'Para', value: recipientName),
          FlowaLedgerRow(label: 'Cuenta', value: accountNumber),
          FlowaLedgerRow(
            label: 'Importe',
            value: FlowaFormatters.currency(amount),
            valueColor: FlowaColors.mint,
          ),
          if (note != null && note!.trim().isNotEmpty)
            FlowaLedgerRow(label: 'Nota', value: note!.trim()),
        ],
      ),
    );
  }
}

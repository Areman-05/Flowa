import 'package:flutter/material.dart';

import '../../../core/utils/flowa_alerts.dart';
import '../../../core/utils/flowa_formatters.dart';
import '../../../core/utils/flowa_haptics.dart';
import '../../../core/utils/flowa_services.dart';
import '../../../design_system/components/flowa_actions.dart';
import '../../../design_system/components/flowa_icon.dart';
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
    await FlowaAlerts.moneySent(to: recipientName, amount: amount);
    await FlowaHaptics.success();

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
    final initial =
        recipientName.isEmpty ? '?' : recipientName[0].toUpperCase();

    return FlowaScreen(
      title: 'Revisar',
      footer: FlowaAcidButton(
        label: 'Enviar ahora',
        onPressed: () => _confirm(context),
      ),
      child: ListView(
        children: [
          const SizedBox(height: FlowaSpacing.lg),
          Center(
            child: Container(
              width: 64,
              height: 64,
              decoration: const BoxDecoration(
                color: FlowaColors.mint,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                initial,
                style: FlowaType.titleLg(color: FlowaColors.mintInk),
              ),
            ),
          ),
          const SizedBox(height: FlowaSpacing.md),
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
          Container(
            padding: const EdgeInsets.fromLTRB(18, 8, 18, 8),
            decoration: const BoxDecoration(
              color: FlowaColors.inkHigh,
              borderRadius: FlowaRadii.xxlAll,
            ),
            child: Column(
              children: [
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
          ),
          const SizedBox(height: FlowaSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const FlowaIcon(
                FlowaGlyph.lock,
                size: 14,
                color: FlowaColors.boneFaint,
              ),
              const SizedBox(width: 6),
              Text(
                'Transferencia instantánea protegida',
                style: FlowaType.micro(),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

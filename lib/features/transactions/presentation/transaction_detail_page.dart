import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/utils/flowa_formatters.dart';
import '../../../core/utils/transaction_export.dart';
import '../../../design_system/tokens/flowa_colors.dart';
import '../../../design_system/tokens/flowa_spacing.dart';
import '../../../domain/entities/finance_entities.dart';
import '../../../shared/navigation/flowa_routes.dart';
import '../../../shared/widgets/flowa_buttons.dart';
import '../../support/presentation/support_center_page.dart';

class TransactionDetailPage extends StatelessWidget {
  const TransactionDetailPage({required this.item, super.key});

  final TransactionItem item;

  Future<void> _shareReceipt(BuildContext context) async {
    final receipt = TransactionExport.receiptFor(item);
    await Clipboard.setData(ClipboardData(text: receipt));
    if (!context.mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Receipt copied to clipboard.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final amountColor = item.isIncome
        ? FlowaColors.income
        : FlowaColors.textPrimary;

    return Scaffold(
      appBar: AppBar(title: const Text('Transaction details')),
      body: SafeArea(
        child: ListView(
          padding: FlowaSpacing.screenPadding,
          children: [
            Container(
              padding: FlowaSpacing.cardPadding,
              decoration: BoxDecoration(
                color: FlowaColors.surface,
                borderRadius: FlowaRadii.lgAll,
                border: Border.all(color: FlowaColors.border),
              ),
              child: Column(
                children: [
                  Text(
                    item.merchant,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: FlowaSpacing.sm),
                  Text(
                    FlowaFormatters.signedCurrency(item.signedAmount),
                    style: Theme.of(
                      context,
                    ).textTheme.displayLarge?.copyWith(color: amountColor),
                  ),
                  const SizedBox(height: FlowaSpacing.xs),
                  Text(
                    FlowaFormatters.transactionStamp(item.occurredAt),
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            const SizedBox(height: FlowaSpacing.xl),
            _DetailRow(label: 'Category', value: item.category ?? 'General'),
            _DetailRow(
              label: 'Direction',
              value: item.isIncome ? 'Incoming' : 'Outgoing',
            ),
            _DetailRow(label: 'Reference', value: item.id),
            const SizedBox(height: FlowaSpacing.md),
            FlowaSecondaryButton(
              label: 'Share receipt',
              onPressed: () => _shareReceipt(context),
            ),
            const SizedBox(height: FlowaSpacing.xl),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.support_agent),
              title: const Text('Need help with this payment?'),
              subtitle: const Text('Open Support if something looks wrong'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () =>
                  pushFlowaRoute<void>(context, const SupportCenterPage()),
            ),
          ],
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: FlowaSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}

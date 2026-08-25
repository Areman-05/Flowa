import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/utils/flowa_formatters.dart';
import '../../../core/utils/transaction_export.dart';
import '../../../design_system/components/flowa_actions.dart';
import '../../../design_system/components/flowa_icon.dart';
import '../../../design_system/components/flowa_primitives.dart';
import '../../../design_system/components/flowa_screen.dart';
import '../../../design_system/components/flowa_transaction_tile.dart';
import '../../../design_system/tokens/flowa_colors.dart';
import '../../../design_system/tokens/flowa_spacing.dart';
import '../../../design_system/tokens/flowa_typography.dart';
import '../../../domain/entities/finance_entities.dart';
import '../../../shared/navigation/flowa_routes.dart';
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
      const SnackBar(content: Text('Recibo copiado.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FlowaScreen(
      title: 'Detalle',
      child: ListView(
        children: [
          const SizedBox(height: FlowaSpacing.md),
          Center(
            child: FlowaIconOrb(
              glyph: FlowaTransactionTile.glyphFor(item),
              size: 72,
              background: item.isIncome
                  ? FlowaColors.mint
                  : FlowaColors.inkHigh,
              foreground:
                  item.isIncome ? FlowaColors.mintInk : FlowaColors.bone,
            ),
          ),
          const SizedBox(height: FlowaSpacing.lg),
          Text(
            item.merchant,
            textAlign: TextAlign.center,
            style: FlowaType.titleLg(),
          ),
          const SizedBox(height: FlowaSpacing.sm),
          Text(
            FlowaFormatters.signedCurrency(item.signedAmount),
            textAlign: TextAlign.center,
            style: FlowaType.figureXl(
              color: item.isIncome ? FlowaColors.mint : FlowaColors.bone,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            FlowaFormatters.transactionStamp(item.occurredAt),
            textAlign: TextAlign.center,
            style: FlowaType.bodySm(),
          ),
          const SizedBox(height: FlowaSpacing.xxl),
          FlowaLedgerRow(
            label: 'Categoría',
            value: item.category ?? 'General',
          ),
          FlowaLedgerRow(
            label: 'Dirección',
            value: item.isIncome ? 'Entrada' : 'Salida',
          ),
          FlowaLedgerRow(label: 'Referencia', value: item.id),
          const SizedBox(height: FlowaSpacing.xl),
          FlowaGhostButton(
            label: 'Compartir recibo',
            onPressed: () => _shareReceipt(context),
          ),
          const SizedBox(height: FlowaSpacing.md),
          FlowaMenuRow(
            glyph: FlowaGlyph.spark,
            title: '¿Problema con este pago?',
            subtitle: 'Abre soporte si algo no cuadra',
            onTap: () =>
                pushFlowaRoute<void>(context, const SupportCenterPage()),
          ),
        ],
      ),
    );
  }
}

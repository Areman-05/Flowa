import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../../core/utils/flowa_formatters.dart';
import '../../../core/utils/transaction_export.dart';
import '../../../design_system/components/flowa_actions.dart';
import '../../../design_system/components/flowa_icon.dart';
import '../../../design_system/components/flowa_primitives.dart';
import '../../../design_system/components/flowa_screen.dart';
import '../../../design_system/components/flowa_transaction_tile.dart';
import '../../../design_system/icons/flowa_lucide_icons.dart';
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
      const SnackBar(
        behavior: SnackBarBehavior.fixed,
        content: Text('Recibo copiado.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final income = item.isIncome;

    return FlowaScreen(
      title: 'Detalle',
      child: ListView(
        padding: const EdgeInsets.only(bottom: FlowaSpacing.xl),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
            decoration: const BoxDecoration(
              color: FlowaColors.inkHigh,
              borderRadius: FlowaRadii.xxlAll,
            ),
            child: Column(
              children: [
                FlowaLucideOrb(
                  icon: FlowaTransactionTile.iconFor(item),
                  size: 72,
                  background: income ? FlowaColors.mint : FlowaColors.ink,
                  foreground: income ? FlowaColors.mintInk : FlowaColors.bone,
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
                    color: income ? FlowaColors.mint : FlowaColors.bone,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  FlowaFormatters.transactionStamp(item.occurredAt),
                  textAlign: TextAlign.center,
                  style: FlowaType.bodySm(),
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: income
                        ? FlowaColors.mintTintedSurface
                        : FlowaColors.ink,
                    borderRadius: FlowaRadii.pillAll,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FlowaLucideIcon(
                        income
                            ? LucideIcons.arrow_down_to_line
                            : LucideIcons.arrow_up_from_line,
                        size: 16,
                        color: income ? FlowaColors.mint : FlowaColors.boneMuted,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        income ? 'Entrada' : 'Salida',
                        style: FlowaType.label(
                          color: income ? FlowaColors.mint : FlowaColors.boneMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: FlowaSpacing.lg),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
            decoration: const BoxDecoration(
              color: FlowaColors.inkHigh,
              borderRadius: FlowaRadii.xxlAll,
            ),
            child: Column(
              children: [
                FlowaLedgerRow(
                  label: 'Categoría',
                  value: item.category ?? 'General',
                ),
                FlowaLedgerRow(
                  label: 'Importe',
                  value: FlowaFormatters.currency(item.amount.abs()),
                ),
                FlowaLedgerRow(
                  label: 'Referencia',
                  value: item.id,
                ),
              ],
            ),
          ),
          const SizedBox(height: FlowaSpacing.xl),
          FlowaPressScale(
            onTap: () => _shareReceipt(context),
            child: Container(
              height: 52,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: FlowaColors.mint,
                borderRadius: FlowaRadii.pillAll,
              ),
              child: Text(
                'Compartir recibo',
                style: FlowaType.label(color: FlowaColors.mintInk),
              ),
            ),
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

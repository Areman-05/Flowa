import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/utils/flowa_formatters.dart';
import '../../../core/utils/flowa_haptics.dart';
import '../../../core/utils/flowa_services.dart';
import '../../../design_system/components/flowa_actions.dart';
import '../../../design_system/components/flowa_icon.dart';
import '../../../design_system/components/flowa_money_text.dart';
import '../../../design_system/components/flowa_primitives.dart';
import '../../../design_system/components/flowa_screen.dart';
import '../../../design_system/tokens/flowa_colors.dart';
import '../../../design_system/tokens/flowa_motion_tokens.dart';
import '../../../design_system/tokens/flowa_spacing.dart';
import '../../../design_system/tokens/flowa_typography.dart';
import '../../../domain/entities/freelance_entities.dart';
import '../../../shared/widgets/flowa_states.dart';

/// The invoice book.
///
/// Ordered by urgency rather than by date: overdue first, then due soonest.
/// Marking an invoice paid moves the money into the account and takes the
/// configured share straight to the tax vault.
class InvoicesPage extends StatefulWidget {
  const InvoicesPage({super.key, this.embedded = false});

  final bool embedded;

  @override
  State<InvoicesPage> createState() => _InvoicesPageState();
}

class _InvoicesPageState extends State<InvoicesPage> {
  List<Invoice> _invoices = const [];
  TaxVault _vault = const TaxVault(reserved: 0, rate: 0.25);
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final invoices = await FlowaServices.freelanceRepository.getInvoices();
    final vault = await FlowaServices.freelanceRepository.getVault();
    if (!mounted) {
      return;
    }
    setState(() {
      _invoices = invoices;
      _vault = vault;
      _loading = false;
    });
  }

  Future<void> _markPaid(Invoice invoice) async {
    final reserved = invoice.amount * _vault.rate;

    await FlowaServices.freelanceRepository.markPaid(invoice.id);
    await FlowaServices.accountRepository.applyBalanceDelta(invoice.amount);
    await FlowaServices.freelanceRepository.adjustReserve(reserved);
    await FlowaHaptics.success();

    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            'Cobrada. ${FlowaFormatters.compact(reserved)} al bote de '
            'impuestos.',
          ),
        ),
      );
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    final outstanding = _invoices
        .where((invoice) => invoice.statusAt(now).isOutstanding)
        .toList()
      ..sort((a, b) => a.dueAt.compareTo(b.dueAt));
    final drafts = _invoices
        .where((invoice) => invoice.status == InvoiceStatus.draft)
        .toList();
    final paid = _invoices
        .where((invoice) => invoice.status == InvoiceStatus.paid)
        .toList();

    final total = outstanding.fold<double>(0, (sum, i) => i.amount + sum);
    final overdue = outstanding
        .where((i) => i.statusAt(now) == InvoiceStatus.overdue)
        .fold<double>(0, (sum, i) => sum + i.amount);

    return FlowaScreen(
      title: 'Facturas',
      embedded: widget.embedded,
      child: _loading
          ? const Center(
              child: CircularProgressIndicator(color: FlowaColors.mint),
            )
          : RefreshIndicator(
              onRefresh: _load,
              color: FlowaColors.mint,
              backgroundColor: FlowaColors.inkHigh,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: const EdgeInsets.only(bottom: FlowaSpacing.navClearance),
                children: [
                  FlowaSurface(
                    padding: const EdgeInsets.all(FlowaSpacing.lg),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Pendiente de cobro', style: FlowaType.micro()),
                        const SizedBox(height: 6),
                        FlowaFigure(amount: total),
                        const SizedBox(height: FlowaSpacing.sm),
                        Text(
                          overdue > 0
                              ? '${FlowaFormatters.compact(overdue)} llevan retraso.'
                              : 'Todo dentro de plazo.',
                          style: FlowaType.bodySm(
                            color: overdue > 0
                                ? FlowaColors.danger
                                : FlowaColors.boneMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: FlowaSpacing.xl),
                  if (outstanding.isNotEmpty) ...[
                    const FlowaSectionHeader(label: 'Esperando cobro'),
                    const SizedBox(height: FlowaSpacing.xs),
                    for (var i = 0; i < outstanding.length; i++)
                      FlowaEntrance(
                        delay: FlowaMotion.stagger(i),
                        child: _InvoiceRow(
                          invoice: outstanding[i],
                          onMarkPaid: () => _markPaid(outstanding[i]),
                        ),
                      ),
                    const SizedBox(height: FlowaSpacing.lg),
                  ],
                  if (drafts.isNotEmpty) ...[
                    const FlowaSectionHeader(label: 'Borradores'),
                    const SizedBox(height: FlowaSpacing.xs),
                    for (final invoice in drafts) _InvoiceRow(invoice: invoice),
                    const SizedBox(height: FlowaSpacing.lg),
                  ],
                  if (paid.isNotEmpty) ...[
                    const FlowaSectionHeader(label: 'Cobradas'),
                    const SizedBox(height: FlowaSpacing.xs),
                    for (final invoice in paid) _InvoiceRow(invoice: invoice),
                  ],
                  if (_invoices.isEmpty)
                    const FlowaEmptyState(
                      title: 'Sin facturas',
                      message: 'Todavía no has emitido ninguna.',
                      glyph: FlowaGlyph.receipt,
                    ),
                ],
              ),
            ),
    );
  }
}

class _InvoiceRow extends StatelessWidget {
  const _InvoiceRow({required this.invoice, this.onMarkPaid});

  final Invoice invoice;
  final VoidCallback? onMarkPaid;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final status = invoice.statusAt(now);
    final overdue = status == InvoiceStatus.overdue;
    final days = invoice.daysUntilDue(now);
    final issued = DateFormat('d MMM', 'es_ES').format(invoice.issuedAt);

    final caption = switch (status) {
      InvoiceStatus.overdue => 'Vencida · ${days.abs()} d',
      InvoiceStatus.paid => 'Cobrada · $issued',
      InvoiceStatus.draft => 'Borrador · $issued',
      InvoiceStatus.sent =>
        days <= 0 ? 'Vence hoy' : 'Vence en $days d',
    };

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: overdue ? FlowaColors.dangerSurface : FlowaColors.inkHigh,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              invoice.client.isEmpty ? '·' : invoice.client[0].toUpperCase(),
              style: FlowaType.titleMd(
                color: overdue ? FlowaColors.danger : FlowaColors.mint,
              ),
            ),
          ),
          const SizedBox(width: FlowaSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  invoice.client,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: FlowaType.titleSm(),
                ),
                const SizedBox(height: 3),
                Text(
                  caption,
                  style: FlowaType.bodySm(
                    color: overdue ? FlowaColors.danger : FlowaColors.boneFaint,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: FlowaSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              FlowaAmountText(signedAmount: invoice.amount),
              if (onMarkPaid != null) ...[
                const SizedBox(height: 6),
                FlowaPressScale(
                  onTap: onMarkPaid,
                  scale: 0.96,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: const BoxDecoration(
                      color: FlowaColors.mint,
                      borderRadius: FlowaRadii.pillAll,
                    ),
                    child: Text(
                      'Cobrar',
                      style: FlowaType.micro(color: FlowaColors.mintInk),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

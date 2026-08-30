import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/utils/flowa_formatters.dart';
import '../../../core/utils/flowa_haptics.dart';
import '../../../core/utils/flowa_services.dart';
import '../../../design_system/components/flowa_actions.dart';
import '../../../design_system/components/flowa_icon.dart';
import '../../../design_system/components/flowa_primitives.dart';
import '../../../design_system/components/flowa_texture.dart';
import '../../../design_system/tokens/flowa_colors.dart';
import '../../../design_system/tokens/flowa_motion_tokens.dart';
import '../../../design_system/tokens/flowa_spacing.dart';
import '../../../design_system/tokens/flowa_typography.dart';
import '../../../domain/entities/freelance_entities.dart';
import '../../../shared/navigation/flowa_routes.dart';
import '../../../shared/widgets/flowa_states.dart';
import '../../notifications/presentation/notification_inbox_page.dart';

/// Invoice book — Privat “Loans” layout: hero card + status cards.
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
  bool _showAll = false;

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
    final others = _invoices
        .where((invoice) => !invoice.statusAt(now).isOutstanding)
        .toList();

    final total = outstanding.fold<double>(0, (sum, i) => i.amount + sum);
    final overdue = outstanding
        .where((i) => i.statusAt(now) == InvoiceStatus.overdue)
        .fold<double>(0, (sum, i) => sum + i.amount);

    final body = _loading
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
              padding: EdgeInsets.fromLTRB(
                FlowaSpacing.gutter,
                FlowaSpacing.md,
                FlowaSpacing.gutter,
                widget.embedded
                    ? FlowaSpacing.navClearance
                    : FlowaSpacing.xl,
              ),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text('Facturas', style: FlowaType.titleLg()),
                    ),
                    FlowaIconAction(
                      glyph: FlowaGlyph.bell,
                      tooltip: 'Avisos',
                      onTap: () => pushFlowaRoute<void>(
                        context,
                        const NotificationInboxPage(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: FlowaSpacing.xl),
                FlowaEntrance(
                  child: _HeroInvoiceCard(
                    total: total,
                    overdue: overdue,
                    rateLabel:
                        'Reserva impuestos ${(_vault.rate * 100).round()}%',
                    onApply: outstanding.isEmpty
                        ? null
                        : () => _markPaid(outstanding.first),
                  ),
                ),
                const SizedBox(height: FlowaSpacing.xl),
                Row(
                  children: [
                    Text('Tus facturas', style: FlowaType.titleSm()),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => setState(() => _showAll = !_showAll),
                      child: Text(
                        _showAll ? 'Ver menos' : 'Ver todo',
                        style: FlowaType.micro(color: FlowaColors.boneMuted),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: FlowaSpacing.sm),
                if (outstanding.isEmpty && !_showAll && others.isEmpty)
                  const FlowaEmptyState(
                    title: 'Sin facturas',
                    message: 'Todavía no has emitido ninguna.',
                    glyph: FlowaGlyph.receipt,
                  )
                else if (outstanding.isEmpty && !_showAll)
                  const FlowaEmptyState(
                    title: 'Nada pendiente',
                    message: 'Pulsa Ver todo para ver el historial.',
                    glyph: FlowaGlyph.receipt,
                  )
                else ...[
                  for (var i = 0; i < outstanding.length; i++) ...[
                    FlowaEntrance(
                      delay: FlowaMotion.stagger(i.clamp(0, 6)),
                      child: _InvoiceLoanCard(
                        invoice: outstanding[i],
                        onMarkPaid: outstanding[i].statusAt(now).isOutstanding
                            ? () => _markPaid(outstanding[i])
                            : null,
                      ),
                    ),
                    if (i < outstanding.length - 1)
                      const SizedBox(height: FlowaSpacing.sm),
                  ],
                  for (var i = 0; i < others.length; i++)
                    FlowaReveal(
                      visible: _showAll,
                      delay: _showAll
                          ? FlowaMotion.stagger(i.clamp(0, 6))
                          : FlowaMotion.stagger(
                              (others.length - 1 - i).clamp(0, 6),
                            ),
                      child: Padding(
                        padding: EdgeInsets.only(
                          top: (outstanding.isNotEmpty || i > 0)
                              ? FlowaSpacing.sm
                              : 0,
                        ),
                        child: _InvoiceLoanCard(
                          invoice: others[i],
                          onMarkPaid: null,
                        ),
                      ),
                    ),
                ],
              ],
            ),
          );

    if (widget.embedded) {
      return SafeArea(bottom: false, child: body);
    }

    return Scaffold(
      backgroundColor: FlowaColors.ink,
      body: FlowaCanvas(
        child: SafeArea(child: body),
      ),
    );
  }
}

class _HeroInvoiceCard extends StatelessWidget {
  const _HeroInvoiceCard({
    required this.total,
    required this.overdue,
    required this.rateLabel,
    required this.onApply,
  });

  final double total;
  final double overdue;
  final String rateLabel;
  final VoidCallback? onApply;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(FlowaSpacing.lg),
      decoration: const BoxDecoration(
        color: FlowaColors.inkHigh,
        borderRadius: FlowaRadii.xxlAll,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Pendiente de cobro', style: FlowaType.titleSm()),
              const Spacer(),
              const FlowaIcon(FlowaGlyph.arrowRight, size: 18),
            ],
          ),
          const SizedBox(height: FlowaSpacing.md),
          Text(
            FlowaFormatters.currency(total),
            style: FlowaType.figureMd(),
          ),
          const SizedBox(height: FlowaSpacing.md),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Text(
                  overdue > 0
                      ? '${FlowaFormatters.compact(overdue)} con retraso'
                      : rateLabel,
                  style: FlowaType.bodySm(
                    color: overdue > 0
                        ? FlowaColors.danger
                        : FlowaColors.boneMuted,
                  ),
                ),
              ),
              FlowaPressScale(
                onTap: onApply,
                enabled: onApply != null,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: onApply == null
                        ? FlowaColors.inkPressed
                        : FlowaColors.mint,
                    borderRadius: FlowaRadii.pillAll,
                  ),
                  child: Text(
                    'Cobrar',
                    style: FlowaType.label(
                      color: onApply == null
                          ? FlowaColors.boneFaint
                          : FlowaColors.mintInk,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _InvoiceLoanCard extends StatelessWidget {
  const _InvoiceLoanCard({required this.invoice, this.onMarkPaid});

  final Invoice invoice;
  final VoidCallback? onMarkPaid;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final status = invoice.statusAt(now);
    final days = invoice.daysUntilDue(now);
    final issued = DateFormat('d MMM', 'es_ES').format(invoice.issuedAt);

    final badge = switch (status) {
      InvoiceStatus.overdue => ('Vencida', FlowaColors.danger, true),
      InvoiceStatus.paid => ('Cobrada', FlowaColors.mint, false),
      InvoiceStatus.draft => ('Borrador', FlowaColors.boneMuted, false),
      InvoiceStatus.sent => ('Activa', FlowaColors.mint, false),
    };

    final detail = switch (status) {
      InvoiceStatus.overdue => 'Retraso ${days.abs()} d',
      InvoiceStatus.paid => 'Cobrada · $issued',
      InvoiceStatus.draft => 'Borrador · $issued',
      InvoiceStatus.sent =>
        days <= 0 ? 'Vence hoy' : 'Vence en $days d',
    };

    return FlowaPressScale(
      onTap: onMarkPaid,
      enabled: onMarkPaid != null,
      haptic: false,
      scale: 0.985,
      child: Container(
        padding: const EdgeInsets.all(FlowaSpacing.md),
        decoration: const BoxDecoration(
          color: FlowaColors.inkHigh,
          borderRadius: FlowaRadii.xlAll,
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    invoice.client,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: FlowaType.titleSm(),
                  ),
                ),
                Text(
                  FlowaFormatters.currency(invoice.amount),
                  style: FlowaType.titleMd(),
                ),
              ],
            ),
            const SizedBox(height: FlowaSpacing.md),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: badge.$3
                        ? FlowaColors.dangerSurface
                        : FlowaColors.mintTintedSurface,
                    borderRadius: FlowaRadii.pillAll,
                    border: Border.all(
                      color: badge.$2.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Text(
                    badge.$1,
                    style: FlowaType.micro(color: badge.$2),
                  ),
                ),
                const Spacer(),
                Text(detail, style: FlowaType.bodySm()),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

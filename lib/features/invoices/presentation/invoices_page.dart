import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/utils/flowa_alerts.dart';
import '../../../core/utils/flowa_formatters.dart';
import '../../../core/utils/flowa_haptics.dart';
import '../../../core/utils/flowa_services.dart';
import '../../../design_system/components/flowa_actions.dart';
import '../../../design_system/components/flowa_glass.dart';
import '../../../design_system/components/flowa_icon.dart';
import '../../../design_system/components/flowa_primitives.dart';
import '../../../design_system/components/flowa_texture.dart';
import '../../../design_system/tokens/flowa_colors.dart';
import '../../../design_system/tokens/flowa_spacing.dart';
import '../../../design_system/tokens/flowa_typography.dart';
import '../../../domain/entities/finance_entities.dart';
import '../../../domain/entities/freelance_entities.dart';
import '../../../shared/navigation/flowa_routes.dart';
import '../../../shared/widgets/flowa_states.dart';
import '../../notifications/presentation/notification_inbox_page.dart';
import 'create_invoice_page.dart';

enum _CollectMode {
  /// Cobro entra en Flowa + reserva al bote.
  toAccount,

  /// Ya cobrado fuera: solo cierra el cobro.
  markOnly,
}

enum _DetailAction { collect, edit, delete }

/// Por cobrar — cobros a clientes; detalle, cobro con opciones, borradores.
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
  int _tab = 0; // 0 pendientes, 1 historial
  int _unread = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final invoices = await FlowaServices.freelanceRepository.getInvoices();
    final vault = await FlowaServices.freelanceRepository.getVault();
    await FlowaAlerts.syncOverdue(invoices);
    final unread = await FlowaServices.inboxRepository.unreadCount();
    if (!mounted) {
      return;
    }
    setState(() {
      _invoices = invoices;
      _vault = vault;
      _unread = unread;
      _loading = false;
    });
  }

  Future<void> _openInbox() async {
    await pushFlowaRoute<void>(
      context,
      const NotificationInboxPage(),
    );
    if (!mounted) {
      return;
    }
    final unread = await FlowaServices.inboxRepository.unreadCount();
    if (!mounted) {
      return;
    }
    setState(() => _unread = unread);
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _afterSave(Invoice saved) async {
    if (saved.status == InvoiceStatus.draft ||
        saved.status == InvoiceStatus.paid) {
      setState(() => _tab = 1);
    } else {
      setState(() => _tab = 0);
    }
    await _load();
    if (!mounted) {
      return;
    }
    _toast(
      saved.status == InvoiceStatus.draft
          ? 'Borrador guardado: ${saved.client}'
          : saved.status == InvoiceStatus.paid
              ? 'Cobro actualizado: ${saved.client}'
              : 'Cobro guardado: ${saved.client}',
    );
  }

  Future<void> _openCreate() async {
    final created = await pushFlowaRoute<Invoice>(
      context,
      const CreateInvoicePage(),
    );
    if (created != null) {
      await _afterSave(created);
    }
  }

  Future<void> _openEdit(Invoice invoice) async {
    final updated = await pushFlowaRoute<Invoice>(
      context,
      CreateInvoicePage(existing: invoice),
    );
    if (updated != null) {
      await _afterSave(updated);
    }
  }

  Future<void> _deleteInvoice(Invoice invoice) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: FlowaColors.inkHigh,
        shape: const RoundedRectangleBorder(borderRadius: FlowaRadii.xxlAll),
        title: Text('Eliminar borrador', style: FlowaType.titleMd()),
        content: Text(
          'Se borrará el cobro de ${invoice.client}. No se puede deshacer.',
          style: FlowaType.bodySm(color: FlowaColors.boneMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancelar',
              style: FlowaType.label(color: FlowaColors.boneMuted),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(
              'Eliminar',
              style: FlowaType.label(color: FlowaColors.danger),
            ),
          ),
        ],
      ),
    );
    if (ok != true || !mounted) {
      return;
    }
    await FlowaServices.freelanceRepository.deleteInvoice(invoice.id);
    await FlowaHaptics.light();
    await _load();
    if (!mounted) {
      return;
    }
    _toast('Borrador eliminado');
  }

  Future<void> _openCollect(Invoice invoice) async {
    final mode = await showFlowaGlassSheet<_CollectMode>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _CollectSheet(
        invoice: invoice,
        rate: _vault.rate,
      ),
    );
    if (mode == null || !mounted) {
      return;
    }
    await _applyCollect(invoice, mode);
  }

  Future<void> _applyCollect(Invoice invoice, _CollectMode mode) async {
    final reserved = invoice.amount * _vault.rate;

    await FlowaServices.freelanceRepository.markPaid(invoice.id);
    if (mode == _CollectMode.toAccount) {
      await FlowaServices.transactionRepository.add(
        TransactionItem(
          id: 'tx-${DateTime.now().millisecondsSinceEpoch}',
          merchant: invoice.client,
          amount: invoice.amount,
          occurredAt: DateTime.now(),
          direction: TransactionDirection.credit,
          category: 'Cobro',
        ),
      );
      await FlowaServices.accountRepository.applyBalanceDelta(invoice.amount);
      await FlowaServices.freelanceRepository.adjustReserve(reserved);
    }
    await FlowaAlerts.cobroCollected(
      invoice,
      toAccount: mode == _CollectMode.toAccount,
      reserved: reserved,
    );
    await FlowaHaptics.success();

    if (!mounted) {
      return;
    }

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) => _CollectDoneDialog(
        invoice: invoice,
        mode: mode,
        reserved: mode == _CollectMode.toAccount ? reserved : 0,
      ),
    );

    await _load();
  }

  Future<void> _openDetail(Invoice invoice) async {
    final action = await showFlowaGlassSheet<_DetailAction>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _InvoiceDetailSheet(invoice: invoice),
    );
    if (action == null || !mounted) {
      return;
    }
    switch (action) {
      case _DetailAction.collect:
        await _openCollect(invoice);
      case _DetailAction.edit:
        await _openEdit(invoice);
      case _DetailAction.delete:
        await _deleteInvoice(invoice);
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    final outstanding = _invoices
        .where((invoice) => invoice.statusAt(now).isOutstanding)
        .toList()
      ..sort((a, b) => a.dueAt.compareTo(b.dueAt));
    final history = _invoices
        .where((invoice) => !invoice.statusAt(now).isOutstanding)
        .toList()
      ..sort((a, b) => b.issuedAt.compareTo(a.issuedAt));

    final total = outstanding.fold<double>(0, (sum, i) => i.amount + sum);
    final overdue = outstanding
        .where((i) => i.statusAt(now) == InvoiceStatus.overdue)
        .fold<double>(0, (sum, i) => sum + i.amount);

    final list = _tab == 0 ? outstanding : history;

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
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Por cobrar', style: FlowaType.titleLg()),
                          const SizedBox(height: 2),
                          Text(
                            outstanding.isEmpty
                                ? 'Nada pendiente de clientes'
                                : '${outstanding.length} '
                                    '${outstanding.length == 1 ? 'cobro' : 'cobros'} '
                                    'abiertos',
                            style: FlowaType.micro(
                              color: FlowaColors.boneMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    FlowaIconAction(
                      glyph: FlowaGlyph.plus,
                      tooltip: 'Nuevo cobro',
                      onTap: _openCreate,
                    ),
                    const SizedBox(width: 8),
                    FlowaIconAction(
                      glyph: FlowaGlyph.bell,
                      tooltip: 'Avisos',
                      badge: _unread > 0,
                      onTap: _openInbox,
                    ),
                  ],
                ),
                const SizedBox(height: FlowaSpacing.xl),
                _SummaryCard(
                  total: total,
                  overdue: overdue,
                  ratePct: (_vault.rate * 100).round(),
                  nextClient:
                      outstanding.isEmpty ? null : outstanding.first.client,
                  onCollect: outstanding.isEmpty
                      ? null
                      : () => _openCollect(outstanding.first),
                ),
                const SizedBox(height: FlowaSpacing.xl),
                _SegmentTabs(
                  index: _tab,
                  pendingCount: outstanding.length,
                  onChanged: (i) => setState(() => _tab = i),
                ),
                const SizedBox(height: FlowaSpacing.md),
                if (list.isEmpty)
                  FlowaEmptyState(
                    title: _tab == 0 ? 'Nada por cobrar' : 'Sin historial',
                    message: _tab == 0
                        ? 'Crea un cobro cuando un cliente te deba.'
                        : 'Aquí verás los cobros cerrados y borradores.',
                    glyph: FlowaGlyph.receipt,
                    actionLabel: _tab == 0 ? 'Nuevo cobro' : null,
                    onAction: _tab == 0 ? _openCreate : null,
                  )
                else
                  for (var i = 0; i < list.length; i++) ...[
                    if (i > 0) const SizedBox(height: 8),
                    _InvoiceDoc(
                      invoice: list[i],
                      onCollect: list[i].statusAt(now).isOutstanding
                          ? () => _openCollect(list[i])
                          : null,
                      onOpen: () => _openDetail(list[i]),
                    ),
                  ],
              ],
            ),
          );

    if (widget.embedded) {
      return SafeArea(bottom: false, child: body);
    }

    return Scaffold(
      backgroundColor: FlowaColors.inkSurface,
      body: FlowaCanvas(
        child: SafeArea(child: body),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.total,
    required this.overdue,
    required this.ratePct,
    required this.nextClient,
    required this.onCollect,
  });

  final double total;
  final double overdue;
  final int ratePct;
  final String? nextClient;
  final VoidCallback? onCollect;

  @override
  Widget build(BuildContext context) {
    final canCollect = onCollect != null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: const BoxDecoration(
        color: FlowaColors.inkHigh,
        borderRadius: FlowaRadii.xxlAll,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'POR COBRAR',
            style: FlowaType.micro(color: FlowaColors.boneMuted),
          ),
          const SizedBox(height: 10),
          Text(
            FlowaFormatters.currency(total),
            style: FlowaType.figureMd(),
          ),
          const SizedBox(height: 6),
          Text(
            overdue > 0
                ? '${FlowaFormatters.compact(overdue)} con retraso'
                : canCollect
                    ? 'Siguiente: $nextClient · $ratePct % al bote'
                    : 'Nada pendiente de cobro',
            style: FlowaType.bodySm(
              color: overdue > 0 ? FlowaColors.danger : FlowaColors.boneMuted,
            ),
          ),
          if (canCollect) ...[
            const SizedBox(height: 16),
            FlowaAcidButton(
              label: nextClient == null || nextClient!.isEmpty
                  ? 'Cobrar'
                  : 'Cobrar · $nextClient',
              onPressed: onCollect,
              compact: true,
            ),
          ],
        ],
      ),
    );
  }
}

class _SegmentTabs extends StatelessWidget {
  const _SegmentTabs({
    required this.index,
    required this.pendingCount,
    required this.onChanged,
  });

  final int index;
  final int pendingCount;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: const BoxDecoration(
        color: FlowaColors.inkHigh,
        borderRadius: FlowaRadii.pillAll,
      ),
      child: Row(
        children: [
          _Seg(
            label:
                pendingCount > 0 ? 'Pendientes ($pendingCount)' : 'Pendientes',
            selected: index == 0,
            onTap: () => onChanged(0),
          ),
          _Seg(
            label: 'Historial',
            selected: index == 1,
            onTap: () => onChanged(1),
          ),
        ],
      ),
    );
  }
}

class _Seg extends StatelessWidget {
  const _Seg({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: FlowaPressScale(
        onTap: onTap,
        scale: 0.98,
        haptic: false,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? FlowaColors.mint : Colors.transparent,
            borderRadius: FlowaRadii.pillAll,
          ),
          child: Text(
            label,
            style: FlowaType.label(
              color: selected ? FlowaColors.mintInk : FlowaColors.boneMuted,
            ),
          ),
        ),
      ),
    );
  }
}

class _InvoiceDoc extends StatelessWidget {
  const _InvoiceDoc({
    required this.invoice,
    this.onCollect,
    this.onOpen,
  });

  final Invoice invoice;
  final VoidCallback? onCollect;
  final VoidCallback? onOpen;

  String get _initial {
    final name = invoice.client.trim();
    if (name.isEmpty) {
      return '·';
    }
    final parts = name.split(RegExp(r'\s+'));
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final status = invoice.statusAt(now);
    final days = invoice.daysUntilDue(now);
    final due = DateFormat('d MMM', 'es_ES').format(invoice.dueAt);
    final overdue = status == InvoiceStatus.overdue;
    final paid = status == InvoiceStatus.paid;
    final draft = status == InvoiceStatus.draft;

    final timing = switch (status) {
      InvoiceStatus.overdue => 'Hace ${days.abs()} d',
      InvoiceStatus.paid => 'Cobrada',
      InvoiceStatus.draft => 'Borrador',
      InvoiceStatus.sent => days <= 0
          ? 'Hoy'
          : days == 1
              ? 'Mañana'
              : 'En $days d',
    };

    final accent = switch (status) {
      InvoiceStatus.overdue => FlowaColors.danger,
      InvoiceStatus.paid => FlowaColors.mint,
      InvoiceStatus.draft => FlowaColors.boneMuted,
      InvoiceStatus.sent => FlowaColors.mint,
    };

    final orbBg = overdue
        ? FlowaColors.dangerSurface
        : paid || status == InvoiceStatus.sent
            ? FlowaColors.mintTintedSurface
            : FlowaColors.inkRaised;
    final orbFg = overdue
        ? FlowaColors.danger
        : paid || status == InvoiceStatus.sent
            ? FlowaColors.mint
            : FlowaColors.boneMuted;

    final card = Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: overdue
            ? FlowaColors.dangerSurface.withValues(alpha: 0.55)
            : FlowaColors.inkHigh,
        borderRadius: FlowaRadii.xxlAll,
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          if (overdue || paid)
            Positioned(
              left: 0,
              top: 16,
              bottom: 16,
              child: Container(
                width: 3,
                decoration: BoxDecoration(
                  color: overdue
                      ? FlowaColors.danger
                      : FlowaColors.mint.withValues(alpha: 0.55),
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: orbBg,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: accent.withValues(alpha: 0.28),
                        ),
                      ),
                      child: Text(
                        _initial,
                        style: FlowaType.label(color: orbFg),
                      ),
                    ),
                    const SizedBox(width: 12),
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
                          if (invoice.concept.isNotEmpty) ...[
                            const SizedBox(height: 3),
                            Text(
                              invoice.concept,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: FlowaType.bodySm(
                                color: FlowaColors.boneMuted,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    FlowaTag(
                      status.label,
                      color: accent,
                      background: switch (status) {
                        InvoiceStatus.overdue => FlowaColors.dangerSurface,
                        InvoiceStatus.paid => FlowaColors.mintTintedSurface,
                        InvoiceStatus.sent => FlowaColors.mintTintedSurface,
                        InvoiceStatus.draft => null,
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const FlowaRule(),
                const SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            FlowaFormatters.currency(invoice.amount),
                            style: FlowaType.figureMd(
                              color: paid
                                  ? FlowaColors.boneMuted
                                  : FlowaColors.bone,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              FlowaIcon(
                                overdue ? FlowaGlyph.clock : FlowaGlyph.receipt,
                                size: 13,
                                color: overdue
                                    ? FlowaColors.danger
                                    : FlowaColors.boneFaint,
                              ),
                              const SizedBox(width: 5),
                              Flexible(
                                child: Text(
                                  draft
                                      ? timing
                                      : paid
                                          ? timing
                                          : '$timing · $due',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: FlowaType.micro(
                                    color: overdue
                                        ? FlowaColors.danger
                                        : FlowaColors.boneMuted,
                                  ),
                                ),
                              ),
                              if (invoice.number != null &&
                                  invoice.number!.isNotEmpty) ...[
                                Text(
                                  '  ·  ',
                                  style: FlowaType.micro(
                                    color: FlowaColors.boneFaint,
                                  ),
                                ),
                                Flexible(
                                  child: Text(
                                    invoice.number!,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: FlowaType.micro(
                                      color: FlowaColors.boneFaint,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (onCollect != null) ...[
                      const SizedBox(width: 10),
                      FlowaPressScale(
                        onTap: onCollect,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          decoration: const BoxDecoration(
                            color: FlowaColors.mint,
                            borderRadius: FlowaRadii.pillAll,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Cobrar',
                                style: FlowaType.label(
                                  color: FlowaColors.mintInk,
                                ),
                              ),
                              const SizedBox(width: 4),
                              const FlowaIcon(
                                FlowaGlyph.arrowRight,
                                size: 14,
                                color: FlowaColors.mintInk,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ] else if (onOpen != null)
                      const Padding(
                        padding: EdgeInsets.only(bottom: 4),
                        child: FlowaIcon(
                          FlowaGlyph.arrowRight,
                          size: 18,
                          color: FlowaColors.boneFaint,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );

    if (onOpen == null) {
      return card;
    }

    return FlowaPressScale(
      onTap: onOpen,
      scale: 0.985,
      haptic: false,
      child: card,
    );
  }
}

class _CollectSheet extends StatefulWidget {
  const _CollectSheet({required this.invoice, required this.rate});

  final Invoice invoice;
  final double rate;

  @override
  State<_CollectSheet> createState() => _CollectSheetState();
}

class _CollectSheetState extends State<_CollectSheet> {
  _CollectMode _mode = _CollectMode.toAccount;

  @override
  Widget build(BuildContext context) {
    final reserved = widget.invoice.amount * widget.rate;
    final net = widget.invoice.amount - reserved;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: FlowaColors.hairlineStrong,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Cobrar', style: FlowaType.titleMd()),
            const SizedBox(height: 4),
            Text(
              widget.invoice.client,
              style: FlowaType.bodySm(color: FlowaColors.boneMuted),
            ),
            const SizedBox(height: 16),
            Text(
              FlowaFormatters.currency(widget.invoice.amount),
              style: FlowaType.figureMd(),
            ),
            if (widget.invoice.concept.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                widget.invoice.concept,
                style: FlowaType.bodySm(color: FlowaColors.boneMuted),
              ),
            ],
            const SizedBox(height: 20),
            Text('¿Cómo lo cobras?', style: FlowaType.titleSm()),
            const SizedBox(height: 10),
            _ModeTile(
              selected: _mode == _CollectMode.toAccount,
              title: 'Ingresar en Flowa',
              subtitle:
                  '${FlowaFormatters.compact(net)} disponible · '
                  '${FlowaFormatters.compact(reserved)} al bote '
                  '(${(widget.rate * 100).round()} %)',
              onTap: () => setState(() => _mode = _CollectMode.toAccount),
            ),
            const SizedBox(height: 8),
            _ModeTile(
              selected: _mode == _CollectMode.markOnly,
              title: 'Ya cobrado fuera',
              subtitle:
                  'Cierra el cobro. El bote no se mueve: el impuesto '
                  'lo gestionas tú.',
              onTap: () => setState(() => _mode = _CollectMode.markOnly),
            ),
            const SizedBox(height: 20),
            FlowaAcidButton(
              label: 'Confirmar',
              onPressed: () => Navigator.of(context).pop(_mode),
              compact: true,
            ),
            const SizedBox(height: 8),
            FlowaGhostButton(
              label: 'Cancelar',
              onPressed: () => Navigator.of(context).pop(),
              compact: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeTile extends StatelessWidget {
  const _ModeTile({
    required this.selected,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final bool selected;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FlowaPressScale(
      onTap: onTap,
      scale: 0.98,
      haptic: false,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        decoration: BoxDecoration(
          color: selected
              ? FlowaColors.mintTintedSurface
              : FlowaColors.inkRaised,
          borderRadius: FlowaRadii.lgAll,
          border: Border.all(
            color: selected
                ? FlowaColors.mint.withValues(alpha: 0.45)
                : FlowaColors.hairline,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? FlowaColors.mint : Colors.transparent,
                border: Border.all(
                  color: selected ? FlowaColors.mint : FlowaColors.boneFaint,
                  width: 1.5,
                ),
              ),
              child: selected
                  ? const Icon(Icons.check, size: 12, color: FlowaColors.mintInk)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: FlowaType.titleSm()),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: FlowaType.bodySm(color: FlowaColors.boneMuted),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CollectDoneDialog extends StatelessWidget {
  const _CollectDoneDialog({
    required this.invoice,
    required this.mode,
    required this.reserved,
  });

  final Invoice invoice;
  final _CollectMode mode;
  final double reserved;

  @override
  Widget build(BuildContext context) {
    final toAccount = mode == _CollectMode.toAccount;

    return Dialog(
      backgroundColor: FlowaColors.inkHigh,
      shape: const RoundedRectangleBorder(borderRadius: FlowaRadii.xxlAll),
      insetPadding: const EdgeInsets.symmetric(horizontal: 28),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 24, 22, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: const BoxDecoration(
                color: FlowaColors.mintTintedSurface,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const FlowaIcon(
                FlowaGlyph.check,
                size: 24,
                color: FlowaColors.mint,
              ),
            ),
            const SizedBox(height: 16),
            Text('Cobro registrado', style: FlowaType.titleMd()),
            const SizedBox(height: 8),
            Text(
              toAccount
                  ? '${FlowaFormatters.currency(invoice.amount)} de '
                      '${invoice.client} ya están en tu cuenta. '
                      '${FlowaFormatters.compact(reserved)} al bote.'
                  : 'Cobro de ${invoice.client} marcado como cobrado. '
                      'El bote no ha cambiado.',
              textAlign: TextAlign.center,
              style: FlowaType.bodySm(color: FlowaColors.boneMuted),
            ),
            const SizedBox(height: 20),
            FlowaAcidButton(
              label: 'Entendido',
              onPressed: () => Navigator.of(context).pop(),
              compact: true,
            ),
          ],
        ),
      ),
    );
  }
}

class _InvoiceDetailSheet extends StatelessWidget {
  const _InvoiceDetailSheet({required this.invoice});

  final Invoice invoice;

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final status = invoice.statusAt(now);
    final issued = DateFormat('d MMM yyyy', 'es_ES').format(invoice.issuedAt);
    final due = DateFormat('d MMM yyyy', 'es_ES').format(invoice.dueAt);
    final outstanding = status.isOutstanding;
    final draft = status == InvoiceStatus.draft;

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: FlowaColors.hairlineStrong,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text('Detalle', style: FlowaType.titleMd()),
                ),
                FlowaTag(
                  status.label,
                  color: status == InvoiceStatus.paid
                      ? FlowaColors.mint
                      : status == InvoiceStatus.overdue
                          ? FlowaColors.danger
                          : FlowaColors.boneMuted,
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              FlowaFormatters.currency(invoice.amount),
              style: FlowaType.figureMd(),
            ),
            const SizedBox(height: 16),
            _DetailRow(label: 'Cliente', value: invoice.client),
            _DetailRow(
              label: 'Concepto',
              value: invoice.concept.isEmpty ? '—' : invoice.concept,
            ),
            _DetailRow(
              label: 'Número',
              value: (invoice.number == null || invoice.number!.isEmpty)
                  ? '—'
                  : invoice.number!,
            ),
            _DetailRow(label: 'Emitida', value: issued),
            _DetailRow(label: 'Vencimiento', value: due),
            if (status == InvoiceStatus.overdue) ...[
              const SizedBox(height: 8),
              Text(
                'Vencida: sigue pendiente. Puedes cobrarla cuando el '
                'cliente pague; el retraso no la cancela.',
                style: FlowaType.bodySm(color: FlowaColors.danger),
              ),
            ],
            const SizedBox(height: 16),
            if (outstanding) ...[
              FlowaAcidButton(
                label: 'Cobrar',
                onPressed: () =>
                    Navigator.of(context).pop(_DetailAction.collect),
                compact: true,
              ),
              const SizedBox(height: 8),
              FlowaGhostButton(
                label: 'Editar',
                onPressed: () => Navigator.of(context).pop(_DetailAction.edit),
                compact: true,
              ),
              const SizedBox(height: 8),
            ],
            if (draft) ...[
              FlowaAcidButton(
                label: 'Editar',
                onPressed: () => Navigator.of(context).pop(_DetailAction.edit),
                compact: true,
              ),
              const SizedBox(height: 8),
              FlowaGhostButton(
                label: 'Eliminar borrador',
                onPressed: () =>
                    Navigator.of(context).pop(_DetailAction.delete),
                compact: true,
              ),
              const SizedBox(height: 8),
            ],
            if (status == InvoiceStatus.paid) ...[
              FlowaAcidButton(
                label: 'Editar',
                onPressed: () => Navigator.of(context).pop(_DetailAction.edit),
                compact: true,
              ),
              const SizedBox(height: 8),
            ],
            FlowaGhostButton(
              label: 'Cerrar',
              onPressed: () => Navigator.of(context).pop(),
              compact: true,
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
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 108,
            child: Text(
              label,
              style: FlowaType.bodySm(color: FlowaColors.boneMuted),
            ),
          ),
          Expanded(
            child: Text(value, style: FlowaType.body()),
          ),
        ],
      ),
    );
  }
}

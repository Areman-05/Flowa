import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../../core/utils/flowa_formatters.dart';
import '../../../design_system/components/flowa_actions.dart';
import '../../../design_system/components/flowa_amount_chips.dart';
import '../../../design_system/components/flowa_icon.dart';
import '../../../design_system/components/flowa_screen.dart';
import '../../../design_system/tokens/flowa_colors.dart';
import '../../../design_system/tokens/flowa_spacing.dart';
import '../../../design_system/tokens/flowa_typography.dart';
import '../domain/more_service_catalog.dart';
import 'more_payment_helper.dart';
import 'more_qr_scanner_page.dart';
import 'widgets/more_service_ui.dart';

/// Compra de entradas para cine, conciertos y deporte.
class MoreTicketsPage extends StatefulWidget {
  const MoreTicketsPage({super.key});

  @override
  State<MoreTicketsPage> createState() => _MoreTicketsPageState();
}

class _MoreTicketsPageState extends State<MoreTicketsPage> {
  String _filter = 'Todos';

  @override
  Widget build(BuildContext context) {
    final categories = [
      'Todos',
      ...MoreServiceCatalog.tickets.map((e) => e.category).toSet(),
    ];
    final events = _filter == 'Todos'
        ? MoreServiceCatalog.tickets
        : MoreServiceCatalog.tickets
            .where((event) => event.category == _filter)
            .toList();

    return FlowaScreen(
      title: 'Entradas',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const MoreServiceIntro(
            icon: LucideIcons.ticket,
            title: 'Entradas',
            description: 'Cine, conciertos, teatro y deporte en un solo sitio.',
            accent: Color(0xFF9A7EC8),
          ),
          const SizedBox(height: FlowaSpacing.lg),
          SizedBox(
            height: 42,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final label = categories.elementAt(index);
                final selected = label == _filter;
                return FlowaPressScale(
                  onTap: () => setState(() => _filter = label),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color:
                          selected ? FlowaColors.mint : FlowaColors.inkHigh,
                      borderRadius: FlowaRadii.pillAll,
                      border: Border.all(
                        color: selected
                            ? FlowaColors.mint
                            : FlowaColors.hairlineStrong,
                      ),
                    ),
                    child: Text(
                      label,
                      style: FlowaType.titleSm(
                        color: selected
                            ? FlowaColors.mintInk
                            : FlowaColors.boneMuted,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: FlowaSpacing.lg),
          Expanded(
            child: ListView.separated(
              itemCount: events.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(height: FlowaSpacing.sm),
              itemBuilder: (context, index) {
                final event = events[index];
                return _EventCard(
                  event: event,
                  onBuy: () => completeMoreServicePayment(
                    context: context,
                    merchant: event.title,
                    amount: event.priceFrom,
                    category: 'Ocio',
                    successTitle: 'Entrada confirmada',
                    successSubtitle: '${event.venue} · ${event.dateLabel}',
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _EventCard extends StatelessWidget {
  const _EventCard({required this.event, required this.onBuy});

  final MoreTicketEvent event;
  final VoidCallback onBuy;

  @override
  Widget build(BuildContext context) {
    return MoreServiceCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: FlowaColors.mintTintedSurface,
                  borderRadius: FlowaRadii.lgAll,
                ),
                alignment: Alignment.center,
                child: const FlowaLucideIcon(
                  LucideIcons.ticket,
                  size: 26,
                  color: FlowaColors.mint,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(event.title, style: FlowaType.titleMd()),
                    const SizedBox(height: 6),
                    Text(
                      event.venue,
                      style: FlowaType.body(color: FlowaColors.boneMuted),
                    ),
                    Text(event.dateLabel, style: FlowaType.bodySm()),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Text(
                'Desde ${FlowaFormatters.currency(event.priceFrom)}',
                style: FlowaType.titleSm(color: FlowaColors.mint),
              ),
              const Spacer(),
              FlowaPressScale(
                onTap: onBuy,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: FlowaColors.mint,
                    borderRadius: FlowaRadii.pillAll,
                  ),
                  child: Text(
                    'Comprar',
                    style: FlowaType.titleSm(color: FlowaColors.mintInk),
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

/// Contratación de seguros básicos.
class MoreInsurancePage extends StatefulWidget {
  const MoreInsurancePage({super.key});

  @override
  State<MoreInsurancePage> createState() => _MoreInsurancePageState();
}

class _MoreInsurancePageState extends State<MoreInsurancePage> {
  String _filter = 'Todos';
  String? _expandedPlan;

  @override
  Widget build(BuildContext context) {
    final categories = [
      'Todos',
      ...MoreServiceCatalog.insurance.map((p) => p.category).toSet(),
    ];
    final plans = _filter == 'Todos'
        ? MoreServiceCatalog.insurance
        : MoreServiceCatalog.insurance
            .where((plan) => plan.category == _filter)
            .toList();

    return FlowaScreen(
      title: 'Seguro',
      child: ListView(
        padding: const EdgeInsets.only(bottom: FlowaSpacing.xl),
        children: [
          const MoreServiceIntro(
            icon: LucideIcons.shield,
            title: 'Seguros',
            description:
                'Salud, hogar, RC profesional y más. Compara coberturas antes de contratar.',
            accent: Color(0xFFCC7888),
          ),
          const SizedBox(height: FlowaSpacing.lg),
          SizedBox(
            height: 42,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final label = categories.elementAt(index);
                final selected = label == _filter;
                return FlowaPressScale(
                  onTap: () => setState(() => _filter = label),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected ? FlowaColors.mint : FlowaColors.inkHigh,
                      borderRadius: FlowaRadii.pillAll,
                      border: Border.all(
                        color: selected
                            ? FlowaColors.mint
                            : FlowaColors.hairlineStrong,
                      ),
                    ),
                    child: Text(
                      label,
                      style: FlowaType.titleSm(
                        color: selected
                            ? FlowaColors.mintInk
                            : FlowaColors.boneMuted,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: FlowaSpacing.lg),
          for (final plan in plans) ...[
            _InsurancePlanCard(
              plan: plan,
              expanded: _expandedPlan == plan.name,
              onToggle: () => setState(() {
                _expandedPlan =
                    _expandedPlan == plan.name ? null : plan.name;
              }),
              onContract: () => completeMoreServicePayment(
                context: context,
                merchant: plan.name,
                amount: plan.monthly,
                category: 'Salud',
                successTitle: 'Seguro contratado',
                successSubtitle:
                    'Primer cargo: ${FlowaFormatters.currency(plan.monthly)}',
              ),
            ),
            const SizedBox(height: FlowaSpacing.sm),
          ],
        ],
      ),
    );
  }
}

class _InsurancePlanCard extends StatelessWidget {
  const _InsurancePlanCard({
    required this.plan,
    required this.expanded,
    required this.onToggle,
    required this.onContract,
  });

  final MoreInsurancePlan plan;
  final bool expanded;
  final VoidCallback onToggle;
  final VoidCallback onContract;

  @override
  Widget build(BuildContext context) {
    return MoreServiceCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FlowaPressScale(
            onTap: onToggle,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: plan.tone.withValues(alpha: 0.16),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: FlowaLucideIcon(
                    LucideIcons.shield,
                    size: 24,
                    color: plan.tone,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(plan.name, style: FlowaType.titleMd()),
                          ),
                          FlowaLucideIcon(
                            expanded
                                ? LucideIcons.chevron_up
                                : LucideIcons.chevron_down,
                            size: 20,
                            color: FlowaColors.boneMuted,
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        plan.summary,
                        style: FlowaType.body(color: FlowaColors.boneMuted),
                      ),
                      if (plan.highlights != null) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: [
                            for (final tag in plan.highlights!)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: FlowaColors.mintTintedSurface,
                                  borderRadius: FlowaRadii.pillAll,
                                ),
                                child: Text(
                                  tag,
                                  style: FlowaType.bodySm(color: FlowaColors.mint),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (expanded) ...[
            const SizedBox(height: 16),
            if (plan.deductible != null)
              _InsuranceDetailRow(
                label: 'Franquicia',
                value: plan.deductible!,
              ),
            if (plan.waitingPeriod != null)
              _InsuranceDetailRow(
                label: 'Carencias',
                value: plan.waitingPeriod!,
              ),
            const SizedBox(height: 8),
            Text('Coberturas incluidas', style: FlowaType.titleSm()),
            const SizedBox(height: 8),
            for (final coverage in plan.coverages)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const FlowaLucideIcon(
                      LucideIcons.check,
                      size: 16,
                      color: FlowaColors.mint,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        coverage,
                        style: FlowaType.body(color: FlowaColors.boneMuted),
                      ),
                    ),
                  ],
                ),
              ),
          ],
          const SizedBox(height: 18),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${FlowaFormatters.currency(plan.monthly)}/mes',
                    style: FlowaType.figureMd(color: FlowaColors.mint),
                  ),
                  Text(
                    plan.category,
                    style: FlowaType.bodySm(color: FlowaColors.boneMuted),
                  ),
                ],
              ),
              const Spacer(),
              FlowaPressScale(
                onTap: onContract,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: FlowaColors.mint,
                    borderRadius: FlowaRadii.pillAll,
                  ),
                  child: Text(
                    'Contratar',
                    style: FlowaType.titleSm(color: FlowaColors.mintInk),
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

class _InsuranceDetailRow extends StatelessWidget {
  const _InsuranceDetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Text('$label: ', style: FlowaType.titleSm()),
          Expanded(
            child: Text(
              value,
              style: FlowaType.body(color: FlowaColors.boneMuted),
            ),
          ),
        ],
      ),
    );
  }
}

/// Pago escaneando o pegando un código QR.
class MoreQrPayPage extends StatefulWidget {
  const MoreQrPayPage({super.key});

  @override
  State<MoreQrPayPage> createState() => _MoreQrPayPageState();
}

class _MoreQrPayPageState extends State<MoreQrPayPage> {
  final _codeController = TextEditingController();
  final _amountController = TextEditingController();
  bool _scanning = false;

  @override
  void dispose() {
    _codeController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _scan() async {
    setState(() => _scanning = true);
    final code = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const MoreQrScannerPage()),
    );
    if (!mounted) {
      return;
    }
    setState(() => _scanning = false);
    if (code != null && code.isNotEmpty) {
      _codeController.text = code;
      _tryParseAmountFromQr(code);
    }
  }

  void _tryParseAmountFromQr(String code) {
    final amountMatch = RegExp(r'amount[=:](\d+\.?\d*)', caseSensitive: false)
        .firstMatch(code);
    if (amountMatch != null) {
      _amountController.text = amountMatch.group(1)!;
    }
  }

  Future<void> _pay() async {
    final amount = double.tryParse(_amountController.text) ?? 0;
    if (_codeController.text.trim().isEmpty || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Introduce código QR e importe.'),
          behavior: SnackBarBehavior.fixed,
        ),
      );
      return;
    }

    await completeMoreServicePayment(
      context: context,
      merchant: 'Pago QR · ${_codeController.text.trim()}',
      amount: amount,
      category: 'Transferencia',
      successTitle: 'Pago QR realizado',
      successSubtitle: FlowaFormatters.currency(amount),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FlowaScreen(
      title: 'Pago QR',
      footer: FlowaAcidButton(label: 'Confirmar pago', onPressed: _pay),
      child: ListView(
        padding: const EdgeInsets.only(bottom: FlowaSpacing.xl),
        children: [
          const MoreServiceIntro(
            icon: LucideIcons.qr_code,
            title: 'Pago QR',
            description: 'Escanea en comercio o pega el código del ticket.',
          ),
          const SizedBox(height: FlowaSpacing.xl),
          FlowaPressScale(
            onTap: _scan,
            enabled: !_scanning,
            child: AspectRatio(
              aspectRatio: 1.2,
              child: Container(
                decoration: BoxDecoration(
                  color: FlowaColors.inkHigh,
                  borderRadius: FlowaRadii.xxlAll,
                  border: Border.all(color: FlowaColors.hairlineStrong),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        color: FlowaColors.mintTintedSurface,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: _scanning
                          ? const SizedBox(
                              width: 28,
                              height: 28,
                              child: CircularProgressIndicator(
                                color: FlowaColors.mint,
                                strokeWidth: 2.5,
                              ),
                            )
                          : const FlowaLucideIcon(
                              LucideIcons.camera,
                              size: 36,
                              color: FlowaColors.mint,
                            ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Toca para escanear',
                      style: FlowaType.titleSm(),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Usa la cámara del móvil',
                      style: FlowaType.body(color: FlowaColors.boneMuted),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: FlowaSpacing.xl),
          TextField(
            controller: _codeController,
            style: moreFieldStyle,
            decoration: moreInputDecoration(
              label: 'Código QR / referencia',
              hint: 'QR-92837465',
            ),
          ),
          const SizedBox(height: FlowaSpacing.lg),
          TextField(
            controller: _amountController,
            style: moreFieldStyle,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
            decoration: moreInputDecoration(label: 'Importe', prefixText: '€ '),
          ),
        ],
      ),
    );
  }
}

/// Donaciones a ONG.
class MoreDonationsPage extends StatefulWidget {
  const MoreDonationsPage({super.key});

  @override
  State<MoreDonationsPage> createState() => _MoreDonationsPageState();
}

class _MoreDonationsPageState extends State<MoreDonationsPage> {
  MoreDonationOrg? _org;
  double? _chip;
  String _filter = 'Todos';
  final _amountController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _donate() async {
    final org = _org;
    final amount = double.tryParse(_amountController.text) ?? 0;
    if (org == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Elige organización e importe.'),
          behavior: SnackBarBehavior.fixed,
        ),
      );
      return;
    }

    await completeMoreServicePayment(
      context: context,
      merchant: 'Donación · ${org.name}',
      amount: amount,
      category: 'Ocio',
      successTitle: 'Donación enviada',
      successSubtitle: '${org.name} · ${FlowaFormatters.currency(amount)}',
    );
  }

  @override
  Widget build(BuildContext context) {
    final categories = [
      'Todos',
      ...MoreServiceCatalog.donations
          .map((o) => o.category)
          .whereType<String>()
          .toSet(),
    ];
    final orgs = _filter == 'Todos'
        ? MoreServiceCatalog.donations
        : MoreServiceCatalog.donations
            .where((org) => org.category == _filter)
            .toList();

    return FlowaScreen(
      title: 'Donaciones',
      footer: FlowaAcidButton(label: 'Donar ahora', onPressed: _donate),
      child: ListView(
        padding: const EdgeInsets.only(bottom: FlowaSpacing.xl),
        children: [
          const MoreServiceIntro(
            icon: LucideIcons.heart_handshake,
            title: 'Donaciones',
            description:
                'Contribuye a causas sociales, salud y medio ambiente desde tu cuenta.',
            accent: Color(0xFF6DB892),
          ),
          const SizedBox(height: FlowaSpacing.lg),
          SizedBox(
            height: 42,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final label = categories.elementAt(index);
                final selected = label == _filter;
                return FlowaPressScale(
                  onTap: () => setState(() => _filter = label),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 18),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected ? FlowaColors.mint : FlowaColors.inkHigh,
                      borderRadius: FlowaRadii.pillAll,
                      border: Border.all(
                        color: selected
                            ? FlowaColors.mint
                            : FlowaColors.hairlineStrong,
                      ),
                    ),
                    child: Text(
                      label,
                      style: FlowaType.titleSm(
                        color: selected
                            ? FlowaColors.mintInk
                            : FlowaColors.boneMuted,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: FlowaSpacing.lg),
          for (final org in orgs) ...[
            FlowaPressScale(
              onTap: () => setState(() => _org = org),
              child: MoreServiceCard(
                selected: _org?.name == org.name,
                padding: const EdgeInsets.all(18),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 24,
                      backgroundColor: org.tone.withValues(alpha: 0.18),
                      child: Text(
                        org.name[0],
                        style: FlowaType.titleSm(color: org.tone),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(org.name, style: FlowaType.titleMd()),
                          const SizedBox(height: 4),
                          Text(
                            org.summary,
                            style: FlowaType.body(color: FlowaColors.boneMuted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: FlowaSpacing.sm),
          ],
          const SizedBox(height: FlowaSpacing.md),
          const MoreSectionLabel('Importe'),
          TextField(
            controller: _amountController,
            style: moreFieldStyle,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
            onChanged: (_) => setState(() => _chip = null),
            decoration: moreInputDecoration(label: 'Cantidad', prefixText: '€ '),
          ),
          const SizedBox(height: FlowaSpacing.lg),
          FlowaAmountChips(
            values: const [5, 10, 25, 50, 100, 250],
            selected: _chip,
            onSelected: (value) {
              setState(() {
                _chip = value;
                _amountController.text = value.toStringAsFixed(2);
              });
            },
          ),
        ],
      ),
    );
  }
}

/// Cambio de divisa.
class MoreExchangePage extends StatefulWidget {
  const MoreExchangePage({super.key});

  @override
  State<MoreExchangePage> createState() => _MoreExchangePageState();
}

class _MoreExchangePageState extends State<MoreExchangePage> {
  String _from = 'EUR';
  String _to = 'USD';
  final _amountController = TextEditingController(text: '100');

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  double get _converted {
    final amount = double.tryParse(_amountController.text) ?? 0;
    final from = MoreServiceCatalog.currencies
        .firstWhere((c) => c.code == _from, orElse: () => MoreServiceCatalog.currencies.first);
    final to = MoreServiceCatalog.currencies
        .firstWhere((c) => c.code == _to, orElse: () => MoreServiceCatalog.currencies.first);
    return amount * (to.rate / from.rate);
  }

  String _symbol(String code) {
    return MoreServiceCatalog.currencies
        .firstWhere((c) => c.code == code, orElse: () => MoreServiceCatalog.currencies.first)
        .symbol;
  }

  Future<void> _exchange() async {
    final amount = double.tryParse(_amountController.text) ?? 0;
    if (amount <= 0) {
      return;
    }

    await completeMoreServicePayment(
      context: context,
      merchant: 'Cambio $_from → $_to',
      amount: amount,
      category: 'Transferencia',
      successTitle: 'Cambio realizado',
      successSubtitle:
          '${FlowaFormatters.currency(amount)} → ${_converted.toStringAsFixed(2)} $_to',
    );
  }

  @override
  Widget build(BuildContext context) {
    return FlowaScreen(
      title: 'Cambio',
      footer: FlowaAcidButton(label: 'Convertir', onPressed: _exchange),
      child: ListView(
        padding: const EdgeInsets.only(bottom: FlowaSpacing.xl),
        children: [
          const MoreServiceIntro(
            icon: LucideIcons.refresh_cw,
            title: 'Cambio de divisa',
            description: 'Tipo orientativo. Sin comisión en demo.',
            accent: Color(0xFF6890B8),
          ),
          const SizedBox(height: FlowaSpacing.xl),
          _CurrencySelector(
            label: 'Desde',
            value: _from,
            exclude: _to,
            onChanged: (value) => setState(() => _from = value),
          ),
          const SizedBox(height: FlowaSpacing.md),
          Center(
            child: FlowaPressScale(
              onTap: () => setState(() {
                final temp = _from;
                _from = _to;
                _to = temp;
              }),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: FlowaColors.inkHigh,
                  shape: BoxShape.circle,
                  border: Border.all(color: FlowaColors.hairlineStrong),
                ),
                alignment: Alignment.center,
                child: const FlowaLucideIcon(
                  LucideIcons.arrow_up_down,
                  size: 20,
                  color: FlowaColors.mint,
                ),
              ),
            ),
          ),
          const SizedBox(height: FlowaSpacing.md),
          _CurrencySelector(
            label: 'A',
            value: _to,
            exclude: _from,
            onChanged: (value) => setState(() => _to = value),
          ),
          const SizedBox(height: FlowaSpacing.xl),
          TextField(
            controller: _amountController,
            style: moreFieldStyle,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: (_) => setState(() {}),
            decoration: moreInputDecoration(
              label: 'Importe $_from',
              prefixText: '${_symbol(_from)} ',
            ),
          ),
          const SizedBox(height: FlowaSpacing.lg),
          MoreServiceCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Recibirás', style: FlowaType.body(color: FlowaColors.boneMuted)),
                const SizedBox(height: 8),
                Text(
                  '${_symbol(_to)} ${_converted.toStringAsFixed(2)}',
                  style: FlowaType.figureLg(color: FlowaColors.mint),
                ),
                const SizedBox(height: 4),
                Text(
                  'Tipo: 1 $_from = ${(MoreServiceCatalog.currencies.firstWhere((c) => c.code == _to).rate / MoreServiceCatalog.currencies.firstWhere((c) => c.code == _from).rate).toStringAsFixed(4)} $_to',
                  style: FlowaType.bodySm(color: FlowaColors.boneMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CurrencySelector extends StatelessWidget {
  const _CurrencySelector({
    required this.label,
    required this.value,
    required this.onChanged,
    this.exclude,
  });

  final String label;
  final String value;
  final String? exclude;
  final ValueChanged<String> onChanged;

  MoreCurrency get _selected => MoreServiceCatalog.currencies.firstWhere(
        (c) => c.code == value,
        orElse: () => MoreServiceCatalog.currencies.first,
      );

  Future<void> _openPicker(BuildContext context) async {
    final picked = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: FlowaColors.inkHigh,
      showDragHandle: true,
      builder: (context) {
        return _CurrencyPickerSheet(
          selected: value,
          exclude: exclude,
        );
      },
    );
    if (picked != null) {
      onChanged(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currency = _selected;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        MoreSectionLabel(label),
        FlowaPressScale(
          onTap: () => _openPicker(context),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            decoration: BoxDecoration(
              color: FlowaColors.inkHigh,
              borderRadius: FlowaRadii.xlAll,
              border: Border.all(color: FlowaColors.hairlineStrong),
            ),
            child: Row(
              children: [
                Text(currency.flag, style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currency.code,
                        style: FlowaType.titleMd(color: FlowaColors.mint),
                      ),
                      Text(
                        currency.name,
                        style: FlowaType.bodySm(color: FlowaColors.boneMuted),
                      ),
                    ],
                  ),
                ),
                const FlowaLucideIcon(
                  LucideIcons.chevron_down,
                  size: 20,
                  color: FlowaColors.boneMuted,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _CurrencyPickerSheet extends StatelessWidget {
  const _CurrencyPickerSheet({
    required this.selected,
    this.exclude,
  });

  final String selected;
  final String? exclude;

  @override
  Widget build(BuildContext context) {
    final currencies = MoreServiceCatalog.currencies
        .where((c) => c.code != exclude)
        .toList();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Elige divisa', style: FlowaType.titleMd()),
            const SizedBox(height: FlowaSpacing.md),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.05,
              ),
              itemCount: currencies.length,
              itemBuilder: (context, index) {
                final currency = currencies[index];
                final isSelected = currency.code == selected;
                return FlowaPressScale(
                  onTap: () => Navigator.pop(context, currency.code),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? FlowaColors.mintTintedSurface
                          : FlowaColors.ink,
                      borderRadius: FlowaRadii.lgAll,
                      border: Border.all(
                        color: isSelected
                            ? FlowaColors.mint
                            : FlowaColors.hairlineStrong,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          currency.flag,
                          style: const TextStyle(fontSize: 22),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          currency.code,
                          style: FlowaType.titleSm(
                            color: isSelected
                                ? FlowaColors.mint
                                : FlowaColors.bone,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Oficinas y puntos de atención.
class MoreBranchesPage extends StatelessWidget {
  const MoreBranchesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return FlowaScreen(
      title: 'Sucursales',
      child: ListView(
        padding: const EdgeInsets.only(bottom: FlowaSpacing.xl),
        children: [
          const MoreServiceIntro(
            icon: LucideIcons.map_pin,
            title: 'Sucursales',
            description: 'Encuentra oficinas Flowa cerca de ti.',
          ),
          const SizedBox(height: FlowaSpacing.lg),
          for (final branch in MoreServiceCatalog.branches) ...[
            MoreServiceCard(
              padding: const EdgeInsets.all(20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: const BoxDecoration(
                      color: FlowaColors.mintTintedSurface,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const FlowaLucideIcon(
                      LucideIcons.map_pin,
                      size: 24,
                      color: FlowaColors.mint,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(branch.name, style: FlowaType.titleMd()),
                        const SizedBox(height: 6),
                        Text(
                          branch.address,
                          style: FlowaType.body(color: FlowaColors.boneMuted),
                        ),
                        const SizedBox(height: 4),
                        Text(branch.hours, style: FlowaType.bodySm()),
                        if (branch.services != null) ...[
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 6,
                            runSpacing: 6,
                            children: [
                              for (final service in branch.services!)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: FlowaColors.mintTintedSurface,
                                    borderRadius: FlowaRadii.pillAll,
                                  ),
                                  child: Text(
                                    service,
                                    style: FlowaType.bodySm(color: FlowaColors.mint),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                  Text(
                    '${branch.distanceKm.toStringAsFixed(1)} km',
                    style: FlowaType.titleSm(color: FlowaColors.mint),
                  ),
                ],
              ),
            ),
            const SizedBox(height: FlowaSpacing.sm),
          ],
        ],
      ),
    );
  }
}

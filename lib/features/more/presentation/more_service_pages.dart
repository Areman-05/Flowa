import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../../core/utils/flowa_formatters.dart';
import '../../../design_system/components/flowa_actions.dart';
import '../../../design_system/components/flowa_amount_chips.dart';
import '../../../design_system/components/flowa_icon.dart';
import '../../../design_system/components/flowa_primitives.dart';
import '../../../design_system/components/flowa_screen.dart';
import '../../../design_system/tokens/flowa_colors.dart';
import '../../../design_system/tokens/flowa_spacing.dart';
import '../../../design_system/tokens/flowa_typography.dart';
import '../domain/more_service_catalog.dart';
import 'more_payment_helper.dart';
import 'more_qr_scanner_page.dart';
import 'widgets/more_payment_ui.dart';
import 'widgets/more_service_ui.dart';

/// Compra de entradas para cine, conciertos y deporte.
class MoreTicketsPage extends StatefulWidget {
  const MoreTicketsPage({super.key});

  @override
  State<MoreTicketsPage> createState() => _MoreTicketsPageState();
}

class _MoreTicketsPageState extends State<MoreTicketsPage> {
  String _filter = 'Todos';
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = [
      'Todos',
      ...MoreServiceCatalog.tickets.map((e) => e.category).toSet(),
    ];
    final query = _searchController.text;
    final events = MoreServiceCatalog.tickets.where((event) {
      if (_filter != 'Todos' && event.category != _filter) {
        return false;
      }
      return moreMatchesQuery(query, [
        event.title,
        event.venue,
        event.category,
        event.dateLabel,
      ]);
    }).toList();

    return FlowaScreen(
      title: 'Entradas',
      canvasColor: FlowaColors.inkSurface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FlowaEntrance(
            child: MoreContextLine(
              'Cine, conciertos, teatro y deporte en un solo sitio.',
            ),
          ),
          const SizedBox(height: FlowaSpacing.md),
          FlowaEntrance(
            delay: const Duration(milliseconds: 20),
            child: MoreSearchField(
              controller: _searchController,
              hint: 'Artista, recinto o ciudad',
              onChanged: (_) => setState(() {}),
            ),
          ),
          const SizedBox(height: FlowaSpacing.md),
          FlowaEntrance(
            delay: const Duration(milliseconds: 30),
            child: MoreFilterRail(
              options: categories,
              selected: _filter,
              onSelected: (value) => setState(() => _filter = value),
            ),
          ),
          const SizedBox(height: FlowaSpacing.md),
          Expanded(
            child: events.isEmpty
                ? Center(
                    child: Text(
                      'Sin resultados',
                      style: FlowaType.body(color: FlowaColors.boneMuted),
                    ),
                  )
                : ListView.separated(
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
    final parts = event.dateLabel.split('·');
    final datePart = parts.isNotEmpty ? parts.first.trim() : event.dateLabel;
    final timePart = parts.length > 1 ? parts.sublist(1).join('·').trim() : '';

    return MoreServiceCard(
      padding: const EdgeInsets.all(18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 58,
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF9A7EC8).withValues(alpha: 0.16),
              borderRadius: FlowaRadii.lgAll,
            ),
            child: Column(
              children: [
                Text(
                  datePart.split(' ').first,
                  style: FlowaType.titleMd(color: const Color(0xFF9A7EC8)),
                ),
                if (datePart.contains(' '))
                  Text(
                    datePart.split(' ').skip(1).join(' '),
                    style: FlowaType.bodySm(color: FlowaColors.boneMuted),
                  ),
                if (timePart.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(timePart, style: FlowaType.bodySm()),
                ],
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(event.title, style: FlowaType.titleLg()),
                const SizedBox(height: 6),
                Text(
                  event.venue,
                  style: FlowaType.body(color: FlowaColors.boneMuted),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Text(
                      'Desde ${FlowaFormatters.currency(event.priceFrom)}',
                      style: FlowaType.titleMd(color: FlowaColors.mint),
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
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = [
      'Todos',
      ...MoreServiceCatalog.insurance.map((p) => p.category).toSet(),
    ];
    final query = _searchController.text;
    final plans = MoreServiceCatalog.insurance.where((plan) {
      if (_filter != 'Todos' && plan.category != _filter) {
        return false;
      }
      return moreMatchesQuery(query, [
        plan.name,
        plan.summary,
        plan.category,
        ...plan.coverages,
        ...?plan.highlights,
      ]);
    }).toList();

    return FlowaScreen(
      title: 'Seguro',
      canvasColor: FlowaColors.inkSurface,
      child: ListView(
        padding: const EdgeInsets.only(bottom: FlowaSpacing.xl),
        children: [
          const FlowaEntrance(
            child: MoreContextLine(
              'Compara coberturas antes de contratar. Sin permanencia en demo.',
            ),
          ),
          const SizedBox(height: FlowaSpacing.md),
          FlowaEntrance(
            delay: const Duration(milliseconds: 20),
            child: MoreSearchField(
              controller: _searchController,
              hint: 'Plan, cobertura o categoría',
              onChanged: (_) => setState(() {}),
            ),
          ),
          const SizedBox(height: FlowaSpacing.md),
          FlowaEntrance(
            delay: const Duration(milliseconds: 30),
            child: MoreFilterRail(
              options: categories,
              selected: _filter,
              onSelected: (value) => setState(() => _filter = value),
            ),
          ),
          const SizedBox(height: FlowaSpacing.md),
          if (plans.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: FlowaSpacing.lg),
              child: Text(
                'Sin resultados',
                style: FlowaType.body(color: FlowaColors.boneMuted),
              ),
            ),
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
                            child: Text(plan.name, style: FlowaType.titleLg()),
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
      canvasColor: FlowaColors.inkSurface,
      footer: FlowaAcidButton(label: 'Confirmar pago', onPressed: _pay),
      child: ListView(
        padding: const EdgeInsets.only(bottom: FlowaSpacing.xl),
        children: [
          FlowaEntrance(
            child: MoreContextLine(
              'Escanea en comercio o pega el código del ticket.',
            ),
          ),
          const SizedBox(height: FlowaSpacing.lg),
          FlowaEntrance(
            delay: const Duration(milliseconds: 30),
            child: FlowaPressScale(
              onTap: _scan,
              enabled: !_scanning,
              child: MoreFintechCard(
                accent: const Color(0xFF8B7FD4),
                padding: const EdgeInsets.symmetric(vertical: 36),
                child: Column(
                  children: [
                    Container(
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        color: FlowaColors.inkSurface,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF8B7FD4).withValues(alpha: 0.5),
                        ),
                        boxShadow: moreNeonGlow(
                          const Color(0xFF8B7FD4),
                          intensity: 0.18,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: _scanning
                          ? const SizedBox(
                              width: 28,
                              height: 28,
                              child: CircularProgressIndicator(
                                color: Color(0xFF8B7FD4),
                                strokeWidth: 2.5,
                              ),
                            )
                          : const FlowaLucideIcon(
                              LucideIcons.camera,
                              size: 36,
                              color: Color(0xFF8B7FD4),
                            ),
                    ),
                  const SizedBox(height: 16),
                  Text('Toca para escanear', style: FlowaType.titleSm()),
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
          const SizedBox(height: FlowaSpacing.lg),
          FlowaEntrance(
            delay: const Duration(milliseconds: 70),
            child: MoreFintechCard(
              accent: const Color(0xFF8B7FD4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _codeController,
                    style: moreFieldStyle,
                    decoration: moreInputDecoration(
                      label: 'Código QR / referencia',
                      hint: 'QR-92837465',
                      prefixIcon: Icons.qr_code_2_rounded,
                    ).copyWith(fillColor: FlowaColors.inkSurface),
                  ),
                  const SizedBox(height: FlowaSpacing.md),
                  TextField(
                    controller: _amountController,
                    style: FlowaType.figureMd(color: const Color(0xFF8B7FD4)),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+\.?\d{0,2}'),
                      ),
                    ],
                    decoration: moreInputDecoration(
                      label: 'Importe',
                      prefixText: '€ ',
                    ).copyWith(
                      fillColor: FlowaColors.inkSurface,
                      prefixStyle:
                          FlowaType.figureMd(color: const Color(0xFF8B7FD4)),
                    ),
                  ),
                ],
              ),
            ),
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
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    _searchController.dispose();
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
    final query = _searchController.text;
    final orgs = MoreServiceCatalog.donations.where((org) {
      if (_filter != 'Todos' && org.category != _filter) {
        return false;
      }
      return moreMatchesQuery(query, [
        org.name,
        org.summary,
        org.category ?? '',
      ]);
    }).toList();

    return FlowaScreen(
      title: 'Donaciones',
      canvasColor: FlowaColors.inkSurface,
      footer: FlowaAcidButton(label: 'Donar ahora', onPressed: _donate),
      child: ListView(
        padding: const EdgeInsets.only(bottom: FlowaSpacing.xl),
        children: [
          const FlowaEntrance(
            child: MoreContextLine(
              'Elige una causa y el importe. 100% va a la ONG en demo.',
            ),
          ),
          const SizedBox(height: FlowaSpacing.md),
          FlowaEntrance(
            delay: const Duration(milliseconds: 20),
            child: MoreSearchField(
              controller: _searchController,
              hint: 'Organización o causa',
              onChanged: (_) => setState(() {}),
            ),
          ),
          const SizedBox(height: FlowaSpacing.md),
          FlowaEntrance(
            delay: const Duration(milliseconds: 30),
            child: MoreFilterRail(
              options: categories,
              selected: _filter,
              onSelected: (value) => setState(() => _filter = value),
            ),
          ),
          const SizedBox(height: FlowaSpacing.md),
          if (orgs.isEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: FlowaSpacing.md),
              child: Text(
                'Sin resultados',
                style: FlowaType.body(color: FlowaColors.boneMuted),
              ),
            ),
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
                          Text(org.name, style: FlowaType.titleLg()),
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
          MoreAmountPanel(
            controller: _amountController,
            chips: const [5, 10, 25, 50, 100, 250],
            selectedChip: _chip,
            onChipSelected: (value) {
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
      canvasColor: FlowaColors.inkSurface,
      footer: FlowaAcidButton(label: 'Convertir', onPressed: _exchange),
      child: ListView(
        padding: const EdgeInsets.only(bottom: FlowaSpacing.xl),
        children: [
          const FlowaEntrance(
            child: MoreContextLine(
              'Tipo orientativo. Sin comisión ni spread oculto en demo.',
            ),
          ),
          const SizedBox(height: FlowaSpacing.lg),
          FlowaEntrance(
            delay: const Duration(milliseconds: 30),
            child: _CurrencySelector(
              label: 'Desde',
              value: _from,
              exclude: _to,
              onChanged: (value) => setState(() => _from = value),
            ),
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
          MoreExchangeCalculator(
            fromCode: _from,
            toCode: _to,
            fromSymbol: _symbol(_from),
            toSymbol: _symbol(_to),
            converted: _converted,
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
class MoreBranchesPage extends StatefulWidget {
  const MoreBranchesPage({super.key});

  @override
  State<MoreBranchesPage> createState() => _MoreBranchesPageState();
}

class _MoreBranchesPageState extends State<MoreBranchesPage> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final query = _searchController.text;
    final branches = MoreServiceCatalog.branches.where((branch) {
      return moreMatchesQuery(query, [
        branch.name,
        branch.address,
        branch.hours,
        ...?branch.services,
      ]);
    }).toList();

    return FlowaScreen(
      title: 'Sucursales',
      child: ListView(
        padding: const EdgeInsets.only(bottom: FlowaSpacing.xl),
        children: [
          const FlowaEntrance(
            child: MoreContextLine(
              'Encuentra oficinas Flowa cerca de ti.',
            ),
          ),
          const SizedBox(height: FlowaSpacing.md),
          FlowaEntrance(
            delay: const Duration(milliseconds: 20),
            child: MoreSearchField(
              controller: _searchController,
              hint: 'Ciudad, dirección o servicio',
              onChanged: (_) => setState(() {}),
            ),
          ),
          const SizedBox(height: FlowaSpacing.lg),
          if (branches.isEmpty)
            Text(
              'Sin resultados',
              style: FlowaType.body(color: FlowaColors.boneMuted),
            ),
          for (final branch in branches) ...[
            MoreServiceCard(
              padding: const EdgeInsets.all(20),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8A838).withValues(alpha: 0.14),
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const FlowaLucideIcon(
                      LucideIcons.map_pin,
                      size: 24,
                      color: Color(0xFFE8A838),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(branch.name, style: FlowaType.titleLg()),
                        const SizedBox(height: 6),
                        Text(
                          branch.address,
                          style: FlowaType.body(color: FlowaColors.boneMuted),
                        ),
                        const SizedBox(height: 4),
                        Text(branch.hours, style: FlowaType.body()),
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
                                    color: const Color(0xFFE8A838).withValues(alpha: 0.12),
                                    borderRadius: FlowaRadii.pillAll,
                                  ),
                                  child: Text(
                                    service,
                                    style: FlowaType.body(
                                      color: const Color(0xFFE8A838),
                                    ),
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
                    style: FlowaType.titleMd(color: Color(0xFFE8A838)),
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

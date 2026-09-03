import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/utils/flowa_formatters.dart';
import '../../../design_system/components/flowa_actions.dart';
import '../../../design_system/components/flowa_primitives.dart';
import '../../../design_system/components/flowa_screen.dart';
import '../../../design_system/tokens/flowa_colors.dart';
import '../../../design_system/tokens/flowa_spacing.dart';
import '../../../design_system/tokens/flowa_typography.dart';
import '../domain/more_service_catalog.dart';
import 'more_payment_helper.dart';
import 'widgets/more_payment_ui.dart';
import 'widgets/more_service_ui.dart';

/// Pago de facturas recurrentes: móvil, suministros, internet, TV.
///
/// Cada servicio usa un layout distinto — no el mismo wireframe con pasos.
class MoreBillPayPage extends StatefulWidget {
  const MoreBillPayPage({required this.service, super.key});

  final MoreBillService service;

  @override
  State<MoreBillPayPage> createState() => _MoreBillPayPageState();
}

class _MoreBillPayPageState extends State<MoreBillPayPage> {
  MoreProvider? _provider;
  String? _utilityType;
  final _referenceController = TextEditingController();
  final _amountController = TextEditingController();
  double? _chip;

  @override
  void dispose() {
    _referenceController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  double get _amount => double.tryParse(_amountController.text) ?? 0;

  List<double> get _chips => switch (widget.service.title) {
        'Móvil' => const [10, 20, 30, 50],
        'Suministros' => const [40, 80, 120, 200],
        'TV' => const [8, 15, 25, 40],
        _ => const [15, 30, 50, 80],
      };

  Future<void> _pay() async {
    final provider = _provider;
    if (provider == null ||
        _referenceController.text.trim().isEmpty ||
        _amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Elige proveedor, referencia e importe.'),
          behavior: SnackBarBehavior.fixed,
        ),
      );
      return;
    }

    final utility = _utilityType == null ? '' : ' · $_utilityType';
    await completeMoreServicePayment(
      context: context,
      merchant: '${provider.name}$utility · ${_referenceController.text.trim()}',
      amount: _amount,
      category: widget.service.category,
      successTitle: '${widget.service.title} pagado',
      successSubtitle:
          '${provider.name} · ${FlowaFormatters.currency(_amount)}',
      detailLines: _utilityType == null ? const [] : ['Tipo: $_utilityType'],
    );
  }

  @override
  Widget build(BuildContext context) {
    final service = widget.service;
    final theme = billPayTheme(service);

    return FlowaScreen(
      title: service.title,
      canvasColor: FlowaColors.inkSurface,
      footer: FlowaAcidButton(
        label: service.title == 'Móvil' ? 'Recargar ahora' : 'Pagar ahora',
        onPressed: _pay,
      ),
      child: ListView(
        padding: const EdgeInsets.only(bottom: FlowaSpacing.xl),
        children: switch (service.title) {
          'Móvil' => _mobileLayout(service, theme),
          'Suministros' => _utilitiesLayout(service, theme),
          'Internet' => _internetLayout(service, theme),
          'TV' => _tvLayout(service, theme),
          _ => _defaultLayout(service, theme),
        },
      ),
    );
  }

  /// Móvil: teléfono grande primero, operador en pills, importe con chips.
  List<Widget> _mobileLayout(
    MoreBillService service,
    ({Color accent, IconData icon, List<String> hints}) theme,
  ) {
    return [
      FlowaEntrance(
        child: MoreContextLine(service.description),
      ),
      const SizedBox(height: FlowaSpacing.lg),
      FlowaEntrance(
        delay: const Duration(milliseconds: 40),
        child: TextField(
          controller: _referenceController,
          style: FlowaType.figureMd(color: theme.accent),
          keyboardType: TextInputType.phone,
          decoration: InputDecoration(
            labelText: 'Número de móvil',
            hintText: '600 000 000',
            prefixIcon: Icon(Icons.phone_android_rounded, color: theme.accent),
            filled: true,
            fillColor: FlowaColors.inkHigh,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 22,
            ),
            labelStyle: FlowaType.bodySm(color: FlowaColors.boneMuted),
            floatingLabelStyle: FlowaType.titleSm(color: theme.accent),
            border: OutlineInputBorder(
              borderRadius: FlowaRadii.xxlAll,
              borderSide: const BorderSide(color: FlowaColors.hairlineStrong),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: FlowaRadii.xxlAll,
              borderSide: const BorderSide(color: FlowaColors.hairlineStrong),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: FlowaRadii.xxlAll,
              borderSide: BorderSide(color: theme.accent),
            ),
          ),
        ),
      ),
      const SizedBox(height: FlowaSpacing.xl),
      FlowaEntrance(
        delay: const Duration(milliseconds: 70),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const MoreFieldLabel('Operador'),
            MoreProviderRail(
              providers: service.providers,
              selectedId: _provider?.id,
              onSelected: (p) => setState(() => _provider = p),
            ),
          ],
        ),
      ),
      const SizedBox(height: FlowaSpacing.xl),
      FlowaEntrance(
        delay: const Duration(milliseconds: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const MoreFieldLabel('Importe', subtitle: 'Sin comisión'),
            MoreAmountPanel(
              controller: _amountController,
              chips: _chips,
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
      ),
    ];
  }

  /// Suministros: tipo en cards grandes, proveedor en grid 2×2.
  List<Widget> _utilitiesLayout(
    MoreBillService service,
    ({Color accent, IconData icon, List<String> hints}) theme,
  ) {
    return [
      FlowaEntrance(
        child: MoreContextLine(service.description),
      ),
      const SizedBox(height: FlowaSpacing.lg),
      FlowaEntrance(
        delay: const Duration(milliseconds: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const MoreFieldLabel('Tipo de suministro'),
            MoreUtilityTypePicker(
              selected: _utilityType,
              accent: theme.accent,
              onSelected: (type) => setState(() => _utilityType = type),
            ),
          ],
        ),
      ),
      const SizedBox(height: FlowaSpacing.xl),
      FlowaEntrance(
        delay: const Duration(milliseconds: 70),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const MoreFieldLabel('Compañía'),
            MoreProviderGrid(
              providers: service.providers,
              selectedId: _provider?.id,
              onSelected: (p) => setState(() => _provider = p),
            ),
          ],
        ),
      ),
      const SizedBox(height: FlowaSpacing.xl),
      FlowaEntrance(
        delay: const Duration(milliseconds: 100),
        child: TextField(
          controller: _referenceController,
          style: moreFieldStyle,
          decoration: moreInputDecoration(
            label: service.referenceLabel,
            hint: service.referenceHint,
            prefixIcon: Icons.tag_rounded,
          ),
        ),
      ),
      const SizedBox(height: FlowaSpacing.lg),
      FlowaEntrance(
        delay: const Duration(milliseconds: 130),
        child: MoreAmountPanel(
          controller: _amountController,
          chips: _chips,
          selectedChip: _chip,
          onChipSelected: (value) {
            setState(() {
              _chip = value;
              _amountController.text = value.toStringAsFixed(2);
            });
          },
        ),
      ),
    ];
  }

  /// Internet: lista vertical de operadores + referencia e importe juntos.
  List<Widget> _internetLayout(
    MoreBillService service,
    ({Color accent, IconData icon, List<String> hints}) theme,
  ) {
    return [
      FlowaEntrance(
        child: MoreContextLine(service.description),
      ),
      const SizedBox(height: FlowaSpacing.lg),
      FlowaEntrance(
        delay: const Duration(milliseconds: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const MoreFieldLabel('Tu operador'),
            MoreProviderList(
              providers: service.providers,
              selectedId: _provider?.id,
              onSelected: (p) => setState(() => _provider = p),
              subtitleFor: (_) => 'Fibra · móvil · fijo',
            ),
          ],
        ),
      ),
      const SizedBox(height: FlowaSpacing.xl),
      FlowaEntrance(
        delay: const Duration(milliseconds: 80),
        child: MoreFintechCard(
          accent: theme.accent,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _referenceController,
                style: moreFieldStyle,
                decoration: moreInputDecoration(
                  label: service.referenceLabel,
                  hint: service.referenceHint,
                  prefixIcon: Icons.tag_rounded,
                ).copyWith(
                  fillColor: FlowaColors.inkSurface,
                ),
              ),
              const SizedBox(height: FlowaSpacing.md),
              MoreAmountPanel(
                controller: _amountController,
                chips: _chips,
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
        ),
      ),
    ];
  }

  /// TV: importe primero (cuota mensual), operador en lista, contrato al final.
  List<Widget> _tvLayout(
    MoreBillService service,
    ({Color accent, IconData icon, List<String> hints}) theme,
  ) {
    return [
      FlowaEntrance(
        child: MoreContextLine('Renueva o paga tu paquete de TV al mes.'),
      ),
      const SizedBox(height: FlowaSpacing.lg),
      FlowaEntrance(
        delay: const Duration(milliseconds: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const MoreFieldLabel('Cuota mensual'),
            MoreAmountPanel(
              controller: _amountController,
              chips: _chips,
              selectedChip: _chip,
              label: 'Importe',
              onChipSelected: (value) {
                setState(() {
                  _chip = value;
                  _amountController.text = value.toStringAsFixed(2);
                });
              },
            ),
          ],
        ),
      ),
      const SizedBox(height: FlowaSpacing.xl),
      FlowaEntrance(
        delay: const Duration(milliseconds: 70),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const MoreFieldLabel('Plataforma'),
            MoreProviderList(
              providers: service.providers,
              selectedId: _provider?.id,
              onSelected: (p) => setState(() => _provider = p),
              subtitleFor: (_) => 'Paquete básico · premium',
            ),
          ],
        ),
      ),
      const SizedBox(height: FlowaSpacing.lg),
      FlowaEntrance(
        delay: const Duration(milliseconds: 100),
        child: TextField(
          controller: _referenceController,
          style: moreFieldStyle,
          decoration: moreInputDecoration(
            label: service.referenceLabel,
            hint: service.referenceHint,
            prefixIcon: Icons.tv_rounded,
          ),
        ),
      ),
    ];
  }

  List<Widget> _defaultLayout(
    MoreBillService service,
    ({Color accent, IconData icon, List<String> hints}) theme,
  ) {
    return [
      FlowaEntrance(child: MoreContextLine(service.description)),
      const SizedBox(height: FlowaSpacing.lg),
      FlowaEntrance(
        child: MoreProviderRail(
          providers: service.providers,
          selectedId: _provider?.id,
          onSelected: (p) => setState(() => _provider = p),
        ),
      ),
      const SizedBox(height: FlowaSpacing.lg),
      FlowaEntrance(
        delay: const Duration(milliseconds: 40),
        child: TextField(
          controller: _referenceController,
          style: moreFieldStyle,
          decoration: moreInputDecoration(
            label: service.referenceLabel,
            hint: service.referenceHint,
          ),
        ),
      ),
      const SizedBox(height: FlowaSpacing.lg),
      FlowaEntrance(
        delay: const Duration(milliseconds: 70),
        child: MoreAmountPanel(
          controller: _amountController,
          chips: _chips,
          selectedChip: _chip,
          onChipSelected: (value) {
            setState(() {
              _chip = value;
              _amountController.text = value.toStringAsFixed(2);
            });
          },
        ),
      ),
    ];
  }
}

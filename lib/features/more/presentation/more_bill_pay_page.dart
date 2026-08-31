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
import 'widgets/more_service_ui.dart';

IconData iconForBillService(MoreBillService service) {
  return switch (service.title) {
    'Móvil' => LucideIcons.smartphone,
    'Suministros' => LucideIcons.house,
    'Internet' => LucideIcons.globe,
    'TV' => LucideIcons.tv,
    _ => LucideIcons.receipt,
  };
}

/// Pago de facturas recurrentes: móvil, suministros, internet, TV.
class MoreBillPayPage extends StatefulWidget {
  const MoreBillPayPage({required this.service, super.key});

  final MoreBillService service;

  @override
  State<MoreBillPayPage> createState() => _MoreBillPayPageState();
}

class _MoreBillPayPageState extends State<MoreBillPayPage> {
  MoreProvider? _provider;
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

    await completeMoreServicePayment(
      context: context,
      merchant: '${provider.name} · ${_referenceController.text.trim()}',
      amount: _amount,
      category: widget.service.category,
      successTitle: '${widget.service.title} pagado',
      successSubtitle:
          '${provider.name} · ${FlowaFormatters.currency(_amount)}',
    );
  }

  @override
  Widget build(BuildContext context) {
    final service = widget.service;

    return FlowaScreen(
      title: service.title,
      footer: FlowaAcidButton(label: 'Pagar ahora', onPressed: _pay),
      child: ListView(
        padding: const EdgeInsets.only(bottom: FlowaSpacing.xl),
        children: [
          MoreServiceIntro(
            icon: iconForBillService(service),
            title: service.title,
            description: service.description,
          ),
          const SizedBox(height: FlowaSpacing.xl),
          const MoreSectionLabel('Proveedor'),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: FlowaSpacing.sm,
            crossAxisSpacing: FlowaSpacing.sm,
            childAspectRatio: 2.4,
            children: [
              for (final provider in service.providers)
                _ProviderTile(
                  provider: provider,
                  selected: _provider?.id == provider.id,
                  onTap: () => setState(() => _provider = provider),
                ),
            ],
          ),
          const SizedBox(height: FlowaSpacing.xl),
          TextField(
            controller: _referenceController,
            style: moreFieldStyle,
            decoration: moreInputDecoration(
              label: service.referenceLabel,
              hint: service.referenceHint,
            ),
          ),
          const SizedBox(height: FlowaSpacing.xl),
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
            values: const [15, 30, 50, 80],
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

class _ProviderTile extends StatelessWidget {
  const _ProviderTile({
    required this.provider,
    required this.selected,
    required this.onTap,
  });

  final MoreProvider provider;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FlowaPressScale(
      onTap: onTap,
      child: MoreServiceCard(
        selected: selected,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: provider.tone.withValues(alpha: 0.18),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                providerInitial(provider),
                style: FlowaType.titleSm(color: provider.tone),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                provider.name,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: FlowaType.titleSm(
                  color: selected ? FlowaColors.mint : FlowaColors.bone,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/utils/flowa_formatters.dart';
import '../../../core/utils/flowa_haptics.dart';
import '../../../core/utils/flowa_services.dart';
import '../../../design_system/components/flowa_actions.dart';
import '../../../design_system/components/flowa_money_text.dart';
import '../../../design_system/components/flowa_primitives.dart';
import '../../../design_system/tokens/flowa_colors.dart';
import '../../../design_system/tokens/flowa_spacing.dart';
import '../../../design_system/tokens/flowa_typography.dart';
import '../../../domain/entities/freelance_entities.dart';

/// Tax vault control.
///
/// Shows what is already locked away, what the quarter is likely to cost, and
/// lets the reserve rate be retuned in place.
Future<void> showTaxVaultSheet({
  required BuildContext context,
  required TaxVault vault,
  required FreelanceOverview overview,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => _TaxVaultSheet(vault: vault, overview: overview),
  );
}

class _TaxVaultSheet extends StatefulWidget {
  const _TaxVaultSheet({required this.vault, required this.overview});

  final TaxVault vault;
  final FreelanceOverview overview;

  @override
  State<_TaxVaultSheet> createState() => _TaxVaultSheetState();
}

class _TaxVaultSheetState extends State<_TaxVaultSheet> {
  late double _rate = widget.vault.rate;
  bool _saving = false;

  /// Rough liability: the last three months of income at the current rate.
  double get _estimatedDue {
    final recent = widget.overview.months.reversed.take(3);
    final earned = recent.fold<double>(0, (sum, m) => sum + m.earned);
    return earned * _rate;
  }

  double get _coverage {
    final due = _estimatedDue;
    if (due <= 0) {
      return 1;
    }
    return (widget.vault.reserved / due).clamp(0, 1);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    await FlowaServices.freelanceRepository.setReserveRate(_rate);
    await FlowaHaptics.success();
    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final deadline = widget.vault.nextDueAt;
    final coverage = _coverage;

    return Container(
      decoration: const BoxDecoration(
        color: FlowaColors.inkRaised,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        border: Border(
          top: BorderSide(color: FlowaColors.hairlineStrong),
        ),
      ),
      padding: EdgeInsets.fromLTRB(
        FlowaSpacing.gutter,
        FlowaSpacing.sm,
        FlowaSpacing.gutter,
        MediaQuery.of(context).viewInsets.bottom + FlowaSpacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 3,
              margin: const EdgeInsets.only(bottom: FlowaSpacing.lg),
              decoration: BoxDecoration(
                color: FlowaColors.hairlineStrong,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const FlowaMicroLabel('Bote de impuestos', dot: true),
          const SizedBox(height: FlowaSpacing.sm),
          FlowaFigure(
            amount: widget.vault.reserved,
            size: FlowaFigureSize.lg,
            color: FlowaColors.acid,
          ),
          const SizedBox(height: FlowaSpacing.xs),
          Text(
            deadline == null
                ? widget.vault.periodLabel
                : '${widget.vault.periodLabel} · vence el '
                    '${DateFormat('d MMMM', 'es_ES').format(deadline)}',
            style: FlowaType.bodySm(),
          ),
          const SizedBox(height: FlowaSpacing.xl),
          const FlowaRule(),
          const SizedBox(height: FlowaSpacing.md),
          Row(
            children: [
              const FlowaMicroLabel('Estimado a pagar'),
              const Spacer(),
              Text(
                FlowaFormatters.compact(_estimatedDue),
                style: FlowaType.amountMd(),
              ),
            ],
          ),
          const SizedBox(height: FlowaSpacing.sm),
          _CoverageBar(fraction: coverage),
          const SizedBox(height: FlowaSpacing.xs),
          Text(
            coverage >= 1
                ? 'Cubierto. Puedes gastar el resto tranquilo.'
                : 'Cubres el ${(coverage * 100).round()} % de lo que vas a '
                    'deber este trimestre.',
            style: FlowaType.bodySm(
              color: coverage >= 1 ? FlowaColors.acid : FlowaColors.warning,
            ),
          ),
          const SizedBox(height: FlowaSpacing.xl),
          const FlowaRule(),
          const SizedBox(height: FlowaSpacing.md),
          Row(
            children: [
              const FlowaMicroLabel('De cada cobro se aparta'),
              const Spacer(),
              Text(
                '${(_rate * 100).round()} %',
                style: FlowaType.amountMd(color: FlowaColors.acid),
              ),
            ],
          ),
          SliderTheme(
            data: const SliderThemeData(
              trackHeight: 2,
              activeTrackColor: FlowaColors.acid,
              inactiveTrackColor: FlowaColors.hairline,
              thumbColor: FlowaColors.acid,
              overlayColor: FlowaColors.acidVeil,
              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 8),
              overlayShape: RoundSliderOverlayShape(overlayRadius: 18),
            ),
            child: Slider(
              value: _rate,
              max: 0.45,
              divisions: 9,
              onChanged: (value) {
                FlowaHaptics.selection();
                setState(() => _rate = value);
              },
            ),
          ),
          const SizedBox(height: FlowaSpacing.md),
          FlowaAcidButton(
            label: 'Guardar',
            loading: _saving,
            onPressed: _save,
          ),
        ],
      ),
    );
  }
}

class _CoverageBar extends StatelessWidget {
  const _CoverageBar({required this.fraction});

  final double fraction;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 4,
      child: Stack(
        children: [
          const Positioned.fill(
            child: ColoredBox(color: FlowaColors.inkPressed),
          ),
          FractionallySizedBox(
            widthFactor: fraction.clamp(0, 1),
            child: ColoredBox(
              color: fraction >= 1 ? FlowaColors.acid : FlowaColors.warning,
            ),
          ),
        ],
      ),
    );
  }
}

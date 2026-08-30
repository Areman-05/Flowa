import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/utils/flowa_formatters.dart';
import '../../../core/utils/flowa_haptics.dart';
import '../../../core/utils/flowa_services.dart';
import '../../../design_system/components/flowa_actions.dart';
import '../../../design_system/components/flowa_glass.dart';
import '../../../design_system/components/flowa_icon.dart';
import '../../../design_system/tokens/flowa_colors.dart';
import '../../../design_system/tokens/flowa_spacing.dart';
import '../../../design_system/tokens/flowa_typography.dart';
import '../../../domain/entities/freelance_entities.dart';

/// Tax vault — reserved money for Hacienda.
Future<void> showTaxVaultSheet({
  required BuildContext context,
  required TaxVault vault,
  required FreelanceOverview overview,
}) {
  return showFlowaGlassSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => _TaxVaultBody(vault: vault, overview: overview),
  );
}

class _TaxVaultBody extends StatefulWidget {
  const _TaxVaultBody({required this.vault, required this.overview});

  final TaxVault vault;
  final FreelanceOverview overview;

  @override
  State<_TaxVaultBody> createState() => _TaxVaultBodyState();
}

class _TaxVaultBodyState extends State<_TaxVaultBody> {
  late double _rate = widget.vault.rate;
  bool _saving = false;

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
    return (widget.vault.reserved / due).clamp(0.0, 1.0);
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
    final covered = coverage >= 1;
    final bottom = MediaQuery.paddingOf(context).bottom;

    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.78,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: FlowaSpacing.md),
              decoration: BoxDecoration(
                color: FlowaColors.border,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
          Text('Bote impuestos', style: FlowaType.titleLg()),
          const SizedBox(height: 4),
          Text(
            deadline == null
                ? widget.vault.periodLabel
                : '${widget.vault.periodLabel} · vence '
                    '${DateFormat('d MMM', 'es_ES').format(deadline)}',
            style: FlowaType.bodySm(),
          ),
          const SizedBox(height: FlowaSpacing.xl),
          Expanded(
            child: ListView(
              padding: EdgeInsets.only(bottom: bottom + 8),
              children: [
                Container(
                  padding: const EdgeInsets.all(FlowaSpacing.lg),
                  decoration: const BoxDecoration(
                    color: FlowaColors.ink,
                    borderRadius: FlowaRadii.xxlAll,
                    border: Border.fromBorderSide(
                      BorderSide(color: Color(0xFF3A3A40)),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: const BoxDecoration(
                              color: FlowaColors.mint,
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: const FlowaIcon(
                              FlowaGlyph.vault,
                              size: 22,
                              color: FlowaColors.mintInk,
                            ),
                          ),
                          const SizedBox(width: FlowaSpacing.sm),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Reservado', style: FlowaType.micro()),
                                const SizedBox(height: 2),
                                Text(
                                  'Para Hacienda',
                                  style: FlowaType.titleSm(),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: FlowaSpacing.lg),
                      Text(
                        FlowaFormatters.currency(widget.vault.reserved),
                        style: FlowaType.figureMd(),
                      ),
                      const SizedBox(height: FlowaSpacing.md),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(99),
                        child: LinearProgressIndicator(
                          value: coverage,
                          minHeight: 8,
                          backgroundColor: FlowaColors.inkHigh,
                          color: covered
                              ? FlowaColors.mint
                              : FlowaColors.warning,
                        ),
                      ),
                      const SizedBox(height: FlowaSpacing.sm),
                      Text(
                        covered
                            ? 'Cubierto al 100 %. El trimestre va bien.'
                            : 'Cubres el ${(coverage * 100).round()} % '
                                'del estimado trimestral.',
                        style: FlowaType.bodySm(
                          color: covered
                              ? FlowaColors.mint
                              : FlowaColors.warning,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: FlowaSpacing.md),
                Row(
                  children: [
                    Expanded(
                      child: _StatTile(
                        label: 'Estimado a pagar',
                        value: FlowaFormatters.currency(_estimatedDue),
                      ),
                    ),
                    const SizedBox(width: FlowaSpacing.sm),
                    Expanded(
                      child: _StatTile(
                        label: 'Reserva actual',
                        value: '${(_rate * 100).round()} %',
                        accent: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: FlowaSpacing.xl),
                Text('De cada cobro se aparta', style: FlowaType.titleSm()),
                const SizedBox(height: FlowaSpacing.sm),
                Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  decoration: const BoxDecoration(
                    color: FlowaColors.inkHigh,
                    borderRadius: FlowaRadii.xxlAll,
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Text('Porcentaje', style: FlowaType.bodySm()),
                          const Spacer(),
                          Text(
                            '${(_rate * 100).round()} %',
                            style: FlowaType.titleMd(color: FlowaColors.mint),
                          ),
                        ],
                      ),
                      SliderTheme(
                        data: SliderThemeData(
                          trackHeight: 4,
                          activeTrackColor: FlowaColors.mint,
                          inactiveTrackColor: FlowaColors.inkPressed,
                          thumbColor: FlowaColors.mint,
                          overlayColor: FlowaColors.mintVeil,
                          thumbShape: const RoundSliderThumbShape(
                            enabledThumbRadius: 10,
                          ),
                          overlayShape: const RoundSliderOverlayShape(
                            overlayRadius: 20,
                          ),
                        ),
                        child: Slider(
                          value: _rate,
                          min: 0.05,
                          max: 0.45,
                          divisions: 8,
                          onChanged: (value) {
                            FlowaHaptics.selection();
                            setState(() => _rate = value);
                          },
                        ),
                      ),
                      Text(
                        'Al cobrar una factura, este % va al bote '
                        'automáticamente.',
                        style: FlowaType.bodySm(),
                      ),
                      const SizedBox(height: 4),
                    ],
                  ),
                ),
                const SizedBox(height: FlowaSpacing.xl),
                FlowaAcidButton(
                  label: 'Guardar reserva',
                  loading: _saving,
                  onPressed: _save,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({
    required this.label,
    required this.value,
    this.accent = false,
  });

  final String label;
  final String value;
  final bool accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(FlowaSpacing.md),
      decoration: const BoxDecoration(
        color: FlowaColors.inkHigh,
        borderRadius: FlowaRadii.xlAll,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: FlowaType.micro()),
          const SizedBox(height: 6),
          Text(
            value,
            style: FlowaType.titleMd(
              color: accent ? FlowaColors.mint : FlowaColors.bone,
            ),
          ),
        ],
      ),
    );
  }
}

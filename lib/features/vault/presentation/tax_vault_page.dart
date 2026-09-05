import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/utils/flowa_formatters.dart';
import '../../../core/utils/flowa_haptics.dart';
import '../../../core/utils/flowa_services.dart';
import '../../../design_system/components/flowa_actions.dart';
import '../../../design_system/components/flowa_icon.dart';
import '../../../design_system/components/flowa_primitives.dart';
import '../../../design_system/components/flowa_screen.dart';
import '../../../design_system/tokens/flowa_colors.dart';
import '../../../design_system/tokens/flowa_motion_tokens.dart';
import '../../../design_system/tokens/flowa_spacing.dart';
import '../../../design_system/tokens/flowa_typography.dart';
import '../../../domain/entities/freelance_entities.dart';
import '../../../shared/widgets/flowa_states.dart';

/// Full-screen tax vault — same quiet hierarchy as Home / Análisis.
class TaxVaultPage extends StatefulWidget {
  const TaxVaultPage({super.key});

  @override
  State<TaxVaultPage> createState() => _TaxVaultPageState();
}

class _TaxVaultPageState extends State<TaxVaultPage> {
  TaxVault? _vault;
  FreelanceOverview _overview = FreelanceOverview.empty;
  double _rate = 0.25;
  bool _loading = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final now = DateTime.now();
      final vault = await FlowaServices.freelanceRepository.getVault();
      final invoices = await FlowaServices.freelanceRepository.getInvoices();
      final commitments =
          await FlowaServices.freelanceRepository.getCommitments();
      final account = await FlowaServices.accountRepository.getPrimaryAccount();
      final transactions = await FlowaServices.transactionRepository.getAll();
      final overview = FreelanceOverview.compute(
        account: account,
        transactions: transactions,
        vault: vault,
        invoices: invoices,
        commitments: commitments,
        now: now,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _vault = vault;
        _overview = overview;
        _rate = vault.rate;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loading = false;
        _error = error.toString();
      });
    }
  }

  double get _estimatedDue {
    final recent = _overview.months.reversed.take(3);
    final earned = recent.fold<double>(0, (sum, m) => sum + m.earned);
    return earned * _rate;
  }

  double get _coverage {
    final vault = _vault;
    final due = _estimatedDue;
    if (vault == null || due <= 0) {
      return 1;
    }
    return (vault.reserved / due).clamp(0.0, 1.0);
  }

  Future<void> _save() async {
    setState(() => _saving = true);
    await FlowaServices.freelanceRepository.setReserveRate(_rate);
    await FlowaHaptics.success();
    if (!mounted) {
      return;
    }
    setState(() => _saving = false);
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final vault = _vault;

    return FlowaScreen(
      title: 'Bote impuestos',
      footer: vault == null
          ? null
          : FlowaAcidButton(
              label: 'Guardar reserva',
              loading: _saving,
              onPressed: _save,
            ),
      child: _loading
          ? const Center(
              child: CircularProgressIndicator(color: FlowaColors.mint),
            )
          : _error != null
              ? FlowaErrorState(
                  message: _error!,
                  onRetry: _load,
                )
              : vault == null
                  ? const FlowaEmptyState(
                      title: 'Sin bote',
                      message: 'No hay datos de reserva todavía.',
                    )
                  : ListView(
                      children: [
                        FlowaEntrance(child: _HeroCard(vault: vault)),
                        const SizedBox(height: FlowaSpacing.md),
                        FlowaEntrance(
                          delay: FlowaMotion.stagger(1),
                          child: _CoverageCard(
                            coverage: _coverage,
                            estimatedDue: _estimatedDue,
                          ),
                        ),
                        const SizedBox(height: FlowaSpacing.md),
                        FlowaEntrance(
                          delay: FlowaMotion.stagger(2),
                          child: Row(
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
                                  label: 'Tu reserva',
                                  value: '${(_rate * 100).round()} %',
                                  accent: true,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: FlowaSpacing.xl),
                        FlowaEntrance(
                          delay: FlowaMotion.stagger(3),
                          child: Text(
                            'De cada cobro se aparta',
                            style: FlowaType.titleSm(),
                          ),
                        ),
                        const SizedBox(height: FlowaSpacing.sm),
                        FlowaEntrance(
                          delay: FlowaMotion.stagger(3),
                          child: _RateCard(
                            rate: _rate,
                            onChanged: (value) {
                              FlowaHaptics.selection();
                              setState(() => _rate = value);
                            },
                          ),
                        ),
                        const SizedBox(height: FlowaSpacing.md),
                        FlowaEntrance(
                          delay: FlowaMotion.stagger(4),
                          child: const _TipCard(),
                        ),
                        const SizedBox(height: FlowaSpacing.lg),
                      ],
                    ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.vault});

  final TaxVault vault;

  @override
  Widget build(BuildContext context) {
    final deadline = vault.nextDueAt;
    final period = deadline == null
        ? vault.periodLabel
        : '${vault.periodLabel} · vence '
            '${DateFormat('d MMM', 'es_ES').format(deadline)}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(FlowaSpacing.lg),
      decoration: const BoxDecoration(
        gradient: FlowaColors.cardFace,
        borderRadius: FlowaRadii.xxlAll,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: FlowaColors.mintInk.withValues(alpha: 0.14),
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
                    Text(
                      'Reservado',
                      style: FlowaType.micro(color: FlowaColors.mintInk),
                    ),
                    Text(
                      'Para Hacienda',
                      style: FlowaType.titleSm(color: FlowaColors.mintInk),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: FlowaSpacing.lg),
          Text(
            FlowaFormatters.currency(vault.reserved),
            style: FlowaType.figureMd(color: FlowaColors.mintInk),
          ),
          const SizedBox(height: 6),
          Text(
            period,
            style: FlowaType.bodySm(
              color: FlowaColors.mintInk.withValues(alpha: 0.72),
            ),
          ),
        ],
      ),
    );
  }
}

class _CoverageCard extends StatelessWidget {
  const _CoverageCard({
    required this.coverage,
    required this.estimatedDue,
  });

  final double coverage;
  final double estimatedDue;

  @override
  Widget build(BuildContext context) {
    final covered = coverage >= 1;
    return Container(
      padding: const EdgeInsets.all(FlowaSpacing.lg),
      decoration: BoxDecoration(
        color: FlowaColors.inkHigh,
        borderRadius: FlowaRadii.xxlAll,
        border: Border.all(color: FlowaColors.hairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Cobertura estimada', style: FlowaType.titleSm()),
          const SizedBox(height: 4),
          Text(
            'Respecto a ${FlowaFormatters.currency(estimatedDue)} '
            'del trimestre',
            style: FlowaType.bodySm(),
          ),
          const SizedBox(height: FlowaSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: coverage,
              minHeight: 8,
              backgroundColor: FlowaColors.inkRaised,
              color: covered ? FlowaColors.mint : FlowaColors.warning,
            ),
          ),
          const SizedBox(height: FlowaSpacing.sm),
          Text(
            covered
                ? 'Cubierto al 100 %. El trimestre va bien.'
                : 'Cubres el ${(coverage * 100).round()} % del estimado.',
            style: FlowaType.bodySm(
              color: covered ? FlowaColors.mint : FlowaColors.warning,
            ),
          ),
        ],
      ),
    );
  }
}

class _RateCard extends StatelessWidget {
  const _RateCard({required this.rate, required this.onChanged});

  final double rate;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
      decoration: BoxDecoration(
        color: FlowaColors.inkHigh,
        borderRadius: FlowaRadii.xxlAll,
        border: Border.all(color: FlowaColors.hairline),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text('Porcentaje', style: FlowaType.bodySm()),
              const Spacer(),
              Text(
                '${(rate * 100).round()} %',
                style: FlowaType.titleMd(color: FlowaColors.mint),
              ),
            ],
          ),
          SliderTheme(
            data: const SliderThemeData(
              trackHeight: 4,
              activeTrackColor: FlowaColors.mint,
              inactiveTrackColor: FlowaColors.inkPressed,
              thumbColor: FlowaColors.mint,
              overlayColor: FlowaColors.mintVeil,
              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 10),
              overlayShape: RoundSliderOverlayShape(),
            ),
            child: Slider(
              value: rate,
              min: 0.05,
              max: 0.45,
              divisions: 8,
              onChanged: onChanged,
            ),
          ),
          Text(
            'Al cobrar una factura, este % va al bote automáticamente.',
            style: FlowaType.bodySm(),
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

class _TipCard extends StatelessWidget {
  const _TipCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(FlowaSpacing.lg),
      decoration: BoxDecoration(
        color: FlowaColors.inkRaised,
        borderRadius: FlowaRadii.xlAll,
        border: Border.all(color: FlowaColors.hairline),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Consejo', style: FlowaType.micro(color: FlowaColors.mint)),
          const SizedBox(height: 6),
          Text(
            'Aparta en cada factura cobrada para no improvisar '
            'en la declaración.',
            style: FlowaType.bodySm(),
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
      decoration: BoxDecoration(
        color: FlowaColors.inkHigh,
        borderRadius: FlowaRadii.xlAll,
        border: Border.all(color: FlowaColors.hairline),
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

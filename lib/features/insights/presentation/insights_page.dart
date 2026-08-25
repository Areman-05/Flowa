import 'package:flutter/material.dart';

import '../../../core/utils/flowa_formatters.dart';
import '../../../core/utils/flowa_services.dart';
import '../../../design_system/components/flowa_actions.dart';
import '../../../design_system/components/flowa_icon.dart';
import '../../../design_system/components/flowa_primitives.dart';
import '../../../design_system/components/flowa_screen.dart';
import '../../../design_system/tokens/flowa_colors.dart';
import '../../../design_system/tokens/flowa_spacing.dart';
import '../../../design_system/tokens/flowa_typography.dart';
import '../../../domain/entities/budget_goal.dart';
import '../../../shared/widgets/flowa_states.dart';
import '../domain/spending_snapshot.dart';

class InsightsPage extends StatefulWidget {
  const InsightsPage({super.key});

  @override
  State<InsightsPage> createState() => _InsightsPageState();
}

class _InsightsPageState extends State<InsightsPage> {
  SpendingSnapshot? _snapshot;
  BudgetGoal? _budget;
  DateTime? _month;
  bool _loading = true;
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
      final results = await Future.wait([
        FlowaServices.transactionRepository.getAll(),
        FlowaServices.preferencesRepository.getMonthlyBudgetLimit(),
        FlowaServices.preferencesRepository.isBudgetEnabled(),
      ]);
      if (!mounted) {
        return;
      }
      final items = results[0] as List;
      final limit = results[1] as double;
      final enabled = results[2] as bool;
      setState(() {
        _snapshot = SpendingInsights.from(items.cast(), month: _month);
        _budget = BudgetGoal(monthlyLimit: limit, enabled: enabled);
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

  void _selectMonth(DateTime? month) {
    setState(() => _month = month);
    _load();
  }

  @override
  Widget build(BuildContext context) {
    final snapshot = _snapshot;
    final budget = _budget;

    Widget body;
    if (_loading) {
      body = const Center(
        child: CircularProgressIndicator(color: FlowaColors.mint),
      );
    } else if (_error != null) {
      body = FlowaErrorState(message: _error!, onRetry: _load);
    } else if (snapshot == null || budget == null) {
      body = const SizedBox.shrink();
    } else if (snapshot.transactionCount == 0) {
      body = const FlowaEmptyState(
        title: 'Sin actividad aún',
        message: 'El resumen aparece tras tus primeros movimientos.',
        glyph: FlowaGlyph.chart,
      );
    } else {
      final maxCategory = snapshot.categories.isEmpty
          ? 1.0
          : snapshot.categories.first.amount;
      body = RefreshIndicator(
        onRefresh: _load,
        color: FlowaColors.mint,
        backgroundColor: FlowaColors.inkHigh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: const EdgeInsets.only(bottom: FlowaSpacing.navClearance),
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FlowaFilterChip(
                  label: 'Todo',
                  selected: _month == null,
                  onTap: () => _selectMonth(null),
                ),
                FlowaFilterChip(
                  label: 'Mar 2026',
                  selected: _month?.month == 3 && _month?.year == 2026,
                  onTap: () => _selectMonth(DateTime(2026, 3)),
                ),
                FlowaFilterChip(
                  label: 'Feb 2026',
                  selected: _month?.month == 2 && _month?.year == 2026,
                  onTap: () => _selectMonth(DateTime(2026, 2)),
                ),
              ],
            ),
            const SizedBox(height: FlowaSpacing.lg),
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: _StatCard(
                      label: 'Entradas',
                      value: FlowaFormatters.compact(snapshot.incoming),
                      mint: true,
                    ),
                  ),
                  const SizedBox(width: FlowaSpacing.sm),
                  Expanded(
                    child: _StatCard(
                      label: 'Salidas',
                      value: FlowaFormatters.compact(snapshot.outgoing),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: FlowaSpacing.sm),
            FlowaSurface(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Neto', style: FlowaType.micro()),
                        const SizedBox(height: 4),
                        Text(
                          FlowaFormatters.signedCurrency(snapshot.net),
                          style: FlowaType.figureMd(
                            color: snapshot.isPositive
                                ? FlowaColors.mint
                                : FlowaColors.bone,
                          ),
                        ),
                      ],
                    ),
                  ),
                  FlowaIconOrb(
                    glyph: snapshot.isPositive
                        ? FlowaGlyph.arrowDown
                        : FlowaGlyph.arrowUp,
                    background: FlowaColors.mintTintedSurface,
                    foreground: FlowaColors.mint,
                  ),
                ],
              ),
            ),
            if (budget.enabled) ...[
              const SizedBox(height: FlowaSpacing.xl),
              const FlowaSectionHeader(label: 'Presupuesto'),
              const SizedBox(height: FlowaSpacing.sm),
              ClipRRect(
                borderRadius: FlowaRadii.pillAll,
                child: LinearProgressIndicator(
                  minHeight: 8,
                  value: budget.progressFor(snapshot.outgoing),
                  backgroundColor: FlowaColors.inkHigh,
                  color: budget.isOverBudget(snapshot.outgoing)
                      ? FlowaColors.danger
                      : FlowaColors.mint,
                ),
              ),
              const SizedBox(height: FlowaSpacing.xs),
              Text(
                '${FlowaFormatters.compact(snapshot.outgoing)} de '
                '${FlowaFormatters.compact(budget.monthlyLimit)}',
                style: FlowaType.bodySm(),
              ),
            ],
            const SizedBox(height: FlowaSpacing.xl),
            const FlowaSectionHeader(label: 'Mayor gasto'),
            const SizedBox(height: FlowaSpacing.xs),
            Text(snapshot.topMerchant, style: FlowaType.editorialMd()),
            if (snapshot.categories.isNotEmpty) ...[
              const SizedBox(height: FlowaSpacing.xl),
              const FlowaSectionHeader(label: 'Por categoría'),
              const SizedBox(height: FlowaSpacing.sm),
              for (final entry in snapshot.categories)
                Padding(
                  padding: const EdgeInsets.only(bottom: FlowaSpacing.md),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(entry.category, style: FlowaType.titleSm()),
                          ),
                          Text(
                            FlowaFormatters.compact(entry.amount),
                            style: FlowaType.amountMd(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: FlowaRadii.pillAll,
                        child: LinearProgressIndicator(
                          minHeight: 6,
                          value: maxCategory == 0
                              ? 0
                              : (entry.amount / maxCategory).clamp(0, 1),
                          backgroundColor: FlowaColors.inkHigh,
                          color: FlowaColors.mint,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
            const SizedBox(height: FlowaSpacing.sm),
            Text(
              '${snapshot.transactionCount} movimientos en este periodo.',
              style: FlowaType.bodySm(),
            ),
          ],
        ),
      );
    }

    return FlowaScreen(title: 'Análisis', child: body);
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    this.mint = false,
  });

  final String label;
  final String value;
  final bool mint;

  @override
  Widget build(BuildContext context) {
    return FlowaSurface(
      color: mint ? FlowaColors.mint : FlowaColors.inkHigh,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: FlowaType.micro(
              color: mint ? FlowaColors.mintInk : FlowaColors.boneFaint,
            ),
          ),
          const SizedBox(height: FlowaSpacing.md),
          Text(
            value,
            style: FlowaType.figureMd(
              color: mint ? FlowaColors.mintInk : FlowaColors.bone,
            ),
          ),
        ],
      ),
    );
  }
}

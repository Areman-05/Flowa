import 'package:flutter/material.dart';

import '../../../core/utils/flowa_formatters.dart';
import '../../../core/utils/flowa_services.dart';
import '../../../design_system/tokens/flowa_colors.dart';
import '../../../design_system/tokens/flowa_spacing.dart';
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
    return Scaffold(
      appBar: AppBar(title: const Text('Insights')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? FlowaErrorState(message: _error!, onRetry: _load)
          : snapshot == null || budget == null
          ? const SizedBox.shrink()
          : snapshot.transactionCount == 0
          ? const FlowaEmptyState(
              title: 'No activity yet',
              message: 'Insights appear after your first movements.',
            )
          : ListView(
              padding: FlowaSpacing.screenPadding,
              children: [
                Wrap(
                  spacing: FlowaSpacing.sm,
                  children: [
                    ChoiceChip(
                      label: const Text('All time'),
                      selected: _month == null,
                      onSelected: (_) => _selectMonth(null),
                    ),
                    ChoiceChip(
                      label: const Text('Mar 2026'),
                      selected: _month?.month == 3 && _month?.year == 2026,
                      onSelected: (_) => _selectMonth(DateTime(2026, 3)),
                    ),
                    ChoiceChip(
                      label: const Text('Feb 2026'),
                      selected: _month?.month == 2 && _month?.year == 2026,
                      onSelected: (_) => _selectMonth(DateTime(2026, 2)),
                    ),
                  ],
                ),
                const SizedBox(height: FlowaSpacing.md),
                _InsightCard(
                  label: 'Money in',
                  value: FlowaFormatters.currency(snapshot.incoming),
                  color: FlowaColors.income,
                ),
                const SizedBox(height: FlowaSpacing.sm),
                _InsightCard(
                  label: 'Money out',
                  value: FlowaFormatters.currency(snapshot.outgoing),
                  color: FlowaColors.textPrimary,
                ),
                const SizedBox(height: FlowaSpacing.sm),
                _InsightCard(
                  label: 'Net',
                  value: FlowaFormatters.signedCurrency(snapshot.net),
                  color: snapshot.isPositive
                      ? FlowaColors.success
                      : FlowaColors.danger,
                ),
                if (budget.enabled) ...[
                  const SizedBox(height: FlowaSpacing.xl),
                  Text(
                    'Monthly budget',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: FlowaSpacing.sm),
                  LinearProgressIndicator(
                    value: budget.progressFor(snapshot.outgoing),
                    backgroundColor: FlowaColors.border,
                    color: budget.isOverBudget(snapshot.outgoing)
                        ? FlowaColors.danger
                        : FlowaColors.primary,
                  ),
                  const SizedBox(height: FlowaSpacing.xs),
                  Text(
                    '${FlowaFormatters.currency(snapshot.outgoing)} of '
                    '${FlowaFormatters.currency(budget.monthlyLimit)} spent',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
                const SizedBox(height: FlowaSpacing.xl),
                Text(
                  'Top merchant',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: FlowaSpacing.xs),
                Text(
                  snapshot.topMerchant,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                if (snapshot.categories.isNotEmpty) ...[
                  const SizedBox(height: FlowaSpacing.xl),
                  Text(
                    'By category',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: FlowaSpacing.sm),
                  for (final entry in snapshot.categories)
                    Padding(
                      padding: const EdgeInsets.only(bottom: FlowaSpacing.sm),
                      child: Row(
                        children: [
                          Expanded(child: Text(entry.category)),
                          Text(
                            FlowaFormatters.currency(entry.amount),
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ],
                      ),
                    ),
                ],
                const SizedBox(height: FlowaSpacing.sm),
                Text(
                  '${snapshot.transactionCount} movements in this snapshot.',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
    );
  }
}

class _InsightCard extends StatelessWidget {
  const _InsightCard({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: FlowaSpacing.cardPadding,
      decoration: BoxDecoration(
        color: FlowaColors.surface,
        borderRadius: FlowaRadii.lgAll,
        border: Border.all(color: FlowaColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: FlowaSpacing.xs),
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.headlineMedium?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

class HomeSpendingStrip extends StatelessWidget {
  const HomeSpendingStrip({required this.snapshot, super.key});

  final SpendingSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: FlowaSpacing.cardPadding,
      decoration: BoxDecoration(
        color: FlowaColors.surface,
        borderRadius: FlowaRadii.lgAll,
        border: Border.all(color: FlowaColors.border),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'This period',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  'Out ${FlowaFormatters.currency(snapshot.outgoing)}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
          ),
          Text(
            FlowaFormatters.signedCurrency(snapshot.net),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: snapshot.isPositive
                  ? FlowaColors.success
                  : FlowaColors.danger,
            ),
          ),
        ],
      ),
    );
  }
}

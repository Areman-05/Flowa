import 'package:flutter/material.dart';

import '../../../core/utils/flowa_formatters.dart';
import '../../../core/utils/flowa_services.dart';
import '../../../design_system/tokens/flowa_colors.dart';
import '../../../design_system/tokens/flowa_spacing.dart';
import '../../../shared/widgets/flowa_states.dart';
import '../domain/spending_snapshot.dart';

class InsightsPage extends StatefulWidget {
  const InsightsPage({super.key});

  @override
  State<InsightsPage> createState() => _InsightsPageState();
}

class _InsightsPageState extends State<InsightsPage> {
  SpendingSnapshot? _snapshot;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final items = await FlowaServices.transactionRepository.getAll();
    if (!mounted) {
      return;
    }
    setState(() {
      _snapshot = SpendingInsights.from(items);
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final snapshot = _snapshot;
    return Scaffold(
      appBar: AppBar(title: const Text('Insights')),
      body: _loading || snapshot == null
          ? const Center(child: CircularProgressIndicator())
          : snapshot.transactionCount == 0
          ? const FlowaEmptyState(
              title: 'No activity yet',
              message: 'Insights appear after your first movements.',
            )
          : ListView(
              padding: FlowaSpacing.screenPadding,
              children: [
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

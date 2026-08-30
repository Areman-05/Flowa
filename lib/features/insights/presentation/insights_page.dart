import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/utils/flowa_formatters.dart';
import '../../../core/utils/flowa_services.dart';
import '../../../design_system/components/flowa_actions.dart';
import '../../../design_system/components/flowa_icon.dart';
import '../../../design_system/components/flowa_screen.dart';
import '../../../design_system/tokens/flowa_colors.dart';
import '../../../design_system/tokens/flowa_spacing.dart';
import '../../../design_system/tokens/flowa_typography.dart';
import '../../../domain/entities/budget_goal.dart';
import '../../../domain/entities/finance_entities.dart';
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
  List<TransactionItem> _items = const [];
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);
  InsightRange _range = InsightRange.week;
  int _tab = 0; // 0 gastos, 1 este mes
  int _selectedBar = 0;
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
      final items = (results[0] as List).cast<TransactionItem>();
      final limit = results[1] as double;
      final enabled = results[2] as bool;
      final snap = SpendingInsights.from(
        items,
        month: _month,
        range: _range,
      );
      setState(() {
        _items = items;
        _snapshot = snap;
        _budget = BudgetGoal(monthlyLimit: limit, enabled: enabled);
        _selectedBar = _peakIndex(snap.bars);
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

  int _peakIndex(List<SpendBar> bars) {
    if (bars.isEmpty) {
      return 0;
    }
    var best = 0;
    for (var i = 1; i < bars.length; i++) {
      if (bars[i].amount >= bars[best].amount) {
        best = i;
      }
    }
    return best;
  }

  void _setRange(InsightRange range) {
    setState(() => _range = range);
    final snap = SpendingInsights.from(
      _items,
      month: _month,
      range: range,
    );
    setState(() {
      _snapshot = snap;
      _selectedBar = _peakIndex(snap.bars);
    });
  }

  Future<void> _pickMonth() async {
    final picked = await showModalBottomSheet<DateTime>(
      context: context,
      backgroundColor: FlowaColors.inkHigh,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        final now = DateTime.now();
        final options = [
          for (var i = 0; i < 6; i++)
            DateTime(now.year, now.month - i),
        ];
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Text('Periodo', style: FlowaType.titleMd()),
              const SizedBox(height: 8),
              for (final m in options)
                ListTile(
                  title: Text(
                    DateFormat('MMM yyyy', 'es_ES').format(m),
                    style: FlowaType.titleSm(),
                  ),
                  trailing: m.year == _month.year && m.month == _month.month
                      ? const FlowaIcon(
                          FlowaGlyph.check,
                          size: 20,
                          color: FlowaColors.mint,
                        )
                      : null,
                  onTap: () => Navigator.pop(context, m),
                ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
    if (picked == null || !mounted) {
      return;
    }
    setState(() => _month = picked);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final snapshot = _snapshot;
    final budget = _budget;
    final monthLabel = DateFormat('MMM yyyy', 'es_ES').format(_month);

    Widget body;
    if (_loading) {
      body = const Center(
        child: CircularProgressIndicator(color: FlowaColors.mint),
      );
    } else if (_error != null) {
      body = FlowaErrorState(message: _error!, onRetry: _load);
    } else if (snapshot == null || budget == null) {
      body = const SizedBox.shrink();
    } else {
      body = RefreshIndicator(
        onRefresh: _load,
        color: FlowaColors.mint,
        backgroundColor: FlowaColors.inkHigh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: const EdgeInsets.only(bottom: FlowaSpacing.xl),
          children: [
            _SegmentTabs(
              index: _tab,
              onChanged: (i) => setState(() => _tab = i),
            ),
            const SizedBox(height: FlowaSpacing.lg),
            if (_tab == 0) ...[
              _TotalSpendCard(
                snapshot: snapshot,
                range: _range,
                selectedBar: _selectedBar,
                onRange: _setRange,
                onSelectBar: (i) => setState(() => _selectedBar = i),
              ),
              const SizedBox(height: FlowaSpacing.xl),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Resumen financiero',
                      style: FlowaType.titleSm(),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: FlowaColors.inkHigh,
                      borderRadius: FlowaRadii.pillAll,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _range == InsightRange.week
                              ? 'Semanal'
                              : _range == InsightRange.month
                                  ? 'Mensual'
                                  : _range == InsightRange.quarter
                                      ? 'Trimestral'
                                      : 'Anual',
                          style: FlowaType.micro(color: FlowaColors.bone),
                        ),
                        const SizedBox(width: 4),
                        const FlowaIcon(
                          FlowaGlyph.arrowDown,
                          size: 14,
                          color: FlowaColors.boneMuted,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: FlowaSpacing.md),
              _OverviewGrid(snapshot: snapshot, budget: budget),
            ] else ...[
              _MonthSummary(snapshot: snapshot, budget: budget),
            ],
          ],
        ),
      );
    }

    return FlowaScreen(
      title: 'Análisis',
      actions: [
        FlowaPressScale(
          onTap: _pickMonth,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: FlowaColors.inkHigh,
              borderRadius: FlowaRadii.pillAll,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(monthLabel, style: FlowaType.micro(color: FlowaColors.bone)),
                const SizedBox(width: 4),
                const FlowaIcon(
                  FlowaGlyph.arrowDown,
                  size: 14,
                  color: FlowaColors.boneMuted,
                ),
              ],
            ),
          ),
        ),
      ],
      child: body,
    );
  }
}

class _SegmentTabs extends StatelessWidget {
  const _SegmentTabs({required this.index, required this.onChanged});

  final int index;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: FlowaColors.inkHigh,
        borderRadius: FlowaRadii.pillAll,
      ),
      child: Row(
        children: [
          _Seg(
            label: 'Gastos',
            selected: index == 0,
            onTap: () => onChanged(0),
          ),
          _Seg(
            label: 'Este mes',
            selected: index == 1,
            onTap: () => onChanged(1),
          ),
        ],
      ),
    );
  }
}

class _Seg extends StatelessWidget {
  const _Seg({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: FlowaPressScale(
        onTap: onTap,
        scale: 0.98,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? FlowaColors.mint : Colors.transparent,
            borderRadius: FlowaRadii.pillAll,
          ),
          child: Text(
            label,
            style: FlowaType.label(
              color: selected ? FlowaColors.mintInk : FlowaColors.boneMuted,
            ),
          ),
        ),
      ),
    );
  }
}

class _TotalSpendCard extends StatelessWidget {
  const _TotalSpendCard({
    required this.snapshot,
    required this.range,
    required this.selectedBar,
    required this.onRange,
    required this.onSelectBar,
  });

  final SpendingSnapshot snapshot;
  final InsightRange range;
  final int selectedBar;
  final ValueChanged<InsightRange> onRange;
  final ValueChanged<int> onSelectBar;

  @override
  Widget build(BuildContext context) {
    final delta = snapshot.outgoingDeltaPct;
    final bars = snapshot.bars;
    final maxBar = bars.fold<double>(
      0,
      (m, b) => b.amount > m ? b.amount : m,
    );
    final tip = bars.isEmpty
        ? 0.0
        : bars[selectedBar.clamp(0, bars.length - 1)].amount;

    return Container(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
      decoration: const BoxDecoration(
        color: FlowaColors.inkHigh,
        borderRadius: FlowaRadii.xxlAll,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const FlowaIcon(
                FlowaGlyph.chart,
                size: 18,
                color: FlowaColors.boneMuted,
              ),
              const SizedBox(width: 8),
              Text('Gasto total', style: FlowaType.bodySm()),
              const Spacer(),
              Container(
                width: 34,
                height: 34,
                decoration: const BoxDecoration(
                  color: FlowaColors.ink,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const FlowaIcon(
                  FlowaGlyph.arrowUp,
                  size: 15,
                  color: FlowaColors.boneMuted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            FlowaFormatters.currency(snapshot.outgoing),
            style: FlowaType.figureMd(),
          ),
          if (delta != null) ...[
            const SizedBox(height: 4),
            Text(
              '${delta >= 0 ? '+' : ''}${delta.toStringAsFixed(0)}% vs periodo ant.',
              style: FlowaType.micro(
                color: delta > 0 ? FlowaColors.danger : FlowaColors.mint,
              ),
            ),
          ],
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              for (final entry in const [
                (InsightRange.week, '1S'),
                (InsightRange.month, '1M'),
                (InsightRange.quarter, '3M'),
                (InsightRange.year, '1A'),
              ])
                Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: _RangeChip(
                    label: entry.$2,
                    selected: range == entry.$1,
                    onTap: () => onRange(entry.$1),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            height: 208,
            child: _SpendBars(
              bars: bars,
              maxValue: maxBar <= 0 ? 1 : maxBar,
              selected: selectedBar,
              tipAmount: tip,
              onSelect: onSelectBar,
            ),
          ),
        ],
      ),
    );
  }
}

class _RangeChip extends StatelessWidget {
  const _RangeChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FlowaPressScale(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? FlowaColors.mint : FlowaColors.ink,
          shape: BoxShape.circle,
        ),
        child: Text(
          label,
          style: FlowaType.micro(
            color: selected ? FlowaColors.mintInk : FlowaColors.boneMuted,
          ).copyWith(fontWeight: FontWeight.w700, fontSize: 11),
        ),
      ),
    );
  }
}

class _SpendBars extends StatelessWidget {
  const _SpendBars({
    required this.bars,
    required this.maxValue,
    required this.selected,
    required this.tipAmount,
    required this.onSelect,
  });

  final List<SpendBar> bars;
  final double maxValue;
  final int selected;
  final double tipAmount;
  final ValueChanged<int> onSelect;

  static const double _axisWidth = 42;
  static const double _labelHeight = 22;
  static const double _tipReserve = 36;

  @override
  Widget build(BuildContext context) {
    if (bars.isEmpty) {
      return Center(
        child: Text('Sin datos', style: FlowaType.bodySm()),
      );
    }

    final axisStyle = FlowaType.micro(color: FlowaColors.boneFaint);

    return Column(
      children: [
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: _axisWidth,
                child: Padding(
                  padding: const EdgeInsets.only(top: _tipReserve),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        FlowaFormatters.compact(maxValue),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: axisStyle,
                      ),
                      Text(
                        FlowaFormatters.compact(maxValue / 2),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: axisStyle,
                      ),
                      Text('0', style: axisStyle),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Stack(
                      children: [
                        Positioned.fill(
                          child: Padding(
                            padding: const EdgeInsets.only(top: _tipReserve),
                            child: CustomPaint(
                              painter: _ChartGuidesPainter(),
                            ),
                          ),
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            for (var i = 0; i < bars.length; i++)
                              Expanded(
                                child: _SpendBarColumn(
                                  amount: bars[i].amount,
                                  maxValue: maxValue,
                                  active: i == selected,
                                  tipAmount: tipAmount,
                                  tipReserve: _tipReserve,
                                  onTap: () => onSelect(i),
                                ),
                              ),
                          ],
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: _labelHeight,
          child: Row(
            children: [
              const SizedBox(width: _axisWidth + 6),
              for (final bar in bars)
                Expanded(
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Text(
                      bar.label,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.clip,
                      style: FlowaType.micro(color: FlowaColors.boneFaint),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SpendBarColumn extends StatelessWidget {
  const _SpendBarColumn({
    required this.amount,
    required this.maxValue,
    required this.active,
    required this.tipAmount,
    required this.tipReserve,
    required this.onTap,
  });

  final double amount;
  final double maxValue;
  final bool active;
  final double tipAmount;
  final double tipReserve;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final plotH = (constraints.maxHeight - tipReserve).clamp(1.0, 9999);
            var ratio = (amount / maxValue).clamp(0.0, 1.0);
            if (amount > 0 && ratio < 0.08) {
              ratio = 0.08;
            }
            final barH = amount <= 0 ? 0.0 : plotH * ratio;

            return Stack(
              clipBehavior: Clip.none,
              children: [
                if (barH > 0)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    height: barH,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOutCubic,
                      decoration: BoxDecoration(
                        color: active
                            ? FlowaColors.mint
                            : FlowaColors.inkPressed.withValues(alpha: 0.85),
                        borderRadius: FlowaRadii.pillAll,
                      ),
                    ),
                  ),
                if (active && amount > 0)
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: barH + 8,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: FlowaColors.mint,
                          borderRadius: FlowaRadii.smAll,
                        ),
                        child: Text(
                          FlowaFormatters.compact(tipAmount),
                          style: FlowaType.micro(
                            color: FlowaColors.mintInk,
                          ).copyWith(fontWeight: FontWeight.w700, fontSize: 11),
                        ),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ChartGuidesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = FlowaColors.hairlineStrong.withValues(alpha: 0.55)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    const dash = 4.0;
    const gap = 4.0;
    for (final t in const [0.0, 0.5, 1.0]) {
      final y = size.height * t;
      var x = 0.0;
      while (x < size.width) {
        canvas.drawLine(
          Offset(x, y),
          Offset((x + dash).clamp(0, size.width), y),
          paint,
        );
        x += dash + gap;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _OverviewGrid extends StatelessWidget {
  const _OverviewGrid({required this.snapshot, required this.budget});

  final SpendingSnapshot snapshot;
  final BudgetGoal budget;

  @override
  Widget build(BuildContext context) {
    final delta = snapshot.outgoingDeltaPct;
    final remaining = budget.enabled
        ? (budget.monthlyLimit - snapshot.outgoing).clamp(0, double.infinity)
        : snapshot.net;

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _OverviewTile(
                label: 'Ingresos',
                value: FlowaFormatters.currency(snapshot.incoming),
                badge: '+',
                badgePositive: true,
              ),
            ),
            const SizedBox(width: FlowaSpacing.sm),
            Expanded(
              child: _OverviewTile(
                label: 'Gastos',
                value: FlowaFormatters.currency(snapshot.outgoing),
                badge: delta == null
                    ? null
                    : '${delta >= 0 ? '+' : ''}${delta.toStringAsFixed(0)}%',
                badgePositive: delta != null && delta <= 0,
              ),
            ),
          ],
        ),
        const SizedBox(height: FlowaSpacing.sm),
        Row(
          children: [
            Expanded(
              child: _OverviewTile(
                label: 'Neto',
                value: FlowaFormatters.signedCurrency(snapshot.net),
                badge: snapshot.isPositive ? 'OK' : null,
                badgePositive: true,
              ),
            ),
            const SizedBox(width: FlowaSpacing.sm),
            Expanded(
              child: _OverviewTile(
                label: budget.enabled ? 'Presupuesto' : 'Top gasto',
                value: budget.enabled
                    ? FlowaFormatters.currency(remaining.toDouble())
                    : snapshot.topMerchant,
                badge: budget.enabled &&
                        budget.isOverBudget(snapshot.outgoing)
                    ? 'Over'
                    : null,
                badgePositive: false,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _OverviewTile extends StatelessWidget {
  const _OverviewTile({
    required this.label,
    required this.value,
    this.badge,
    this.badgePositive = true,
  });

  final String label;
  final String value;
  final String? badge;
  final bool badgePositive;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 132,
      padding: const EdgeInsets.all(FlowaSpacing.md),
      decoration: const BoxDecoration(
        color: FlowaColors.inkHigh,
        borderRadius: FlowaRadii.xxlAll,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(label, style: FlowaType.bodySm()),
              ),
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                  color: FlowaColors.mint,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const FlowaIcon(
                  FlowaGlyph.arrowUp,
                  size: 14,
                  color: FlowaColors.mintInk,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: FlowaType.titleMd(),
          ),
          if (badge != null) ...[
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: badgePositive
                    ? FlowaColors.mintTintedSurface
                    : FlowaColors.dangerSurface,
                borderRadius: FlowaRadii.pillAll,
              ),
              child: Text(
                badge!,
                style: FlowaType.micro(
                  color: badgePositive
                      ? FlowaColors.mint
                      : FlowaColors.danger,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MonthSummary extends StatelessWidget {
  const _MonthSummary({required this.snapshot, required this.budget});

  final SpendingSnapshot snapshot;
  final BudgetGoal budget;

  @override
  Widget build(BuildContext context) {
    final maxCategory = snapshot.categories.isEmpty
        ? 1.0
        : snapshot.categories.first.amount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(FlowaSpacing.lg),
          decoration: const BoxDecoration(
            color: FlowaColors.inkHigh,
            borderRadius: FlowaRadii.xxlAll,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Este mes', style: FlowaType.micro()),
              const SizedBox(height: 6),
              Text(
                FlowaFormatters.currency(snapshot.outgoing),
                style: FlowaType.figureMd(),
              ),
              const SizedBox(height: 4),
              Text(
                '${snapshot.transactionCount} movimientos · top ${snapshot.topMerchant}',
                style: FlowaType.bodySm(),
              ),
              if (budget.enabled) ...[
                const SizedBox(height: FlowaSpacing.md),
                ClipRRect(
                  borderRadius: FlowaRadii.pillAll,
                  child: LinearProgressIndicator(
                    minHeight: 8,
                    value: budget.progressFor(snapshot.outgoing),
                    backgroundColor: FlowaColors.ink,
                    color: budget.isOverBudget(snapshot.outgoing)
                        ? FlowaColors.danger
                        : FlowaColors.mint,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${FlowaFormatters.compact(snapshot.outgoing)} de '
                  '${FlowaFormatters.compact(budget.monthlyLimit)}',
                  style: FlowaType.bodySm(),
                ),
              ],
            ],
          ),
        ),
        if (snapshot.categories.isNotEmpty) ...[
          const SizedBox(height: FlowaSpacing.xl),
          Text('Por categoría', style: FlowaType.titleSm()),
          const SizedBox(height: FlowaSpacing.md),
          for (final entry in snapshot.categories)
            Padding(
              padding: const EdgeInsets.only(bottom: FlowaSpacing.md),
              child: Container(
                padding: const EdgeInsets.all(FlowaSpacing.md),
                decoration: const BoxDecoration(
                  color: FlowaColors.inkHigh,
                  borderRadius: FlowaRadii.xlAll,
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            entry.category,
                            style: FlowaType.titleSm(),
                          ),
                        ),
                        Text(
                          FlowaFormatters.compact(entry.amount),
                          style: FlowaType.titleSm(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    ClipRRect(
                      borderRadius: FlowaRadii.pillAll,
                      child: LinearProgressIndicator(
                        minHeight: 6,
                        value: maxCategory == 0
                            ? 0
                            : (entry.amount / maxCategory).clamp(0, 1),
                        backgroundColor: FlowaColors.ink,
                        color: FlowaColors.mint,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ],
    );
  }
}

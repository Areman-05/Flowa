import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:intl/intl.dart';

import '../../../core/utils/flowa_formatters.dart';
import '../../../core/utils/flowa_services.dart';
import '../../../design_system/components/flowa_actions.dart';
import '../../../design_system/components/flowa_glass.dart';
import '../../../design_system/components/flowa_month_picker.dart';
import '../../../design_system/components/flowa_icon.dart';
import '../../../design_system/components/flowa_screen.dart';
import '../../../design_system/tokens/flowa_colors.dart';
import '../../../design_system/tokens/flowa_spacing.dart';
import '../../../design_system/tokens/flowa_typography.dart';
import '../../../domain/entities/budget_goal.dart';
import '../../../domain/entities/finance_entities.dart';
import '../../../shared/widgets/flowa_states.dart';
import '../../../design_system/icons/flowa_lucide_icons.dart';
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
  InsightRange _range = InsightRange.month;
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
    final picked = await showFlowaMonthPicker(context, selected: _month);
    if (picked == null || !mounted) {
      return;
    }
    setState(() => _month = picked);
    await _load();
  }

  Future<void> _pickOverviewRange() async {
    final picked = await showFlowaGlassSheet<InsightRange>(
      context: context,
      builder: (context) => _RangePickerSheet(selected: _range),
    );
    if (picked == null || !mounted) {
      return;
    }
    _setRange(picked);
  }

  String _rangeLabel(InsightRange range) {
    return switch (range) {
      InsightRange.day => 'Diario',
      InsightRange.week => 'Semanal',
      InsightRange.month => 'Mensual',
      InsightRange.quarter => 'Trimestral',
      InsightRange.year => 'Anual',
    };
  }

  @override
  Widget build(BuildContext context) {
    final snapshot = _snapshot;
    final budget = _budget;
    final monthLabel = DateFormat('MMM yyyy', 'es_ES').format(_month);
    final now = DateTime.now();
    final periodLabel = SpendingInsights.periodLabel(
      anchor: _month,
      range: _range,
      now: now,
    );
    final monthPeriodLabel = SpendingInsights.periodLabel(
      anchor: _month,
      range: InsightRange.month,
      now: now,
    );

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
      final monthSnapshot = SpendingInsights.from(
        _items,
        month: _month,
        range: InsightRange.month,
      );
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
                periodLabel: periodLabel,
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
                      style: FlowaType.titleMd(),
                    ),
                  ),
                  FlowaPressScale(
                    onTap: _pickOverviewRange,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: FlowaColors.inkHigh,
                        borderRadius: FlowaRadii.pillAll,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _rangeLabel(_range),
                            style: FlowaType.body(color: FlowaColors.bone),
                          ),
                          const SizedBox(width: 6),
                          const FlowaIcon(
                            FlowaGlyph.arrowDown,
                            size: 16,
                            color: FlowaColors.boneMuted,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: FlowaSpacing.md),
              _OverviewGrid(snapshot: snapshot, budget: budget),
            ] else ...[
              _MonthSummary(
                snapshot: monthSnapshot,
                budget: budget,
                periodLabel: monthPeriodLabel,
              ),
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
                Text(
                  monthLabel,
                  style: FlowaType.body(color: FlowaColors.bone),
                ),
                const SizedBox(width: 6),
                const FlowaIcon(
                  FlowaGlyph.arrowDown,
                  size: 16,
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
    required this.periodLabel,
    required this.selectedBar,
    required this.onRange,
    required this.onSelectBar,
  });

  final SpendingSnapshot snapshot;
  final InsightRange range;
  final String periodLabel;
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
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
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
                size: 22,
                color: FlowaColors.boneMuted,
              ),
              const SizedBox(width: 10),
              Text('Gasto total', style: FlowaType.titleSm()),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            FlowaFormatters.currency(snapshot.outgoing),
            style: FlowaType.figureLg(),
          ),
          if (delta != null) ...[
            const SizedBox(height: 6),
            Text(
              '${delta >= 0 ? '+' : ''}${delta.toStringAsFixed(0)}% vs periodo ant.',
              style: FlowaType.body(
                color: delta > 0 ? FlowaColors.danger : FlowaColors.mint,
              ),
            ),
          ],
          const SizedBox(height: 4),
          Text(periodLabel, style: FlowaType.bodySm()),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              for (final entry in const [
                (InsightRange.day, '1D'),
                (InsightRange.week, '1S'),
                (InsightRange.month, '1M'),
                (InsightRange.year, '1A'),
              ])
                Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: _RangeChip(
                    label: entry.$2,
                    selected: range == entry.$1,
                    onTap: () => onRange(entry.$1),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 220,
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
        width: 46,
        height: 46,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? FlowaColors.mint : FlowaColors.ink,
          shape: BoxShape.circle,
        ),
        child: Text(
          label,
          style: FlowaType.label(
            color: selected ? FlowaColors.mintInk : FlowaColors.boneMuted,
          ).copyWith(fontSize: 13),
        ),
      ),
    );
  }
}

class _SpendBars extends StatefulWidget {
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

  @override
  State<_SpendBars> createState() => _SpendBarsState();
}

class _SpendBarsState extends State<_SpendBars> {
  static const double _axisWidth = 54;
  static const double _labelHeight = 28;
  static const double _tipReserve = 40;

  double _slotWidth(int count) {
    if (count == 6) {
      return 56;
    }
    if (count <= 4) {
      return 64;
    }
    if (count <= 7) {
      return 44;
    }
    if (count <= 12) {
      return 36;
    }
    return 28;
  }

  double _barWidth(int count, double slotWidth) {
    if (count <= 4) {
      return math.min(28, slotWidth - 8);
    }
    if (count <= 7) {
      return math.min(22, slotWidth - 6);
    }
    if (count <= 12) {
      return math.min(18, slotWidth - 4);
    }
    return math.min(14, slotWidth - 4);
  }

  @override
  Widget build(BuildContext context) {
    final bars = widget.bars;
    if (bars.isEmpty) {
      return Center(
        child: Text('Sin datos', style: FlowaType.body()),
      );
    }

    final axisStyle = FlowaType.microLg(color: FlowaColors.boneMuted);
    final slotWidth = _slotWidth(bars.length);
    final chartWidth = bars.length * slotWidth;
    final barWidth = _barWidth(bars.length, slotWidth);

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
                        FlowaFormatters.compact(widget.maxValue),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: axisStyle,
                      ),
                      Text(
                        FlowaFormatters.compact(widget.maxValue / 2),
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
                    final viewport = constraints.maxWidth;
                    final contentWidth = math.max(viewport, chartWidth);

                    final chartBody = SizedBox(
                      width: contentWidth,
                      child: Column(
                        children: [
                          Expanded(
                            child: Stack(
                              children: [
                                Positioned.fill(
                                  child: Padding(
                                    padding: const EdgeInsets.only(
                                      top: _tipReserve,
                                    ),
                                    child: CustomPaint(
                                      painter: _ChartGuidesPainter(),
                                    ),
                                  ),
                                ),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    for (var i = 0; i < bars.length; i++)
                                      SizedBox(
                                        width: slotWidth,
                                        child: _SpendBarColumn(
                                          amount: bars[i].amount,
                                          maxValue: widget.maxValue,
                                          active: i == widget.selected,
                                          tipAmount: widget.tipAmount,
                                          tipReserve: _tipReserve,
                                          barWidth: barWidth,
                                          onTap: () => widget.onSelect(i),
                                        ),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: _labelHeight,
                            child: Row(
                              children: [
                                for (final bar in bars)
                                  SizedBox(
                                    width: slotWidth,
                                    child: Align(
                                      alignment: Alignment.bottomCenter,
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 2,
                                          ),
                                          child: Text(
                                            bar.label,
                                            textAlign: TextAlign.center,
                                            maxLines: 1,
                                            style: FlowaType.microLg(
                                              color: FlowaColors.boneMuted,
                                            ).copyWith(fontSize: 11.5),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );

                    if (chartWidth <= viewport) {
                      return chartBody;
                    }

                    return SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: chartBody,
                    );
                  },
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
    required this.barWidth,
    required this.onTap,
  });

  final double amount;
  final double maxValue;
  final bool active;
  final double tipAmount;
  final double tipReserve;
  final double barWidth;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final plotH = (constraints.maxHeight - tipReserve).clamp(1.0, 9999);
          var ratio = (amount / maxValue).clamp(0.0, 1.0);
          if (amount > 0 && ratio < 0.08) {
            ratio = 0.08;
          }
          final barH = amount <= 0 ? 0.0 : plotH * ratio;
          final width = math.min(barWidth, constraints.maxWidth - 2);
          final left = (constraints.maxWidth - width) / 2;

          return Stack(
            clipBehavior: Clip.none,
            children: [
              if (barH > 0)
                Positioned(
                  left: left,
                  width: width,
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
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: FlowaColors.mint,
                          borderRadius: FlowaRadii.smAll,
                        ),
                        child: Text(
                          FlowaFormatters.compact(tipAmount),
                          style: FlowaType.label(
                            color: FlowaColors.mintInk,
                          ).copyWith(fontSize: 13),
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
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
                textValue: !budget.enabled,
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
    this.textValue = false,
    this.badge,
    this.badgePositive = true,
  });

  final String label;
  final String value;
  final bool textValue;
  final String? badge;
  final bool badgePositive;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: textValue ? 156 : 148,
      padding: const EdgeInsets.all(18),
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
                child: Text(label, style: FlowaType.titleSm()),
              ),
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(
                  color: FlowaColors.mint,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: const FlowaIcon(
                  FlowaGlyph.arrowUp,
                  size: 16,
                  color: FlowaColors.mintInk,
                ),
              ),
            ],
          ),
          const Spacer(),
          Text(
            value,
            maxLines: textValue ? 2 : 1,
            overflow: TextOverflow.ellipsis,
            style: textValue ? FlowaType.titleSm() : FlowaType.figureMd(),
          ),
          if (badge != null) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: badgePositive
                    ? FlowaColors.mintTintedSurface
                    : FlowaColors.dangerSurface,
                borderRadius: FlowaRadii.pillAll,
              ),
              child: Text(
                badge!,
                style: FlowaType.bodySm(
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
  const _MonthSummary({
    required this.snapshot,
    required this.budget,
    required this.periodLabel,
  });

  final SpendingSnapshot snapshot;
  final BudgetGoal budget;
  final String periodLabel;

  @override
  Widget build(BuildContext context) {
    final maxCategory = snapshot.categories.isEmpty
        ? 1.0
        : snapshot.categories.first.amount;
    final delta = snapshot.outgoingDeltaPct;
    final topCategory = snapshot.categories.isEmpty
        ? null
        : snapshot.categories.first;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: FlowaColors.inkHigh,
            borderRadius: FlowaRadii.xxlAll,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      color: FlowaColors.ink,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: const FlowaIcon(
                      FlowaGlyph.chart,
                      size: 20,
                      color: FlowaColors.boneMuted,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Este mes', style: FlowaType.titleSm()),
                        Text(
                          periodLabel,
                          style: FlowaType.bodySm(),
                        ),
                      ],
                    ),
                  ),
                  if (delta != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: delta > 0
                            ? FlowaColors.dangerSurface
                            : FlowaColors.mintTintedSurface,
                        borderRadius: FlowaRadii.pillAll,
                      ),
                      child: Text(
                        '${delta >= 0 ? '+' : ''}${delta.toStringAsFixed(0)}%',
                        style: FlowaType.bodySm(
                          color: delta > 0
                              ? FlowaColors.danger
                              : FlowaColors.mint,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                FlowaFormatters.currency(snapshot.outgoing),
                style: FlowaType.figureLg(),
              ),
              const SizedBox(height: 4),
              Text(
                '${snapshot.transactionCount} movimientos · '
                '${FlowaFormatters.currency(snapshot.outgoing)} en gastos',
                style: FlowaType.bodySm(),
              ),
              const SizedBox(height: 18),
              Row(
                children: [
                  Expanded(
                    child: _MonthStatChip(
                      label: 'Ingresos',
                      value: FlowaFormatters.currency(snapshot.incoming),
                      positive: true,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _MonthStatChip(
                      label: 'Gastos',
                      value: FlowaFormatters.currency(snapshot.outgoing),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _MonthStatChip(
                      label: 'Neto',
                      value: FlowaFormatters.signedCurrency(snapshot.net),
                      positive: snapshot.isPositive,
                    ),
                  ),
                ],
              ),
              if (budget.enabled) ...[
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: Text('Presupuesto', style: FlowaType.bodySm()),
                    ),
                    Text(
                      '${(budget.progressFor(snapshot.outgoing) * 100).toStringAsFixed(0)}%',
                      style: FlowaType.titleSm(
                        color: budget.isOverBudget(snapshot.outgoing)
                            ? FlowaColors.danger
                            : FlowaColors.mint,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: FlowaRadii.pillAll,
                  child: LinearProgressIndicator(
                    minHeight: 10,
                    value: budget.progressFor(snapshot.outgoing),
                    backgroundColor: FlowaColors.ink,
                    color: budget.isOverBudget(snapshot.outgoing)
                        ? FlowaColors.danger
                        : FlowaColors.mint,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${FlowaFormatters.currency(snapshot.outgoing)} de '
                  '${FlowaFormatters.currency(budget.monthlyLimit)}',
                  style: FlowaType.bodySm(),
                ),
              ],
            ],
          ),
        ),
        if (snapshot.topMerchant != '—') ...[
          const SizedBox(height: FlowaSpacing.md),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: const BoxDecoration(
              color: FlowaColors.inkHigh,
              borderRadius: FlowaRadii.xxlAll,
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: FlowaColors.mint,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                child: const FlowaLucideIcon(
                  LucideIcons.trending_up,
                  size: 18,
                  color: FlowaColors.mintInk,
                ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Mayor gasto', style: FlowaType.bodySm()),
                      const SizedBox(height: 2),
                      Text(
                        snapshot.topMerchant,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: FlowaType.titleSm(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
        if (topCategory != null) ...[
          const SizedBox(height: FlowaSpacing.md),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: const BoxDecoration(
              color: FlowaColors.inkHigh,
              borderRadius: FlowaRadii.xxlAll,
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: FlowaColors.mint.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '1',
                    style: FlowaType.titleSm(color: FlowaColors.mint),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Categoría top', style: FlowaType.bodySm()),
                      const SizedBox(height: 2),
                      Text(topCategory.category, style: FlowaType.titleSm()),
                    ],
                  ),
                ),
                Text(
                  FlowaFormatters.currency(topCategory.amount),
                  style: FlowaType.titleSm(color: FlowaColors.mint),
                ),
              ],
            ),
          ),
        ],
        if (snapshot.categories.isNotEmpty) ...[
          const SizedBox(height: FlowaSpacing.xl),
          Text('Por categoría', style: FlowaType.titleMd()),
          const SizedBox(height: FlowaSpacing.md),
          for (var i = 0; i < snapshot.categories.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: FlowaSpacing.sm),
              child: _CategoryRow(
                rank: i + 1,
                category: snapshot.categories[i].category,
                icon: categoryLucideIcon(snapshot.categories[i].category),
                amount: snapshot.categories[i].amount,
                share: snapshot.outgoing <= 0
                    ? 0
                    : snapshot.categories[i].amount / snapshot.outgoing,
                maxAmount: maxCategory,
              ),
            ),
        ],
      ],
    );
  }
}

class _MonthStatChip extends StatelessWidget {
  const _MonthStatChip({
    required this.label,
    required this.value,
    this.positive = false,
  });

  final String label;
  final String value;
  final bool positive;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: FlowaColors.ink,
        borderRadius: FlowaRadii.lgAll,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: FlowaType.bodySm()),
          const SizedBox(height: 4),
          Text(
            value,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: FlowaType.bodySm(
              color: positive ? FlowaColors.mint : FlowaColors.bone,
            ).copyWith(fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow({
    required this.rank,
    required this.category,
    required this.icon,
    required this.amount,
    required this.share,
    required this.maxAmount,
  });

  final int rank;
  final String category;
  final IconData icon;
  final double amount;
  final double share;
  final double maxAmount;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: FlowaColors.inkHigh,
        borderRadius: FlowaRadii.xlAll,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: rank == 1
                      ? FlowaColors.mint.withValues(alpha: 0.18)
                      : FlowaColors.ink,
                  shape: BoxShape.circle,
                ),
                child: FlowaLucideIcon(
                  icon,
                  size: 18,
                  color: rank == 1 ? FlowaColors.mint : FlowaColors.boneMuted,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(category, style: FlowaType.titleSm()),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    FlowaFormatters.currency(amount),
                    style: FlowaType.titleSm(),
                  ),
                  Text(
                    '${(share * 100).toStringAsFixed(0)}%',
                    style: FlowaType.bodySm(color: FlowaColors.boneFaint),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: FlowaRadii.pillAll,
            child: LinearProgressIndicator(
              minHeight: 8,
              value: maxAmount == 0 ? 0 : (amount / maxAmount).clamp(0, 1),
              backgroundColor: FlowaColors.ink,
              color: rank == 1 ? FlowaColors.mint : FlowaColors.inkPressed,
            ),
          ),
        ],
      ),
    );
  }
}

class _RangePickerSheet extends StatelessWidget {
  const _RangePickerSheet({required this.selected});

  final InsightRange selected;

  static const _options = [
    (InsightRange.day, 'Diario', 'Hoy'),
    (InsightRange.week, 'Semanal', 'Últimos 7 días'),
    (InsightRange.month, 'Mensual', 'Mes seleccionado'),
    (InsightRange.year, 'Anual', 'Año completo'),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 4),
          Text('Intervalo', style: FlowaType.titleLg()),
          const SizedBox(height: 16),
          for (final option in _options) ...[
            FlowaPressScale(
              onTap: () => Navigator.pop(context, option.$1),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: selected == option.$1
                      ? FlowaColors.mintTintedSurface
                      : FlowaColors.ink,
                  borderRadius: FlowaRadii.lgAll,
                  border: selected == option.$1
                      ? Border.all(color: FlowaColors.mint.withValues(alpha: 0.4))
                      : null,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(option.$2, style: FlowaType.titleSm()),
                          const SizedBox(height: 2),
                          Text(option.$3, style: FlowaType.bodySm()),
                        ],
                      ),
                    ),
                    if (selected == option.$1)
                      const FlowaIcon(
                        FlowaGlyph.check,
                        size: 20,
                        color: FlowaColors.mint,
                      ),
                  ],
                ),
              ),
            ),
          ],
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

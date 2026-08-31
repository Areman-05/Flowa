import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:intl/intl.dart';

import '../../../core/utils/flowa_formatters.dart';
import '../../../core/utils/flowa_services.dart';
import '../../../design_system/components/flowa_actions.dart';
import '../../../design_system/components/flowa_icon.dart';
import '../../../design_system/components/flowa_month_picker.dart';
import '../../../design_system/components/flowa_primitives.dart';
import '../../../design_system/components/flowa_texture.dart';
import '../../../design_system/icons/flowa_lucide_icons.dart';
import '../../../design_system/tokens/flowa_category_colors.dart';
import '../../../design_system/tokens/flowa_colors.dart';
import '../../../design_system/tokens/flowa_motion_tokens.dart';
import '../../../design_system/tokens/flowa_spacing.dart';
import '../../../design_system/tokens/flowa_typography.dart';
import '../../../domain/entities/finance_entities.dart';
import '../../../shared/navigation/flowa_routes.dart';
import '../../../shared/widgets/flowa_states.dart';
import '../../insights/domain/spending_snapshot.dart';
import '../../notifications/presentation/notification_inbox_page.dart';
import '../domain/transaction_filters.dart';
import 'transaction_detail_page.dart';

class _CategoryGroup {
  const _CategoryGroup({
    required this.name,
    required this.amount,
    required this.count,
    required this.income,
    required this.items,
  });

  final String name;
  final double amount;
  final int count;
  final bool income;
  final List<TransactionItem> items;
}

/// Movimientos — layout envelope (referencia Privat).
class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key, this.embedded = false});

  final bool embedded;

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  List<TransactionItem> _all = const [];
  List<TransactionItem> _visible = const [];
  bool _loading = true;
  int _unread = 0;
  DateTime _month = DateTime(DateTime.now().year, DateTime.now().month);

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final results = await Future.wait([
      FlowaServices.transactionRepository.getAll(),
      FlowaServices.inboxRepository.unreadCount(),
    ]);
    if (!mounted) {
      return;
    }
    setState(() {
      _all = results[0] as List<TransactionItem>;
      _unread = results[1] as int;
      _loading = false;
      _apply();
    });
  }

  void _apply() {
    _visible = TransactionFilters.apply(
      items: _all,
      filter: TransactionFilter.all,
      month: _month,
    );
  }

  SpendingSnapshot _snapshot() {
    return SpendingInsights.from(
      _all,
      month: _month,
      range: InsightRange.month,
    );
  }

  List<_CategoryGroup> _groups() {
    final map = <String, _CategoryGroup>{};
    for (final item in _visible) {
      final name = item.isIncome ? 'Ingresos' : (item.category ?? 'General');
      final existing = map[name];
      if (existing == null) {
        map[name] = _CategoryGroup(
          name: name,
          amount: item.amount.abs(),
          count: 1,
          income: item.isIncome,
          items: [item],
        );
      } else {
        map[name] = _CategoryGroup(
          name: name,
          amount: existing.amount + item.amount.abs(),
          count: existing.count + 1,
          income: existing.income,
          items: [...existing.items, item],
        );
      }
    }
    final groups = map.values.toList()
      ..sort((a, b) => b.amount.compareTo(a.amount));
    return groups;
  }

  Future<void> _pickMonth() async {
    final picked = await showFlowaMonthPicker(context, selected: _month);
    if (picked == null || !mounted) {
      return;
    }
    setState(() {
      _month = picked;
      _apply();
    });
  }

  Future<void> _openInbox() async {
    await pushFlowaRoute<void>(context, const NotificationInboxPage());
    if (!mounted) {
      return;
    }
    final unread = await FlowaServices.inboxRepository.unreadCount();
    setState(() => _unread = unread);
  }

  void _openDetail(TransactionItem item) {
    pushFlowaRoute<void>(context, TransactionDetailPage(item: item));
  }

  @override
  Widget build(BuildContext context) {
    final monthLabel = DateFormat('MMM yyyy', 'es_ES').format(_month);
    final snapshot = _snapshot();
    final sparkValues = snapshot.bars.map((b) => b.amount).toList();
    final groups = _groups();

    final body = _loading
        ? const Center(
            child: CircularProgressIndicator(color: FlowaColors.mint),
          )
        : RefreshIndicator(
            onRefresh: _load,
            color: FlowaColors.mint,
            backgroundColor: FlowaColors.inkHigh,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics(),
              ),
              padding: EdgeInsets.fromLTRB(
                FlowaSpacing.gutter,
                FlowaSpacing.md,
                FlowaSpacing.gutter,
                widget.embedded
                    ? FlowaSpacing.navClearance
                    : FlowaSpacing.xl,
              ),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text('Movimientos', style: FlowaType.titleLg()),
                    ),
                    FlowaPressScale(
                      onTap: _pickMonth,
                      child: Container(
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
                    const SizedBox(width: 4),
                    FlowaIconAction(
                      glyph: FlowaGlyph.bell,
                      tooltip: 'Avisos',
                      badge: _unread > 0,
                      onTap: _openInbox,
                    ),
                  ],
                ),
                const SizedBox(height: FlowaSpacing.lg),
                FlowaEntrance(
                  child: _HeroEnvelopeCard(
                    snapshot: snapshot,
                    sparkValues: sparkValues,
                  ),
                ),
                const SizedBox(height: FlowaSpacing.xl),
                Text('Tus movimientos', style: FlowaType.titleSm()),
                const SizedBox(height: FlowaSpacing.md),
                if (groups.isEmpty)
                  const FlowaEmptyState(
                    title: 'Sin movimientos',
                    message: 'No hay movimientos en este mes.',
                    glyph: FlowaGlyph.transfer,
                  )
                else
                  for (var i = 0; i < groups.length; i++) ...[
                    FlowaEntrance(
                      delay: FlowaMotion.stagger(i.clamp(0, 8)),
                      child: _EnvelopeCategoryCard(
                        group: groups[i],
                        snapshot: snapshot,
                        onTap: () => _openDetail(groups[i].items.first),
                      ),
                    ),
                    if (i < groups.length - 1)
                      const SizedBox(height: FlowaSpacing.sm),
                  ],
                if (groups.isNotEmpty) ...[
                  const SizedBox(height: FlowaSpacing.md),
                  FlowaEntrance(
                    delay: FlowaMotion.stagger(2),
                    child: _InsightBanner(snapshot: snapshot),
                  ),
                ],
              ],
            ),
          );

    if (widget.embedded) {
      return SafeArea(bottom: false, child: body);
    }

    return Scaffold(
      backgroundColor: FlowaColors.ink,
      body: FlowaCanvas(child: SafeArea(child: body)),
    );
  }
}

class _HeroEnvelopeCard extends StatelessWidget {
  const _HeroEnvelopeCard({
    required this.snapshot,
    required this.sparkValues,
  });

  final SpendingSnapshot snapshot;
  final List<double> sparkValues;

  @override
  Widget build(BuildContext context) {
    final subtitle =
        '${FlowaFormatters.compact(snapshot.outgoing)} gastos · '
        '${FlowaFormatters.compact(snapshot.incoming)} entradas';

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: const BoxDecoration(
        color: FlowaColors.inkHigh,
        borderRadius: FlowaRadii.xxlAll,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Este mes', style: FlowaType.titleSm()),
                const SizedBox(height: 10),
                Text(
                  FlowaFormatters.signedCurrency(snapshot.net),
                  style: FlowaType.figureMd(
                    color: snapshot.isPositive
                        ? FlowaColors.mint
                        : FlowaColors.bone,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: FlowaType.bodySm(color: FlowaColors.boneMuted),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 108,
            height: 72,
            child: CustomPaint(
              painter: _AreaChartPainter(values: sparkValues),
            ),
          ),
        ],
      ),
    );
  }
}

class _AreaChartPainter extends CustomPainter {
  const _AreaChartPainter({required this.values});

  final List<double> values;

  List<Offset> _smoothPoints(List<double> data, Size size) {
    if (data.isEmpty) {
      return [
        Offset(0, size.height * 0.65),
        Offset(size.width * 0.5, size.height * 0.45),
        Offset(size.width, size.height * 0.55),
      ];
    }

    final max = data.fold<double>(0, (m, v) => math.max(m, v));
    final min = data.fold<double>(max, (m, v) => math.min(m, v));
    final span = (max - min).clamp(1.0, double.infinity);
    const topPad = 18.0;
    const bottomPad = 8.0;
    final plotH = size.height - topPad - bottomPad;

    return [
      for (var i = 0; i < data.length; i++)
        Offset(
          data.length == 1 ? size.width / 2 : (i / (data.length - 1)) * size.width,
          topPad + plotH - ((data[i] - min) / span) * plotH,
        ),
    ];
  }

  List<double> _plotValues() {
    if (values.length >= 6) {
      return values;
    }
    if (values.isEmpty) {
      return [0.15, 0.42, 0.28, 0.62, 0.38, 0.55, 0.48, 0.72, 0.5];
    }
    final expanded = <double>[];
    for (var i = 0; i < values.length; i++) {
      expanded.add(values[i]);
      if (i < values.length - 1) {
        expanded.add((values[i] + values[i + 1]) / 2);
      }
    }
    return expanded;
  }

  Path _smoothPath(List<Offset> points) {
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final cp1 = Offset(
        p0.dx + (p1.dx - p0.dx) * 0.42,
        p0.dy,
      );
      final cp2 = Offset(
        p1.dx - (p1.dx - p0.dx) * 0.42,
        p1.dy,
      );
      path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, p1.dx, p1.dy);
    }
    return path;
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) {
      return;
    }

    final points = _smoothPoints(_plotValues(), size);
    final linePath = _smoothPath(points);

    final fillPath = Path.from(linePath)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(
      fillPath,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(0, 0),
          Offset(0, size.height),
          [
            FlowaColors.mint.withValues(alpha: 0.42),
            FlowaColors.mint.withValues(alpha: 0.16),
            FlowaColors.mint.withValues(alpha: 0),
          ],
          [0, 0.55, 1],
        ),
    );

    for (final width in [6.0, 3.5, 2.0]) {
      canvas.drawPath(
        linePath,
        Paint()
          ..color = FlowaColors.mint.withValues(alpha: width == 2 ? 0.95 : 0.14)
          ..style = PaintingStyle.stroke
          ..strokeWidth = width
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _AreaChartPainter oldDelegate) =>
      oldDelegate.values != values;
}

class _EnvelopeCategoryCard extends StatelessWidget {
  const _EnvelopeCategoryCard({
    required this.group,
    required this.snapshot,
    required this.onTap,
  });

  final _CategoryGroup group;
  final SpendingSnapshot snapshot;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final pool =
        group.income ? snapshot.incoming : snapshot.outgoing;
    final progress =
        pool <= 0 ? 0.0 : (group.amount / pool).clamp(0.0, 1.0);
    final pct = (progress * 100).round();
    final tone = FlowaCategoryColors.forCategory(group.name);
    final goalLabel = group.income
        ? '$pct% de tus entradas · ${group.count} movs'
        : '$pct% del gasto del mes · ${group.count} movs';

    return FlowaPressScale(
      onTap: onTap,
      scale: 0.985,
      haptic: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 16),
        decoration: BoxDecoration(
          color: FlowaColors.inkHigh,
          borderRadius: FlowaRadii.xlAll,
          boxShadow: FlowaShadows.soft,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned(
                  top: 0,
                  right: 0,
                  child: FlowaLucideIcon(
                    LucideIcons.arrow_up_right,
                    size: 15,
                    color: FlowaColors.boneGhost,
                  ),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: tone.orbBackground,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: FlowaLucideIcon(
                        categoryLucideIcon(group.name),
                        size: 22,
                        color: tone.icon,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Text(
                                  group.name,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: FlowaType.titleSm(),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                FlowaFormatters.currency(group.amount),
                                style: FlowaType.titleMd(),
                              ),
                            ],
                          ),
                          const SizedBox(height: 5),
                          Text(goalLabel, style: FlowaType.bodySm()),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 14),
            ClipRRect(
              borderRadius: FlowaRadii.pillAll,
              child: SizedBox(
                height: 4,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    const ColoredBox(color: FlowaColors.inkPressed),
                    FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: progress,
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [tone.progressStart, tone.progressEnd],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InsightBanner extends StatelessWidget {
  const _InsightBanner({required this.snapshot});

  final SpendingSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final delta = snapshot.outgoingDeltaPct;
    late final String message;
    if (snapshot.isPositive && snapshot.net > 0) {
      message = '¡Bien! Tu balance neto este mes es positivo.';
    } else if (delta != null && delta < 0) {
      message =
          'Gastas un ${delta.abs().toStringAsFixed(0)}% menos que el mes pasado.';
    } else if (delta != null && delta > 0) {
      message =
          'Has gastado un ${delta.toStringAsFixed(0)}% más que el mes anterior.';
    } else {
      message =
          'Llevas ${snapshot.transactionCount} movimientos registrados este mes.';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: FlowaColors.inkHigh,
        borderRadius: FlowaRadii.xlAll,
        boxShadow: FlowaShadows.soft,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: FlowaColors.inkPressed,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: const FlowaLucideIcon(
              LucideIcons.check,
              size: 16,
              color: FlowaColors.boneMuted,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: FlowaType.bodySm(color: FlowaColors.boneMuted),
            ),
          ),
        ],
      ),
    );
  }
}

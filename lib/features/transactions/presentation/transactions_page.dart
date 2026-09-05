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
import '../../../design_system/components/flowa_transaction_tile.dart';
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
import 'month_transactions_page.dart';
import 'transaction_detail_page.dart';

/// Movimientos — extracto del mes: resumen + últimos 6 + ver todos.
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
    final filtered = TransactionFilters.apply(
      items: _all,
      filter: TransactionFilter.all,
      month: _month,
    );
    _visible = List<TransactionItem>.from(filtered)
      ..sort((a, b) => b.occurredAt.compareTo(a.occurredAt));
  }

  List<TransactionItem> get _preview =>
      _visible.take(6).toList(growable: false);

  SpendingSnapshot _snapshot() {
    return SpendingInsights.from(
      _all,
      month: _month,
      range: InsightRange.month,
    );
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

  void _openAllForMonth() {
    pushFlowaRoute<void>(
      context,
      MonthTransactionsPage(month: _month, items: _visible),
    );
  }

  @override
  Widget build(BuildContext context) {
    final monthLabel = DateFormat('MMM yyyy', 'es_ES').format(_month);
    final snapshot = _snapshot();
    final sparkValues = snapshot.bars.map((b) => b.amount).toList();
    final preview = _preview;

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
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Últimos movimientos',
                        style: FlowaType.titleSm(),
                      ),
                    ),
                    FlowaPressScale(
                      onTap: _openAllForMonth,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 6,
                        ),
                        child: Text(
                          'Ver todos',
                          style: FlowaType.micro(color: FlowaColors.mint),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: FlowaSpacing.md),
                if (preview.isEmpty)
                  const FlowaEmptyState(
                    title: 'Sin movimientos',
                    message: 'No hay movimientos en este mes.',
                    glyph: FlowaGlyph.transfer,
                  )
                else
                  FlowaEntrance(
                    child: Container(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                      decoration: const BoxDecoration(
                        color: FlowaColors.inkHigh,
                        borderRadius: FlowaRadii.xxlAll,
                      ),
                      child: Column(
                        children: [
                          for (final item in preview)
                            FlowaTransactionTile(
                              item: item,
                              onTap: () => _openDetail(item),
                            ),
                        ],
                      ),
                    ),
                  ),
                if (preview.isNotEmpty) ...[
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
          data.length == 1
              ? size.width / 2
              : (i / (data.length - 1)) * size.width,
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
          Offset.zero,
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
        border: Border.all(color: FlowaColors.hairlineStrong),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: const BoxDecoration(
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

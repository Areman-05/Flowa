import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../design_system/components/flowa_actions.dart';
import '../../../design_system/components/flowa_icon.dart';
import '../../../design_system/components/flowa_primitives.dart';
import '../../../design_system/components/flowa_texture.dart';
import '../../../design_system/components/flowa_transaction_tile.dart';
import '../../../design_system/tokens/flowa_colors.dart';
import '../../../design_system/tokens/flowa_spacing.dart';
import '../../../design_system/tokens/flowa_typography.dart';
import '../../../domain/entities/finance_entities.dart';
import '../../../shared/navigation/flowa_routes.dart';
import '../../../shared/widgets/flowa_states.dart';
import '../domain/transaction_filters.dart';
import 'transaction_detail_page.dart';

/// Lista completa del mes — orden cronológico + búsqueda.
class MonthTransactionsPage extends StatefulWidget {
  const MonthTransactionsPage({
    required this.month,
    required this.items,
    super.key,
  });

  final DateTime month;
  final List<TransactionItem> items;

  @override
  State<MonthTransactionsPage> createState() => _MonthTransactionsPageState();
}

class _MonthTransactionsPageState extends State<MonthTransactionsPage> {
  final _query = TextEditingController();
  bool _searching = false;

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  List<TransactionItem> get _filtered {
    final list = TransactionFilters.apply(
      items: widget.items,
      filter: TransactionFilter.all,
      query: _query.text,
    ).toList(growable: false);
    return List<TransactionItem>.from(list)
      ..sort((a, b) => b.occurredAt.compareTo(a.occurredAt));
  }

  @override
  Widget build(BuildContext context) {
    final monthLabel = DateFormat('MMMM yyyy', 'es_ES').format(widget.month);
    final visible = _filtered;

    return Scaffold(
      backgroundColor: FlowaColors.ink,
      body: FlowaCanvas(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  FlowaSpacing.gutter,
                  FlowaSpacing.sm,
                  FlowaSpacing.gutter,
                  FlowaSpacing.md,
                ),
                child: Row(
                  children: [
                    FlowaIconAction(
                      glyph: FlowaGlyph.arrowLeft,
                      tooltip: 'Volver',
                      onTap: () => Navigator.of(context).maybePop(),
                    ),
                    const SizedBox(width: FlowaSpacing.sm),
                    Expanded(
                      child: _searching
                          ? TextField(
                              controller: _query,
                              autofocus: true,
                              style: FlowaType.body(color: FlowaColors.bone),
                              cursorColor: FlowaColors.mint,
                              decoration: InputDecoration(
                                hintText: 'Buscar movimiento',
                                hintStyle: FlowaType.body(
                                  color: FlowaColors.boneFaint,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                              ),
                              onChanged: (_) => setState(() {}),
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Todos los movimientos',
                                  style: FlowaType.titleLg(),
                                ),
                                Text(
                                  monthLabel,
                                  style: FlowaType.micro(
                                    color: FlowaColors.boneMuted,
                                  ),
                                ),
                              ],
                            ),
                    ),
                    FlowaIconAction(
                      glyph: FlowaGlyph.search,
                      tooltip: _searching ? 'Cerrar búsqueda' : 'Buscar',
                      onTap: () {
                        setState(() {
                          _searching = !_searching;
                          if (!_searching) {
                            _query.clear();
                          }
                        });
                      },
                    ),
                  ],
                ),
              ),
              Expanded(
                child: visible.isEmpty
                    ? const FlowaEmptyState(
                        title: 'Sin resultados',
                        message: 'No hay movimientos con ese criterio.',
                        glyph: FlowaGlyph.transfer,
                      )
                    : ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(
                          FlowaSpacing.gutter,
                          0,
                          FlowaSpacing.gutter,
                          FlowaSpacing.xl,
                        ),
                        itemCount: visible.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: FlowaSpacing.xs),
                        itemBuilder: (context, index) {
                          final item = visible[index];
                          return FlowaEntrance(
                            delay: Duration(
                              milliseconds: index.clamp(0, 8) * 24,
                            ),
                            child: Container(
                              decoration: const BoxDecoration(
                                color: FlowaColors.inkHigh,
                                borderRadius: FlowaRadii.lgAll,
                              ),
                              child: FlowaTransactionTile(
                                item: item,
                                orbBackground: FlowaColors.ink,
                                onTap: () => pushFlowaRoute<void>(
                                  context,
                                  TransactionDetailPage(item: item),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/utils/debouncer.dart';
import '../../../core/utils/flowa_formatters.dart';
import '../../../core/utils/flowa_services.dart';
import '../../../core/utils/transaction_export.dart';
import '../../../design_system/components/flowa_actions.dart';
import '../../../design_system/components/flowa_icon.dart';
import '../../../design_system/components/flowa_screen.dart';
import '../../../design_system/components/flowa_transaction_tile.dart';
import '../../../design_system/tokens/flowa_colors.dart';
import '../../../design_system/tokens/flowa_spacing.dart';
import '../../../design_system/tokens/flowa_typography.dart';
import '../../../domain/entities/finance_entities.dart';
import '../../../shared/navigation/flowa_routes.dart';
import '../../../shared/widgets/flowa_states.dart';
import '../domain/transaction_filters.dart';
import 'transaction_detail_page.dart';
import 'transaction_filter_bar.dart';

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
  TransactionFilter _filter = TransactionFilter.all;
  String _query = '';
  final _debouncer = Debouncer();
  final _search = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _debouncer.dispose();
    _search.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final items = await FlowaServices.transactionRepository.getAll();
    if (!mounted) {
      return;
    }
    setState(() {
      _all = items;
      _loading = false;
      _apply();
    });
  }

  void _apply() {
    _visible = TransactionFilters.apply(
      items: _all,
      filter: _filter,
      query: _query,
    );
  }

  Future<void> _export() async {
    final csv = TransactionExport.toCsv(_visible);
    await Clipboard.setData(ClipboardData(text: csv));
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Exportados ${_visible.length} movimientos.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final outgoing = TransactionFilters.totalOutgoing(_visible);
    final incoming = TransactionFilters.totalIncoming(_visible);

    return FlowaScreen(
      title: 'Movimientos',
      embedded: widget.embedded,
      actions: [
        FlowaIconAction(
          glyph: FlowaGlyph.receipt,
          tooltip: 'Exportar',
          onTap: _visible.isEmpty ? null : _export,
        ),
      ],
      child: _loading
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
                padding: const EdgeInsets.only(bottom: FlowaSpacing.navClearance),
                children: [
                  TextField(
                    controller: _search,
                    onChanged: (value) {
                      _debouncer.run(() {
                        setState(() {
                          _query = value;
                          _apply();
                        });
                      });
                    },
                    style: FlowaType.body(color: FlowaColors.bone),
                    decoration: InputDecoration(
                      hintText: 'Buscar comercio o importe',
                      prefixIcon: const Padding(
                        padding: EdgeInsets.only(left: 12, right: 8),
                        child: FlowaIcon(
                          FlowaGlyph.search,
                          size: 18,
                          color: FlowaColors.boneFaint,
                        ),
                      ),
                      prefixIconConstraints: const BoxConstraints(
                        minWidth: 44,
                        minHeight: 44,
                      ),
                    ),
                  ),
                  const SizedBox(height: FlowaSpacing.md),
                  TransactionFilterBar(
                    value: _filter,
                    onChanged: (value) {
                      setState(() {
                        _filter = value;
                        _apply();
                      });
                    },
                  ),
                  const SizedBox(height: FlowaSpacing.md),
                  Text(
                    '${_visible.length} movs · '
                    'Sale ${FlowaFormatters.compact(outgoing)} · '
                    'Entra ${FlowaFormatters.compact(incoming)}',
                    style: FlowaType.bodySm(),
                  ),
                  const SizedBox(height: FlowaSpacing.sm),
                  if (_visible.isEmpty)
                    FlowaEmptyState(
                      title: 'Sin coincidencias',
                      message: _query.isEmpty
                          ? 'Prueba otro filtro para ver más movimientos.'
                          : 'Nada coincide con "$_query".',
                      glyph: FlowaGlyph.search,
                    )
                  else
                    FlowaGroupedTransactionList(
                      items: _visible,
                      onItemTap: (item) {
                        pushFlowaRoute<void>(
                          context,
                          TransactionDetailPage(item: item),
                        );
                      },
                    ),
                ],
              ),
            ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/utils/debouncer.dart';
import '../../../core/utils/flowa_formatters.dart';
import '../../../core/utils/flowa_services.dart';
import '../../../core/utils/transaction_export.dart';
import '../../../design_system/components/flowa_transaction_tile.dart';
import '../../../design_system/tokens/flowa_spacing.dart';
import '../../../domain/entities/finance_entities.dart';
import '../../../shared/navigation/flowa_routes.dart';
import '../../../shared/widgets/flowa_states.dart';
import '../domain/transaction_filters.dart';
import 'transaction_detail_page.dart';
import 'transaction_filter_bar.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

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

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _debouncer.dispose();
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

  Future<void> _exportPdf() async {
    final text = TransactionExport.toPdfPlaceholder(_visible);
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Statement copied. PDF generation coming soon.'),
      ),
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
        content: Text('Exported ${_visible.length} movements to clipboard.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final outgoing = TransactionFilters.totalOutgoing(_visible);
    final incoming = TransactionFilters.totalIncoming(_visible);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Transactions'),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.download_outlined),
            enabled: _visible.isNotEmpty,
            onSelected: (value) {
              if (value == 'csv') {
                _export();
              } else if (value == 'pdf') {
                _exportPdf();
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(value: 'csv', child: Text('Copy as CSV')),
              PopupMenuItem(value: 'pdf', child: Text('Export statement')),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _load,
                child: ListView(
                  padding: FlowaSpacing.screenPadding,
                  children: [
                    TextField(
                      onChanged: (value) {
                        _debouncer.run(() {
                          setState(() {
                            _query = value;
                            _apply();
                          });
                        });
                      },
                      decoration: const InputDecoration(
                        hintText: 'Search merchant, category, or amount',
                        prefixIcon: Icon(Icons.search),
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
                      '${_visible.length} movements · '
                      'Out ${FlowaFormatters.currency(outgoing)} · '
                      'In ${FlowaFormatters.currency(incoming)}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: FlowaSpacing.md),
                    if (_visible.isEmpty)
                      FlowaEmptyState(
                        title: 'No matches',
                        message: _query.isEmpty
                            ? 'Try another filter to see more movements.'
                            : 'Nothing matched "$_query". Try another merchant or amount.',
                        icon: Icons.search_off_outlined,
                      )
                    else
                      FlowaTransactionList(
                        items: _visible,
                        physics: const NeverScrollableScrollPhysics(),
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
      ),
    );
  }
}

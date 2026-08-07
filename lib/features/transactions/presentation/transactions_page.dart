import 'package:flutter/material.dart';

import '../../../core/utils/flowa_services.dart';
import '../../../design_system/components/flowa_transaction_tile.dart';
import '../../../design_system/tokens/flowa_spacing.dart';
import '../../../domain/entities/finance_entities.dart';

class TransactionsPage extends StatefulWidget {
  const TransactionsPage({super.key});

  @override
  State<TransactionsPage> createState() => _TransactionsPageState();
}

class _TransactionsPageState extends State<TransactionsPage> {
  List<TransactionItem> _items = const [];
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
      _items = items;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Transactions')),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _load,
                child: ListView(
                  padding: FlowaSpacing.screenPadding,
                  children: [
                    Text(
                      '${_items.length} movements',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: FlowaSpacing.md),
                    FlowaTransactionList(
                      items: _items,
                      physics: const NeverScrollableScrollPhysics(),
                    ),
                  ],
                ),
              ),
      ),
    );
  }
}

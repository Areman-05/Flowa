import 'package:flutter/material.dart';

import '../../../design_system/components/flowa_actions.dart';
import '../domain/transaction_filters.dart';

class TransactionFilterBar extends StatelessWidget {
  const TransactionFilterBar({
    required this.value,
    required this.onChanged,
    super.key,
  });

  final TransactionFilter value;
  final ValueChanged<TransactionFilter> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final filter in TransactionFilter.values) ...[
          FlowaFilterChip(
            label: _label(filter),
            selected: value == filter,
            onTap: () => onChanged(filter),
          ),
          if (filter != TransactionFilter.values.last) const SizedBox(width: 8),
        ],
      ],
    );
  }

  String _label(TransactionFilter filter) {
    return switch (filter) {
      TransactionFilter.all => 'Todos',
      TransactionFilter.income => 'Ingresos',
      TransactionFilter.expense => 'Gastos',
    };
  }
}

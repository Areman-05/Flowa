import 'package:flutter/material.dart';

import '../../../design_system/tokens/flowa_colors.dart';
import '../../../design_system/tokens/flowa_spacing.dart';
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
    return Wrap(
      spacing: FlowaSpacing.sm,
      children: [
        for (final filter in TransactionFilter.values)
          ChoiceChip(
            label: Text(_label(filter)),
            selected: value == filter,
            onSelected: (_) => onChanged(filter),
            selectedColor: FlowaColors.primarySoft,
            labelStyle: TextStyle(
              color: value == filter
                  ? FlowaColors.primary
                  : FlowaColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
            side: BorderSide(
              color:
                  value == filter ? FlowaColors.primary : FlowaColors.border,
            ),
            showCheckmark: false,
          ),
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

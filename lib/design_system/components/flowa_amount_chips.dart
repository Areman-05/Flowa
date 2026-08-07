import 'package:flutter/material.dart';

import '../tokens/flowa_colors.dart';
import '../tokens/flowa_spacing.dart';

/// Quick amount chips used in Top-Up and AI flows.
class FlowaAmountChips extends StatelessWidget {
  const FlowaAmountChips({
    required this.values,
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final List<double> values;
  final double? selected;
  final ValueChanged<double> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: FlowaSpacing.sm,
      runSpacing: FlowaSpacing.sm,
      children: [
        for (final value in values)
          ChoiceChip(
            label: Text('\$${value.toStringAsFixed(0)}'),
            selected: selected == value,
            onSelected: (_) => onSelected(value),
            selectedColor: FlowaColors.primarySoft,
            labelStyle: TextStyle(
              color: selected == value
                  ? FlowaColors.primary
                  : FlowaColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
            side: BorderSide(
              color: selected == value
                  ? FlowaColors.primary
                  : FlowaColors.border,
            ),
            backgroundColor: FlowaColors.surface,
            showCheckmark: false,
          ),
      ],
    );
  }
}

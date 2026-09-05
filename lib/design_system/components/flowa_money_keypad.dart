import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../tokens/flowa_colors.dart';
import '../tokens/flowa_spacing.dart';
import '../tokens/flowa_typography.dart';
import 'flowa_actions.dart';

/// Numeric money keypad — digits + clear delete. Shared by Ingresar / Enviar.
class FlowaMoneyKeypad extends StatelessWidget {
  const FlowaMoneyKeypad({required this.onKey, super.key});

  /// Digit `0`–`9`, or `<` for backspace.
  final ValueChanged<String> onKey;

  static const _keys = [
    ['1', '2', '3'],
    ['4', '5', '6'],
    ['7', '8', '9'],
    ['', '0', '<'],
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final row in _keys)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (final key in row) _KeySlot(label: key, onKey: onKey),
              ],
            ),
          ),
      ],
    );
  }
}

class _KeySlot extends StatelessWidget {
  const _KeySlot({required this.label, required this.onKey});

  final String label;
  final ValueChanged<String> onKey;

  @override
  Widget build(BuildContext context) {
    const size = Size(76, 56);

    if (label.isEmpty) {
      return SizedBox(width: size.width, height: size.height);
    }

    final isDelete = label == '<';

    return SizedBox(
      width: size.width,
      height: size.height,
      child: FlowaPressScale(
        onTap: () => onKey(label),
        scale: 0.94,
        haptic: false,
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isDelete ? FlowaColors.dangerSurface : FlowaColors.inkHigh,
            borderRadius: FlowaRadii.xlAll,
            border: Border.all(
              color: isDelete
                  ? FlowaColors.danger.withValues(alpha: 0.35)
                  : FlowaColors.hairline,
            ),
          ),
          child: isDelete
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      LucideIcons.delete,
                      size: 22,
                      color: FlowaColors.danger,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Borrar',
                      style: FlowaType.micro(color: FlowaColors.danger),
                    ),
                  ],
                )
              : Text(label, style: FlowaType.titleLg()),
        ),
      ),
    );
  }
}

/// Quick amount pills for money flows.
class FlowaQuickAmounts extends StatelessWidget {
  const FlowaQuickAmounts({
    required this.values,
    required this.onSelected,
    super.key,
    this.activeCents,
  });

  final List<int> values;
  final ValueChanged<int> onSelected;

  /// Current amount in cents — highlights matching chip.
  final int? activeCents;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < values.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(
            child: FlowaPressScale(
              onTap: () => onSelected(values[i]),
              scale: 0.96,
              child: Container(
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: activeCents == values[i] * 100
                      ? FlowaColors.mint
                      : FlowaColors.inkHigh,
                  borderRadius: FlowaRadii.pillAll,
                ),
                child: Text(
                  '${values[i]} €',
                  style: FlowaType.label(
                    color: activeCents == values[i] * 100
                        ? FlowaColors.mintInk
                        : FlowaColors.bone,
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

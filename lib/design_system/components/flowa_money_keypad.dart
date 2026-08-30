import 'package:flutter/material.dart';

import '../tokens/flowa_colors.dart';
import '../tokens/flowa_spacing.dart';
import '../tokens/flowa_typography.dart';
import 'flowa_actions.dart';
import 'flowa_icon.dart';

/// Circular money keypad shared by Ingresar / Enviar.
class FlowaMoneyKeypad extends StatelessWidget {
  const FlowaMoneyKeypad({required this.onKey, super.key});

  /// Digit, `00`, or `<` for backspace.
  final ValueChanged<String> onKey;

  static const _keys = [
    ['1', '2', '3'],
    ['4', '5', '6'],
    ['7', '8', '9'],
    ['00', '0', '<'],
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
                for (final key in row)
                  SizedBox(
                    width: 72,
                    height: 56,
                    child: FlowaPressScale(
                      onTap: () => onKey(key),
                      scale: 0.94,
                      haptic: false,
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: key == '<'
                              ? Colors.transparent
                              : FlowaColors.inkHigh,
                          shape: BoxShape.circle,
                        ),
                        child: key == '<'
                            ? const FlowaIcon(
                                FlowaGlyph.arrowLeft,
                                size: 20,
                                color: FlowaColors.boneMuted,
                              )
                            : Text(key, style: FlowaType.titleLg()),
                      ),
                    ),
                  ),
              ],
            ),
          ),
      ],
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

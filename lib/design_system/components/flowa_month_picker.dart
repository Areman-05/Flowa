import 'package:flutter/material.dart';

import '../tokens/flowa_colors.dart';
import '../tokens/flowa_spacing.dart';
import '../tokens/flowa_typography.dart';
import 'flowa_actions.dart';
import 'flowa_glass.dart';
import 'flowa_icon.dart';

/// Glass sheet month picker — same UX as Análisis.
class FlowaMonthCalendarPicker extends StatefulWidget {
  const FlowaMonthCalendarPicker({required this.selected, super.key});

  final DateTime selected;

  @override
  State<FlowaMonthCalendarPicker> createState() =>
      _FlowaMonthCalendarPickerState();
}

class _FlowaMonthCalendarPickerState extends State<FlowaMonthCalendarPicker> {
  static const _months = [
    'Ene',
    'Feb',
    'Mar',
    'Abr',
    'May',
    'Jun',
    'Jul',
    'Ago',
    'Sep',
    'Oct',
    'Nov',
    'Dic',
  ];

  late int _year;

  @override
  void initState() {
    super.initState();
    _year = widget.selected.year;
  }

  bool _isFuture(int month) {
    final now = DateTime.now();
    if (_year > now.year) {
      return true;
    }
    if (_year == now.year && month > now.month) {
      return true;
    }
    return false;
  }

  bool _isSelected(int month) {
    return widget.selected.year == _year && widget.selected.month == month;
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 4),
          Text('Periodo', style: FlowaType.titleLg()),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _YearNavButton(
                icon: FlowaGlyph.arrowLeft,
                enabled: _year > now.year - 5,
                onTap: () => setState(() => _year--),
              ),
              const SizedBox(width: 20),
              Text('$_year', style: FlowaType.titleLg()),
              const SizedBox(width: 20),
              _YearNavButton(
                icon: FlowaGlyph.arrowRight,
                enabled: _year < now.year,
                onTap: () => setState(() => _year++),
              ),
            ],
          ),
          const SizedBox(height: 20),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 12,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              childAspectRatio: 1.55,
            ),
            itemBuilder: (context, index) {
              final month = index + 1;
              final future = _isFuture(month);
              final selected = _isSelected(month);

              return FlowaPressScale(
                onTap: future
                    ? null
                    : () => Navigator.pop(
                          context,
                          DateTime(_year, month),
                        ),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: selected
                        ? FlowaColors.mint
                        : future
                            ? FlowaColors.ink
                            : FlowaColors.inkPressed,
                    borderRadius: FlowaRadii.lgAll,
                  ),
                  child: Text(
                    _months[index],
                    style: FlowaType.label(
                      color: selected
                          ? FlowaColors.mintInk
                          : future
                              ? FlowaColors.boneGhost
                              : FlowaColors.bone,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _YearNavButton extends StatelessWidget {
  const _YearNavButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final FlowaGlyph icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FlowaPressScale(
      onTap: enabled ? onTap : null,
      child: Container(
        width: 44,
        height: 44,
        decoration: const BoxDecoration(
          color: FlowaColors.ink,
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: FlowaIcon(
          icon,
          size: 18,
          color: enabled ? FlowaColors.bone : FlowaColors.boneGhost,
        ),
      ),
    );
  }
}

Future<DateTime?> showFlowaMonthPicker(
  BuildContext context, {
  required DateTime selected,
}) {
  return showFlowaGlassSheet<DateTime>(
    context: context,
    builder: (context) => FlowaMonthCalendarPicker(selected: selected),
  );
}

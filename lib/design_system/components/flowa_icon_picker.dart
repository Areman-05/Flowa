import 'package:flutter/material.dart';

import '../tokens/flowa_colors.dart';
import '../tokens/flowa_spacing.dart';

class SubAccountIconOption {
  const SubAccountIconOption({
    required this.key,
    required this.icon,
    required this.label,
  });

  final String key;
  final IconData icon;
  final String label;
}

/// Horizontal icon picker for sub-account categorization.
class FlowaIconPicker extends StatelessWidget {
  const FlowaIconPicker({
    required this.options,
    required this.selectedKey,
    required this.onSelected,
    super.key,
  });

  static const List<SubAccountIconOption> defaults = [
    SubAccountIconOption(
      key: 'briefcase',
      icon: Icons.work_outline_rounded,
      label: 'Business',
    ),
    SubAccountIconOption(
      key: 'home',
      icon: Icons.home_outlined,
      label: 'Home',
    ),
    SubAccountIconOption(
      key: 'family',
      icon: Icons.family_restroom_outlined,
      label: 'Family',
    ),
    SubAccountIconOption(
      key: 'plane',
      icon: Icons.flight_outlined,
      label: 'Travel',
    ),
    SubAccountIconOption(
      key: 'gift',
      icon: Icons.card_giftcard_outlined,
      label: 'Gift',
    ),
    SubAccountIconOption(
      key: 'school',
      icon: Icons.school_outlined,
      label: 'Education',
    ),
  ];

  final List<SubAccountIconOption> options;
  final String selectedKey;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 72,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: options.length,
        separatorBuilder: (_, _) => const SizedBox(width: FlowaSpacing.sm),
        itemBuilder: (context, index) {
          final option = options[index];
          final selected = option.key == selectedKey;
          return InkWell(
            onTap: () => onSelected(option.key),
            borderRadius: FlowaRadii.mdAll,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 56,
              height: 56,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected
                    ? FlowaColors.primarySoft
                    : FlowaColors.surfaceMuted,
                borderRadius: FlowaRadii.mdAll,
                border: Border.all(
                  color: selected ? FlowaColors.primary : FlowaColors.border,
                  width: selected ? 2 : 1,
                ),
              ),
              child: Icon(
                option.icon,
                color: selected ? FlowaColors.primary : FlowaColors.textPrimary,
              ),
            ),
          );
        },
      ),
    );
  }
}

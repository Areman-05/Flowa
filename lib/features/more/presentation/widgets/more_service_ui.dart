import 'package:flutter/material.dart';

import '../../../../design_system/components/flowa_icon.dart';
import '../../../../design_system/tokens/flowa_colors.dart';
import '../../../../design_system/tokens/flowa_spacing.dart';
import '../../../../design_system/tokens/flowa_typography.dart';
import '../widgets/more_payment_ui.dart';

/// Cabecera introductoria para pantallas del hub Más.
class MoreServiceIntro extends StatelessWidget {
  const MoreServiceIntro({
    required this.icon,
    required this.title,
    required this.description,
    super.key,
    this.accent = FlowaColors.mint,
  });

  final IconData icon;
  final String title;
  final String description;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: FlowaColors.inkHigh,
        borderRadius: FlowaRadii.xxlAll,
        border: Border.all(color: FlowaColors.hairlineStrong),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: FlowaLucideIcon(icon, size: 28, color: accent),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: FlowaType.titleMd()),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: FlowaType.body(color: FlowaColors.boneMuted),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MoreSectionLabel extends StatelessWidget {
  const MoreSectionLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: FlowaSpacing.sm),
      child: Text(text, style: FlowaType.titleMd()),
    );
  }
}

class MoreServiceCard extends StatelessWidget {
  const MoreServiceCard({
    required this.child,
    super.key,
    this.padding = const EdgeInsets.all(18),
    this.selected = false,
    this.onTap,
  });

  final Widget child;
  final EdgeInsets padding;
  final bool selected;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: selected
            ? FlowaColors.mintTintedSurface
            : FlowaColors.inkHigh,
        borderRadius: FlowaRadii.xlAll,
        border: Border.all(
          color: selected
              ? FlowaColors.mint.withValues(alpha: 0.45)
              : FlowaColors.hairlineStrong,
        ),
        boxShadow: selected
            ? moreNeonGlow(FlowaColors.mint, intensity: 0.12)
            : null,
      ),
      child: child,
    );

    if (onTap == null) {
      return card;
    }

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: card,
    );
  }
}

/// Campo de formulario más grande y legible.
InputDecoration moreInputDecoration({
  required String label,
  String? hint,
  String? prefixText,
  IconData? prefixIcon,
}) {
  return InputDecoration(
    labelText: label,
    hintText: hint,
    prefixText: prefixText,
    prefixIcon: prefixIcon == null
        ? null
        : Icon(prefixIcon, size: 20, color: FlowaColors.boneMuted),
    filled: true,
    fillColor: FlowaColors.inkHigh,
    contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
    labelStyle: FlowaType.bodySm(),
    floatingLabelStyle: FlowaType.titleSm(color: FlowaColors.mint),
    border: OutlineInputBorder(
      borderRadius: FlowaRadii.xlAll,
      borderSide: const BorderSide(color: FlowaColors.hairlineStrong),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: FlowaRadii.xlAll,
      borderSide: const BorderSide(color: FlowaColors.hairlineStrong),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: FlowaRadii.xlAll,
      borderSide: const BorderSide(color: FlowaColors.mint),
    ),
  );
}

TextStyle get moreFieldStyle => FlowaType.titleSm(color: FlowaColors.bone);

class MoreSearchField extends StatelessWidget {
  const MoreSearchField({
    required this.controller,
    required this.hint,
    required this.onChanged,
    super.key,
  });

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: moreFieldStyle,
      onChanged: onChanged,
      textInputAction: TextInputAction.search,
      decoration: moreInputDecoration(
        label: 'Buscar',
        hint: hint,
        prefixIcon: Icons.search_rounded,
      ),
    );
  }
}

bool moreMatchesQuery(String query, Iterable<String> fields) {
  final needle = query.trim().toLowerCase();
  if (needle.isEmpty) {
    return true;
  }
  return fields.any((field) => field.toLowerCase().contains(needle));
}

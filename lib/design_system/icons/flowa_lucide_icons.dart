import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../tokens/flowa_colors.dart';

/// Flowa glyph keys — mapped to Lucide icons (lucide.dev).
enum FlowaGlyph {
  home,
  chart,
  transfer,
  card,
  person,
  arrowDown,
  arrowUp,
  arrowRight,
  arrowLeft,
  plus,
  bell,
  search,
  receipt,
  vault,
  more,
  eye,
  eyeOff,
  check,
  clock,
  lock,
  logout,
  settings,
  spark,
  pin,
  gift,
  grid,
}

/// Lucide (lucide.dev) — thin line icons aligned with Privat-style UI.
class FlowaLucideIcon extends StatelessWidget {
  const FlowaLucideIcon(
    this.icon, {
    super.key,
    this.size = 18,
    this.color = FlowaColors.bone,
  });

  final IconData icon;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Icon(icon, size: size, color: color);
  }
}

IconData glyphLucideIcon(FlowaGlyph glyph) {
  return switch (glyph) {
    FlowaGlyph.home => LucideIcons.house,
    FlowaGlyph.chart => LucideIcons.chart_line,
    FlowaGlyph.transfer => LucideIcons.arrow_left_right,
    FlowaGlyph.card => LucideIcons.credit_card,
    FlowaGlyph.person => LucideIcons.user,
    FlowaGlyph.arrowDown => LucideIcons.arrow_down,
    FlowaGlyph.arrowUp => LucideIcons.arrow_up,
    FlowaGlyph.arrowRight => LucideIcons.chevron_right,
    FlowaGlyph.arrowLeft => LucideIcons.chevron_left,
    FlowaGlyph.plus => LucideIcons.plus,
    FlowaGlyph.bell => LucideIcons.bell,
    FlowaGlyph.search => LucideIcons.search,
    FlowaGlyph.receipt => LucideIcons.receipt,
    FlowaGlyph.vault => LucideIcons.piggy_bank,
    FlowaGlyph.more => LucideIcons.ellipsis,
    FlowaGlyph.eye => LucideIcons.eye,
    FlowaGlyph.eyeOff => LucideIcons.eye_off,
    FlowaGlyph.check => LucideIcons.check,
    FlowaGlyph.clock => LucideIcons.clock,
    FlowaGlyph.lock => LucideIcons.lock,
    FlowaGlyph.logout => LucideIcons.log_out,
    FlowaGlyph.settings => LucideIcons.settings,
    FlowaGlyph.spark => LucideIcons.sparkles,
    FlowaGlyph.pin => LucideIcons.grip,
    FlowaGlyph.gift => LucideIcons.gift,
    FlowaGlyph.grid => LucideIcons.layout_grid,
  };
}

IconData categoryLucideIcon(String category) {
  final key = category.toLowerCase();
  if (key.contains('aliment') ||
      key.contains('comida') ||
      key.contains('restaur') ||
      key.contains('mercad')) {
    return LucideIcons.shopping_bag;
  }
  if (key.contains('transport') ||
      key.contains('renfe') ||
      key.contains('taxi') ||
      key.contains('uber')) {
    return LucideIcons.bus;
  }
  if (key.contains('viviend') || key.contains('alquiler')) {
    return LucideIcons.house;
  }
  if (key.contains('espacio') || key.contains('cowork')) {
    return LucideIcons.building_2;
  }
  if (key.contains('ocio') ||
      key.contains('cine') ||
      key.contains('café') ||
      key.contains('cafe') ||
      key.contains('filmin')) {
    return LucideIcons.clapperboard;
  }
  if (key.contains('software') ||
      key.contains('figma') ||
      key.contains('adobe')) {
    return LucideIcons.laptop_minimal;
  }
  if (key.contains('servic') || key.contains('gestor')) {
    return LucideIcons.briefcase_business;
  }
  if (key.contains('salud') || key.contains('seguro')) {
    return LucideIcons.heart_pulse;
  }
  if (key.contains('impuest') || key.contains('autónom')) {
    return LucideIcons.landmark;
  }
  if (key.contains('material') ||
      key.contains('amazon') ||
      key.contains('compr')) {
    return LucideIcons.package;
  }
  if (key.contains('ingreso') || key.contains('recarga')) {
    return LucideIcons.arrow_down_to_line;
  }
  if (key.contains('transfer')) {
    return LucideIcons.arrow_left_right;
  }
  return LucideIcons.circle_dollar_sign;
}

class FlowaLucideOrb extends StatelessWidget {
  const FlowaLucideOrb({
    required this.icon,
    super.key,
    this.size = 48,
    this.background = FlowaColors.inkSurface,
    this.foreground = FlowaColors.bone,
    this.borderColor,
  });

  final IconData icon;
  final double size;
  final Color background;
  final Color foreground;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: background,
        shape: BoxShape.circle,
        border: borderColor == null ? null : Border.all(color: borderColor!),
      ),
      alignment: Alignment.center,
      child: FlowaLucideIcon(
        icon,
        size: size * 0.46,
        color: foreground,
      ),
    );
  }
}

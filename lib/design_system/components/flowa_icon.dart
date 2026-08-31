import 'package:flutter/material.dart';

import '../icons/flowa_lucide_icons.dart';
import '../tokens/flowa_colors.dart';

export '../icons/flowa_lucide_icons.dart'
    show
        FlowaGlyph,
        FlowaLucideIcon,
        FlowaLucideOrb,
        categoryLucideIcon,
        glyphLucideIcon;

class FlowaIcon extends StatelessWidget {
  const FlowaIcon(
    this.glyph, {
    super.key,
    this.size = 26,
    this.color = FlowaColors.bone,
    this.strokeWidth,
  });

  final FlowaGlyph glyph;
  final double size;
  final Color color;
  final double? strokeWidth;

  @override
  Widget build(BuildContext context) {
    return FlowaLucideIcon(
      glyphLucideIcon(glyph),
      size: size,
      color: color,
    );
  }
}

class FlowaIconOrb extends StatelessWidget {
  const FlowaIconOrb({
    required this.glyph,
    super.key,
    this.size = 48,
    this.background = FlowaColors.inkSurface,
    this.foreground = FlowaColors.bone,
    this.borderColor,
  });

  final FlowaGlyph glyph;
  final double size;
  final Color background;
  final Color foreground;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return FlowaLucideOrb(
      icon: glyphLucideIcon(glyph),
      size: size,
      background: background,
      foreground: foreground,
      borderColor: borderColor,
    );
  }
}

class FlowaIconRotated extends StatelessWidget {
  const FlowaIconRotated({
    required this.glyph,
    required this.turns,
    super.key,
    this.size = 22,
    this.color = FlowaColors.bone,
  });

  final FlowaGlyph glyph;
  final double turns;
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: turns * 2 * 3.141592653589793,
      child: FlowaIcon(glyph, size: size, color: color),
    );
  }
}

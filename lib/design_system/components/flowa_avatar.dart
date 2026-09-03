import 'dart:io';

import 'package:flutter/material.dart';

import '../tokens/flowa_colors.dart';
import '../tokens/flowa_typography.dart';

/// Circular avatar from a local file, or the user’s initial on mint.
class FlowaAvatar extends StatelessWidget {
  const FlowaAvatar({
    required this.name,
    super.key,
    this.path,
    this.size = 64,
  });

  final String name;
  final String? path;
  final double size;

  String get _initial {
    final trimmed = name.trim();
    if (trimmed.isEmpty) {
      return 'F';
    }
    return trimmed[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final file = path == null || path!.isEmpty ? null : File(path!);
    final hasFile = file != null && file.existsSync();

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: FlowaColors.mint,
        shape: BoxShape.circle,
        image: hasFile
            ? DecorationImage(
                image: FileImage(file),
                fit: BoxFit.cover,
              )
            : null,
      ),
      alignment: Alignment.center,
      child: hasFile
          ? null
          : Text(
              _initial,
              style: FlowaType.titleMd(color: FlowaColors.mintInk).copyWith(
                fontSize: size * 0.38,
                fontWeight: FontWeight.w800,
              ),
            ),
    );
  }
}

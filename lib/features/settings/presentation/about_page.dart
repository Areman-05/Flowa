import 'package:flutter/material.dart';

import '../../../core/constants/flowa_constants.dart';
import '../../../design_system/components/flowa_icon.dart';
import '../../../design_system/components/flowa_primitives.dart';
import '../../../design_system/components/flowa_screen.dart';
import '../../../design_system/tokens/flowa_colors.dart';
import '../../../design_system/tokens/flowa_spacing.dart';
import '../../../design_system/tokens/flowa_typography.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return FlowaScreen(
      title: 'Acerca de',
      child: ListView(
        children: [
          const SizedBox(height: FlowaSpacing.xl),
          const Center(
            child: FlowaIconOrb(
              glyph: FlowaGlyph.card,
              size: 72,
              background: FlowaColors.mint,
              foreground: FlowaColors.mintInk,
            ),
          ),
          const SizedBox(height: FlowaSpacing.md),
          Text(
            FlowaConstants.appName,
            textAlign: TextAlign.center,
            style: FlowaType.editorialMd(),
          ),
          const SizedBox(height: FlowaSpacing.xs),
          Text(
            FlowaConstants.appTagline,
            textAlign: TextAlign.center,
            style: FlowaType.body(),
          ),
          const SizedBox(height: FlowaSpacing.xl),
          const FlowaLedgerRow(label: 'Versión', value: '1.0.0'),
          const FlowaLedgerRow(label: 'Build', value: 'portfolio-demo'),
          const FlowaLedgerRow(label: 'Plataforma', value: 'Flutter'),
          const FlowaLedgerRow(label: 'Licencia', value: 'MIT'),
          const SizedBox(height: FlowaSpacing.xl),
          Text(
            'Banco para quien factura. Tu dinero, claro y bajo control.',
            textAlign: TextAlign.center,
            style: FlowaType.bodySm(),
          ),
        ],
      ),
    );
  }
}

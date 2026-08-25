import 'package:flutter/material.dart';

import '../../../core/extensions/finance_labels.dart';
import '../../../design_system/components/flowa_icon.dart';
import '../../../design_system/components/flowa_primitives.dart';
import '../../../design_system/components/flowa_screen.dart';
import '../../../design_system/tokens/flowa_colors.dart';
import '../../../design_system/tokens/flowa_spacing.dart';
import '../../../design_system/tokens/flowa_typography.dart';
import '../../../domain/entities/finance_entities.dart';

class SubAccountDetailPage extends StatelessWidget {
  const SubAccountDetailPage({required this.account, super.key});

  final SubAccount account;

  @override
  Widget build(BuildContext context) {
    return FlowaScreen(
      title: account.name,
      child: ListView(
        children: [
          FlowaSurface(
            color: FlowaColors.mint,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const FlowaIcon(
                  FlowaGlyph.vault,
                  color: FlowaColors.mintInk,
                ),
                const SizedBox(height: FlowaSpacing.sm),
                Text(
                  account.accountNumber,
                  style: FlowaType.editorialMd(color: FlowaColors.mintInk),
                ),
                const SizedBox(height: FlowaSpacing.xs),
                Text(
                  'Número asignado para gestionarla aparte.',
                  style: FlowaType.bodySm(color: FlowaColors.mintInk),
                ),
              ],
            ),
          ),
          const SizedBox(height: FlowaSpacing.xl),
          FlowaLedgerRow(label: 'Uso', value: account.purpose.label),
          FlowaLedgerRow(label: 'Acceso', value: account.accessLevel.label),
          FlowaLedgerRow(
            label: 'Usuario vinculado',
            value: account.linkedEmail ?? 'Solo tú',
          ),
        ],
      ),
    );
  }
}

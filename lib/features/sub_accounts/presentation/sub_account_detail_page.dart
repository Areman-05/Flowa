import 'package:flutter/material.dart';

import '../../../core/extensions/finance_labels.dart';
import '../../../design_system/components/flowa_icon_picker.dart';
import '../../../design_system/tokens/flowa_colors.dart';
import '../../../design_system/tokens/flowa_spacing.dart';
import '../../../domain/entities/finance_entities.dart';

class SubAccountDetailPage extends StatelessWidget {
  const SubAccountDetailPage({required this.account, super.key});

  final SubAccount account;

  IconData get _icon {
    return FlowaIconPicker.defaults
        .firstWhere(
          (option) => option.key == account.iconKey,
          orElse: () => FlowaIconPicker.defaults.first,
        )
        .icon;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(account.name)),
      body: ListView(
        padding: FlowaSpacing.screenPadding,
        children: [
          Container(
            padding: FlowaSpacing.cardPadding,
            decoration: const BoxDecoration(
              gradient: FlowaColors.cardGreenGradient,
              borderRadius: FlowaRadii.lgAll,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(_icon, color: FlowaColors.textPrimary),
                const SizedBox(height: FlowaSpacing.sm),
                Text(
                  account.accountNumber,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: FlowaSpacing.xs),
                Text(
                  'Automatically assigned for easier management.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: FlowaSpacing.xl),
          _Row(label: 'Purpose', value: account.purpose.label),
          _Row(label: 'Access', value: account.accessLevel.label),
          _Row(label: 'Linked user', value: account.linkedEmail ?? 'Only you'),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: FlowaSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
        ],
      ),
    );
  }
}

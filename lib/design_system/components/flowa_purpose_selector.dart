import 'package:flutter/material.dart';

import '../../domain/entities/finance_entities.dart';
import '../tokens/flowa_colors.dart';
import '../tokens/flowa_spacing.dart';

/// Family / Business purpose cards for Create Sub-Account.
class FlowaPurposeSelector extends StatelessWidget {
  const FlowaPurposeSelector({
    required this.value,
    required this.onChanged,
    super.key,
  });

  final AccountKind value;
  final ValueChanged<AccountKind> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _PurposeCard(
            label: 'Family',
            icon: Icons.family_restroom_outlined,
            selected: value == AccountKind.family,
            onTap: () => onChanged(AccountKind.family),
          ),
        ),
        const SizedBox(width: FlowaSpacing.sm),
        Expanded(
          child: _PurposeCard(
            label: 'Business',
            icon: Icons.work_outline_rounded,
            selected: value == AccountKind.business,
            onTap: () => onChanged(AccountKind.business),
          ),
        ),
      ],
    );
  }
}

class _PurposeCard extends StatelessWidget {
  const _PurposeCard({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: FlowaColors.surface,
      borderRadius: FlowaRadii.mdAll,
      child: InkWell(
        onTap: onTap,
        borderRadius: FlowaRadii.mdAll,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(FlowaSpacing.md),
          decoration: BoxDecoration(
            borderRadius: FlowaRadii.mdAll,
            border: Border.all(
              color: selected ? FlowaColors.primary : FlowaColors.border,
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: selected ? FlowaColors.primary : FlowaColors.textSecondary,
              ),
              const SizedBox(height: FlowaSpacing.xs),
              Text(
                label,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: selected
                          ? FlowaColors.primary
                          : FlowaColors.textPrimary,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Limited / Full access radio-style options.
class FlowaAccessLevelSelector extends StatelessWidget {
  const FlowaAccessLevelSelector({
    required this.value,
    required this.onChanged,
    super.key,
  });

  final AccessLevel value;
  final ValueChanged<AccessLevel> onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _AccessTile(
          title: 'Limited Access',
          subtitle: 'Can view balances and request transfers only.',
          selected: value == AccessLevel.limited,
          onTap: () => onChanged(AccessLevel.limited),
        ),
        const SizedBox(height: FlowaSpacing.sm),
        _AccessTile(
          title: 'Full Access',
          subtitle: 'Can send, top-up, and manage linked wallets.',
          selected: value == AccessLevel.full,
          onTap: () => onChanged(AccessLevel.full),
        ),
      ],
    );
  }
}

class _AccessTile extends StatelessWidget {
  const _AccessTile({
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: FlowaColors.surface,
      borderRadius: FlowaRadii.mdAll,
      child: InkWell(
        onTap: onTap,
        borderRadius: FlowaRadii.mdAll,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(FlowaSpacing.md),
          decoration: BoxDecoration(
            borderRadius: FlowaRadii.mdAll,
            border: Border.all(
              color: selected ? FlowaColors.primary : FlowaColors.border,
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 4),
                    Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                  ],
                ),
              ),
              Icon(
                selected ? Icons.check_circle : Icons.circle_outlined,
                color: selected ? FlowaColors.primary : FlowaColors.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

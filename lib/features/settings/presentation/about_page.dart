import 'package:flutter/material.dart';

import '../../../core/constants/flowa_constants.dart';
import '../../../design_system/tokens/flowa_colors.dart';
import '../../../design_system/tokens/flowa_spacing.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: ListView(
        padding: FlowaSpacing.screenPadding,
        children: [
          const SizedBox(height: FlowaSpacing.xl),
          const Icon(
            Icons.account_balance_wallet_rounded,
            size: 64,
            color: FlowaColors.primary,
          ),
          const SizedBox(height: FlowaSpacing.md),
          Text(
            FlowaConstants.appName,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          const SizedBox(height: FlowaSpacing.xs),
          Text(
            FlowaConstants.appTagline,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: FlowaSpacing.xl),
          const _InfoRow(label: 'Version', value: '1.0.0'),
          const _InfoRow(label: 'Build', value: 'portfolio-demo'),
          const _InfoRow(label: 'Platform', value: 'Flutter'),
          const _InfoRow(label: 'License', value: 'MIT'),
          const SizedBox(height: FlowaSpacing.xl),
          Text(
            'Designed as a portfolio case study inspired by '
            '"Simplifying Finance" from Opedia Studio on Behance.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

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

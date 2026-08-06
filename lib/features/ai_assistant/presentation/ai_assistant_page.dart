import 'package:flutter/material.dart';

import '../../../design_system/tokens/flowa_colors.dart';
import '../../../design_system/tokens/flowa_spacing.dart';

class AiAssistantPage extends StatelessWidget {
  const AiAssistantPage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: Padding(
        padding: FlowaSpacing.screenPadding,
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.auto_awesome, size: 18),
                label: const Text('Start a New Chat'),
              ),
            ),
            const Spacer(),
            Icon(
              Icons.auto_awesome,
              size: 48,
              color: FlowaColors.primary.withValues(alpha: 0.9),
            ),
            const SizedBox(height: FlowaSpacing.md),
            Text(
              'What Can I Help You?',
              style: textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: FlowaSpacing.lg),
            const Wrap(
              spacing: FlowaSpacing.sm,
              runSpacing: FlowaSpacing.sm,
              alignment: WrapAlignment.center,
              children: [
                _AiChip(label: 'Send', icon: Icons.send_outlined),
                _AiChip(label: 'Receive', icon: Icons.call_received),
                _AiChip(label: 'Top-Up', icon: Icons.phone_android),
                _AiChip(label: 'Support', icon: Icons.support_agent),
                _AiChip(label: 'More', icon: Icons.more_horiz),
              ],
            ),
            const Spacer(),
            TextField(
              decoration: InputDecoration(
                hintText: 'Tell me what do you want',
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      onPressed: () {},
                      icon: const Icon(Icons.mic_none_rounded),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(right: FlowaSpacing.xs),
                      child: CircleAvatar(
                        backgroundColor: FlowaColors.primary,
                        child: IconButton(
                          onPressed: () {},
                          icon: const Icon(
                            Icons.send_rounded,
                            color: FlowaColors.textOnPrimary,
                            size: 18,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AiChip extends StatelessWidget {
  const _AiChip({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: FlowaColors.surface,
      borderRadius: FlowaRadii.mdAll,
      child: InkWell(
        onTap: () {},
        borderRadius: FlowaRadii.mdAll,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: FlowaSpacing.md,
            vertical: FlowaSpacing.sm,
          ),
          decoration: BoxDecoration(
            borderRadius: FlowaRadii.mdAll,
            border: Border.all(color: FlowaColors.border),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: FlowaColors.primary),
              const SizedBox(width: FlowaSpacing.xs),
              Text(label),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../core/constants/flowa_constants.dart';
import '../../../design_system/tokens/flowa_colors.dart';
import '../../../design_system/tokens/flowa_spacing.dart';
import '../../../shared/widgets/flowa_buttons.dart';

/// Home dashboard placeholder — card + quick actions come next.
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: ListView(
        padding: FlowaSpacing.screenPadding,
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 22,
                backgroundColor: FlowaColors.primarySoft,
                child: Icon(Icons.person, color: FlowaColors.primary),
              ),
              const SizedBox(width: FlowaSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Good Morning,', style: textTheme.bodyMedium),
                    Text('John Doe', style: textTheme.titleLarge),
                  ],
                ),
              ),
              IconButton.outlined(
                onPressed: () {},
                icon: const Badge(
                  smallSize: 8,
                  child: Icon(Icons.notifications_none_rounded),
                ),
              ),
            ],
          ),
          const SizedBox(height: FlowaSpacing.lg),
          Container(
            height: 180,
            decoration: const BoxDecoration(
              gradient: FlowaColors.cardPrimaryGradient,
              borderRadius: FlowaRadii.xlAll,
              boxShadow: FlowaShadows.card,
            ),
            padding: FlowaSpacing.cardPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Account Number',
                      style: textTheme.labelMedium?.copyWith(
                        color: FlowaColors.textOnCard.withValues(alpha: 0.85),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      'VISA',
                      style: textTheme.titleMedium?.copyWith(
                        color: FlowaColors.textOnCard,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: FlowaSpacing.xs),
                Text(
                  '**** **** **** 6457',
                  style: textTheme.titleMedium?.copyWith(
                    color: FlowaColors.textOnCard,
                  ),
                ),
                const Spacer(),
                Text(
                  'Available Balance',
                  style: textTheme.labelMedium?.copyWith(
                    color: FlowaColors.textOnCard.withValues(alpha: 0.85),
                  ),
                ),
                Row(
                  children: [
                    Text(
                      '******',
                      style: textTheme.headlineMedium?.copyWith(
                        color: FlowaColors.textOnCard,
                      ),
                    ),
                    const SizedBox(width: FlowaSpacing.xs),
                    Icon(
                      Icons.visibility_off_outlined,
                      size: 18,
                      color: FlowaColors.textOnCard.withValues(alpha: 0.9),
                    ),
                    const Spacer(),
                    Text(
                      '12/28 Expire Date',
                      style: textTheme.labelSmall?.copyWith(
                        color: FlowaColors.textOnCard.withValues(alpha: 0.9),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: FlowaSpacing.xl),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              FlowaQuickAction(
                label: 'Send',
                icon: Icons.account_balance_wallet_outlined,
                background: FlowaColors.actionSend,
                onTap: () {},
              ),
              FlowaQuickAction(
                label: 'Receive',
                icon: Icons.payments_outlined,
                background: FlowaColors.actionReceive,
                onTap: () {},
              ),
              FlowaQuickAction(
                label: 'Top-Up',
                icon: Icons.point_of_sale_outlined,
                background: FlowaColors.actionTopUp,
                onTap: () {},
              ),
              FlowaQuickAction(
                label: 'More',
                icon: Icons.grid_view_rounded,
                background: FlowaColors.actionMore,
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: FlowaSpacing.xl),
          Row(
            children: [
              Text('Recent Transaction', style: textTheme.titleMedium),
              const Spacer(),
              TextButton(
                onPressed: () {},
                child: const Text('See all >'),
              ),
            ],
          ),
          const SizedBox(height: FlowaSpacing.sm),
          Text(
            FlowaConstants.appTagline,
            style: textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

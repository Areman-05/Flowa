import 'package:flutter/material.dart';

import '../../design_system/tokens/flowa_colors.dart';
import '../../design_system/tokens/flowa_spacing.dart';
import '../../features/insights/presentation/insights_page.dart';
import '../../features/sub_accounts/presentation/sub_accounts_page.dart';
import '../../features/wallets/presentation/wallets_page.dart';
import '../navigation/flowa_routes.dart';

Future<void> showFlowaMoreActionsSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(FlowaRadii.xl)),
    ),
    builder: (context) {
      return SafeArea(
        child: Padding(
          padding: FlowaSpacing.screenPadding,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('More', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: FlowaSpacing.sm),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(
                    backgroundColor: FlowaColors.actionMore,
                    child: Icon(Icons.account_tree_outlined),
                  ),
                  title: const Text('Sub-Accounts'),
                  subtitle: const Text('Separate family and business money'),
                  onTap: () async {
                    Navigator.pop(context);
                    await pushFlowaRoute<void>(
                      context,
                      const SubAccountsPage(),
                    );
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(
                    backgroundColor: FlowaColors.primarySoft,
                    child: Icon(Icons.account_balance_wallet_outlined),
                  ),
                  title: const Text('Wallets'),
                  subtitle: const Text('Link PayPal and external wallets'),
                  onTap: () async {
                    Navigator.pop(context);
                    await pushFlowaRoute<void>(context, const WalletsPage());
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(
                    backgroundColor: FlowaColors.actionReceive,
                    child: Icon(Icons.insights_outlined),
                  ),
                  title: const Text('Insights'),
                  subtitle: const Text(
                    'See money in, money out, and top spend',
                  ),
                  onTap: () async {
                    Navigator.pop(context);
                    await pushFlowaRoute<void>(context, const InsightsPage());
                  },
                ),
                const SizedBox(height: FlowaSpacing.md),
              ],
            ),
          ),
        ),
      );
    },
  );
}

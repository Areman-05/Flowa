import 'package:flutter/material.dart';

import '../../design_system/tokens/flowa_colors.dart';
import '../../design_system/tokens/flowa_spacing.dart';
import '../../features/contacts/presentation/contacts_page.dart';
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
                Text('Más', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: FlowaSpacing.sm),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(
                    backgroundColor: FlowaColors.actionSend,
                    child: Icon(Icons.groups_outlined),
                  ),
                  title: const Text('Contactos'),
                  subtitle: const Text('Personas y empresas destinatarias'),
                  onTap: () async {
                    Navigator.pop(context);
                    await pushFlowaRoute<void>(context, const ContactsPage());
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(
                    backgroundColor: FlowaColors.actionMore,
                    child: Icon(Icons.account_tree_outlined),
                  ),
                  title: const Text('Subcuentas'),
                  subtitle: const Text('Separa dinero familiar y de empresa'),
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
                  title: const Text('Monederos'),
                  subtitle: const Text('Vincula PayPal y otros monederos'),
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
                  title: const Text('Resumen'),
                  subtitle: const Text(
                    'Entradas, salidas y principales gastos',
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

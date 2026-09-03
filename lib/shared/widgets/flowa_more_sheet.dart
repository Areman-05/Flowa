import 'package:flutter/material.dart';

import '../../design_system/components/flowa_glass.dart';
import '../../design_system/tokens/flowa_colors.dart';
import '../../design_system/tokens/flowa_spacing.dart';
import '../../features/contacts/presentation/contacts_page.dart';
import '../../features/insights/presentation/insights_page.dart';
import '../../features/sub_accounts/presentation/sub_accounts_page.dart';
import '../../features/wallets/presentation/wallets_page.dart';
import '../navigation/flowa_routes.dart';

Future<void> showFlowaMoreActionsSheet(BuildContext context) {
  return showFlowaGlassSheet<void>(
    context: context,
    builder: (context) {
      return SafeArea(
        top: false,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: FlowaSpacing.md),
                  decoration: BoxDecoration(
                    color: FlowaColors.border,
                    borderRadius: BorderRadius.circular(99),
                  ),
                ),
              ),
              Text('Más', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: FlowaSpacing.xs),
              Text(
                'Elige qué gestionar ahora.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: FlowaSpacing.md),
              _MoreRow(
                color: FlowaColors.actionSend,
                icon: Icons.groups_outlined,
                title: 'Contactos',
                subtitle: 'A quién envías',
                onTap: () async {
                  Navigator.pop(context);
                  await pushFlowaRoute<void>(context, const ContactsPage());
                },
              ),
              _MoreRow(
                color: FlowaColors.actionMore,
                icon: Icons.account_tree_outlined,
                title: 'Subcuentas',
                subtitle: 'Separar familiar y empresa',
                onTap: () async {
                  Navigator.pop(context);
                  await pushFlowaRoute<void>(
                    context,
                    const SubAccountsPage(),
                  );
                },
              ),
              _MoreRow(
                color: FlowaColors.primarySoft,
                icon: Icons.account_balance_wallet_outlined,
                title: 'Monederos',
                subtitle: 'PayPal y otros',
                onTap: () async {
                  Navigator.pop(context);
                  await pushFlowaRoute<void>(context, const WalletsPage());
                },
              ),
              _MoreRow(
                color: FlowaColors.actionReceive,
                icon: Icons.insights_outlined,
                title: 'Resumen',
                subtitle: 'Entradas, salidas, foco',
                onTap: () async {
                  Navigator.pop(context);
                  await pushFlowaRoute<void>(context, const InsightsPage());
                },
              ),
              const SizedBox(height: FlowaSpacing.sm),
            ],
          ),
        ),
      );
    },
  );
}

class _MoreRow extends StatelessWidget {
  const _MoreRow({
    required this.color,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final Color color;
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: CircleAvatar(
          backgroundColor: color,
          child: Icon(icon, color: FlowaColors.textPrimary),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        onTap: onTap,
      ),
    );
  }
}

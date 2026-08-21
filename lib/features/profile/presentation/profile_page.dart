import 'package:flutter/material.dart';

import '../../../core/constants/flowa_constants.dart';
import '../../../core/utils/flowa_services.dart';
import '../../../design_system/tokens/flowa_spacing.dart';
import '../../../domain/entities/finance_entities.dart';
import '../../../shared/navigation/flowa_routes.dart';
import '../../../shared/widgets/flowa_buttons.dart';
import '../../contacts/presentation/contacts_page.dart';
import 'profile_edit_page.dart';
import '../../notifications/presentation/notification_settings_page.dart';
import '../../settings/presentation/app_settings_page.dart';
import '../../sub_accounts/presentation/sub_accounts_page.dart';
import '../../support/presentation/support_center_page.dart';
import '../../wallets/presentation/wallets_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, this.onLogout});

  final Future<void> Function()? onLogout;

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  UserProfile? _user;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final user = await FlowaServices.accountRepository.getCurrentUser();
    if (!mounted) {
      return;
    }
    setState(() => _user = user);
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cerrar sesión'),
          content: const Text('¿Seguro que quieres salir de Flowa?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Salir'),
            ),
          ],
        );
      },
    );
    if (confirmed == true) {
      await widget.onLogout?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _user;

    return FlowaPage(
      title: 'Perfil',
      child: user == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.fullName,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: FlowaSpacing.xs),
                Text(
                  user.email ?? FlowaConstants.appName,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: FlowaSpacing.sm),
                FlowaSecondaryButton(
                  label: 'Editar perfil',
                  onPressed: () async {
                    final updated = await pushFlowaRoute<bool>(
                      context,
                      ProfileEditPage(user: user),
                    );
                    if (updated == true) {
                      await _load();
                    }
                  },
                ),
                const SizedBox(height: FlowaSpacing.xl),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.groups_outlined),
                  title: const Text('Contactos'),
                  subtitle: const Text('Personas y empresas'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    pushFlowaRoute<void>(context, const ContactsPage());
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.notifications_outlined),
                  title: const Text('Notificaciones'),
                  subtitle: const Text('Alertas útiles, silenciar promos'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    pushFlowaRoute<void>(
                      context,
                      const NotificationSettingsPage(),
                    );
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.account_tree_outlined),
                  title: const Text('Subcuentas'),
                  subtitle: const Text('Dinero familiar y de empresa'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    pushFlowaRoute<void>(context, const SubAccountsPage());
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.account_balance_wallet_outlined),
                  title: const Text('Monederos'),
                  subtitle: const Text('Vincula PayPal y cuentas externas'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    pushFlowaRoute<void>(context, const WalletsPage());
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.settings_outlined),
                  title: const Text('Ajustes'),
                  subtitle: const Text('Privacidad y bloqueo de la app'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    pushFlowaRoute<void>(context, const AppSettingsPage());
                  },
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.support_agent_outlined),
                  title: const Text('Soporte'),
                  subtitle: const Text('Ayuda si un pago falla'),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    pushFlowaRoute<void>(context, const SupportCenterPage());
                  },
                ),
                const Spacer(),
                FlowaSecondaryButton(
                  label: 'Cerrar sesión',
                  onPressed: widget.onLogout == null ? null : _logout,
                ),
              ],
            ),
    );
  }
}

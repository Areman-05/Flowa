import 'package:flutter/material.dart';

import '../../../core/constants/flowa_constants.dart';
import '../../../core/utils/flowa_services.dart';
import '../../../design_system/components/flowa_actions.dart';
import '../../../design_system/components/flowa_icon.dart';
import '../../../design_system/components/flowa_screen.dart';
import '../../../design_system/tokens/flowa_colors.dart';
import '../../../design_system/tokens/flowa_spacing.dart';
import '../../../design_system/tokens/flowa_typography.dart';
import '../../../domain/entities/finance_entities.dart';
import '../../../shared/navigation/flowa_routes.dart';
import '../../contacts/presentation/contacts_page.dart';
import '../../notifications/presentation/notification_settings_page.dart';
import '../../settings/presentation/app_settings_page.dart';
import '../../sub_accounts/presentation/sub_accounts_page.dart';
import '../../support/presentation/support_center_page.dart';
import '../../wallets/presentation/wallets_page.dart';
import 'profile_edit_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key, this.onLogout, this.embedded = false});

  final Future<void> Function()? onLogout;
  final bool embedded;

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
          backgroundColor: FlowaColors.inkHigh,
          title: Text('Cerrar sesión', style: FlowaType.titleMd()),
          content: Text(
            '¿Seguro que quieres salir de Flowa?',
            style: FlowaType.body(),
          ),
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

    return FlowaScreen(
      title: 'Perfil',
      embedded: widget.embedded,
      child: user == null
          ? const Center(
              child: CircularProgressIndicator(color: FlowaColors.mint),
            )
          : ListView(
              padding: const EdgeInsets.only(bottom: FlowaSpacing.navClearance),
              children: [
                const SizedBox(height: FlowaSpacing.sm),
                Center(
                  child: Container(
                    width: 84,
                    height: 84,
                    decoration: const BoxDecoration(
                      color: FlowaColors.mint,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      user.firstName.isEmpty
                          ? 'F'
                          : user.firstName[0].toUpperCase(),
                      style: FlowaType.editorialLg(color: FlowaColors.mintInk),
                    ),
                  ),
                ),
                const SizedBox(height: FlowaSpacing.md),
                Text(
                  user.fullName,
                  textAlign: TextAlign.center,
                  style: FlowaType.titleLg(),
                ),
                const SizedBox(height: 4),
                Text(
                  user.email ?? FlowaConstants.appName,
                  textAlign: TextAlign.center,
                  style: FlowaType.bodySm(),
                ),
                const SizedBox(height: FlowaSpacing.lg),
                FlowaGhostButton(
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
                FlowaMenuRow(
                  glyph: FlowaGlyph.person,
                  title: 'Contactos',
                  subtitle: 'Personas y empresas',
                  onTap: () =>
                      pushFlowaRoute<void>(context, const ContactsPage()),
                ),
                FlowaMenuRow(
                  glyph: FlowaGlyph.bell,
                  title: 'Notificaciones',
                  subtitle: 'Alertas útiles, silenciar promos',
                  onTap: () => pushFlowaRoute<void>(
                    context,
                    const NotificationSettingsPage(),
                  ),
                ),
                FlowaMenuRow(
                  glyph: FlowaGlyph.vault,
                  title: 'Subcuentas',
                  subtitle: 'Dinero familiar y de empresa',
                  onTap: () =>
                      pushFlowaRoute<void>(context, const SubAccountsPage()),
                ),
                FlowaMenuRow(
                  glyph: FlowaGlyph.card,
                  title: 'Monederos',
                  subtitle: 'Vincula PayPal y cuentas externas',
                  onTap: () =>
                      pushFlowaRoute<void>(context, const WalletsPage()),
                ),
                FlowaMenuRow(
                  glyph: FlowaGlyph.settings,
                  title: 'Ajustes',
                  subtitle: 'Privacidad y bloqueo de la app',
                  onTap: () =>
                      pushFlowaRoute<void>(context, const AppSettingsPage()),
                ),
                FlowaMenuRow(
                  glyph: FlowaGlyph.spark,
                  title: 'Soporte',
                  subtitle: 'Ayuda si un pago falla',
                  onTap: () =>
                      pushFlowaRoute<void>(context, const SupportCenterPage()),
                ),
                const SizedBox(height: FlowaSpacing.xl),
                FlowaGhostButton(
                  label: 'Cerrar sesión',
                  destructive: true,
                  onPressed: widget.onLogout == null ? null : _logout,
                ),
              ],
            ),
    );
  }
}

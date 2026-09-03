import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../../core/constants/flowa_constants.dart';
import '../../../core/utils/flowa_services.dart';
import '../../../design_system/components/flowa_actions.dart';
import '../../../design_system/components/flowa_avatar.dart';
import '../../../design_system/components/flowa_icon.dart';
import '../../../design_system/components/flowa_screen.dart';
import '../../../design_system/tokens/flowa_colors.dart';
import '../../../design_system/tokens/flowa_spacing.dart';
import '../../../design_system/tokens/flowa_typography.dart';
import '../../../domain/entities/finance_entities.dart';
import '../../../shared/navigation/flowa_routes.dart';
import '../../contacts/presentation/contacts_page.dart';
import '../../notifications/presentation/notification_settings_page.dart';
import '../../settings/presentation/about_page.dart';
import '../../settings/presentation/app_settings_page.dart';
import '../../support/presentation/support_center_page.dart';
import 'profile_details_page.dart';
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

  Future<void> _openDetails(UserProfile user) async {
    final updated = await pushFlowaRoute<bool>(
      context,
      ProfileDetailsPage(user: user),
    );
    if (updated == true) {
      await _load();
    }
  }

  Future<void> _openEdit(UserProfile user) async {
    final updated = await pushFlowaRoute<bool>(
      context,
      ProfileEditPage(user: user),
    );
    if (updated == true) {
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = _user;

    return FlowaScreen(
      title: 'Perfil',
      embedded: widget.embedded,
      actions: [
        FlowaIconAction(
          glyph: FlowaGlyph.settings,
          tooltip: 'Ajustes',
          onTap: () =>
              pushFlowaRoute<void>(context, const AppSettingsPage()),
        ),
      ],
      footer: widget.onLogout == null
          ? null
          : FlowaAcidButton(
              label: 'Cerrar sesión',
              glyph: FlowaGlyph.logout,
              onPressed: _logout,
            ),
      child: user == null
          ? const Center(
              child: CircularProgressIndicator(color: FlowaColors.mint),
            )
          : ListView(
              padding: const EdgeInsets.only(bottom: FlowaSpacing.md),
              children: [
                _ProfileHeaderCard(
                  user: user,
                  onOpen: () => _openDetails(user),
                ),
                const SizedBox(height: FlowaSpacing.md),
                _ProfileMenuCard(
                  icon: LucideIcons.user,
                  title: 'Información personal',
                  subtitle: 'Edita nombre, correo y contraseña',
                  onTap: () => _openEdit(user),
                ),
                const SizedBox(height: FlowaSpacing.sm),
                _ProfileMenuCard(
                  icon: LucideIcons.contact,
                  title: 'Contactos',
                  subtitle: 'Ver, buscar, añadir o eliminar',
                  onTap: () => pushFlowaRoute<void>(
                    context,
                    const ContactsPage(),
                  ),
                ),
                const SizedBox(height: FlowaSpacing.sm),
                _ProfileMenuCard(
                  icon: LucideIcons.shield,
                  title: 'Ajustes de seguridad',
                  subtitle: 'Controla tu seguridad',
                  onTap: () => pushFlowaRoute<void>(
                    context,
                    const AppSettingsPage(),
                  ),
                ),
                const SizedBox(height: FlowaSpacing.sm),
                _ProfileMenuCard(
                  icon: LucideIcons.bell,
                  title: 'Notificaciones',
                  subtitle: 'Gestiona tus avisos',
                  onTap: () => pushFlowaRoute<void>(
                    context,
                    const NotificationSettingsPage(),
                  ),
                ),
                const SizedBox(height: FlowaSpacing.sm),
                _ProfileMenuCard(
                  icon: LucideIcons.headset,
                  title: 'Centro de ayuda',
                  subtitle: 'Ayuda cuando lo necesites',
                  onTap: () => pushFlowaRoute<void>(
                    context,
                    const SupportCenterPage(),
                  ),
                ),
                const SizedBox(height: FlowaSpacing.sm),
                _ProfileMenuCard(
                  icon: LucideIcons.info,
                  title: 'Sobre Flowa',
                  subtitle: 'Conoce más sobre Flowa',
                  onTap: () =>
                      pushFlowaRoute<void>(context, const AboutPage()),
                ),
              ],
            ),
    );
  }
}

class _ProfileHeaderCard extends StatelessWidget {
  const _ProfileHeaderCard({required this.user, required this.onOpen});

  final UserProfile user;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    return FlowaPressScale(
      onTap: onOpen,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        decoration: BoxDecoration(
          color: FlowaColors.inkHigh,
          borderRadius: FlowaRadii.xxlAll,
          border: Border.all(color: FlowaColors.hairlineStrong),
        ),
        child: Row(
          children: [
            FlowaAvatar(
              name: user.fullName,
              path: user.avatarPath,
              size: 64,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(user.fullName, style: FlowaType.titleMd()),
                  const SizedBox(height: 4),
                  Text(
                    '@${user.handle}',
                    style: FlowaType.body(color: FlowaColors.mint),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    user.email ?? FlowaConstants.appName,
                    style: FlowaType.bodySm(color: FlowaColors.boneMuted),
                  ),
                ],
              ),
            ),
            const FlowaLucideIcon(
              LucideIcons.chevron_right,
              size: 22,
              color: FlowaColors.boneMuted,
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileMenuCard extends StatelessWidget {
  const _ProfileMenuCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FlowaPressScale(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: FlowaColors.inkHigh,
          borderRadius: FlowaRadii.xlAll,
          border: Border.all(color: FlowaColors.hairlineStrong),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: FlowaColors.inkSurface,
                borderRadius: FlowaRadii.lgAll,
              ),
              alignment: Alignment.center,
              child: FlowaLucideIcon(
                icon,
                size: 22,
                color: FlowaColors.bone,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: FlowaType.titleSm()),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: FlowaType.bodySm(color: FlowaColors.boneMuted),
                  ),
                ],
              ),
            ),
            const FlowaLucideIcon(
              LucideIcons.chevron_right,
              size: 20,
              color: FlowaColors.boneFaint,
            ),
          ],
        ),
      ),
    );
  }
}

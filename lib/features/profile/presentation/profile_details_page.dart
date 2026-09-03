import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/flowa_constants.dart';
import '../../../design_system/components/flowa_actions.dart';
import '../../../design_system/components/flowa_avatar.dart';
import '../../../design_system/components/flowa_icon.dart';
import '../../../design_system/components/flowa_screen.dart';
import '../../../design_system/tokens/flowa_colors.dart';
import '../../../design_system/tokens/flowa_spacing.dart';
import '../../../design_system/tokens/flowa_typography.dart';
import '../../../domain/entities/finance_entities.dart';
import '../../../shared/navigation/flowa_routes.dart';
import 'profile_edit_page.dart';

/// Read-only profile summary — distinct from the edit form.
class ProfileDetailsPage extends StatelessWidget {
  const ProfileDetailsPage({required this.user, super.key});

  final UserProfile user;

  @override
  Widget build(BuildContext context) {
    final birth = user.dateOfBirth == null
        ? 'No indicada'
        : DateFormat('d MMMM yyyy', 'es_ES').format(user.dateOfBirth!);

    return FlowaScreen(
      title: 'Mi perfil',
      footer: FlowaAcidButton(
        label: 'Editar información',
        onPressed: () async {
          final updated = await pushFlowaRoute<bool>(
            context,
            ProfileEditPage(user: user),
          );
          if (updated == true && context.mounted) {
            Navigator.of(context).pop(true);
          }
        },
      ),
      child: ListView(
        padding: const EdgeInsets.only(bottom: FlowaSpacing.xl),
        children: [
          Center(
            child: FlowaAvatar(
              name: user.fullName,
              path: user.avatarPath,
              size: 96,
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
            '@${user.handle}',
            textAlign: TextAlign.center,
            style: FlowaType.body(color: FlowaColors.mint),
          ),
          const SizedBox(height: FlowaSpacing.xl),
          _DetailRow(
            icon: LucideIcons.mail,
            label: 'Correo',
            value: user.email ?? FlowaConstants.appName,
          ),
          const SizedBox(height: FlowaSpacing.sm),
          _DetailRow(
            icon: LucideIcons.cake,
            label: 'Fecha de nacimiento',
            value: birth,
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: FlowaColors.inkHigh,
        borderRadius: FlowaRadii.xlAll,
        border: Border.all(color: FlowaColors.hairlineStrong),
      ),
      child: Row(
        children: [
          FlowaLucideIcon(icon, size: 20, color: FlowaColors.boneMuted),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: FlowaType.bodySm(color: FlowaColors.boneMuted),
                ),
                const SizedBox(height: 2),
                Text(value, style: FlowaType.titleSm()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

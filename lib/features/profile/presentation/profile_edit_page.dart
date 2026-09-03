import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import '../../../core/utils/flowa_password.dart';
import '../../../core/utils/flowa_services.dart';
import '../../../design_system/components/flowa_actions.dart';
import '../../../design_system/components/flowa_avatar.dart';
import '../../../design_system/components/flowa_fields.dart';
import '../../../design_system/components/flowa_icon.dart';
import '../../../design_system/components/flowa_screen.dart';
import '../../../design_system/tokens/flowa_colors.dart';
import '../../../design_system/tokens/flowa_spacing.dart';
import '../../../design_system/tokens/flowa_typography.dart';
import '../../../domain/entities/finance_entities.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../more/presentation/widgets/more_service_ui.dart';

class ProfileEditPage extends StatefulWidget {
  const ProfileEditPage({required this.user, super.key});

  final UserProfile user;

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  late final TextEditingController _nameController;
  late final TextEditingController _usernameController;
  late final TextEditingController _emailController;
  final _currentPassword = TextEditingController();
  final _newPassword = TextEditingController();
  final _confirmPassword = TextEditingController();

  DateTime? _birthDate;
  String? _avatarPath;
  String? _error;
  bool _saving = false;
  bool _obscureCurrent = true;
  bool _obscureNew = true;

  static final _usernamePattern = RegExp(r'^[a-zA-Z0-9._]{3,20}$');
  static final _emailPattern = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.fullName);
    _usernameController = TextEditingController(text: widget.user.handle);
    _emailController = TextEditingController(text: widget.user.email ?? '');
    _birthDate = widget.user.dateOfBirth;
    _avatarPath = widget.user.avatarPath;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _currentPassword.dispose();
    _newPassword.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  Future<void> _choosePhotoSource() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: FlowaColors.inkHigh,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Foto de perfil', style: FlowaType.titleMd()),
                const SizedBox(height: FlowaSpacing.md),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.photo_library_outlined,
                    color: FlowaColors.mint,
                  ),
                  title: Text('Galería', style: FlowaType.titleSm()),
                  onTap: () => Navigator.pop(context, ImageSource.gallery),
                ),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.photo_camera_outlined,
                    color: FlowaColors.mint,
                  ),
                  title: Text('Cámara', style: FlowaType.titleSm()),
                  onTap: () => Navigator.pop(context, ImageSource.camera),
                ),
              ],
            ),
          ),
        );
      },
    );
    if (source != null) {
      await _pickPhoto(source);
    }
  }

  Future<void> _pickPhoto(ImageSource source) async {
    try {
      final picked = await ImagePicker().pickImage(
        source: source,
        maxWidth: 1024,
        imageQuality: 85,
      );
      if (picked == null) {
        return;
      }
      final docs = await getApplicationDocumentsDirectory();
      final dest = File('${docs.path}/avatar_${widget.user.id}.jpg');
      await File(picked.path).copy(dest.path);
      if (!mounted) {
        return;
      }
      setState(() => _avatarPath = dest.path);
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() => _error = 'No se pudo actualizar la foto.');
    }
  }

  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final initial = _birthDate ?? DateTime(now.year - 25, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1920),
      lastDate: now,
      helpText: 'Fecha de nacimiento',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: FlowaColors.mint,
              onPrimary: FlowaColors.mintInk,
              surface: FlowaColors.inkHigh,
              onSurface: FlowaColors.bone,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _birthDate = picked);
    }
  }

  String? _validate() {
    final name = _nameController.text.trim();
    final username = _usernameController.text.trim();
    final email = _emailController.text.trim().toLowerCase();

    if (name.isEmpty) {
      return 'El nombre es obligatorio';
    }
    if (!_usernamePattern.hasMatch(username)) {
      return 'Usuario: 3–20 caracteres (letras, números, punto o _)';
    }
    if (!_emailPattern.hasMatch(email)) {
      return 'Introduce un email válido';
    }
    if (_birthDate == null) {
      return 'Indica tu fecha de nacimiento';
    }
    final sixteen = DateTime(
      DateTime.now().year - 16,
      DateTime.now().month,
      DateTime.now().day,
    );
    if (_birthDate!.isAfter(sixteen)) {
      return 'Debes tener al menos 16 años';
    }

    final changingPassword = _currentPassword.text.isNotEmpty ||
        _newPassword.text.isNotEmpty ||
        _confirmPassword.text.isNotEmpty;
    if (changingPassword) {
      if (_currentPassword.text.isEmpty) {
        return 'Introduce tu contraseña actual';
      }
      if (!FlowaPassword.isStrong(_newPassword.text)) {
        return FlowaPassword.validationMessage(_newPassword.text) ??
            'La nueva contraseña no es válida';
      }
      if (_newPassword.text != _confirmPassword.text) {
        return 'Las contraseñas nuevas no coinciden';
      }
    }
    return null;
  }

  Future<void> _save() async {
    final error = _validate();
    if (error != null) {
      setState(() => _error = error);
      return;
    }

    setState(() {
      _error = null;
      _saving = true;
    });

    try {
      final updated = widget.user.copyWith(
        fullName: _nameController.text.trim(),
        username: _usernameController.text.trim(),
        email: _emailController.text.trim().toLowerCase(),
        dateOfBirth: _birthDate,
        avatarPath: _avatarPath,
      );

      await FlowaServices.accountRepository.updateProfile(updated);
      await FlowaServices.authRepository.updateAccount(
        fullName: updated.fullName,
        email: updated.email,
      );
      await FlowaServices.authRepository.saveProfileExtras(
        UserProfileExtras(
          username: updated.username,
          avatarPath: updated.avatarPath,
          dateOfBirth: updated.dateOfBirth,
        ),
      );

      final changingPassword = _newPassword.text.isNotEmpty;
      if (changingPassword) {
        await FlowaServices.authRepository.changePassword(
          currentPassword: _currentPassword.text,
          newPassword: _newPassword.text,
        );
      }

      if (!mounted) {
        return;
      }
      Navigator.of(context).pop(true);
    } on AuthException catch (e) {
      setState(() {
        _error = e.message;
        _saving = false;
      });
    } catch (_) {
      setState(() {
        _error = 'No se pudo guardar. Inténtalo de nuevo.';
        _saving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final birthLabel = _birthDate == null
        ? 'Selecciona una fecha'
        : DateFormat('d MMMM yyyy', 'es_ES').format(_birthDate!);

    return FlowaScreen(
      title: 'Editar perfil',
      footer: FlowaAcidButton(
        label: 'Guardar',
        loading: _saving,
        onPressed: _saving ? null : _save,
      ),
      child: ListView(
        padding: const EdgeInsets.only(bottom: FlowaSpacing.xl),
        children: [
          Center(
            child: FlowaPressScale(
              onTap: _choosePhotoSource,
              child: Stack(
                children: [
                  FlowaAvatar(
                    name: _nameController.text,
                    path: _avatarPath,
                    size: 96,
                  ),
                  Positioned(
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: FlowaColors.mint,
                        shape: BoxShape.circle,
                      ),
                      alignment: Alignment.center,
                      child: const FlowaLucideIcon(
                        LucideIcons.camera,
                        size: 16,
                        color: FlowaColors.mintInk,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Toca para cambiar la foto',
            textAlign: TextAlign.center,
            style: FlowaType.bodySm(color: FlowaColors.boneMuted),
          ),
          const SizedBox(height: FlowaSpacing.xl),
          TextField(
            controller: _nameController,
            style: moreFieldStyle,
            textCapitalization: TextCapitalization.words,
            decoration: moreInputDecoration(
              label: 'Nombre',
              hint: 'Nombre y apellidos',
              prefixIcon: Icons.badge_outlined,
            ),
          ),
          const SizedBox(height: FlowaSpacing.md),
          TextField(
            controller: _usernameController,
            style: moreFieldStyle,
            decoration: moreInputDecoration(
              label: 'Nombre de usuario',
              hint: 'flowa_user',
              prefixIcon: Icons.alternate_email_rounded,
            ),
          ),
          const SizedBox(height: FlowaSpacing.md),
          TextField(
            controller: _emailController,
            style: moreFieldStyle,
            keyboardType: TextInputType.emailAddress,
            decoration: moreInputDecoration(
              label: 'Correo',
              hint: 'tu@email.com',
              prefixIcon: Icons.mail_outline_rounded,
            ),
          ),
          const SizedBox(height: FlowaSpacing.md),
          FlowaPressScale(
            onTap: _pickBirthDate,
            child: InputDecorator(
              decoration: moreInputDecoration(
                label: 'Fecha de nacimiento',
                prefixIcon: Icons.cake_outlined,
              ),
              child: Text(birthLabel, style: moreFieldStyle),
            ),
          ),
          const SizedBox(height: FlowaSpacing.xl),
          Text('Contraseña', style: FlowaType.titleMd()),
          const SizedBox(height: 6),
          Text(
            'Déjalo vacío si no quieres cambiarla. Mínimo 8 caracteres, '
            'con letra y número.',
            style: FlowaType.bodySm(color: FlowaColors.boneMuted),
          ),
          const SizedBox(height: FlowaSpacing.md),
          TextField(
            controller: _currentPassword,
            style: moreFieldStyle,
            obscureText: _obscureCurrent,
            decoration: moreInputDecoration(
              label: 'Contraseña actual',
              prefixIcon: Icons.lock_outline_rounded,
            ).copyWith(
              suffixIcon: IconButton(
                onPressed: () =>
                    setState(() => _obscureCurrent = !_obscureCurrent),
                icon: Icon(
                  _obscureCurrent
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: FlowaColors.boneMuted,
                ),
              ),
            ),
          ),
          const SizedBox(height: FlowaSpacing.md),
          TextField(
            controller: _newPassword,
            style: moreFieldStyle,
            obscureText: _obscureNew,
            onChanged: (_) => setState(() {}),
            decoration: moreInputDecoration(
              label: 'Nueva contraseña',
              prefixIcon: Icons.lock_reset_rounded,
            ).copyWith(
              suffixIcon: IconButton(
                onPressed: () => setState(() => _obscureNew = !_obscureNew),
                icon: Icon(
                  _obscureNew
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: FlowaColors.boneMuted,
                ),
              ),
            ),
          ),
          if (_newPassword.text.isNotEmpty) ...[
            const SizedBox(height: FlowaSpacing.sm),
            FlowaStrengthMeter(score: FlowaStrengthMeter.scoreFor(_newPassword.text)),
          ],
          const SizedBox(height: FlowaSpacing.md),
          TextField(
            controller: _confirmPassword,
            style: moreFieldStyle,
            obscureText: true,
            decoration: moreInputDecoration(
              label: 'Repite la nueva contraseña',
              prefixIcon: Icons.lock_outline_rounded,
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: FlowaSpacing.md),
            Text(
              _error!,
              style: FlowaType.body(color: FlowaColors.danger),
            ),
          ],
        ],
      ),
    );
  }
}

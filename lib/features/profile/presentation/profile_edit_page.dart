import 'package:flutter/material.dart';

import '../../../core/utils/flowa_services.dart';
import '../../../design_system/tokens/flowa_spacing.dart';
import '../../../domain/entities/finance_entities.dart';
import '../../../shared/widgets/flowa_buttons.dart';

class ProfileEditPage extends StatefulWidget {
  const ProfileEditPage({required this.user, super.key});

  final UserProfile user;

  @override
  State<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends State<ProfileEditPage> {
  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  String? _error;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.fullName);
    _emailController = TextEditingController(text: widget.user.email ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'Display name is required');
      return;
    }
    await FlowaServices.accountRepository.updateDisplayName(name);
    if (!mounted) {
      return;
    }
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit profile')),
      body: ListView(
        padding: FlowaSpacing.screenPadding,
        children: [
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: 'Display name',
              errorText: _error,
            ),
          ),
          const SizedBox(height: FlowaSpacing.sm),
          TextField(
            controller: _emailController,
            readOnly: true,
            decoration: const InputDecoration(
              labelText: 'Email',
              helperText: 'Email changes are handled outside this demo.',
            ),
          ),
          const SizedBox(height: FlowaSpacing.xl),
          FlowaPrimaryButton(label: 'Save', onPressed: _save),
        ],
      ),
    );
  }
}

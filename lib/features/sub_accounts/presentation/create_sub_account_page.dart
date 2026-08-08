import 'package:flutter/material.dart';

import '../../../core/utils/flowa_services.dart';
import '../../../core/utils/flowa_validators.dart';
import '../../../design_system/components/flowa_icon_picker.dart';
import '../../../design_system/components/flowa_purpose_selector.dart';
import '../../../design_system/tokens/flowa_colors.dart';
import '../../../design_system/tokens/flowa_spacing.dart';
import '../../../domain/entities/finance_entities.dart';
import '../../../shared/widgets/flowa_buttons.dart';

class CreateSubAccountPage extends StatefulWidget {
  const CreateSubAccountPage({super.key});

  @override
  State<CreateSubAccountPage> createState() => _CreateSubAccountPageState();
}

class _CreateSubAccountPageState extends State<CreateSubAccountPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  AccountKind _purpose = AccountKind.family;
  AccessLevel _accessLevel = AccessLevel.limited;
  String _iconKey = 'family';
  bool _saving = false;
  String? _nameError;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _create() async {
    final nameError = FlowaValidators.requiredLabel(
      _nameController.text,
      field: 'Account name',
    );
    final emailError = FlowaValidators.optionalEmail(_emailController.text);

    setState(() {
      _nameError = nameError ?? emailError;
    });
    if (nameError != null || emailError != null) {
      return;
    }

    setState(() => _saving = true);
    final created = await FlowaServices.subAccountRepository.create(
      name: _nameController.text,
      purpose: _purpose,
      accessLevel: _accessLevel,
      iconKey: _iconKey,
      linkedEmail: _emailController.text,
    );
    if (!mounted) {
      return;
    }
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Created ${created.name}')),
    );
    Navigator.of(context).pop(created);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Sub-Account')),
      body: SafeArea(
        child: ListView(
          padding: FlowaSpacing.screenPadding,
          children: [
            Container(
              width: double.infinity,
              padding: FlowaSpacing.cardPadding,
              decoration: const BoxDecoration(
                gradient: FlowaColors.cardGreenGradient,
                borderRadius: FlowaRadii.lgAll,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Account Number',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  const SizedBox(height: FlowaSpacing.xs),
                  Text(
                    'Automatically assigned for easier management.',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: FlowaSpacing.sm),
                  Text(
                    '1476 5849 5748 ····',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            ),
            const SizedBox(height: FlowaSpacing.xl),
            Text(
              'Account Purpose',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: FlowaSpacing.sm),
            FlowaPurposeSelector(
              value: _purpose,
              onChanged: (value) => setState(() => _purpose = value),
            ),
            const SizedBox(height: FlowaSpacing.xl),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Account Name',
                hintText: "e.g. Emma's College Fund",
                errorText: _nameError,
              ),
            ),
            const SizedBox(height: FlowaSpacing.xl),
            Text('Icon', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: FlowaSpacing.sm),
            FlowaIconPicker(
              options: FlowaIconPicker.defaults,
              selectedKey: _iconKey,
              onSelected: (value) => setState(() => _iconKey = value),
            ),
            const SizedBox(height: FlowaSpacing.xl),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Link to User',
                hintText: 'email@example.com',
              ),
            ),
            const SizedBox(height: FlowaSpacing.xl),
            Text(
              'Access Level',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: FlowaSpacing.sm),
            FlowaAccessLevelSelector(
              value: _accessLevel,
              onChanged: (value) => setState(() => _accessLevel = value),
            ),
            const SizedBox(height: FlowaSpacing.xxl),
            FlowaPrimaryButton(
              label: 'Create Sub-Account',
              isLoading: _saving,
              onPressed: _create,
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../core/utils/flowa_services.dart';
import '../../../design_system/tokens/flowa_spacing.dart';
import '../../../domain/entities/payee_contact.dart';
import '../../../shared/widgets/flowa_buttons.dart';

class CreateContactPage extends StatefulWidget {
  const CreateContactPage({super.key});

  @override
  State<CreateContactPage> createState() => _CreateContactPageState();
}

class _CreateContactPageState extends State<CreateContactPage> {
  final _nameController = TextEditingController();
  final _accountController = TextEditingController();
  final _noteController = TextEditingController();
  PayeeKind _kind = PayeeKind.person;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _accountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() => _error = 'El nombre es obligatorio');
      return;
    }
    final contact = await FlowaServices.contactRepository.create(
      name: name,
      kind: _kind,
      accountNumber: _accountController.text,
      note: _noteController.text,
    );
    if (!mounted) {
      return;
    }
    Navigator.of(context).pop(contact);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nuevo contacto')),
      body: ListView(
        padding: FlowaSpacing.screenPadding,
        children: [
          TextField(
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            decoration: InputDecoration(
              labelText: 'Nombre',
              errorText: _error,
            ),
          ),
          const SizedBox(height: FlowaSpacing.md),
          Text('Tipo', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: FlowaSpacing.sm),
          Wrap(
            spacing: FlowaSpacing.sm,
            children: [
              ChoiceChip(
                label: const Text('Persona'),
                selected: _kind == PayeeKind.person,
                onSelected: (_) => setState(() => _kind = PayeeKind.person),
              ),
              ChoiceChip(
                label: const Text('Empresa'),
                selected: _kind == PayeeKind.business,
                onSelected: (_) => setState(() => _kind = PayeeKind.business),
              ),
            ],
          ),
          const SizedBox(height: FlowaSpacing.md),
          TextField(
            controller: _accountController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Nº de cuenta (opcional)',
            ),
          ),
          const SizedBox(height: FlowaSpacing.sm),
          TextField(
            controller: _noteController,
            decoration: const InputDecoration(
              labelText: 'Nota (opcional)',
            ),
          ),
          const SizedBox(height: FlowaSpacing.xl),
          FlowaPrimaryButton(label: 'Guardar', onPressed: _save),
        ],
      ),
    );
  }
}

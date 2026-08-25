import 'package:flutter/material.dart';

import '../../../core/utils/flowa_services.dart';
import '../../../design_system/components/flowa_actions.dart';
import '../../../design_system/components/flowa_screen.dart';
import '../../../design_system/tokens/flowa_spacing.dart';
import '../../../domain/entities/payee_contact.dart';

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
    return FlowaScreen(
      title: 'Nuevo contacto',
      footer: FlowaAcidButton(label: 'Guardar', onPressed: _save),
      child: ListView(
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
          Row(
            children: [
              FlowaFilterChip(
                label: 'Persona',
                selected: _kind == PayeeKind.person,
                onTap: () => setState(() => _kind = PayeeKind.person),
              ),
              const SizedBox(width: 8),
              FlowaFilterChip(
                label: 'Empresa',
                selected: _kind == PayeeKind.business,
                onTap: () => setState(() => _kind = PayeeKind.business),
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
            decoration: const InputDecoration(labelText: 'Nota (opcional)'),
          ),
        ],
      ),
    );
  }
}

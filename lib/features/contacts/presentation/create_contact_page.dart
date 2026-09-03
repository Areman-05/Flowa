import 'package:flutter/material.dart';

import '../../../core/utils/flowa_services.dart';
import '../../../design_system/components/flowa_actions.dart';
import '../../../design_system/components/flowa_screen.dart';
import '../../../design_system/tokens/flowa_colors.dart';
import '../../../design_system/tokens/flowa_spacing.dart';
import '../../../design_system/tokens/flowa_typography.dart';
import '../../../domain/entities/payee_contact.dart';
import '../../more/presentation/widgets/more_service_ui.dart';

class CreateContactPage extends StatefulWidget {
  const CreateContactPage({super.key, this.existing});

  final PayeeContact? existing;

  @override
  State<CreateContactPage> createState() => _CreateContactPageState();
}

class _CreateContactPageState extends State<CreateContactPage> {
  late final TextEditingController _nameController;
  late final TextEditingController _accountController;
  late final TextEditingController _noteController;
  late PayeeKind _kind;
  String? _error;
  bool _saving = false;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    _nameController = TextEditingController(text: existing?.name ?? '');
    _accountController =
        TextEditingController(text: existing?.accountNumber ?? '');
    _noteController = TextEditingController(text: existing?.note ?? '');
    _kind = existing?.kind ?? PayeeKind.person;
  }

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

    setState(() {
      _error = null;
      _saving = true;
    });

    try {
      final PayeeContact contact;
      if (_isEditing) {
        contact = await FlowaServices.contactRepository.update(
          widget.existing!.copyWith(
            name: name,
            kind: _kind,
            accountNumber: _accountController.text,
            note: _noteController.text,
            clearNote: _noteController.text.trim().isEmpty,
          ),
        );
      } else {
        contact = await FlowaServices.contactRepository.create(
          name: name,
          kind: _kind,
          accountNumber: _accountController.text,
          note: _noteController.text,
        );
      }
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop(contact);
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _error = 'No se pudo guardar el contacto';
        _saving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FlowaScreen(
      title: _isEditing ? 'Editar contacto' : 'Nuevo contacto',
      footer: FlowaAcidButton(
        label: 'Guardar',
        loading: _saving,
        onPressed: _saving ? null : _save,
      ),
      child: ListView(
        children: [
          TextField(
            controller: _nameController,
            style: moreFieldStyle,
            textCapitalization: TextCapitalization.words,
            decoration: moreInputDecoration(
              label: 'Nombre',
              hint: 'Nombre o empresa',
              prefixIcon: Icons.person_outline_rounded,
            ).copyWith(errorText: _error),
          ),
          const SizedBox(height: FlowaSpacing.md),
          Text('Tipo', style: FlowaType.bodySm(color: FlowaColors.boneMuted)),
          const SizedBox(height: 8),
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
            style: moreFieldStyle,
            keyboardType: TextInputType.text,
            decoration: moreInputDecoration(
              label: 'Nº de cuenta',
              hint: 'IBAN u otro identificador',
              prefixIcon: Icons.account_balance_outlined,
            ),
          ),
          const SizedBox(height: FlowaSpacing.md),
          TextField(
            controller: _noteController,
            style: moreFieldStyle,
            decoration: moreInputDecoration(
              label: 'Nota',
              hint: 'Opcional',
              prefixIcon: Icons.sticky_note_2_outlined,
            ),
          ),
        ],
      ),
    );
  }
}

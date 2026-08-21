import 'package:flutter/material.dart';

import '../../../core/utils/flowa_services.dart';
import '../../../design_system/tokens/flowa_colors.dart';
import '../../../design_system/tokens/flowa_spacing.dart';
import '../../../domain/entities/payee_contact.dart';
import '../../../shared/navigation/flowa_routes.dart';
import '../../../shared/widgets/flowa_states.dart';
import 'create_contact_page.dart';

class ContactsPage extends StatefulWidget {
  const ContactsPage({super.key, this.selectMode = false});

  /// When true, tapping a contact pops with that [PayeeContact].
  final bool selectMode;

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  List<PayeeContact> _items = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final items = await FlowaServices.contactRepository.getAll();
    if (!mounted) {
      return;
    }
    setState(() {
      _items = items;
      _loading = false;
    });
  }

  Future<void> _create() async {
    final created = await pushFlowaRoute<PayeeContact>(
      context,
      const CreateContactPage(),
    );
    if (created != null) {
      await _load();
      if (widget.selectMode && mounted) {
        Navigator.of(context).pop(created);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.selectMode ? 'Elegir contacto' : 'Contactos'),
        actions: [
          IconButton(
            tooltip: 'Añadir',
            onPressed: _create,
            icon: const Icon(Icons.person_add_alt_1_outlined),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
              ? FlowaEmptyState(
                  title: 'Sin contactos',
                  message:
                      'Añade personas o empresas a las que envías dinero.',
                  icon: Icons.groups_outlined,
                  actionLabel: 'Añadir contacto',
                  onAction: _create,
                )
              : ListView.separated(
                  padding: FlowaSpacing.screenPadding,
                  itemCount: _items.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: FlowaSpacing.sm),
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    return Material(
                      color: FlowaColors.surface,
                      borderRadius: FlowaRadii.mdAll,
                      child: ListTile(
                        shape: const RoundedRectangleBorder(
                          borderRadius: FlowaRadii.mdAll,
                          side: BorderSide(color: FlowaColors.border),
                        ),
                        leading: CircleAvatar(
                          backgroundColor: FlowaColors.primarySoft,
                          child: Icon(
                            item.kind == PayeeKind.business
                                ? Icons.apartment_outlined
                                : Icons.person_outline,
                            color: FlowaColors.primary,
                          ),
                        ),
                        title: Text(item.name),
                        subtitle: Text(
                          [
                            item.kindLabel,
                            if (item.accountNumber.isNotEmpty)
                              item.accountNumber,
                          ].join(' · '),
                        ),
                        trailing: widget.selectMode
                            ? const Icon(Icons.chevron_right)
                            : IconButton(
                                icon: const Icon(Icons.delete_outline),
                                onPressed: () async {
                                  await FlowaServices.contactRepository
                                      .delete(item.id);
                                  await _load();
                                },
                              ),
                        onTap: widget.selectMode
                            ? () => Navigator.of(context).pop(item)
                            : null,
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _create,
        icon: const Icon(Icons.add),
        label: const Text('Nuevo'),
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../core/utils/flowa_services.dart';
import '../../../design_system/components/flowa_actions.dart';
import '../../../design_system/components/flowa_icon.dart';
import '../../../design_system/components/flowa_screen.dart';
import '../../../design_system/tokens/flowa_colors.dart';
import '../../../domain/entities/payee_contact.dart';
import '../../../shared/navigation/flowa_routes.dart';
import '../../../shared/widgets/flowa_states.dart';
import 'create_contact_page.dart';

class ContactsPage extends StatefulWidget {
  const ContactsPage({super.key, this.selectMode = false});

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
    return FlowaScreen(
      title: widget.selectMode ? 'Elegir contacto' : 'Contactos',
      actions: [
        FlowaIconAction(glyph: FlowaGlyph.plus, onTap: _create),
      ],
      footer: widget.selectMode
          ? null
          : FlowaAcidButton(label: 'Nuevo contacto', onPressed: _create),
      child: _loading
          ? const Center(
              child: CircularProgressIndicator(color: FlowaColors.mint),
            )
          : _items.isEmpty
              ? FlowaEmptyState(
                  title: 'Sin contactos',
                  message:
                      'Añade personas o empresas a las que envías dinero.',
                  glyph: FlowaGlyph.person,
                  actionLabel: 'Añadir contacto',
                  onAction: _create,
                )
              : ListView.builder(
                  itemCount: _items.length,
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    return FlowaMenuRow(
                      glyph: item.kind == PayeeKind.business
                          ? FlowaGlyph.receipt
                          : FlowaGlyph.person,
                      title: item.name,
                      subtitle: [
                        item.kindLabel,
                        if (item.accountNumber.isNotEmpty) item.accountNumber,
                      ].join(' · '),
                      onTap: widget.selectMode
                          ? () => Navigator.of(context).pop(item)
                          : () {},
                      trailing: widget.selectMode
                          ? null
                          : FlowaPressScale(
                              onTap: () async {
                                await FlowaServices.contactRepository
                                    .delete(item.id);
                                await _load();
                              },
                              child: const FlowaIcon(
                                FlowaGlyph.more,
                                size: 16,
                                color: FlowaColors.boneFaint,
                              ),
                            ),
                    );
                  },
                ),
    );
  }
}

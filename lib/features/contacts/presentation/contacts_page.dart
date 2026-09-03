import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../../core/utils/flowa_services.dart';
import '../../../design_system/components/flowa_actions.dart';
import '../../../design_system/components/flowa_icon.dart';
import '../../../design_system/components/flowa_screen.dart';
import '../../../design_system/tokens/flowa_colors.dart';
import '../../../design_system/tokens/flowa_spacing.dart';
import '../../../design_system/tokens/flowa_typography.dart';
import '../../../domain/entities/payee_contact.dart';
import '../../../shared/navigation/flowa_routes.dart';
import '../../../shared/widgets/flowa_states.dart';
import '../../more/presentation/widgets/more_service_ui.dart';
import 'create_contact_page.dart';

class ContactsPage extends StatefulWidget {
  const ContactsPage({super.key, this.selectMode = false});

  final bool selectMode;

  @override
  State<ContactsPage> createState() => _ContactsPageState();
}

class _ContactsPageState extends State<ContactsPage> {
  final _search = TextEditingController();
  List<PayeeContact> _items = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  List<PayeeContact> get _filtered {
    return _items
        .where(
          (item) => moreMatchesQuery(_search.text, [
            item.name,
            item.kindLabel,
            item.accountNumber,
            item.note ?? '',
          ]),
        )
        .toList(growable: false);
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

  Future<void> _open(PayeeContact item) async {
    if (widget.selectMode) {
      Navigator.of(context).pop(item);
      return;
    }
    final updated = await pushFlowaRoute<PayeeContact>(
      context,
      CreateContactPage(existing: item),
    );
    if (updated != null) {
      await _load();
    }
  }

  Future<void> _confirmDelete(PayeeContact item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: FlowaColors.inkHigh,
          title: Text('Eliminar contacto', style: FlowaType.titleMd()),
          content: Text(
            '¿Quieres eliminar a ${item.name}?',
            style: FlowaType.body(),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(
                'Eliminar',
                style: FlowaType.label(color: FlowaColors.danger),
              ),
            ),
          ],
        );
      },
    );
    if (confirmed != true) {
      return;
    }
    await FlowaServices.contactRepository.delete(item.id);
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filtered;

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
          : Column(
              children: [
                MoreSearchField(
                  controller: _search,
                  hint: 'Nombre, cuenta o nota',
                  onChanged: (_) => setState(() {}),
                ),
                const SizedBox(height: FlowaSpacing.md),
                Expanded(
                  child: _items.isEmpty
                      ? FlowaEmptyState(
                          title: 'Sin contactos',
                          message:
                              'Añade personas o empresas a las que envías dinero.',
                          glyph: FlowaGlyph.person,
                          actionLabel: 'Añadir contacto',
                          onAction: _create,
                        )
                      : filtered.isEmpty
                          ? Center(
                              child: Text(
                                'Ningún resultado',
                                style: FlowaType.body(
                                  color: FlowaColors.boneMuted,
                                ),
                              ),
                            )
                          : ListView.separated(
                              itemCount: filtered.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(height: 8),
                              itemBuilder: (context, index) {
                                final item = filtered[index];
                                return _ContactTile(
                                  contact: item,
                                  selectMode: widget.selectMode,
                                  onTap: () => _open(item),
                                  onDelete: () => _confirmDelete(item),
                                );
                              },
                            ),
                ),
              ],
            ),
    );
  }
}

class _ContactTile extends StatelessWidget {
  const _ContactTile({
    required this.contact,
    required this.selectMode,
    required this.onTap,
    required this.onDelete,
  });

  final PayeeContact contact;
  final bool selectMode;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final initial =
        contact.name.isEmpty ? '?' : contact.name[0].toUpperCase();

    return FlowaPressScale(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
              decoration: const BoxDecoration(
                color: FlowaColors.mint,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                initial,
                style: FlowaType.titleMd(color: FlowaColors.mintInk),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(contact.name, style: FlowaType.titleSm()),
                  const SizedBox(height: 2),
                  Text(
                    [
                      contact.kindLabel,
                      if (contact.accountNumber.isNotEmpty)
                        contact.accountNumber,
                    ].join(' · '),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: FlowaType.bodySm(color: FlowaColors.boneMuted),
                  ),
                  if (contact.note != null && contact.note!.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      contact.note!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: FlowaType.bodySm(color: FlowaColors.boneFaint),
                    ),
                  ],
                ],
              ),
            ),
            if (!selectMode)
              IconButton(
                onPressed: onDelete,
                tooltip: 'Eliminar',
                icon: const FlowaLucideIcon(
                  LucideIcons.trash_2,
                  size: 18,
                  color: FlowaColors.boneFaint,
                ),
              )
            else
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

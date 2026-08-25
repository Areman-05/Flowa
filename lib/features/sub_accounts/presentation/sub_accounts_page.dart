import 'package:flutter/material.dart';

import '../../../core/extensions/finance_labels.dart';
import '../../../core/utils/flowa_services.dart';
import '../../../design_system/components/flowa_actions.dart';
import '../../../design_system/components/flowa_icon.dart';
import '../../../design_system/components/flowa_screen.dart';
import '../../../design_system/tokens/flowa_colors.dart';
import '../../../domain/entities/finance_entities.dart';
import '../../../shared/navigation/flowa_routes.dart';
import '../../../shared/widgets/flowa_states.dart';
import 'create_sub_account_page.dart';
import 'sub_account_detail_page.dart';

class SubAccountsPage extends StatefulWidget {
  const SubAccountsPage({super.key});

  @override
  State<SubAccountsPage> createState() => _SubAccountsPageState();
}

class _SubAccountsPageState extends State<SubAccountsPage> {
  List<SubAccount> _items = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final items = await FlowaServices.subAccountRepository.getAll();
    if (!mounted) {
      return;
    }
    setState(() {
      _items = items;
      _loading = false;
    });
  }

  Future<void> _openCreate() async {
    final created = await Navigator.of(context).push<SubAccount>(
      MaterialPageRoute(builder: (_) => const CreateSubAccountPage()),
    );
    if (created != null) {
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    return FlowaScreen(
      title: 'Subcuentas',
      footer: FlowaAcidButton(label: 'Crear subcuenta', onPressed: _openCreate),
      child: _loading
          ? const Center(
              child: CircularProgressIndicator(color: FlowaColors.mint),
            )
          : _items.isEmpty
              ? FlowaEmptyState(
                  title: 'Sin subcuentas',
                  message:
                      'Separa el dinero familiar y de empresa para no mezclarlo.',
                  glyph: FlowaGlyph.vault,
                )
              : ListView.builder(
                  itemCount: _items.length,
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    return FlowaMenuRow(
                      glyph: FlowaGlyph.vault,
                      title: item.name,
                      subtitle:
                          '${item.purpose.label} · ${item.accessLevel.label}',
                      onTap: () {
                        pushFlowaRoute<void>(
                          context,
                          SubAccountDetailPage(account: item),
                        );
                      },
                    );
                  },
                ),
    );
  }
}

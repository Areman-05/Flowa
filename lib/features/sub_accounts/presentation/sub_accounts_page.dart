import 'package:flutter/material.dart';

import '../../../core/extensions/finance_labels.dart';
import '../../../core/utils/flowa_services.dart';
import '../../../design_system/components/flowa_icon_picker.dart';
import '../../../design_system/tokens/flowa_colors.dart';
import '../../../design_system/tokens/flowa_spacing.dart';
import '../../../domain/entities/finance_entities.dart';
import '../../../shared/widgets/flowa_buttons.dart';
import '../../../shared/widgets/flowa_states.dart';
import 'create_sub_account_page.dart';

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

  IconData _iconFor(String key) {
    return FlowaIconPicker.defaults
        .firstWhere(
          (option) => option.key == key,
          orElse: () => FlowaIconPicker.defaults.first,
        )
        .icon;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sub-Accounts')),
      body: SafeArea(
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _items.isEmpty
                ? FlowaEmptyState(
                    title: 'No sub-accounts yet',
                    message:
                        'Separate family and business money to stay in control.',
                    actionLabel: 'Create Sub-Account',
                    onAction: _openCreate,
                  )
                : ListView.separated(
                    padding: FlowaSpacing.screenPadding,
                    itemCount: _items.length + 1,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: FlowaSpacing.sm),
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return FlowaPrimaryButton(
                          label: 'Create Sub-Account',
                          onPressed: _openCreate,
                        );
                      }
                      final item = _items[index - 1];
                      return ListTile(
                        shape: const RoundedRectangleBorder(
                          borderRadius: FlowaRadii.mdAll,
                          side: BorderSide(color: FlowaColors.border),
                        ),
                        leading: CircleAvatar(
                          backgroundColor: FlowaColors.primarySoft,
                          child: Icon(
                            _iconFor(item.iconKey),
                            color: FlowaColors.primary,
                          ),
                        ),
                        title: Text(item.name),
                        subtitle: Text(
                          '${item.purpose.label} · ${item.accessLevel.label} access\n'
                          '${item.accountNumber}',
                        ),
                        isThreeLine: true,
                      );
                    },
                  ),
      ),
    );
  }
}

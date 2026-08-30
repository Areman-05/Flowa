import 'package:flutter/material.dart';

import '../../../core/utils/flowa_formatters.dart';
import '../../../core/utils/flowa_haptics.dart';
import '../../../core/utils/flowa_services.dart';
import '../../../design_system/components/flowa_actions.dart';
import '../../../design_system/components/flowa_icon.dart';
import '../../../design_system/components/flowa_money_keypad.dart';
import '../../../design_system/components/flowa_screen.dart';
import '../../../design_system/tokens/flowa_colors.dart';
import '../../../design_system/tokens/flowa_spacing.dart';
import '../../../design_system/tokens/flowa_typography.dart';
import '../../../domain/entities/finance_entities.dart';
import '../../../domain/entities/payee_contact.dart';
import '../../../shared/navigation/flowa_routes.dart';
import '../../contacts/presentation/contacts_page.dart';
import 'send_review_page.dart';

/// Send money — contacts, hero amount, circular keypad.
class SendMoneyPage extends StatefulWidget {
  const SendMoneyPage({super.key});

  @override
  State<SendMoneyPage> createState() => _SendMoneyPageState();
}

class _SendMoneyPageState extends State<SendMoneyPage> {
  List<PayeeContact> _contacts = const [];
  PayeeContact? _selected;
  Account? _account;
  int _cents = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final contacts = await FlowaServices.contactRepository.getAll();
    final account = await FlowaServices.accountRepository.getPrimaryAccount();
    if (!mounted) {
      return;
    }
    setState(() {
      _contacts = contacts;
      _account = account;
    });
  }

  double get _amount => _cents / 100.0;

  void _digit(String key) {
    FlowaHaptics.selection();
    setState(() {
      if (key == '<') {
        _cents = _cents ~/ 10;
        return;
      }
      if (key == '00') {
        if (_cents >= 1000000) {
          return;
        }
        _cents = _cents * 100;
        return;
      }
      if (_cents >= 99999999) {
        return;
      }
      _cents = _cents * 10 + int.parse(key);
    });
  }

  Future<void> _pickContact() async {
    final contact = await pushFlowaRoute<PayeeContact>(
      context,
      const ContactsPage(selectMode: true),
    );
    if (contact == null || !mounted) {
      return;
    }
    setState(() => _selected = contact);
    await _load();
  }

  Future<void> _submit() async {
    final selected = _selected;
    if (selected == null || _amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Elige un contacto y un importe válido.'),
        ),
      );
      return;
    }

    final available = _account?.availableBalance ?? 0;
    if (_amount > available) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Solo tienes ${FlowaFormatters.currency(available)} disponibles.',
          ),
        ),
      );
      return;
    }

    await pushFlowaRoute<void>(
      context,
      SendReviewPage(
        recipientName: selected.name,
        accountNumber: selected.accountNumber,
        amount: _amount,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final available = _account?.availableBalance;

    return FlowaScreen(
      title: 'Enviar',
      footer: FlowaAcidButton(
        label: 'Continuar',
        onPressed: _submit,
      ),
      child: Column(
        children: [
          SizedBox(
            height: 78,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _contacts.length + 1,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                if (index == _contacts.length) {
                  return _ContactOrb(
                    label: 'Nuevo',
                    mint: true,
                    glyph: FlowaGlyph.plus,
                    selected: false,
                    onTap: _pickContact,
                  );
                }
                final contact = _contacts[index];
                final selected = _selected?.id == contact.id;
                return _ContactOrb(
                  label: contact.name,
                  initial: contact.name.isEmpty
                      ? '?'
                      : contact.name[0].toUpperCase(),
                  selected: selected,
                  onTap: () => setState(() => _selected = contact),
                );
              },
            ),
          ),
          const SizedBox(height: FlowaSpacing.lg),
          Text(
            _selected == null ? '¿A quién envías?' : 'Para ${_selected!.name}',
            style: FlowaType.micro(),
          ),
          const SizedBox(height: FlowaSpacing.sm),
          Text(
            FlowaFormatters.currency(_amount),
            style: FlowaType.figureXl(),
          ),
          if (available != null) ...[
            const SizedBox(height: 6),
            Text(
              'Disponible ${FlowaFormatters.currency(available)}',
              style: FlowaType.bodySm(
                color: _amount > available
                    ? FlowaColors.danger
                    : FlowaColors.boneMuted,
              ),
            ),
          ],
          const SizedBox(height: FlowaSpacing.md),
          FlowaQuickAmounts(
            values: const [10, 25, 50, 100],
            activeCents: _cents,
            onSelected: (euros) => setState(() => _cents = euros * 100),
          ),
          const Spacer(),
          FlowaMoneyKeypad(onKey: _digit),
          const SizedBox(height: FlowaSpacing.sm),
        ],
      ),
    );
  }
}

class _ContactOrb extends StatelessWidget {
  const _ContactOrb({
    required this.label,
    required this.selected,
    required this.onTap,
    this.initial,
    this.glyph,
    this.mint = false,
  });

  final String label;
  final String? initial;
  final FlowaGlyph? glyph;
  final bool selected;
  final bool mint;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final fill = mint || selected ? FlowaColors.mint : FlowaColors.inkHigh;
    final ink = mint || selected ? FlowaColors.mintInk : FlowaColors.bone;
    return FlowaPressScale(
      onTap: onTap,
      scale: 0.94,
      child: SizedBox(
        width: 64,
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: fill,
                shape: BoxShape.circle,
                border: selected && !mint
                    ? Border.all(color: FlowaColors.mintBright, width: 2)
                    : null,
              ),
              alignment: Alignment.center,
              child: glyph != null
                  ? FlowaIcon(glyph!, color: ink, size: 18)
                  : Text(initial ?? '', style: FlowaType.titleMd(color: ink)),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: FlowaType.micro(
                color: selected ? FlowaColors.bone : FlowaColors.boneMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

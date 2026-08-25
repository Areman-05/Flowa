import 'package:flutter/material.dart';

import '../../../core/utils/flowa_formatters.dart';
import '../../../core/utils/flowa_haptics.dart';
import '../../../core/utils/flowa_services.dart';
import '../../../design_system/components/flowa_actions.dart';
import '../../../design_system/components/flowa_icon.dart';
import '../../../design_system/components/flowa_screen.dart';
import '../../../design_system/tokens/flowa_colors.dart';
import '../../../design_system/tokens/flowa_spacing.dart';
import '../../../design_system/tokens/flowa_typography.dart';
import '../../../domain/entities/payee_contact.dart';
import '../../../shared/navigation/flowa_routes.dart';
import '../../contacts/presentation/contacts_page.dart';
import 'send_review_page.dart';

/// Send money — Vare: huge amount, keypad, mint CTA.
class SendMoneyPage extends StatefulWidget {
  const SendMoneyPage({super.key});

  @override
  State<SendMoneyPage> createState() => _SendMoneyPageState();
}

class _SendMoneyPageState extends State<SendMoneyPage> {
  List<PayeeContact> _contacts = const [];
  PayeeContact? _selected;
  int _cents = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final contacts = await FlowaServices.contactRepository.getAll();
    if (!mounted) {
      return;
    }
    setState(() => _contacts = contacts);
  }

  double get _amount => _cents / 100.0;

  void _digit(String key) {
    FlowaHaptics.selection();
    setState(() {
      if (key == '<') {
        _cents = _cents ~/ 10;
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
    return FlowaScreen(
      title: 'Enviar',
      footer: FlowaAcidButton(
        label: 'Continuar',
        onPressed: _submit,
      ),
      child: Column(
        children: [
          SizedBox(
            height: 72,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _contacts.length + 1,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
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
            _selected == null ? '¿A quién?' : _selected!.name,
            style: FlowaType.micro(),
          ),
          const SizedBox(height: FlowaSpacing.sm),
          Text(
            FlowaFormatters.currency(_amount),
            style: FlowaType.figureXl(),
          ),
          const Spacer(),
          _Keypad(onKey: _digit),
          const SizedBox(height: FlowaSpacing.md),
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
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(color: fill, shape: BoxShape.circle),
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
              style: FlowaType.micro(),
            ),
          ],
        ),
      ),
    );
  }
}

class _Keypad extends StatelessWidget {
  const _Keypad({required this.onKey});

  final ValueChanged<String> onKey;

  static const _keys = [
    ['1', '2', '3'],
    ['4', '5', '6'],
    ['7', '8', '9'],
    ['00', '0', '<'],
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final row in _keys)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                for (final key in row)
                  Expanded(
                    child: FlowaPressScale(
                      onTap: () {
                        if (key == '00') {
                          onKey('0');
                          onKey('0');
                        } else {
                          onKey(key);
                        }
                      },
                      scale: 0.94,
                      haptic: false,
                      child: SizedBox(
                        height: 56,
                        child: Center(
                          child: key == '<'
                              ? const FlowaIcon(
                                  FlowaGlyph.arrowLeft,
                                  size: 20,
                                  color: FlowaColors.boneMuted,
                                )
                              : Text(key, style: FlowaType.titleLg()),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

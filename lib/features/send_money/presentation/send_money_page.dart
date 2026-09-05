import 'package:flutter/material.dart';

import '../../../core/utils/flowa_formatters.dart';
import '../../../core/utils/flowa_haptics.dart';
import '../../../core/utils/flowa_services.dart';
import '../../../design_system/components/flowa_actions.dart';
import '../../../design_system/components/flowa_icon.dart';
import '../../../design_system/components/flowa_money_keypad.dart';
import '../../../design_system/components/flowa_primitives.dart';
import '../../../design_system/components/flowa_screen.dart';
import '../../../design_system/tokens/flowa_colors.dart';
import '../../../design_system/tokens/flowa_motion_tokens.dart';
import '../../../design_system/tokens/flowa_spacing.dart';
import '../../../design_system/tokens/flowa_typography.dart';
import '../../../domain/entities/finance_entities.dart';
import '../../../domain/entities/payee_contact.dart';
import '../../../shared/navigation/flowa_routes.dart';
import '../../contacts/presentation/contacts_page.dart';
import 'send_review_page.dart';

/// Send money — recipient card + 5 recent orbs + amount + keypad.
class SendMoneyPage extends StatefulWidget {
  const SendMoneyPage({super.key});

  @override
  State<SendMoneyPage> createState() => _SendMoneyPageState();
}

class _SendMoneyPageState extends State<SendMoneyPage> {
  List<PayeeContact> _recent = const [];
  PayeeContact? _selected;
  Account? _account;
  int _cents = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  List<PayeeContact> _takeRecent(List<PayeeContact> all) {
    final sorted = List<PayeeContact>.from(all)
      ..sort((a, b) {
        final aAt = a.lastUsedAt;
        final bAt = b.lastUsedAt;
        if (aAt == null && bAt == null) {
          return a.name.toLowerCase().compareTo(b.name.toLowerCase());
        }
        if (aAt == null) {
          return 1;
        }
        if (bAt == null) {
          return -1;
        }
        return bAt.compareTo(aAt);
      });
    return sorted.take(5).toList(growable: false);
  }

  Future<void> _load() async {
    final contacts = await FlowaServices.contactRepository.getAll();
    final account = await FlowaServices.accountRepository.getPrimaryAccount();
    if (!mounted) {
      return;
    }
    setState(() {
      _recent = _takeRecent(contacts);
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

  Future<void> _select(PayeeContact contact) async {
    await FlowaHaptics.selection();
    final touched = await FlowaServices.contactRepository.touch(contact.id);
    if (!mounted) {
      return;
    }
    setState(() => _selected = touched);
    await _load();
  }

  Future<void> _pickContact() async {
    final contact = await pushFlowaRoute<PayeeContact>(
      context,
      const ContactsPage(
        selectMode: true,
        selectHint: 'Toca una tarjeta para enviarle dinero.',
      ),
    );
    if (contact == null || !mounted) {
      return;
    }
    await _select(contact);
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

    await FlowaServices.contactRepository.touch(selected.id);

    await pushFlowaRoute<void>(
      context,
      SendReviewPage(
        recipientName: selected.name,
        accountNumber: selected.accountNumber,
        amount: _amount,
      ),
    );
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final available = _account?.availableBalance;
    final over = available != null && _amount > available;

    return FlowaScreen(
      title: 'Enviar',
      footer: FlowaAcidButton(
        label: 'Continuar',
        onPressed: _submit,
      ),
      child: _account == null
          ? const Center(
              child: CircularProgressIndicator(color: FlowaColors.mint),
            )
          : ListView(
              children: [
                FlowaEntrance(
                  child: _RecipientCard(
                    contact: _selected,
                    onTap: _pickContact,
                  ),
                ),
                if (_recent.isNotEmpty) ...[
                  const SizedBox(height: FlowaSpacing.md),
                  FlowaEntrance(
                    delay: FlowaMotion.stagger(1),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Recientes', style: FlowaType.micro()),
                        const SizedBox(height: FlowaSpacing.sm),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            for (final contact in _recent)
                              _ContactOrb(
                                label: contact.name,
                                initial: contact.name.isEmpty
                                    ? '?'
                                    : contact.name[0].toUpperCase(),
                                selected: _selected?.id == contact.id,
                                onTap: () => _select(contact),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: FlowaSpacing.xl),
                FlowaEntrance(
                  delay: FlowaMotion.stagger(2),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Importe', style: FlowaType.micro()),
                      const SizedBox(height: 6),
                      Text(
                        FlowaFormatters.currency(_amount),
                        style: FlowaType.figureXl(),
                      ),
                      if (available != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          'Disponible ${FlowaFormatters.currency(available)}',
                          style: FlowaType.bodySm(
                            color: over
                                ? FlowaColors.danger
                                : FlowaColors.boneMuted,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: FlowaSpacing.md),
                FlowaEntrance(
                  delay: FlowaMotion.stagger(3),
                  child: FlowaQuickAmounts(
                    values: const [20, 50, 100, 250],
                    activeCents: _cents,
                    onSelected: (euros) => setState(() => _cents = euros * 100),
                  ),
                ),
                const SizedBox(height: FlowaSpacing.md),
                FlowaEntrance(
                  delay: FlowaMotion.stagger(4),
                  child: FlowaMoneyKeypad(onKey: _digit),
                ),
                const SizedBox(height: FlowaSpacing.sm),
              ],
            ),
    );
  }
}

class _RecipientCard extends StatelessWidget {
  const _RecipientCard({required this.contact, required this.onTap});

  final PayeeContact? contact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final has = contact != null;
    return FlowaPressScale(
      onTap: onTap,
      scale: 0.98,
      child: Container(
        padding: const EdgeInsets.all(FlowaSpacing.lg),
        decoration: BoxDecoration(
          color: FlowaColors.inkHigh,
          borderRadius: FlowaRadii.xxlAll,
          border: Border.all(color: FlowaColors.hairline),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: has ? FlowaColors.mint : FlowaColors.inkRaised,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: has
                  ? Text(
                      contact!.name.isEmpty
                          ? '?'
                          : contact!.name[0].toUpperCase(),
                      style: FlowaType.titleMd(color: FlowaColors.mintInk),
                    )
                  : const FlowaIcon(
                      FlowaGlyph.transfer,
                      size: 20,
                      color: FlowaColors.boneMuted,
                    ),
            ),
            const SizedBox(width: FlowaSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    has ? 'Para' : 'Destinatario',
                    style: FlowaType.micro(),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    has ? contact!.name : 'Elegir contacto',
                    style: FlowaType.titleSm(
                      color: has ? FlowaColors.bone : FlowaColors.boneMuted,
                    ),
                  ),
                  if (has) ...[
                    const SizedBox(height: 2),
                    Text(
                      contact!.accountNumber,
                      style: FlowaType.bodySm(),
                    ),
                  ],
                ],
              ),
            ),
            FlowaIcon(
              has ? FlowaGlyph.arrowRight : FlowaGlyph.plus,
              size: 18,
              color: FlowaColors.boneMuted,
            ),
          ],
        ),
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
  });

  final String label;
  final String? initial;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FlowaPressScale(
      onTap: onTap,
      scale: 0.94,
      child: SizedBox(
        width: 60,
        child: Column(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: selected ? FlowaColors.mint : FlowaColors.inkHigh,
                shape: BoxShape.circle,
                border: Border.all(
                  color: selected
                      ? FlowaColors.mintBright
                      : FlowaColors.hairline,
                  width: selected ? 2 : 1,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                initial ?? '',
                style: FlowaType.titleMd(
                  color: selected ? FlowaColors.mintInk : FlowaColors.bone,
                ),
              ),
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

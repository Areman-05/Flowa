import 'package:flutter/material.dart';

import '../../../design_system/components/flowa_actions.dart';
import '../../../design_system/components/flowa_glass.dart';
import '../../../design_system/components/flowa_icon.dart';
import '../../../design_system/components/flowa_visa_card.dart';
import '../../../design_system/tokens/flowa_colors.dart';
import '../../../design_system/tokens/flowa_spacing.dart';
import '../../../design_system/tokens/flowa_typography.dart';
import '../../../domain/entities/finance_entities.dart';
import '../../../domain/entities/freelance_entities.dart';
import 'card_create_flow.dart';
import 'card_details_sheet.dart';
import 'card_profile.dart';
import 'card_wallet_store.dart';

Future<void> showCardWalletSheet({
  required BuildContext context,
  required Account primary,
  required TaxVault vault,
  required double trulyAvailable,
  VoidCallback? onChanged,
}) {
  CardWalletStore.instance.ensureSeeded(
    primary: primary,
    vault: vault,
    trulyAvailable: trulyAvailable,
  );

  return showFlowaGlassSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) => _CardWalletBody(
      onChanged: onChanged,
      onOpenDetails: (profile) async {
        Navigator.of(sheetContext).pop();
        await showCardDetailsSheet(context, profile);
        onChanged?.call();
      },
    ),
  );
}

class _CardWalletBody extends StatefulWidget {
  const _CardWalletBody({
    required this.onOpenDetails,
    this.onChanged,
  });

  final VoidCallback? onChanged;
  final Future<void> Function(CardProfile profile) onOpenDetails;

  @override
  State<_CardWalletBody> createState() => _CardWalletBodyState();
}

class _CardWalletBodyState extends State<_CardWalletBody> {
  final _store = CardWalletStore.instance;

  @override
  void initState() {
    super.initState();
    _store.addListener(_onStore);
  }

  @override
  void dispose() {
    _store.removeListener(_onStore);
    super.dispose();
  }

  void _onStore() {
    if (mounted) {
      setState(() {});
      widget.onChanged?.call();
    }
  }

  Future<void> _addCard() async {
    final created = await showCreateCardFlow(context);
    if (created == null || !mounted) {
      return;
    }
    _store.add(created);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Tarjeta añadida a tu cartera.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.paddingOf(context).bottom;
    final cards = _store.cards;

    return SizedBox(
      height: MediaQuery.sizeOf(context).height * 0.82,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: FlowaSpacing.md),
              decoration: BoxDecoration(
                color: FlowaColors.border,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
          Text('Cartera', style: FlowaType.titleLg()),
          const SizedBox(height: 4),
          Text(
            'Elige una tarjeta o añade otra.',
            style: FlowaType.bodySm(),
          ),
          const SizedBox(height: FlowaSpacing.md),
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.only(bottom: bottom + 8),
              itemCount: cards.length + 1,
              separatorBuilder: (_, index) => SizedBox(
                height: index == cards.length - 1
                    ? FlowaSpacing.xxl
                    : FlowaSpacing.md,
              ),
              itemBuilder: (context, index) {
                if (index == cards.length) {
                  return _AddCardTile(onTap: _addCard);
                }
                final card = cards[index];
                return FlowaPressScale(
                  onTap: () => widget.onOpenDetails(card),
                  child: FlowaVisaCard(
                    account: card.account,
                    style: card.style,
                    pattern: card.pattern,
                    caption: card.caption,
                    amount: card.account.availableBalance,
                    height: 168,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _AddCardTile extends StatelessWidget {
  const _AddCardTile({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FlowaPressScale(
      onTap: onTap,
      child: Container(
        height: 88,
        decoration: BoxDecoration(
          color: FlowaColors.inkHigh,
          borderRadius: FlowaRadii.xlAll,
          border: Border.all(
            color: FlowaColors.hairlineStrong,
            width: 1.5,
          ),
        ),
        alignment: Alignment.center,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: const BoxDecoration(
                color: FlowaColors.mint,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: const FlowaIcon(
                FlowaGlyph.plus,
                size: 20,
                color: FlowaColors.mintInk,
              ),
            ),
            const SizedBox(width: FlowaSpacing.sm),
            Text('Añadir tarjeta', style: FlowaType.titleSm()),
          ],
        ),
      ),
    );
  }
}

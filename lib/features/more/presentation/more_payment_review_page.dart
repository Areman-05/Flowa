import 'package:flutter/material.dart';

import '../../../core/utils/flowa_formatters.dart';
import '../../../core/utils/flowa_haptics.dart';
import '../../../core/utils/flowa_services.dart';
import '../../../design_system/components/flowa_actions.dart';
import '../../../design_system/components/flowa_icon.dart';
import '../../../design_system/components/flowa_payment_processing.dart';
import '../../../design_system/components/flowa_primitives.dart';
import '../../../design_system/components/flowa_screen.dart';
import '../../../design_system/tokens/flowa_colors.dart';
import '../../../design_system/tokens/flowa_spacing.dart';
import '../../../design_system/tokens/flowa_typography.dart';
import '../../../domain/entities/freelance_entities.dart';
import '../../../shared/navigation/flowa_routes.dart';
import '../../home/presentation/card_profile.dart';
import '../../home/presentation/card_wallet_store.dart';
import '../../transfers/presentation/transfer_success_page.dart';
import 'more_payment_helper.dart';
import 'widgets/more_payment_ui.dart';

/// Review step before any Más payment.
class MorePaymentReviewPage extends StatefulWidget {
  const MorePaymentReviewPage({
    required this.merchant,
    required this.amount,
    required this.category,
    required this.successTitle,
    required this.successSubtitle,
    super.key,
    this.detailLines = const [],
  });

  final String merchant;
  final double amount;
  final String category;
  final String successTitle;
  final String successSubtitle;
  final List<String> detailLines;

  @override
  State<MorePaymentReviewPage> createState() => _MorePaymentReviewPageState();
}

class _MorePaymentReviewPageState extends State<MorePaymentReviewPage> {
  final _store = CardWalletStore.instance;
  CardProfile? _selected;
  bool _loadingCards = true;
  bool _paying = false;

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  Future<void> _loadCards() async {
    final account = await FlowaServices.accountRepository.getPrimaryAccount();
    final vault = await FlowaServices.freelanceRepository.getVault();
    final invoices = await FlowaServices.freelanceRepository.getInvoices();
    final commitments =
        await FlowaServices.freelanceRepository.getCommitments();
    final transactions =
        await FlowaServices.transactionRepository.getRecent(limit: 200);

    final overview = FreelanceOverview.compute(
      account: account,
      transactions: transactions,
      vault: vault,
      invoices: invoices,
      commitments: commitments,
      now: DateTime.now(),
    );

    _store.ensureSeeded(
      primary: account,
      vault: vault,
      trulyAvailable: overview.trulyAvailable,
    );

    if (!mounted) {
      return;
    }
    setState(() {
      _selected = _store.cards.isNotEmpty ? _store.cards.first : null;
      _loadingCards = false;
    });
  }

  Future<void> _pay() async {
    final card = _selected;
    if (card == null || widget.amount <= 0 || _paying) {
      return;
    }

    if (card.account.availableBalance < widget.amount) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Saldo insuficiente en esta tarjeta.'),
          behavior: SnackBarBehavior.fixed,
        ),
      );
      return;
    }

    setState(() => _paying = true);
    await FlowaHaptics.selection();

    await runFlowaPaymentProcessing<void>(
      context: context,
      label: 'Procesando pago…',
      subtitle: widget.merchant,
      task: () async {
        await completeMoreServicePaymentCore(
          merchant: widget.merchant,
          amount: widget.amount,
          category: widget.category,
          cardLabel: card.account.displayName,
          successTitle: widget.successTitle,
        );
      },
    );

    if (!mounted) {
      return;
    }

    setState(() => _paying = false);

    await pushFlowaRoute<void>(
      context,
      TransferSuccessPage(
        title: widget.successTitle,
        amount: widget.amount,
        subtitle: widget.successSubtitle,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selected = _selected;
    final remaining = selected == null
        ? null
        : selected.account.availableBalance - widget.amount;

    return FlowaScreen(
      title: 'Confirmar pago',
      canvasColor: FlowaColors.inkSurface,
      footer: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const FlowaIcon(
                FlowaGlyph.lock,
                size: 14,
                color: FlowaColors.boneFaint,
              ),
              const SizedBox(width: 6),
              Text(
                'Pago cifrado · Sin comisión',
                style: FlowaType.bodySm(color: FlowaColors.boneFaint),
              ),
            ],
          ),
          const SizedBox(height: FlowaSpacing.sm),
          FlowaAcidButton(
            label: 'Pagar ${FlowaFormatters.currency(widget.amount)}',
            loading: _paying,
            onPressed: selected == null || _loadingCards ? null : _pay,
          ),
        ],
      ),
      child: _loadingCards
          ? const Center(
              child: CircularProgressIndicator(color: FlowaColors.mint),
            )
          : ListView(
              padding: const EdgeInsets.only(bottom: FlowaSpacing.xl),
              children: [
                FlowaEntrance(
                  child: Column(
                    children: [
                      Text(
                        FlowaFormatters.currency(widget.amount),
                        style: FlowaType.figureXl(color: FlowaColors.mint),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: FlowaSpacing.xs),
                      Text(
                        widget.merchant,
                        style: FlowaType.titleMd(),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: FlowaSpacing.xs),
                      Text(
                        widget.category,
                        style: FlowaType.bodySm(color: FlowaColors.boneMuted),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: FlowaSpacing.xl),
                FlowaEntrance(
                  delay: const Duration(milliseconds: 50),
                  child: MorePaymentReceipt(
                    rows: [
                      (
                        label: 'Concepto',
                        value: widget.merchant,
                      ),
                      (
                        label: 'Comisión',
                        value: '0 €',
                      ),
                    ],
                    total: FlowaFormatters.currency(widget.amount),
                    footerLines: widget.detailLines,
                  ),
                ),
                if (selected != null) ...[
                  const SizedBox(height: FlowaSpacing.xl),
                  FlowaEntrance(
                    delay: const Duration(milliseconds: 90),
                    child: MorePayFromCard(
                      card: selected,
                      remaining: remaining,
                      onTap: () async {
                        final picked = await showMoreCardPicker(
                          context: context,
                          cards: _store.cards,
                          selected: selected,
                        );
                        if (picked == null || !mounted) {
                          return;
                        }
                        FlowaHaptics.selection();
                        setState(() => _selected = picked);
                      },
                    ),
                  ),
                ],
              ],
            ),
    );
  }
}

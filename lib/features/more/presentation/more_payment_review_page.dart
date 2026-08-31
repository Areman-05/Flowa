import 'package:flutter/material.dart';

import '../../../core/utils/flowa_formatters.dart';
import '../../../core/utils/flowa_haptics.dart';
import '../../../core/utils/flowa_services.dart';
import '../../../design_system/components/flowa_actions.dart';
import '../../../design_system/components/flowa_payment_processing.dart';
import '../../../design_system/components/flowa_primitives.dart';
import '../../../design_system/components/flowa_screen.dart';
import '../../../design_system/components/flowa_visa_card.dart';
import '../../../design_system/tokens/flowa_colors.dart';
import '../../../design_system/tokens/flowa_spacing.dart';
import '../../../design_system/tokens/flowa_typography.dart';
import '../../../domain/entities/freelance_entities.dart';
import '../../../shared/navigation/flowa_routes.dart';
import '../../home/presentation/card_profile.dart';
import '../../home/presentation/card_wallet_store.dart';
import '../../transfers/presentation/transfer_success_page.dart';
import 'more_payment_helper.dart';
import 'widgets/more_service_ui.dart';

/// Review step before any Más payment: summary, card picker, processing animation.
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
    final cards = _store.cards;

    return FlowaScreen(
      title: 'Confirmar pago',
      footer: FlowaAcidButton(
        label: 'Pagar ${FlowaFormatters.currency(widget.amount)}',
        loading: _paying,
        onPressed: _selected == null || _loadingCards ? null : _pay,
      ),
      child: _loadingCards
          ? const Center(
              child: CircularProgressIndicator(color: FlowaColors.mint),
            )
          : ListView(
              padding: const EdgeInsets.only(bottom: FlowaSpacing.xl),
              children: [
                FlowaEntrance(
                  child: MoreServiceCard(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Resumen', style: FlowaType.micro()),
                        const SizedBox(height: FlowaSpacing.sm),
                        Text(widget.merchant, style: FlowaType.titleMd()),
                        const SizedBox(height: FlowaSpacing.xs),
                        Text(
                          widget.category,
                          style: FlowaType.bodySm(
                            color: FlowaColors.boneMuted,
                          ),
                        ),
                        if (widget.detailLines.isNotEmpty) ...[
                          const SizedBox(height: FlowaSpacing.sm),
                          for (final line in widget.detailLines)
                            Padding(
                              padding: const EdgeInsets.only(top: 4),
                              child: Text(
                                line,
                                style: FlowaType.bodySm(),
                              ),
                            ),
                        ],
                        const SizedBox(height: FlowaSpacing.lg),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              FlowaFormatters.currency(widget.amount),
                              style: FlowaType.figureLg(
                                color: FlowaColors.mint,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              'Comisión 0 €',
                              style: FlowaType.bodySm(
                                color: FlowaColors.boneFaint,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: FlowaSpacing.xl),
                FlowaEntrance(
                  delay: const Duration(milliseconds: 60),
                  child: const MoreSectionLabel('Pagar con'),
                ),
                const SizedBox(height: FlowaSpacing.sm),
                FlowaEntrance(
                  delay: const Duration(milliseconds: 100),
                  child: SizedBox(
                    height: 132,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: cards.length,
                      separatorBuilder: (_, _) =>
                          const SizedBox(width: FlowaSpacing.sm),
                      itemBuilder: (context, index) {
                        final card = cards[index];
                        final selected = _selected?.account.id == card.account.id;
                        return _CompactCardOption(
                          profile: card,
                          selected: selected,
                          onTap: () {
                            FlowaHaptics.selection();
                            setState(() => _selected = card);
                          },
                        );
                      },
                    ),
                  ),
                ),
                if (_selected != null) ...[
                  const SizedBox(height: FlowaSpacing.lg),
                  FlowaEntrance(
                    delay: const Duration(milliseconds: 140),
                    child: FlowaVisaCard(
                      account: _selected!.account,
                      style: _selected!.style,
                      pattern: _selected!.pattern,
                      caption: _selected!.caption,
                      amount: _selected!.account.availableBalance,
                      height: 168,
                    ),
                  ),
                ],
              ],
            ),
    );
  }
}

class _CompactCardOption extends StatelessWidget {
  const _CompactCardOption({
    required this.profile,
    required this.selected,
    required this.onTap,
  });

  final CardProfile profile;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tint = profile.style;

    return FlowaPressScale(
      onTap: onTap,
      scale: 0.96,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 168,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: FlowaColors.inkHigh,
          borderRadius: FlowaRadii.lgAll,
          border: Border.all(
            color: selected ? FlowaColors.mint : FlowaColors.hairlineStrong,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 28,
                  height: 20,
                  decoration: BoxDecoration(
                    color: tint.fill,
                    borderRadius: BorderRadius.circular(4),
                    border: tint.needsEdge
                        ? Border.all(color: tint.edge, width: 1)
                        : null,
                  ),
                ),
                const Spacer(),
                if (selected)
                  const Icon(
                    Icons.check_circle_rounded,
                    size: 18,
                    color: FlowaColors.mint,
                  ),
              ],
            ),
            const Spacer(),
            Text(
              profile.account.displayName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: FlowaType.titleSm(
                color: selected ? FlowaColors.mint : FlowaColors.bone,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '··· ${profile.account.lastFour}',
              style: FlowaType.bodySm(color: FlowaColors.boneMuted),
            ),
          ],
        ),
      ),
    );
  }
}

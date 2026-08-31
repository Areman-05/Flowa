import 'package:flutter/material.dart';

import '../../../core/utils/flowa_formatters.dart';
import '../../../core/utils/flowa_services.dart';
import '../../../design_system/components/flowa_actions.dart';
import '../../../design_system/components/flowa_icon.dart';
import '../../../design_system/components/flowa_primitives.dart';
import '../../../design_system/components/flowa_transaction_tile.dart';
import '../../../design_system/components/flowa_visa_card.dart';
import '../../../design_system/tokens/flowa_colors.dart';
import '../../../design_system/tokens/flowa_motion_tokens.dart';
import '../../../design_system/tokens/flowa_spacing.dart';
import '../../../design_system/tokens/flowa_typography.dart';
import '../../../domain/entities/finance_entities.dart';
import '../../../domain/entities/freelance_entities.dart';
import '../../../shared/navigation/flowa_routes.dart';
import '../../../shared/widgets/flowa_states.dart';
import '../../insights/domain/spending_snapshot.dart';
import '../../insights/presentation/insights_page.dart';
import '../../invoices/presentation/invoices_page.dart';
import '../../notifications/presentation/notification_inbox_page.dart';
import '../../receive/presentation/receive_page.dart';
import '../../send_money/presentation/send_money_page.dart';
import '../../profile/presentation/profile_page.dart';
import '../../transactions/presentation/transaction_detail_page.dart';
import '../../vault/presentation/tax_vault_sheet.dart';
import 'card_wallet_sheet.dart';
import 'card_wallet_store.dart';

/// Home.
///
/// The hero is not the balance — it is what is left after tax and committed
/// outgoings, because for someone with lumpy income the raw balance is the one
/// number guaranteed to mislead them.
class HomePage extends StatefulWidget {
  const HomePage({
    super.key,
    this.onSeeAllTransactions,
    this.onBadgeRefresh,
    this.onOpenProfile,
    this.onLogout,
  });

  final VoidCallback? onSeeAllTransactions;
  final VoidCallback? onBadgeRefresh;
  final VoidCallback? onOpenProfile;
  final Future<void> Function()? onLogout;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Account? _account;
  UserProfile? _user;
  List<TransactionItem> _recent = const [];
  List<Invoice> _invoices = const [];
  TaxVault _vault = const TaxVault(reserved: 0, rate: 0.25);
  FreelanceOverview _overview = FreelanceOverview.empty;
  SpendingSnapshot _monthSpend = const SpendingSnapshot(
    incoming: 0,
    outgoing: 0,
    net: 0,
    topMerchant: '',
    transactionCount: 0,
  );

  bool _loading = true;
  bool _balanceVisible = true;
  int _unread = 0;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = _account == null;
      _error = null;
    });

    try {
      final now = DateTime.now();
      final account = await FlowaServices.accountRepository.getPrimaryAccount();
      final user = await FlowaServices.accountRepository.getCurrentUser();
      final all = await FlowaServices.transactionRepository.getAll();
      final recent =
          await FlowaServices.transactionRepository.getRecent(limit: 6);
      final hidden =
          await FlowaServices.preferencesRepository.isBalanceHiddenByDefault();
      final unread = await FlowaServices.inboxRepository.unreadCount();
      final vault = await FlowaServices.freelanceRepository.getVault();
      final invoices = await FlowaServices.freelanceRepository.getInvoices();
      final commitments =
          await FlowaServices.freelanceRepository.getCommitments();

      if (!mounted) {
        return;
      }

      setState(() {
        _account = account;
        _user = user;
        _recent = recent;
        _invoices = invoices;
        _vault = vault;
        _unread = unread;
        _balanceVisible = !hidden;
        _overview = FreelanceOverview.compute(
          account: account,
          transactions: all,
          vault: vault,
          invoices: invoices,
          commitments: commitments,
          now: now,
        );
        _monthSpend = SpendingInsights.from(
          all,
          month: DateTime(now.year, now.month),
          range: InsightRange.month,
        );
        _loading = false;
      });
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loading = false;
        _error = error.toString();
      });
    }
  }

  Future<void> _open(Widget page) async {
    await pushFlowaRoute<void>(context, page);
    await _load();
    widget.onBadgeRefresh?.call();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading && (_account == null || _user == null)) {
      return const SafeArea(child: _HomeSkeleton());
    }
    if (_error != null) {
      return SafeArea(child: FlowaErrorState(message: _error!, onRetry: _load));
    }
    final account = _account;
    final user = _user;
    if (account == null || user == null) {
      return const SizedBox.shrink();
    }

    final now = DateTime.now();
    final outstanding = _invoices
        .where((invoice) => invoice.statusAt(now).isOutstanding)
        .take(3)
        .toList(growable: false);

    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        onRefresh: _load,
        color: FlowaColors.mint,
        backgroundColor: FlowaColors.inkHigh,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(
            parent: BouncingScrollPhysics(),
          ),
          padding: const EdgeInsets.fromLTRB(
            FlowaSpacing.gutter,
            FlowaSpacing.md,
            FlowaSpacing.gutter,
            FlowaSpacing.navClearance,
          ),
          children: [
            FlowaEntrance(
              child: _Header(
                user: user,
                unread: _unread,
                onProfile: widget.onOpenProfile ??
                    () => _open(ProfilePage(onLogout: widget.onLogout)),
                onInbox: () => _open(const NotificationInboxPage()),
                onSearch: () => _open(const InsightsPage()),
              ),
            ),
            const SizedBox(height: FlowaSpacing.xl),
            FlowaEntrance(
              delay: FlowaMotion.stagger(1),
              child: Builder(
                builder: (context) {
                  final store = CardWalletStore.instance;
                  store.ensureSeeded(
                    primary: account,
                    vault: _vault,
                    trulyAvailable: _overview.trulyAvailable,
                  );
                  return ListenableBuilder(
                    listenable: store,
                    builder: (context, _) {
                      final live = store.deck;
                      return FlowaCardDeck(
                        cards: [
                          for (final c in live)
                            (
                              account: c.account,
                              tint: c.style,
                              pattern: c.pattern,
                              caption: c.caption,
                              amount: c.account.availableBalance,
                            ),
                        ],
                        onOpen: () => showCardWalletSheet(
                          context: context,
                          primary: account,
                          vault: _vault,
                          trulyAvailable: _overview.trulyAvailable,
                          onChanged: () => setState(() {}),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: FlowaSpacing.xl),
            FlowaEntrance(
              delay: FlowaMotion.stagger(2),
              child: Row(
                children: [
                  FlowaRailAction(
                    label: 'Ingresar',
                    glyph: FlowaGlyph.arrowDown,
                    onTap: () => _open(const ReceivePage()),
                  ),
                  FlowaRailAction(
                    label: 'Enviar',
                    glyph: FlowaGlyph.transfer,
                    onTap: () => _open(const SendMoneyPage()),
                  ),
                  FlowaRailAction(
                    label: 'Bote',
                    glyph: FlowaGlyph.vault,
                    onTap: _openVault,
                  ),
                  FlowaRailAction(
                    label: 'Análisis',
                    glyph: FlowaGlyph.chart,
                    onTap: () => _open(const InsightsPage()),
                  ),
                ],
              ),
            ),
            const SizedBox(height: FlowaSpacing.xl),
            FlowaEntrance(
              delay: FlowaMotion.stagger(3),
              child: _TwinCards(
                monthSpend: _monthSpend,
                overview: _overview,
                invoices: outstanding,
                visible: _balanceVisible,
                onExpenses: () => _open(const InsightsPage()),
                onRecent: () => _open(const InvoicesPage()),
              ),
            ),
            const SizedBox(height: FlowaSpacing.xl),
            FlowaEntrance(
              delay: FlowaMotion.stagger(4),
              child: _HistoryCard(
                items: _recent,
                masked: !_balanceVisible,
                onSeeAll: widget.onSeeAllTransactions,
                onItemTap: (item) => _open(TransactionDetailPage(item: item)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _openVault() async {
    await showTaxVaultSheet(
      context: context,
      vault: _vault,
      overview: _overview,
    );
    await _load();
  }
}

class _Header extends StatelessWidget {
  const _Header({
    required this.user,
    required this.unread,
    required this.onProfile,
    required this.onInbox,
    required this.onSearch,
  });

  final UserProfile user;
  final int unread;
  final VoidCallback onProfile;
  final VoidCallback onInbox;
  final VoidCallback onSearch;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: onProfile,
            behavior: HitTestBehavior.opaque,
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: const BoxDecoration(
                    color: FlowaColors.mint,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    user.firstName.isEmpty
                        ? 'F'
                        : user.firstName[0].toUpperCase(),
                    style: FlowaType.titleMd(color: FlowaColors.mintInk),
                  ),
                ),
                const SizedBox(width: FlowaSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        FlowaGreeting.forDateTime(DateTime.now()),
                        style: FlowaType.micro(color: FlowaColors.boneMuted),
                      ),
                      Text(user.firstName, style: FlowaType.titleLg()),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        FlowaIconAction(
          glyph: FlowaGlyph.search,
          tooltip: 'Buscar',
          onTap: onSearch,
        ),
        const SizedBox(width: FlowaSpacing.xs),
        FlowaIconAction(
          glyph: FlowaGlyph.bell,
          tooltip: 'Notificaciones',
          badge: unread > 0,
          onTap: onInbox,
        ),
      ],
    );
  }
}

/// Expenses + recent invoices, side by side like Privat.
class _TwinCards extends StatelessWidget {
  const _TwinCards({
    required this.monthSpend,
    required this.overview,
    required this.invoices,
    required this.visible,
    required this.onExpenses,
    required this.onRecent,
  });

  final SpendingSnapshot monthSpend;
  final FreelanceOverview overview;
  final List<Invoice> invoices;
  final bool visible;
  final VoidCallback onExpenses;
  final VoidCallback onRecent;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _Panel(
              onTap: onExpenses,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('Gastos', style: FlowaType.titleSm()),
                      const Spacer(),
                      const FlowaIconOrb(
                        glyph: FlowaGlyph.arrowUp,
                        size: 32,
                        background: FlowaColors.mintTintedSurface,
                        foreground: FlowaColors.mint,
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text('Este mes', style: FlowaType.micro()),
                  const SizedBox(height: 4),
                  Text(
                    visible
                        ? FlowaFormatters.compact(monthSpend.outgoing)
                        : '••••',
                    style: FlowaType.figureMd(),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: FlowaSpacing.sm),
          Expanded(
            child: _Panel(
              onTap: onRecent,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Pendiente', style: FlowaType.titleSm()),
                  const SizedBox(height: FlowaSpacing.md),
                  if (invoices.isEmpty)
                    Text(
                      'Sin facturas abiertas',
                      style: FlowaType.bodySm(),
                    )
                  else
                    Wrap(
                      spacing: -10,
                      children: [
                        for (var i = 0; i < invoices.take(3).length; i++)
                          Transform.translate(
                            offset: Offset(i * -8.0, 0),
                            child: Container(
                              width: 34,
                              height: 34,
                              decoration: BoxDecoration(
                                color: i.isEven
                                    ? FlowaColors.mint
                                    : FlowaColors.inkPressed,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: FlowaColors.inkHigh,
                                  width: 2,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                invoices[i].client.isEmpty
                                    ? '·'
                                    : invoices[i].client[0].toUpperCase(),
                                style: FlowaType.micro(
                                  color: i.isEven
                                      ? FlowaColors.mintInk
                                      : FlowaColors.bone,
                                ),
                              ),
                            ),
                          ),
                        Transform.translate(
                          offset: Offset(
                            invoices.take(3).length * -8.0,
                            0,
                          ),
                          child: Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: FlowaColors.mint,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: FlowaColors.inkHigh,
                                width: 2,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: const FlowaIcon(
                              FlowaGlyph.plus,
                              size: 14,
                              color: FlowaColors.mintInk,
                            ),
                          ),
                        ),
                      ],
                    ),
                  const Spacer(),
                  Text(
                    visible
                        ? FlowaFormatters.compact(overview.outstandingInvoiced)
                        : '••••',
                    style: FlowaType.amountMd(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child, required this.onTap});

  final Widget child;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(FlowaSpacing.md),
        decoration: const BoxDecoration(
          color: FlowaColors.inkHigh,
          borderRadius: FlowaRadii.mdAll,
        ),
        child: child,
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({
    required this.items,
    required this.masked,
    required this.onSeeAll,
    required this.onItemTap,
  });

  final List<TransactionItem> items;
  final bool masked;
  final VoidCallback? onSeeAll;
  final ValueChanged<TransactionItem> onItemTap;

  @override
  Widget build(BuildContext context) {
    final preview = items.take(6).toList(growable: false);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      decoration: const BoxDecoration(
        color: FlowaColors.inkHigh,
        borderRadius: FlowaRadii.xxlAll,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Historial', style: FlowaType.titleSm()),
          if (preview.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: FlowaSpacing.md),
              child: Text('Sin movimientos', style: FlowaType.bodySm()),
            )
          else
            for (final item in preview)
              FlowaTransactionTile(
                item: item,
                masked: masked,
                orbBackground: FlowaColors.ink,
                onTap: () => onItemTap(item),
              ),
          const SizedBox(height: FlowaSpacing.xs),
          FlowaPressScale(
            onTap: onSeeAll,
            child: Container(
              height: 44,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: FlowaColors.mint,
                borderRadius: FlowaRadii.pillAll,
              ),
              child: Text(
                'Ver historial completo',
                style: FlowaType.label(color: FlowaColors.mintInk),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HomeSkeleton extends StatelessWidget {
  const _HomeSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: FlowaSpacing.gutter),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: FlowaSpacing.xxl),
          _Bone(width: 120, height: 10),
          SizedBox(height: FlowaSpacing.md),
          _Bone(width: 220, height: 52),
          SizedBox(height: FlowaSpacing.xxl),
          FlowaRule(),
          SizedBox(height: FlowaSpacing.xl),
          _Bone(height: 96),
          SizedBox(height: FlowaSpacing.xl),
          _Bone(height: 52),
        ],
      ),
    );
  }
}

class _Bone extends StatelessWidget {
  const _Bone({this.width = double.infinity, this.height = 16});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: const BoxDecoration(
        color: FlowaColors.inkHigh,
        borderRadius: FlowaRadii.xsAll,
      ),
    );
  }
}

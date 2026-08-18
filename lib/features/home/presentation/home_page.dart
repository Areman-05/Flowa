import 'package:flutter/material.dart';

import '../../../core/utils/flowa_formatters.dart';
import '../../../core/utils/flowa_services.dart';
import '../../../design_system/components/flowa_motion.dart';
import '../../../design_system/components/flowa_transaction_tile.dart';
import '../../../design_system/components/flowa_visa_card.dart';
import '../../../design_system/tokens/flowa_colors.dart';
import '../../../design_system/tokens/flowa_spacing.dart';
import '../../../domain/entities/finance_entities.dart';
import '../../../shared/navigation/flowa_routes.dart';
import '../../../shared/widgets/flowa_buttons.dart';
import '../../../shared/widgets/flowa_more_sheet.dart';
import '../../../shared/widgets/flowa_states.dart';
import '../../insights/domain/spending_snapshot.dart';
import '../../insights/presentation/insights_page.dart';
import '../../notifications/presentation/notification_inbox_page.dart';
import '../../receive/presentation/receive_page.dart';
import '../../send_money/presentation/send_money_page.dart';
import '../../top_up/presentation/top_up_page.dart';
import '../../transactions/presentation/transaction_detail_page.dart';

/// Home dashboard with live account card and recent transactions.
class HomePage extends StatefulWidget {
  const HomePage({super.key, this.onSeeAllTransactions});

  final VoidCallback? onSeeAllTransactions;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Account? _account;
  UserProfile? _user;
  List<TransactionItem> _recent = const [];
  SpendingSnapshot _snapshot = const SpendingSnapshot(
    incoming: 0,
    outgoing: 0,
    net: 0,
    topMerchant: '—',
    transactionCount: 0,
  );
  bool _loading = true;
  bool _balanceVisible = false;
  bool _cardFrozen = false;
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
      final results = await Future.wait([
        FlowaServices.accountRepository.getPrimaryAccount(),
        FlowaServices.accountRepository.getCurrentUser(),
        FlowaServices.transactionRepository.getRecent(),
        FlowaServices.preferencesRepository.isBalanceHiddenByDefault(),
        FlowaServices.transactionRepository.getAll(),
        FlowaServices.inboxRepository.unreadCount(),
      ]);

      if (!mounted) {
        return;
      }

      setState(() {
        _account = results[0] as Account;
        _user = results[1] as UserProfile;
        _recent = results[2] as List<TransactionItem>;
        final hiddenByDefault = results[3] as bool;
        _balanceVisible = !hiddenByDefault;
        _snapshot = SpendingInsights.from(results[4] as List<TransactionItem>);
        _unread = results[5] as int;
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
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    if (_loading && (_account == null || _user == null)) {
      return const SafeArea(child: FlowaHomeSkeleton());
    }

    if (_error != null) {
      return SafeArea(
        child: FlowaErrorState(message: _error!, onRetry: _load),
      );
    }

    if (_account == null || _user == null) {
      return const SizedBox.shrink();
    }

    return SafeArea(
      child: RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: FlowaSpacing.screenPadding,
          children: [
            Row(
              children: [
                const CircleAvatar(
                  radius: 22,
                  backgroundColor: FlowaColors.primarySoft,
                  child: Icon(Icons.person, color: FlowaColors.primary),
                ),
                const SizedBox(width: FlowaSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        FlowaGreeting.forDateTime(DateTime.now()),
                        style: textTheme.bodyMedium,
                      ),
                      Text(_user!.fullName, style: textTheme.titleLarge),
                    ],
                  ),
                ),
                IconButton.outlined(
                  onPressed: () async {
                    await _open(const NotificationInboxPage());
                    await _load();
                  },
                  icon: Badge(
                    isLabelVisible: _unread > 0,
                    smallSize: 8,
                    child: const Icon(Icons.notifications_none_rounded),
                  ),
                ),
              ],
            ),
            const SizedBox(height: FlowaSpacing.lg),
            FlowaVisaCard(
              account: _account!,
              balanceVisible: _balanceVisible,
              isFrozen: _cardFrozen,
              onToggleVisibility: () {
                setState(() => _balanceVisible = !_balanceVisible);
              },
              onToggleFreeze: () {
                setState(() => _cardFrozen = !_cardFrozen);
              },
            ),
            const SizedBox(height: FlowaSpacing.md),
            GestureDetector(
              onTap: () => _open(const InsightsPage()),
              child: HomeSpendingStrip(snapshot: _snapshot),
            ),
            const SizedBox(height: FlowaSpacing.xl),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                FlowaQuickAction(
                  label: 'Send',
                  icon: Icons.account_balance_wallet_outlined,
                  background: FlowaColors.actionSend,
                  onTap: () => _open(const SendMoneyPage()),
                ),
                FlowaQuickAction(
                  label: 'Receive',
                  icon: Icons.payments_outlined,
                  background: FlowaColors.actionReceive,
                  onTap: () => _open(const ReceivePage()),
                ),
                FlowaQuickAction(
                  label: 'Top-Up',
                  icon: Icons.point_of_sale_outlined,
                  background: FlowaColors.actionTopUp,
                  onTap: () => _open(const TopUpPage()),
                ),
                FlowaQuickAction(
                  label: 'More',
                  icon: Icons.grid_view_rounded,
                  background: FlowaColors.actionMore,
                  onTap: () => showFlowaMoreActionsSheet(context),
                ),
              ],
            ),
            const SizedBox(height: FlowaSpacing.xl),
            Row(
              children: [
                Text('Recent Transaction', style: textTheme.titleMedium),
                const Spacer(),
                TextButton(
                  onPressed: widget.onSeeAllTransactions,
                  child: const Text('See all >'),
                ),
              ],
            ),
            const SizedBox(height: FlowaSpacing.sm),
            FlowaTransactionList(
              items: _recent,
              onItemTap: (item) {
                pushFlowaRoute<void>(
                  context,
                  TransactionDetailPage(item: item),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

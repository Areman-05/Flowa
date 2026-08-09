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
  bool _loading = true;
  bool _balanceVisible = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final results = await Future.wait([
      FlowaServices.accountRepository.getPrimaryAccount(),
      FlowaServices.accountRepository.getCurrentUser(),
      FlowaServices.transactionRepository.getRecent(),
      FlowaServices.preferencesRepository.isBalanceHiddenByDefault(),
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
      _loading = false;
    });
  }

  Future<void> _open(Widget page) async {
    await pushFlowaRoute<void>(context, page);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    if (_loading || _account == null || _user == null) {
      return const SafeArea(child: FlowaHomeSkeleton());
    }

    return SafeArea(
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
                onPressed: () {},
                icon: const Badge(
                  smallSize: 8,
                  child: Icon(Icons.notifications_none_rounded),
                ),
              ),
            ],
          ),
          const SizedBox(height: FlowaSpacing.lg),
          FlowaVisaCard(
            account: _account!,
            balanceVisible: _balanceVisible,
            onToggleVisibility: () {
              setState(() => _balanceVisible = !_balanceVisible);
            },
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
    );
  }
}

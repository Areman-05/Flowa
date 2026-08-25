import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../core/utils/flowa_services.dart';
import '../design_system/components/flowa_capsule_nav.dart';
import '../design_system/components/flowa_icon.dart';
import '../design_system/components/flowa_texture.dart';
import '../design_system/tokens/flowa_colors.dart';
import '../design_system/tokens/flowa_motion_tokens.dart';
import '../features/ai_assistant/presentation/ai_assistant_page.dart';
import '../features/home/presentation/home_page.dart';
import '../features/invoices/presentation/invoices_page.dart';
import '../features/profile/presentation/profile_page.dart';
import '../features/transactions/presentation/transactions_page.dart';

/// Root shell. The canvas lives here so texture stays continuous across tabs.
class MainShell extends StatefulWidget {
  const MainShell({super.key, this.onLogout});

  final Future<void> Function()? onLogout;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;
  int _unread = 0;

  @override
  void initState() {
    super.initState();
    _refreshBadge();
  }

  void _openTransactionsTab() => setState(() => _index = 2);

  Future<void> _refreshBadge() async {
    final count = await FlowaServices.inboxRepository.unreadCount();
    if (!mounted) {
      return;
    }
    setState(() => _unread = count);
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      HomePage(
        onSeeAllTransactions: _openTransactionsTab,
        onBadgeRefresh: _refreshBadge,
      ),
      const _Tab(child: InvoicesPage(embedded: true)),
      const _Tab(child: TransactionsPage(embedded: true)),
      const _Tab(child: AiAssistantPage(embedded: true)),
      _Tab(child: ProfilePage(embedded: true, onLogout: widget.onLogout)),
    ];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        extendBody: true,
        backgroundColor: FlowaColors.ink,
        body: FlowaCanvas(
          child: AnimatedSwitcher(
            duration: FlowaMotion.base,
            switchInCurve: FlowaMotion.expoOut,
            switchOutCurve: FlowaMotion.exit,
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: child,
            ),
            child: KeyedSubtree(
              key: ValueKey<int>(_index),
              child: pages[_index],
            ),
          ),
        ),
        bottomNavigationBar: FlowaCapsuleNav(
          index: _index,
          onSelected: (value) {
            setState(() => _index = value);
            _refreshBadge();
          },
          items: [
            const FlowaNavItem(glyph: FlowaGlyph.home, label: 'Inicio'),
            const FlowaNavItem(glyph: FlowaGlyph.receipt, label: 'Facturas'),
            const FlowaNavItem(glyph: FlowaGlyph.transfer, label: 'Movs'),
            const FlowaNavItem(glyph: FlowaGlyph.chart, label: 'IA'),
            FlowaNavItem(
              glyph: FlowaGlyph.person,
              label: 'Perfil',
              badge: _unread > 0,
            ),
          ],
        ),
      ),
    );
  }
}

class _Tab extends StatelessWidget {
  const _Tab({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => child;
}

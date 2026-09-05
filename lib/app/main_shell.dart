import 'package:flutter/material.dart';

import 'package:flutter/services.dart';

import '../core/utils/flowa_services.dart';
import '../core/utils/flowa_shell_nav.dart';
import '../design_system/components/flowa_capsule_nav.dart';
import '../design_system/components/flowa_icon.dart';
import '../design_system/components/flowa_texture.dart';
import '../design_system/tokens/flowa_colors.dart';
import '../design_system/tokens/flowa_motion_tokens.dart';
import '../features/home/presentation/home_page.dart';
import '../features/invoices/presentation/invoices_page.dart';
import '../features/more/presentation/more_page.dart';
import '../features/profile/presentation/profile_page.dart';
import '../features/transactions/presentation/transactions_page.dart';
import '../shared/navigation/flowa_routes.dart';

/// Root shell. The canvas lives here so texture stays continuous across tabs.
///
/// Primary nav follows the freelance thesis: money home, por cobrar, movements,
/// and Más — rewards stay out of the rail.
class MainShell extends StatefulWidget {
  const MainShell({super.key, this.onLogout});

  final Future<void> Function()? onLogout;

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    FlowaShellNav.openHome = () => setState(() => _index = 0);
    FlowaShellNav.openPorCobrar = () => setState(() => _index = 1);
    FlowaShellNav.openMovimientos = () => setState(() => _index = 2);
    _refreshBadge();
  }

  @override
  void dispose() {
    FlowaShellNav.openHome = null;
    FlowaShellNav.openPorCobrar = null;
    FlowaShellNav.openMovimientos = null;
    super.dispose();
  }

  void _openTransactionsTab() => setState(() => _index = 2);

  void _openPorCobrarTab() => setState(() => _index = 1);

  Future<void> _refreshBadge() async {
    await FlowaServices.inboxRepository.unreadCount();
    if (!mounted) {
      return;
    }
    setState(() {});
  }

  Future<void> _openProfile() async {
    await pushFlowaRoute<void>(
      context,
      ProfilePage(onLogout: widget.onLogout),
    );
    await _refreshBadge();
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      HomePage(
        onSeeAllTransactions: _openTransactionsTab,
        onOpenPorCobrar: _openPorCobrarTab,
        onBadgeRefresh: _refreshBadge,
        onLogout: widget.onLogout,
        onOpenProfile: _openProfile,
      ),
      const _Tab(child: InvoicesPage(embedded: true)),
      const _Tab(child: TransactionsPage(embedded: true)),
      const _Tab(child: MorePage(embedded: true)),
    ];

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        extendBody: true,
        backgroundColor: FlowaColors.inkSurface,
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
          items: const [
            FlowaNavItem(glyph: FlowaGlyph.home, label: 'Inicio'),
            FlowaNavItem(glyph: FlowaGlyph.receipt, label: 'Por cobrar'),
            FlowaNavItem(glyph: FlowaGlyph.transfer, label: 'Movs'),
            FlowaNavItem(glyph: FlowaGlyph.grid, label: 'Más'),
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

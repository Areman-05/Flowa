import 'package:flutter/material.dart';

import '../core/utils/flowa_services.dart';
import '../design_system/tokens/flowa_colors.dart';
import '../features/ai_assistant/presentation/ai_assistant_page.dart';
import '../features/home/presentation/home_page.dart';
import '../features/profile/presentation/profile_page.dart';
import '../features/transactions/presentation/transactions_page.dart';

/// Root shell with Inicio · Movimientos · IA · Perfil navigation.
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

  void _openTransactionsTab() {
    setState(() => _index = 1);
  }

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
      const TransactionsPage(),
      const AiAssistantPage(),
      ProfilePage(onLogout: widget.onLogout),
    ];

    return Scaffold(
      body: IndexedStack(index: _index, children: pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        backgroundColor: FlowaColors.surface,
        indicatorColor: FlowaColors.primarySoft,
        onDestinationSelected: (value) {
          setState(() => _index = value);
          _refreshBadge();
        },
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home_rounded),
            label: 'Inicio',
            tooltip: 'Inicio',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: _unread > 0,
              smallSize: 8,
              child: const Icon(Icons.receipt_long_outlined),
            ),
            selectedIcon: Badge(
              isLabelVisible: _unread > 0,
              smallSize: 8,
              child: const Icon(Icons.receipt_long_rounded),
            ),
            label: 'Movimientos',
            tooltip: 'Historial de movimientos',
          ),
          const NavigationDestination(
            icon: Icon(Icons.auto_awesome_outlined),
            selectedIcon: Icon(Icons.auto_awesome),
            label: 'IA',
            tooltip: 'Asistente IA',
          ),
          const NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person_rounded),
            label: 'Perfil',
            tooltip: 'Perfil y ajustes',
          ),
        ],
      ),
    );
  }
}

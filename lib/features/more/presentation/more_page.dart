import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../../core/utils/flowa_services.dart';
import '../../../design_system/components/flowa_actions.dart';
import '../../../design_system/components/flowa_icon.dart';
import '../../../design_system/components/flowa_primitives.dart';
import '../../../design_system/components/flowa_texture.dart';
import '../../../design_system/tokens/flowa_colors.dart';
import '../../../design_system/tokens/flowa_spacing.dart';
import '../../../design_system/tokens/flowa_typography.dart';
import '../../../shared/navigation/flowa_routes.dart';
import '../../notifications/presentation/notification_inbox_page.dart';
import '../../rewards/presentation/rewards_page.dart';
import '../../settings/presentation/app_settings_page.dart';
import '../../support/presentation/support_center_page.dart';
import '../domain/more_service_catalog.dart';
import 'more_bill_pay_page.dart';
import 'more_service_pages.dart';

class _MoreMenuItem {
  const _MoreMenuItem({
    required this.label,
    required this.icon,
    required this.page,
    this.hubLabel,
  });

  final String label;
  final String? hubLabel;
  final IconData icon;
  final Widget page;

  String get displayLabel => hubLabel ?? label;
}

/// Hub utilidades — lista fintech (mint + ink), no supermercado de tiles.
class MorePage extends StatefulWidget {
  const MorePage({super.key, this.embedded = false});

  final bool embedded;

  @override
  State<MorePage> createState() => _MorePageState();
}

class _MorePageState extends State<MorePage> {
  int _unread = 0;

  @override
  void initState() {
    super.initState();
    _refreshBadge();
  }

  Future<void> _refreshBadge() async {
    final unread = await FlowaServices.inboxRepository.unreadCount();
    if (!mounted) {
      return;
    }
    setState(() => _unread = unread);
  }

  Future<void> _open(BuildContext context, Widget page) async {
    await pushFlowaRoute<void>(context, page);
  }

  Future<void> _openInbox() async {
    await pushFlowaRoute<void>(context, const NotificationInboxPage());
    await _refreshBadge();
  }

  @override
  Widget build(BuildContext context) {
    final embedded = widget.embedded;
    const pagos = [
      _MoreMenuItem(
        label: 'Móvil',
        icon: LucideIcons.smartphone,
        page: MoreBillPayPage(service: MoreServiceCatalog.mobile),
      ),
      _MoreMenuItem(
        label: 'Suministros',
        hubLabel: 'Luz y gas',
        icon: LucideIcons.house,
        page: MoreBillPayPage(service: MoreServiceCatalog.utilities),
      ),
      _MoreMenuItem(
        label: 'Internet',
        icon: LucideIcons.globe,
        page: MoreBillPayPage(service: MoreServiceCatalog.internet),
      ),
      _MoreMenuItem(
        label: 'TV',
        icon: LucideIcons.tv,
        page: MoreBillPayPage(service: MoreServiceCatalog.tv),
      ),
    ];

    const servicios = [
      _MoreMenuItem(
        label: 'Entradas',
        icon: LucideIcons.ticket,
        page: MoreTicketsPage(),
      ),
      _MoreMenuItem(
        label: 'Seguro',
        icon: LucideIcons.shield,
        page: MoreInsurancePage(),
      ),
      _MoreMenuItem(
        label: 'Pago QR',
        hubLabel: 'QR',
        icon: LucideIcons.qr_code,
        page: MoreQrPayPage(),
      ),
      _MoreMenuItem(
        label: 'Donaciones',
        hubLabel: 'Donar',
        icon: LucideIcons.heart_handshake,
        page: MoreDonationsPage(),
      ),
    ];

    const otros = [
      _MoreMenuItem(
        label: 'Recompensas',
        icon: LucideIcons.gift,
        page: RewardsPage(),
      ),
      _MoreMenuItem(
        label: 'Cambio',
        icon: LucideIcons.refresh_cw,
        page: MoreExchangePage(),
      ),
      _MoreMenuItem(
        label: 'Sucursales',
        hubLabel: 'Oficinas',
        icon: LucideIcons.map_pin,
        page: MoreBranchesPage(),
      ),
      _MoreMenuItem(
        label: 'Soporte',
        icon: LucideIcons.headset,
        page: SupportCenterPage(),
      ),
      _MoreMenuItem(
        label: 'Ajustes',
        icon: LucideIcons.settings,
        page: AppSettingsPage(),
      ),
    ];

    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.fromLTRB(
              FlowaSpacing.gutter,
              embedded ? FlowaSpacing.xs : FlowaSpacing.md,
              FlowaSpacing.gutter,
              embedded ? FlowaSpacing.navClearance + 8 : FlowaSpacing.xl,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(child: Text('Más', style: FlowaType.titleLg())),
                    FlowaIconAction(
                      glyph: FlowaGlyph.bell,
                      tooltip: 'Avisos',
                      badge: _unread > 0,
                      onTap: _openInbox,
                    ),
                  ],
                ),
                const SizedBox(height: FlowaSpacing.sm),
                Text(
                  'Pagos y utilidades',
                  style: FlowaType.bodySm(color: FlowaColors.boneMuted),
                ),
                SizedBox(height: embedded ? FlowaSpacing.lg : FlowaSpacing.xl),
                FlowaEntrance(
                  rise: 0,
                  child: _MoreSection(
                    title: 'Pagos',
                    items: pagos,
                    onTap: (page) => _open(context, page),
                  ),
                ),
                const SizedBox(height: FlowaSpacing.md),
                FlowaEntrance(
                  rise: 0,
                  delay: const Duration(milliseconds: 40),
                  child: _MoreSection(
                    title: 'Servicios',
                    items: servicios,
                    onTap: (page) => _open(context, page),
                  ),
                ),
                const SizedBox(height: FlowaSpacing.md),
                FlowaEntrance(
                  rise: 0,
                  delay: const Duration(milliseconds: 80),
                  child: _MoreSection(
                    title: 'Cuenta',
                    items: otros,
                    onTap: (page) => _open(context, page),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );

    if (embedded) {
      return SafeArea(bottom: false, child: body);
    }

    return Scaffold(
      backgroundColor: FlowaColors.ink,
      body: FlowaCanvas(child: SafeArea(child: body)),
    );
  }
}

class _MoreSection extends StatelessWidget {
  const _MoreSection({
    required this.title,
    required this.items,
    required this.onTap,
  });

  final String title;
  final List<_MoreMenuItem> items;
  final ValueChanged<Widget> onTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            title,
            style: FlowaType.micro(color: FlowaColors.boneMuted),
          ),
        ),
        Container(
          decoration: const BoxDecoration(
            color: FlowaColors.inkHigh,
            borderRadius: FlowaRadii.xxlAll,
          ),
          child: Column(
            children: [
              for (var i = 0; i < items.length; i++) ...[
                _MoreRow(
                  item: items[i],
                  onTap: () => onTap(items[i].page),
                ),
                if (i < items.length - 1)
                  const Divider(
                    height: 1,
                    thickness: 1,
                    indent: 68,
                    color: FlowaColors.hairline,
                  ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _MoreRow extends StatelessWidget {
  const _MoreRow({
    required this.item,
    required this.onTap,
  });

  final _MoreMenuItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FlowaPressScale(
      onTap: onTap,
      scale: 0.985,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 42,
              height: 42,
              decoration: const BoxDecoration(
                color: FlowaColors.mintTintedSurface,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: FlowaLucideIcon(
                item.icon,
                size: 20,
                color: FlowaColors.mint,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Text(item.displayLabel, style: FlowaType.titleSm()),
            ),
            const FlowaIcon(
              FlowaGlyph.arrowRight,
              size: 18,
              color: FlowaColors.boneGhost,
            ),
          ],
        ),
      ),
    );
  }
}

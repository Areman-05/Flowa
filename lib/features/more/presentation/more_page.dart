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
import '../../settings/presentation/app_settings_page.dart';
import '../../support/presentation/support_center_page.dart';
import '../domain/more_service_catalog.dart';
import 'more_bill_pay_page.dart';
import 'more_service_pages.dart';
import 'widgets/more_payment_ui.dart';

class _MoreMenuItem {
  const _MoreMenuItem({
    required this.label,
    required this.icon,
    required this.page,
    required this.accent,
    this.hubLabel,
  });

  final String label;
  final String? hubLabel;
  final IconData icon;
  final Widget page;
  final Color accent;

  String get displayLabel => hubLabel ?? label;
}

/// Hub bancario — pagos, servicios y utilidades.
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
        accent: Color(0xFF00A9E0),
        page: MoreBillPayPage(service: MoreServiceCatalog.mobile),
      ),
      _MoreMenuItem(
        label: 'Suministros',
        hubLabel: 'Luz y gas',
        icon: LucideIcons.house,
        accent: Color(0xFF7A94D4),
        page: MoreBillPayPage(service: MoreServiceCatalog.utilities),
      ),
      _MoreMenuItem(
        label: 'Internet',
        icon: LucideIcons.globe,
        accent: Color(0xFF6B7FD7),
        page: MoreBillPayPage(service: MoreServiceCatalog.internet),
      ),
      _MoreMenuItem(
        label: 'TV',
        icon: LucideIcons.tv,
        accent: Color(0xFFCC9168),
        page: MoreBillPayPage(service: MoreServiceCatalog.tv),
      ),
    ];

    const servicios = [
      _MoreMenuItem(
        label: 'Entradas',
        icon: LucideIcons.ticket,
        accent: Color(0xFF9A7EC8),
        page: MoreTicketsPage(),
      ),
      _MoreMenuItem(
        label: 'Seguro',
        icon: LucideIcons.shield,
        accent: Color(0xFFCC7888),
        page: MoreInsurancePage(),
      ),
      _MoreMenuItem(
        label: 'Pago QR',
        hubLabel: 'QR',
        icon: LucideIcons.qr_code,
        accent: Color(0xFF8B7FD4),
        page: MoreQrPayPage(),
      ),
      _MoreMenuItem(
        label: 'Donaciones',
        hubLabel: 'Donar',
        icon: LucideIcons.heart_handshake,
        accent: Color(0xFF6DB892),
        page: MoreDonationsPage(),
      ),
    ];

    const otros = [
      _MoreMenuItem(
        label: 'Cambio',
        icon: LucideIcons.refresh_cw,
        accent: Color(0xFF6890B8),
        page: MoreExchangePage(),
      ),
      _MoreMenuItem(
        label: 'Sucursales',
        hubLabel: 'Oficinas',
        icon: LucideIcons.map_pin,
        accent: Color(0xFFE8A838),
        page: MoreBranchesPage(),
      ),
      _MoreMenuItem(
        label: 'Soporte',
        icon: LucideIcons.headset,
        accent: Color(0xFF8888A0),
        page: SupportCenterPage(),
      ),
      _MoreMenuItem(
        label: 'Ajustes',
        icon: LucideIcons.settings,
        accent: Color(0xFFC4A060),
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
                    title: 'Otros',
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
    return MoreFintechCard(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: FlowaType.titleSm()),
          const SizedBox(height: FlowaSpacing.md),
          LayoutBuilder(
            builder: (context, constraints) {
              const gap = FlowaSpacing.sm;
              final tileWidth = (constraints.maxWidth - gap * 3) / 4;

              return Wrap(
                spacing: gap,
                runSpacing: FlowaSpacing.sm,
                children: [
                  for (final item in items)
                    SizedBox(
                      width: tileWidth,
                      child: _MoreTile(
                        item: item,
                        onTap: () => onTap(item.page),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _MoreTile extends StatelessWidget {
  const _MoreTile({
    required this.item,
    required this.onTap,
  });

  final _MoreMenuItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FlowaPressScale(
      onTap: onTap,
      scale: 0.97,
      haptic: false,
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: Container(
              decoration: BoxDecoration(
                color: FlowaColors.inkSurface,
                borderRadius: FlowaRadii.lgAll,
                border: Border.all(
                  color: item.accent.withValues(alpha: 0.18),
                ),
              ),
              child: Center(
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: item.accent.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: FlowaLucideIcon(
                    item.icon,
                    size: 22,
                    color: item.accent,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 32,
            child: Center(
              child: Text(
                item.displayLabel,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: FlowaType.micro(color: FlowaColors.boneMuted),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

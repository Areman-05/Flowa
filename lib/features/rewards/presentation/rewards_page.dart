import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:intl/intl.dart';

import '../../../core/utils/flowa_formatters.dart';
import '../../../core/utils/flowa_services.dart';
import '../../../data/datasources/flowa_rewards_demo.dart';
import '../../../design_system/components/flowa_actions.dart';
import '../../../design_system/components/flowa_icon.dart';
import '../../../design_system/components/flowa_primitives.dart';
import '../../../design_system/components/flowa_texture.dart';
import '../../../design_system/tokens/flowa_colors.dart';
import '../../../design_system/tokens/flowa_spacing.dart';
import '../../../design_system/tokens/flowa_typography.dart';
import '../../../domain/entities/reward_entities.dart';
import '../../../shared/navigation/flowa_routes.dart';
import '../../notifications/presentation/notification_inbox_page.dart';
import 'all_offers_page.dart';

/// Cashback & partner rewards — replaces the old AI assistant tab.
class RewardsPage extends StatefulWidget {
  const RewardsPage({super.key, this.embedded = false});

  final bool embedded;

  @override
  State<RewardsPage> createState() => _RewardsPageState();
}

class _RewardsPageState extends State<RewardsPage> {
  int _unread = 0;
  late List<CashbackEntry> _recent;
  late double _balance;

  @override
  void initState() {
    super.initState();
    _loadData();
    _refreshBadge();
  }

  void _loadData() {
    final now = DateTime.now();
    _recent = FlowaRewardsDemo.recent(now);
    _balance = FlowaRewardsDemo.totalBalance(_recent) + 439.65;
  }

  Future<void> _refreshBadge() async {
    final count = await FlowaServices.inboxRepository.unreadCount();
    if (!mounted) {
      return;
    }
    setState(() => _unread = count);
  }

  Future<void> _openInbox() async {
    await pushFlowaRoute<void>(context, const NotificationInboxPage());
    await _refreshBadge();
  }

  Future<void> _openAllOffers() async {
    await pushFlowaRoute<void>(context, const AllOffersPage());
  }

  String _relativeStamp(DateTime value) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final day = DateTime(value.year, value.month, value.day);
    final time = DateFormat('HH:mm', 'es_ES').format(value);
    if (day == today) {
      return 'Hoy, $time';
    }
    if (day == today.subtract(const Duration(days: 1))) {
      return 'Ayer, $time';
    }
    return DateFormat('d MMM · HH:mm', 'es_ES').format(value);
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = widget.embedded
        ? FlowaSpacing.navClearance + FlowaSpacing.lg
        : FlowaSpacing.xl;

    final body = RefreshIndicator(
      onRefresh: () async {
        _loadData();
        await _refreshBadge();
        setState(() {});
      },
      color: FlowaColors.mint,
      backgroundColor: FlowaColors.inkHigh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(
          parent: BouncingScrollPhysics(),
        ),
        padding: EdgeInsets.fromLTRB(
          FlowaSpacing.gutter,
          FlowaSpacing.md,
          FlowaSpacing.gutter,
          bottomPad,
        ),
        children: [
          Row(
            children: [
              Expanded(
                child: Text('Recompensas', style: FlowaType.titleLg()),
              ),
              FlowaIconAction(
                glyph: FlowaGlyph.bell,
                tooltip: 'Avisos',
                badge: _unread > 0,
                onTap: _openInbox,
              ),
            ],
          ),
          const SizedBox(height: FlowaSpacing.lg),
          FlowaEntrance(
            child: _CashbackHeroCard(balance: _balance),
          ),
          const SizedBox(height: FlowaSpacing.xl),
          Row(
            children: [
              Expanded(
                child: Text('Ofertas populares', style: FlowaType.titleSm()),
              ),
              FlowaPressScale(
                onTap: _openAllOffers,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                    vertical: 6,
                  ),
                  child: Text(
                    'Ver todas',
                    style: FlowaType.micro(color: FlowaColors.mint),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: FlowaSpacing.md),
          SizedBox(
            height: _OfferCard.height,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              primary: false,
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              itemCount: FlowaRewardsDemo.popularOffers.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(width: FlowaSpacing.sm),
              itemBuilder: (context, index) {
                return _OfferCard(
                  offer: FlowaRewardsDemo.popularOffers[index],
                );
              },
            ),
          ),
          const SizedBox(height: FlowaSpacing.xl),
          Text('Cashback reciente', style: FlowaType.titleSm()),
          const SizedBox(height: FlowaSpacing.md),
          FlowaEntrance(
            child: Container(
              decoration: BoxDecoration(
                color: FlowaColors.inkHigh,
                borderRadius: FlowaRadii.xlAll,
                boxShadow: FlowaShadows.soft,
              ),
              child: Column(
                children: [
                  for (var i = 0; i < _recent.length; i++) ...[
                    _CashbackRow(
                      entry: _recent[i],
                      stamp: _relativeStamp(_recent[i].occurredAt),
                    ),
                    if (i < _recent.length - 1)
                      const Divider(
                        height: 1,
                        thickness: 1,
                        color: FlowaColors.hairline,
                        indent: 72,
                      ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: FlowaSpacing.lg),
          Text(
            'Cashback en compras de proveedores habituales. '
            'Las recompensas se acumulan automáticamente.',
            style: FlowaType.bodySm(color: FlowaColors.boneMuted).copyWith(
              height: 1.55,
            ),
          ),
        ],
      ),
    );

    if (widget.embedded) {
      return SafeArea(bottom: false, child: body);
    }

    return Scaffold(
      backgroundColor: FlowaColors.ink,
      body: FlowaCanvas(child: SafeArea(child: body)),
    );
  }
}

class _CashbackHeroCard extends StatelessWidget {
  const _CashbackHeroCard({required this.balance});

  final double balance;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 22, 16, 22),
      decoration: BoxDecoration(
        gradient: FlowaColors.cardFace,
        borderRadius: FlowaRadii.xxlAll,
        boxShadow: FlowaShadows.soft,
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            right: -4,
            top: -6,
            child: Opacity(
              opacity: 0.22,
              child: FlowaLucideIcon(
                LucideIcons.gift,
                size: 88,
                color: FlowaColors.mintInk,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tu cashback',
                style: FlowaType.bodySm(
                  color: FlowaColors.mintInk.withValues(alpha: 0.72),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                FlowaFormatters.currency(balance),
                style: FlowaType.figureLg(color: FlowaColors.mintInk),
              ),
              const SizedBox(height: 6),
              Text(
                'Disponible para retirar o aplicar a gastos',
                style: FlowaType.micro(
                  color: FlowaColors.mintInk.withValues(alpha: 0.62),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OfferCard extends StatelessWidget {
  const _OfferCard({required this.offer});

  static const double height = 136;
  static const double width = 112;

  final RewardOffer offer;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: Material(
        color: FlowaColors.inkHigh,
        borderRadius: FlowaRadii.xlAll,
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: offer.tone.withValues(alpha: 0.16),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: FlowaLucideIcon(offer.icon, size: 20, color: offer.tone),
              ),
              const Spacer(),
              Text(
                offer.brand,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: FlowaType.titleSm(),
              ),
              const SizedBox(height: 4),
              Text(
                'Hasta ${offer.maxRatePct.toStringAsFixed(0)}%',
                style: FlowaType.micro(color: FlowaColors.boneMuted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CashbackRow extends StatelessWidget {
  const _CashbackRow({required this.entry, required this.stamp});

  final CashbackEntry entry;
  final String stamp;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: entry.tone.withValues(alpha: 0.16),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: FlowaLucideIcon(entry.icon, size: 20, color: entry.tone),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(entry.brand, style: FlowaType.titleSm()),
                const SizedBox(height: 2),
                Text(stamp, style: FlowaType.bodySm()),
              ],
            ),
          ),
          Text(
            '+${FlowaFormatters.currency(entry.amount)}',
            style: FlowaType.titleSm(color: FlowaColors.mint),
          ),
        ],
      ),
    );
  }
}

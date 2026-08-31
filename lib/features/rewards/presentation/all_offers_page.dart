import 'package:flutter/material.dart';

import '../../../data/datasources/flowa_rewards_demo.dart';
import '../../../design_system/components/flowa_icon.dart';
import '../../../design_system/components/flowa_primitives.dart';
import '../../../design_system/components/flowa_screen.dart';
import '../../../design_system/tokens/flowa_colors.dart';
import '../../../design_system/tokens/flowa_motion_tokens.dart';
import '../../../design_system/tokens/flowa_spacing.dart';
import '../../../design_system/tokens/flowa_typography.dart';
import '../../../domain/entities/reward_entities.dart';

/// Full catalogue of partner cashback offers.
class AllOffersPage extends StatelessWidget {
  const AllOffersPage({super.key});

  @override
  Widget build(BuildContext context) {
    return FlowaScreen(
      title: 'Todas las ofertas',
      child: ListView.separated(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: FlowaSpacing.xl),
        itemCount: FlowaRewardsDemo.offers.length,
        separatorBuilder: (_, __) => const SizedBox(height: FlowaSpacing.sm),
        itemBuilder: (context, index) {
          return FlowaEntrance(
            delay: FlowaMotion.stagger(index.clamp(0, 8)),
            child: _OfferListTile(offer: FlowaRewardsDemo.offers[index]),
          );
        },
      ),
    );
  }
}

class _OfferListTile extends StatelessWidget {
  const _OfferListTile({required this.offer});

  final RewardOffer offer;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: FlowaColors.inkHigh,
        borderRadius: FlowaRadii.xlAll,
        boxShadow: FlowaShadows.soft,
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: offer.tone.withValues(alpha: 0.16),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: FlowaLucideIcon(offer.icon, size: 22, color: offer.tone),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  offer.brand,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: FlowaType.titleSm(),
                ),
                const SizedBox(height: 3),
                Text(offer.subtitle, style: FlowaType.bodySm()),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: FlowaColors.mintTintedSurface,
              borderRadius: FlowaRadii.pillAll,
            ),
            child: Text(
              'Hasta ${offer.maxRatePct.toStringAsFixed(0)}%',
              style: FlowaType.micro(color: FlowaColors.mint),
            ),
          ),
        ],
      ),
    );
  }
}

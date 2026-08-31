import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../domain/entities/reward_entities.dart';

/// Demo cashback data aligned with Flowa freelance categories.
abstract final class FlowaRewardsDemo {
  static List<RewardOffer> get popularOffers =>
      offers.take(4).toList(growable: false);

  static const offers = <RewardOffer>[
    RewardOffer(
      id: 'mercadona',
      brand: 'Mercadona',
      subtitle: 'Alimentación',
      maxRatePct: 3,
      icon: LucideIcons.shopping_bag,
      tone: Color(0xFF6DB892),
    ),
    RewardOffer(
      id: 'renfe',
      brand: 'Renfe',
      subtitle: 'Transporte',
      maxRatePct: 5,
      icon: LucideIcons.train_front,
      tone: Color(0xFF5FA4B2),
    ),
    RewardOffer(
      id: 'adobe',
      brand: 'Adobe',
      subtitle: 'Software',
      maxRatePct: 8,
      icon: LucideIcons.laptop_minimal,
      tone: Color(0xFF7A94D4),
    ),
    RewardOffer(
      id: 'amazon',
      brand: 'Amazon',
      subtitle: 'Material',
      maxRatePct: 4,
      icon: LucideIcons.package,
      tone: Color(0xFFC4A060),
    ),
    RewardOffer(
      id: 'figma',
      brand: 'Figma',
      subtitle: 'Software',
      maxRatePct: 6,
      icon: LucideIcons.pen_tool,
      tone: Color(0xFF9A7EC8),
    ),
    RewardOffer(
      id: 'coworking',
      brand: 'La Nave',
      subtitle: 'Espacio de trabajo',
      maxRatePct: 5,
      icon: LucideIcons.building_2,
      tone: Color(0xFF6890B8),
    ),
    RewardOffer(
      id: 'filmin',
      brand: 'Filmin',
      subtitle: 'Ocio',
      maxRatePct: 10,
      icon: LucideIcons.clapperboard,
      tone: Color(0xFFCC9168),
    ),
    RewardOffer(
      id: 'gestoria',
      brand: 'Gestoría Ordoñez',
      subtitle: 'Servicios',
      maxRatePct: 3,
      icon: LucideIcons.briefcase_business,
      tone: Color(0xFF9A7EC8),
    ),
    RewardOffer(
      id: 'salud',
      brand: 'Seguro de salud',
      subtitle: 'Salud',
      maxRatePct: 4,
      icon: LucideIcons.heart_pulse,
      tone: Color(0xFFCC7888),
    ),
    RewardOffer(
      id: 'ikea',
      brand: 'IKEA',
      subtitle: 'Vivienda',
      maxRatePct: 2,
      icon: LucideIcons.lamp,
      tone: Color(0xFFA07058),
    ),
  ];

  static List<CashbackEntry> recent(DateTime now) {
    return [
      CashbackEntry(
        id: 'cb-1',
        brand: 'Mercadona',
        amount: 2.23,
        occurredAt: DateTime(now.year, now.month, now.day, 12, 5),
        icon: LucideIcons.shopping_bag,
        tone: Color(0xFF6DB892),
      ),
      CashbackEntry(
        id: 'cb-2',
        brand: 'Renfe',
        amount: 1.63,
        occurredAt: DateTime(now.year, now.month, now.day - 1, 7, 45),
        icon: LucideIcons.train_front,
        tone: Color(0xFF5FA4B2),
      ),
      CashbackEntry(
        id: 'cb-3',
        brand: 'Adobe',
        amount: 5.32,
        occurredAt: DateTime(now.year, now.month, now.day - 3, 9, 10),
        icon: LucideIcons.laptop_minimal,
        tone: Color(0xFF7A94D4),
      ),
      CashbackEntry(
        id: 'cb-4',
        brand: 'Amazon',
        amount: 1.65,
        occurredAt: DateTime(now.year, now.month, now.day - 5, 16, 20),
        icon: LucideIcons.package,
        tone: Color(0xFFC4A060),
      ),
    ];
  }

  static double totalBalance(List<CashbackEntry> entries) {
    return entries.fold<double>(0, (sum, entry) => sum + entry.amount);
  }
}

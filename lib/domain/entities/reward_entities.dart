import 'package:flutter/material.dart';

/// Partner offer with cashback rate.
class RewardOffer {
  const RewardOffer({
    required this.id,
    required this.brand,
    required this.subtitle,
    required this.maxRatePct,
    required this.icon,
    required this.tone,
  });

  final String id;
  final String brand;
  final String subtitle;
  final double maxRatePct;
  final IconData icon;
  final Color tone;
}

/// Earned cashback line item.
class CashbackEntry {
  const CashbackEntry({
    required this.id,
    required this.brand,
    required this.amount,
    required this.occurredAt,
    required this.icon,
    required this.tone,
  });

  final String id;
  final String brand;
  final double amount;
  final DateTime occurredAt;
  final IconData icon;
  final Color tone;
}

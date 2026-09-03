import 'package:flutter/foundation.dart';

import '../../../design_system/components/flowa_card_face.dart';
import '../../../domain/entities/finance_entities.dart';
import '../../../domain/entities/freelance_entities.dart';
import 'card_profile.dart';

/// In-memory wallet shared by Home deck and Cartera sheet.
class CardWalletStore extends ChangeNotifier {
  CardWalletStore._();
  static final CardWalletStore instance = CardWalletStore._();

  final List<CardProfile> _cards = [];
  bool _seeded = false;

  List<CardProfile> get cards => List.unmodifiable(_cards);

  /// Front three for the home deck.
  List<CardProfile> get deck => _cards.take(3).toList(growable: false);

  void ensureSeeded({
    required Account primary,
    required TaxVault vault,
    required double trulyAvailable,
  }) {
    if (_seeded) {
      _syncBalances(
        primary: primary,
        vault: vault,
        trulyAvailable: trulyAvailable,
      );
      return;
    }
    _seeded = true;
    _cards
      ..clear()
      ..addAll([
        CardProfile.fromAccount(
          account: primary,
          style: FlowaCardTint.turquoise,
          caption: 'Disponible de verdad',
          amount: trulyAvailable,
        ),
        CardProfile.fromAccount(
          account: Account(
            id: 'vault-tax',
            displayName: 'Bote impuestos',
            maskedNumber: '**** **** **** 8841',
            availableBalance: vault.reserved,
            expiryLabel: '03/28',
            brand: 'Flowa',
            kind: AccountKind.business,
          ),
          style: FlowaCardTint.black,
          caption: 'Reservado para Hacienda',
          amount: vault.reserved,
        ),
        CardProfile.fromAccount(
          account: Account(
            id: 'buffer-ops',
            displayName: 'Gastos fijos',
            maskedNumber: '**** **** **** 2290',
            availableBalance: (trulyAvailable * 0.18).clamp(120, 900).toDouble(),
            expiryLabel: '11/28',
            brand: 'VISA',
          ),
          style: FlowaCardTint.navy,
          pattern: FlowaCardPattern.arcs,
          caption: 'Colchón operativo',
          amount: (trulyAvailable * 0.18).clamp(120, 900).toDouble(),
        ),
      ]);
    sortByBalance();
  }

  void _syncBalances({
    required Account primary,
    required TaxVault vault,
    required double trulyAvailable,
  }) {
    var changed = false;
    for (var i = 0; i < _cards.length; i++) {
      final card = _cards[i];
      if (card.account.id == primary.id) {
        _cards[i] = card.copyWith(
          account: primary.copyWith(availableBalance: trulyAvailable),
        );
        changed = true;
      } else if (card.account.id == 'vault-tax') {
        _cards[i] = card.copyWith(
          account: card.account.copyWith(availableBalance: vault.reserved),
        );
        changed = true;
      }
    }
    if (changed) {
      notifyListeners();
    }
  }

  void sortByBalance() {
    _cards.sort(
      (a, b) => b.account.availableBalance.compareTo(a.account.availableBalance),
    );
    notifyListeners();
  }

  /// Bring deck index [index] (0 front …) to the front of the wallet.
  void promoteDeckIndex(int index) {
    if (index <= 0 || index >= _cards.length || index > 2) {
      return;
    }
    final card = _cards.removeAt(index);
    _cards.insert(0, card);
    notifyListeners();
  }

  /// Cycle: send front card to the back of the top-3 deck.
  void cycleDeckForward() {
    if (_cards.length < 2) {
      return;
    }
    final front = _cards.removeAt(0);
    final insertAt = _cards.length >= 2 ? 2 : _cards.length;
    _cards.insert(insertAt, front);
    notifyListeners();
  }

  void reorder(int from, int to) {
    if (from == to || from < 0 || to < 0 || from >= _cards.length) {
      return;
    }
    final item = _cards.removeAt(from);
    _cards.insert(to.clamp(0, _cards.length), item);
    notifyListeners();
  }

  /// Drops in-memory cards so the next session can seed a clean wallet.
  void clear() {
    _cards.clear();
    _seeded = false;
    notifyListeners();
  }

  void add(CardProfile profile) {
    _cards.add(profile);
    notifyListeners();
  }

  void update(CardProfile profile) {
    final i = _cards.indexWhere((c) => c.account.id == profile.account.id);
    if (i < 0) {
      return;
    }
    _cards[i] = profile;
    notifyListeners();
  }
}

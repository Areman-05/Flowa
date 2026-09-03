import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:flowa/core/utils/transaction_export.dart';
import 'package:flowa/data/repositories/in_memory_preferences_repository.dart';
import 'package:flowa/design_system/tokens/flowa_colors.dart';
import 'package:flowa/domain/entities/budget_goal.dart';
import 'package:flowa/domain/entities/finance_entities.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('es_ES');
  });

  group('FlowaTheme', () {
    test('canvas is true black', () {
      expect(FlowaColors.ink, const Color(0xFF000000));
    });

    test('dark and light resolve to the same ink', () {
      expect(FlowaColors.background, FlowaColors.ink);
    });
  });

  group('BudgetGoal spending alert', () {
    test('80 pct threshold triggers alert range', () {
      const goal = BudgetGoal(monthlyLimit: 500, enabled: true);
      expect(goal.progressFor(400), 0.8);
      expect(goal.isOverBudget(400), isFalse);
      expect(goal.isOverBudget(501), isTrue);
    });
  });

  group('TransactionExport PDF placeholder', () {
    test('generates statement header', () {
      final items = [
        TransactionItem(
          id: 'tx1',
          merchant: 'Shop',
          amount: 30,
          occurredAt: DateTime(2026, 3, 1),
          direction: TransactionDirection.debit,
        ),
      ];
      final text = TransactionExport.toPdfPlaceholder(items);
      expect(text, contains('FLOWA STATEMENT'));
      expect(text, contains('Shop'));
      expect(text, contains('Total items: 1'));
    });
  });

  group('InMemoryPreferencesRepository dark mode', () {
    test('default is disabled', () async {
      final prefs = InMemoryPreferencesRepository();
      expect(await prefs.isDarkModeEnabled(), isFalse);
    });

    test('persists toggle', () async {
      final prefs = InMemoryPreferencesRepository();
      await prefs.setDarkModeEnabled(true);
      expect(await prefs.isDarkModeEnabled(), isTrue);
    });
  });
}

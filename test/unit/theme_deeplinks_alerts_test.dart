import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:flowa/core/utils/deep_links.dart';
import 'package:flowa/core/utils/transaction_export.dart';
import 'package:flowa/data/repositories/in_memory_preferences_repository.dart';
import 'package:flowa/design_system/theme/flowa_theme.dart';
import 'package:flowa/domain/entities/budget_goal.dart';
import 'package:flowa/domain/entities/finance_entities.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('es_ES');
  });

  group('FlowaTheme', () {
    test('light theme uses Radient dark canvas', () {
      final theme = FlowaTheme.light();
      expect(theme.brightness, Brightness.dark);
      expect(theme.scaffoldBackgroundColor, const Color(0xFF0A0A0A));
    });

    test('dark theme uses dark brightness', () {
      final theme = FlowaTheme.dark();
      expect(theme.brightness, Brightness.dark);
    });
  });

  group('FlowaDeepLinks', () {
    test('parses /send', () {
      final route = FlowaDeepLinks.parse(Uri.parse('flowa:///send'));
      expect(route, isNotNull);
      expect(route!.destination, DeepLinkDestination.send);
    });

    test('parses /receive', () {
      final route = FlowaDeepLinks.parse(Uri.parse('flowa:///receive'));
      expect(route!.destination, DeepLinkDestination.receive);
    });

    test('parses /transaction/:id', () {
      final route =
          FlowaDeepLinks.parse(Uri.parse('flowa:///transaction/tx-42'));
      expect(route!.destination, DeepLinkDestination.transactionDetail);
      expect(route.id, 'tx-42');
    });

    test('returns null for unknown path', () {
      expect(FlowaDeepLinks.parse(Uri.parse('flowa:///unknown')), isNull);
    });

    test('returns null for empty path', () {
      expect(FlowaDeepLinks.parse(Uri.parse('flowa:///')), isNull);
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

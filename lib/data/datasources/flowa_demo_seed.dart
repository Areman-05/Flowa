import '../../core/utils/flowa_runtime.dart';
import '../../domain/entities/finance_entities.dart';
import '../../domain/entities/freelance_entities.dart';

/// Portfolio demo data: six months in the life of a freelance designer in
/// Spain — lumpy income, fixed monthly costs, an invoice that went overdue.
///
/// Seeded by [FlowaSession.hydrate] when [enabled]: primary account (~9184 €),
/// six months of movements, tax vault, invoices, commitments, and payee
/// contacts. Inbox, scheduled transfers and linked wallets stay empty.
///
/// Widget tests opt out via [enabled] so empty-state coverage keeps working.
/// Tests that need the demo world set [overrideEnabled].
abstract final class FlowaDemoSeed {
  static bool? overrideEnabled;

  static bool get enabled =>
      overrideEnabled ?? !FlowaRuntime.isWidgetTest;

  static const double startingBalance = 9184.60;
  static const double reservedForTax = 3120;
  static const double reserveRate = 0.25;

  static Account account(UserProfile user) {
    final seed = user.id.hashCode.abs() % 10000;
    return Account(
      id: 'acc-${user.id}',
      displayName: 'Cuenta Flowa',
      maskedNumber: '**** **** **** ${seed.toString().padLeft(4, '0')}',
      availableBalance: startingBalance,
      expiryLabel: '09/29',
    );
  }

  static TaxVault vault(DateTime now) => TaxVault(
        reserved: reservedForTax,
        rate: reserveRate,
        nextDueAt: _nextQuarterDeadline(now),
      );

  /// Spanish quarterly VAT falls on the 20th of January, April, July and
  /// October.
  static DateTime _nextQuarterDeadline(DateTime now) {
    const months = [1, 4, 7, 10];
    for (final month in months) {
      final candidate = DateTime(now.year, month, 20);
      if (candidate.isAfter(now)) {
        return candidate;
      }
    }
    return DateTime(now.year + 1, 1, 20);
  }

  static List<Commitment> commitments(DateTime now) {
    DateTime nextOccurrenceOf(int day) {
      final thisMonth = _clampToMonth(now.year, now.month, day);
      if (thisMonth.isAfter(now)) {
        return thisMonth;
      }
      return _clampToMonth(now.year, now.month + 1, day);
    }

    return [
      Commitment(
        id: 'cmt-autonomos',
        label: 'Cuota de autónomos',
        amount: 320,
        dueAt: nextOccurrenceOf(30),
      ),
      Commitment(
        id: 'cmt-alquiler',
        label: 'Alquiler · Somió',
        amount: 720,
        dueAt: nextOccurrenceOf(2),
      ),
      Commitment(
        id: 'cmt-coworking',
        label: 'Coworking La Nave',
        amount: 165,
        dueAt: nextOccurrenceOf(1),
      ),
      Commitment(
        id: 'cmt-gestoria',
        label: 'Gestoría Ordoñez',
        amount: 60,
        dueAt: nextOccurrenceOf(5),
      ),
      Commitment(
        id: 'cmt-adobe',
        label: 'Adobe Creative Cloud',
        amount: 66.50,
        dueAt: nextOccurrenceOf(3),
      ),
    ];
  }

  static List<Invoice> invoices(DateTime now) => [
        Invoice(
          id: 'inv-014',
          number: '2026-014',
          client: 'Kernel Labs',
          concept: 'Sistema de diseño · fase 2',
          amount: 3400,
          issuedAt: now.subtract(const Duration(days: 18)),
          dueAt: now.add(const Duration(days: 12)),
          status: InvoiceStatus.sent,
        ),
        Invoice(
          id: 'inv-013',
          number: '2026-013',
          client: 'Nomad Coffee',
          concept: 'Identidad visual',
          amount: 1850,
          issuedAt: now.subtract(const Duration(days: 39)),
          dueAt: now.subtract(const Duration(days: 9)),
          status: InvoiceStatus.sent,
        ),
        Invoice(
          id: 'inv-012',
          number: '2026-012',
          client: 'Ayuntamiento de Gijón',
          concept: 'Cartelería festival',
          amount: 2240,
          issuedAt: now.subtract(const Duration(days: 6)),
          dueAt: now.add(const Duration(days: 26)),
          status: InvoiceStatus.sent,
        ),
        Invoice(
          id: 'inv-011',
          number: '2026-011',
          client: 'Estudio Vera',
          concept: 'Landing page',
          amount: 980,
          issuedAt: now.subtract(const Duration(days: 52)),
          dueAt: now.subtract(const Duration(days: 22)),
          status: InvoiceStatus.paid,
        ),
        Invoice(
          id: 'inv-015',
          client: 'Marta Ruiz',
          concept: 'Retainer mensual',
          amount: 600,
          issuedAt: now,
          dueAt: now.add(const Duration(days: 30)),
          status: InvoiceStatus.draft,
        ),
      ];

  static List<TransactionItem> transactions(DateTime now) {
    final items = <TransactionItem>[];
    var sequence = 0;

    void add({
      required int monthsAgo,
      required int day,
      required String merchant,
      required double amount,
      required TransactionDirection direction,
      required String category,
      int hour = 11,
      int minute = 20,
    }) {
      final when = _clampToMonth(
        now.year,
        now.month - monthsAgo,
        day,
        hour: hour,
        minute: minute,
      );
      if (when.isAfter(now)) {
        return;
      }
      sequence++;
      items.add(
        TransactionItem(
          id: 'demo-${sequence.toString().padLeft(3, '0')}',
          merchant: merchant,
          amount: amount,
          occurredAt: when,
          direction: direction,
          category: category,
        ),
      );
    }

    void expense(int monthsAgo, int day, String merchant, double amount,
        String category, {int hour = 11, int minute = 20}) {
      add(
        monthsAgo: monthsAgo,
        day: day,
        merchant: merchant,
        amount: amount,
        direction: TransactionDirection.debit,
        category: category,
        hour: hour,
        minute: minute,
      );
    }

    void income(int monthsAgo, int day, String client, double amount) {
      add(
        monthsAgo: monthsAgo,
        day: day,
        merchant: client,
        amount: amount,
        direction: TransactionDirection.credit,
        category: 'Ingresos',
        hour: 9,
        minute: 5,
      );
    }

    for (var monthsAgo = 5; monthsAgo >= 0; monthsAgo--) {
      final drift = (5 - monthsAgo) * 2.35;

      expense(monthsAgo, 1, 'Coworking La Nave', 165, 'Espacio', hour: 8);
      expense(monthsAgo, 2, 'Alquiler · Somió', 720, 'Vivienda', hour: 7);
      expense(monthsAgo, 3, 'Adobe Creative Cloud', 66.50, 'Software');
      expense(monthsAgo, 5, 'Gestoría Ordoñez', 60, 'Servicios');
      expense(monthsAgo, 8, 'Figma', 13.50, 'Software');
      expense(monthsAgo, 12, 'Seguro de salud', 58.90, 'Salud');
      expense(monthsAgo, 30, 'Cuota de autónomos', 320, 'Impuestos', hour: 6);

      expense(monthsAgo, 6, 'Mercadona', 74.20 + drift, 'Alimentación',
          hour: 19, minute: 40);
      expense(monthsAgo, 9, 'Café de Indias', 4.80, 'Ocio',
          hour: 9, minute: 12);
      expense(monthsAgo, 14, 'Mercadona', 62.10 + drift, 'Alimentación',
          hour: 20, minute: 5);
      expense(monthsAgo, 18, 'Renfe', 32.50, 'Transporte', hour: 7, minute: 45);
      expense(monthsAgo, 21, 'Filmin', 7.99, 'Ocio', hour: 22);
      expense(monthsAgo, 23, 'La Salgar', 38, 'Ocio', hour: 21, minute: 30);
      expense(monthsAgo, 26, 'Amazon', 41.30 + drift, 'Material', hour: 16);
    }

    income(5, 11, 'Estudio Vera', 2400);
    income(4, 19, 'Marta Ruiz', 650);
    income(3, 7, 'Kernel Labs', 3850);
    income(3, 23, 'Estudio Vera', 480);
    income(2, 15, 'Ayuntamiento de Gijón', 1200);
    income(1, 4, 'Nomad Coffee', 4600);
    income(0, 6, 'Kernel Labs', 1850);

    return items;
  }

  static DateTime _clampToMonth(
    int year,
    int month,
    int day, {
    int hour = 11,
    int minute = 20,
  }) {
    final normalised = DateTime(year, month);
    final lastDay = DateTime(normalised.year, normalised.month + 1, 0).day;
    return DateTime(
      normalised.year,
      normalised.month,
      day > lastDay ? lastDay : day,
      hour,
      minute,
    );
  }
}

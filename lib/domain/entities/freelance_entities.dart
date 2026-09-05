import 'package:equatable/equatable.dart';

import 'finance_entities.dart';

/// Lifecycle of a freelance invoice.
enum InvoiceStatus { draft, sent, paid, overdue }

extension InvoiceStatusLabel on InvoiceStatus {
  String get label => switch (this) {
        InvoiceStatus.draft => 'Borrador',
        InvoiceStatus.sent => 'Pendiente',
        InvoiceStatus.paid => 'Cobrada',
        InvoiceStatus.overdue => 'Vencida',
      };

  /// Money the freelancer is still waiting for.
  bool get isOutstanding =>
      this == InvoiceStatus.sent || this == InvoiceStatus.overdue;
}

class Invoice extends Equatable {
  const Invoice({
    required this.id,
    required this.client,
    required this.concept,
    required this.amount,
    required this.issuedAt,
    required this.dueAt,
    required this.status,
    this.number,
  });

  final String id;
  final String client;
  final String concept;
  final double amount;
  final DateTime issuedAt;
  final DateTime dueAt;
  final InvoiceStatus status;
  final String? number;

  int daysUntilDue(DateTime now) {
    final today = DateTime(now.year, now.month, now.day);
    final dueDay = DateTime(dueAt.year, dueAt.month, dueAt.day);
    return dueDay.difference(today).inDays;
  }

  /// Overdue only after the due calendar day has passed (due day = still pending).
  InvoiceStatus statusAt(DateTime now) {
    if (status == InvoiceStatus.sent) {
      final today = DateTime(now.year, now.month, now.day);
      final dueDay = DateTime(dueAt.year, dueAt.month, dueAt.day);
      if (today.isAfter(dueDay)) {
        return InvoiceStatus.overdue;
      }
    }
    return status;
  }

  Invoice copyWith({
    String? client,
    String? concept,
    double? amount,
    DateTime? issuedAt,
    DateTime? dueAt,
    InvoiceStatus? status,
    String? number,
    bool clearNumber = false,
  }) =>
      Invoice(
        id: id,
        client: client ?? this.client,
        concept: concept ?? this.concept,
        amount: amount ?? this.amount,
        issuedAt: issuedAt ?? this.issuedAt,
        dueAt: dueAt ?? this.dueAt,
        status: status ?? this.status,
        number: clearNumber ? null : (number ?? this.number),
      );

  @override
  List<Object?> get props =>
      [id, client, concept, amount, issuedAt, dueAt, status, number];
}

/// Money set aside for the tax office. The single most useful thing a bank can
/// do for a freelancer is stop them from spending it.
class TaxVault extends Equatable {
  const TaxVault({
    required this.reserved,
    required this.rate,
    this.nextDueAt,
    this.periodLabel = 'IVA · trimestre en curso',
  });

  final double reserved;

  /// Fraction of every incoming payment moved to the vault, 0–1.
  final double rate;
  final DateTime? nextDueAt;
  final String periodLabel;

  int get ratePercent => (rate * 100).round();

  TaxVault copyWith({double? reserved, double? rate, DateTime? nextDueAt}) =>
      TaxVault(
        reserved: reserved ?? this.reserved,
        rate: rate ?? this.rate,
        nextDueAt: nextDueAt ?? this.nextDueAt,
        periodLabel: periodLabel,
      );

  @override
  List<Object?> get props => [reserved, rate, nextDueAt, periodLabel];
}

/// A known outgoing that has not left the account yet: the autónomo quota, the
/// coworking desk, the accountant. Money that is in the balance but already
/// spoken for.
class Commitment extends Equatable {
  const Commitment({
    required this.id,
    required this.label,
    required this.amount,
    required this.dueAt,
    this.recurring = true,
  });

  final String id;
  final String label;
  final double amount;
  final DateTime dueAt;
  final bool recurring;

  int daysUntilDue(DateTime now) => dueAt.difference(now).inDays;

  @override
  List<Object?> get props => [id, label, amount, dueAt, recurring];
}

/// One month of the income series shown on Home.
class MonthlyIncome extends Equatable {
  const MonthlyIncome({
    required this.month,
    required this.earned,
    required this.spent,
  });

  final DateTime month;
  final double earned;
  final double spent;

  @override
  List<Object?> get props => [month, earned, spent];
}

/// The number the whole product is built around.
///
/// A freelancer's account balance is a lie: part of it belongs to the tax
/// office and part is already committed. [trulyAvailable] is what is actually
/// theirs, and [runwayMonths] is how long it lasts at the current burn.
class FreelanceOverview extends Equatable {
  const FreelanceOverview({
    required this.balance,
    required this.taxReserved,
    required this.committed,
    required this.outstandingInvoiced,
    required this.monthlyBurn,
    required this.months,
  });

  static const FreelanceOverview empty = FreelanceOverview(
    balance: 0,
    taxReserved: 0,
    committed: 0,
    outstandingInvoiced: 0,
    monthlyBurn: 0,
    months: [],
  );

  final double balance;
  final double taxReserved;
  final double committed;
  final double outstandingInvoiced;
  final double monthlyBurn;
  final List<MonthlyIncome> months;

  double get trulyAvailable {
    final value = balance - taxReserved - committed;
    return value < 0 ? 0 : value;
  }

  /// Capped at two years: beyond that the figure stops being meaningful and
  /// starts being noise.
  double get runwayMonths {
    if (monthlyBurn <= 0) {
      return 0;
    }
    final months = trulyAvailable / monthlyBurn;
    return months > 24 ? 24 : months;
  }

  bool get hasRunway => monthlyBurn > 0;

  /// How irregular the income is, 0 (steady) to 1 (feast or famine). Drives
  /// the tone of the Home summary line.
  double get volatility {
    final earned = months.map((m) => m.earned).where((v) => v > 0).toList();
    if (earned.length < 2) {
      return 0;
    }
    final average = earned.reduce((a, b) => a + b) / earned.length;
    if (average <= 0) {
      return 0;
    }
    final variance = earned
            .map((v) => (v - average) * (v - average))
            .reduce((a, b) => a + b) /
        earned.length;
    final deviation = variance <= 0 ? 0.0 : _sqrt(variance);
    final ratio = deviation / average;
    return ratio > 1 ? 1 : ratio;
  }

  static double _sqrt(double value) {
    var guess = value;
    for (var i = 0; i < 24; i++) {
      guess = 0.5 * (guess + value / guess);
    }
    return guess;
  }

  /// Rolls the raw sources into the single view Home renders.
  static FreelanceOverview compute({
    required Account account,
    required List<TransactionItem> transactions,
    required TaxVault vault,
    required List<Invoice> invoices,
    required DateTime now,
    List<Commitment> commitments = const [],
    int commitmentWindowDays = 30,
  }) {
    final horizon = now.add(Duration(days: commitmentWindowDays));
    final committed = commitments
        .where((c) => c.dueAt.isAfter(now) && c.dueAt.isBefore(horizon))
        .fold<double>(0, (sum, c) => sum + c.amount);

    final months = <DateTime, MonthlyIncome>{};
    for (var offset = 5; offset >= 0; offset--) {
      final month = DateTime(now.year, now.month - offset);
      months[month] = MonthlyIncome(month: month, earned: 0, spent: 0);
    }

    for (final item in transactions) {
      final key = DateTime(item.occurredAt.year, item.occurredAt.month);
      final current = months[key];
      if (current == null) {
        continue;
      }
      months[key] = MonthlyIncome(
        month: key,
        earned: current.earned + (item.isIncome ? item.amount.abs() : 0),
        spent: current.spent + (item.isIncome ? 0 : item.amount.abs()),
      );
    }

    final series = months.values.toList()
      ..sort((a, b) => a.month.compareTo(b.month));

    final closed = series.take(series.length > 1 ? series.length - 1 : 1);
    final spending = closed.map((m) => m.spent).where((v) => v > 0).toList();
    final burn = spending.isEmpty
        ? 0.0
        : spending.reduce((a, b) => a + b) / spending.length;

    final outstanding = invoices
        .where((invoice) => invoice.statusAt(now).isOutstanding)
        .fold<double>(0, (sum, invoice) => sum + invoice.amount);

    return FreelanceOverview(
      balance: account.availableBalance,
      taxReserved: vault.reserved,
      committed: committed,
      outstandingInvoiced: outstanding,
      monthlyBurn: burn,
      months: series,
    );
  }

  @override
  List<Object?> get props => [
        balance,
        taxReserved,
        committed,
        outstandingInvoiced,
        monthlyBurn,
        months,
      ];
}

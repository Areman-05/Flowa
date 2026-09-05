import '../../domain/entities/freelance_entities.dart';
import '../../domain/entities/inbox_notification.dart';
import 'flowa_formatters.dart';
import 'flowa_services.dart';

/// In-app alerts for money and cobros (respects notification prefs).
abstract final class FlowaAlerts {
  static Future<bool> _enabled() async {
    final prefs =
        await FlowaServices.preferencesRepository.getNotificationPreferences();
    return prefs.allowNotifications && prefs.transactionNotifications;
  }

  static Future<void> push({
    required String id,
    required String title,
    required String body,
    InboxNotificationKind kind = InboxNotificationKind.transaction,
    String? actionLabel,
    bool once = false,
  }) async {
    if (!await _enabled()) {
      return;
    }
    if (once) {
      final existing = await FlowaServices.inboxRepository.getAll();
      if (existing.any((item) => item.id == id)) {
        return;
      }
    }
    await FlowaServices.inboxRepository.push(
      InboxNotification(
        id: id,
        title: title,
        body: body,
        kind: kind,
        createdAt: DateTime.now(),
        actionLabel: actionLabel,
      ),
    );
  }

  static Future<void> moneySent({
    required String to,
    required double amount,
  }) {
    return push(
      id: 'sent-${DateTime.now().millisecondsSinceEpoch}',
      title: 'Has enviado dinero',
      body: '$to · ${FlowaFormatters.currency(amount)}',
    );
  }

  static Future<void> moneyReceived({
    required double amount,
    String? note,
  }) {
    final label = (note == null || note.isEmpty) ? 'Ingreso' : note;
    return push(
      id: 'recv-${DateTime.now().millisecondsSinceEpoch}',
      title: 'Has recibido dinero',
      body: '$label · ${FlowaFormatters.currency(amount)}',
    );
  }

  static Future<void> paymentMade({
    required String title,
    required String body,
  }) {
    return push(
      id: 'pay-${DateTime.now().millisecondsSinceEpoch}',
      title: title,
      body: body,
    );
  }

  static Future<void> cobroPending(Invoice invoice) {
    return push(
      id: 'cobro-new-${invoice.id}',
      title: 'Cobro pendiente',
      body:
          '${invoice.client} · ${FlowaFormatters.currency(invoice.amount)}',
      actionLabel: 'Ver cobro',
      once: true,
    );
  }

  static Future<void> cobroCollected(
    Invoice invoice, {
    required bool toAccount,
    required double reserved,
  }) {
    if (toAccount) {
      return push(
        id: 'cobro-paid-${invoice.id}-${DateTime.now().millisecondsSinceEpoch}',
        title: 'Cobro ingresado',
        body:
            '${invoice.client} · ${FlowaFormatters.currency(invoice.amount)}'
            ' · ${FlowaFormatters.compact(reserved)} al bote',
        actionLabel: 'Ver cobro',
      );
    }
    return push(
      id: 'cobro-closed-${invoice.id}-${DateTime.now().millisecondsSinceEpoch}',
      title: 'Cobro cerrado',
      body:
          '${invoice.client} · ${FlowaFormatters.currency(invoice.amount)}'
          ' · cobrado fuera (bote sin cambios)',
      actionLabel: 'Ver cobro',
    );
  }

  /// One alert per overdue cobro (idempotent for the session inbox).
  static Future<void> syncOverdue(List<Invoice> invoices) async {
    final now = DateTime.now();
    for (final invoice in invoices) {
      if (invoice.statusAt(now) != InvoiceStatus.overdue) {
        continue;
      }
      final days = invoice.daysUntilDue(now).abs();
      await push(
        id: 'overdue-${invoice.id}',
        title: 'Cobro vencido',
        body:
            '${invoice.client} · ${FlowaFormatters.currency(invoice.amount)}'
            ' · hace $days d. Sigue pendiente de cobro.',
        actionLabel: 'Ver cobro',
        once: true,
      );
    }
  }
}

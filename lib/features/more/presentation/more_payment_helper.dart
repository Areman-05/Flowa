import 'package:flutter/material.dart';

import '../../../core/utils/flowa_alerts.dart';
import '../../../core/utils/flowa_formatters.dart';
import '../../../core/utils/flowa_services.dart';
import '../../../domain/entities/finance_entities.dart';
import '../../../shared/navigation/flowa_routes.dart';
import '../domain/more_service_catalog.dart';
import 'more_payment_review_page.dart';

/// Opens the review screen (card picker + processing) before charging.
Future<void> completeMoreServicePayment({
  required BuildContext context,
  required String merchant,
  required double amount,
  required String category,
  required String successTitle,
  required String successSubtitle,
  List<String> detailLines = const [],
}) {
  if (amount <= 0) {
    return Future<void>.value();
  }

  return pushFlowaRoute<void>(
    context,
    MorePaymentReviewPage(
      merchant: merchant,
      amount: amount,
      category: category,
      successTitle: successTitle,
      successSubtitle: successSubtitle,
      detailLines: detailLines,
    ),
  );
}

/// Executes the debit, transaction log and inbox notification.
Future<void> completeMoreServicePaymentCore({
  required String merchant,
  required double amount,
  required String category,
  required String cardLabel,
  required String successTitle,
}) async {
  await FlowaServices.transactionRepository.add(
    TransactionItem(
      id: 'tx-${DateTime.now().millisecondsSinceEpoch}',
      merchant: merchant,
      amount: amount,
      occurredAt: DateTime.now(),
      direction: TransactionDirection.debit,
      category: category,
    ),
  );
  await FlowaServices.accountRepository.applyBalanceDelta(-amount);
  await FlowaAlerts.paymentMade(
    title: successTitle,
    body: '$merchant · ${FlowaFormatters.currency(amount)} · $cardLabel',
  );
}

String providerInitial(MoreProvider provider) {
  if (provider.initial != null && provider.initial!.isNotEmpty) {
    return provider.initial!;
  }
  return provider.name.isEmpty ? '·' : provider.name[0].toUpperCase();
}

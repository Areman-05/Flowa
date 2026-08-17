import 'package:flutter/material.dart';

import '../../../core/utils/flowa_formatters.dart';
import '../../../design_system/tokens/flowa_spacing.dart';
import '../../../shared/navigation/flowa_routes.dart';
import '../../../shared/widgets/flowa_buttons.dart';
import '../../transfers/presentation/transfer_success_page.dart';

class SendReviewPage extends StatelessWidget {
  const SendReviewPage({
    required this.recipientName,
    required this.accountNumber,
    required this.amount,
    this.note,
    super.key,
  });

  final String recipientName;
  final String accountNumber;
  final double amount;
  final String? note;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Review Send')),
      body: SafeArea(
        child: Padding(
          padding: FlowaSpacing.screenPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Confirm this is a bank transfer, not a Top-Up.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: FlowaSpacing.xl),
              _ReviewRow(label: 'To', value: recipientName),
              _ReviewRow(label: 'Account', value: accountNumber),
              _ReviewRow(
                label: 'Amount',
                value: FlowaFormatters.currency(amount),
              ),
              if (note != null && note!.trim().isNotEmpty)
                _ReviewRow(label: 'Note', value: note!.trim()),
              const Spacer(),
              FlowaPrimaryButton(
                label: 'Send now',
                onPressed: () {
                  pushFlowaRoute<void>(
                    context,
                    TransferSuccessPage(
                      title: 'Money sent',
                      amount: amount,
                      subtitle: 'Delivered to $recipientName',
                    ),
                  );
                },
              ),
              const SizedBox(height: FlowaSpacing.sm),
              FlowaSecondaryButton(
                label: 'Go back',
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ReviewRow extends StatelessWidget {
  const _ReviewRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: FlowaSpacing.md),
      child: Row(
        children: [
          SizedBox(
            width: 88,
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.titleMedium),
          ),
        ],
      ),
    );
  }
}

class RecentRecipient {
  const RecentRecipient({required this.name, required this.accountNumber});

  final String name;
  final String accountNumber;
}

abstract final class RecentRecipients {
  static const items = [
    RecentRecipient(name: 'Emma Parker', accountNumber: '1476584951012345'),
    RecentRecipient(name: 'Alex Chen', accountNumber: '5416247141794136'),
    RecentRecipient(name: "Mega's World", accountNumber: '1476584957480102'),
  ];
}

import 'package:equatable/equatable.dart';

enum ScheduledTransferFrequency { once, weekly, monthly }

/// A queued bank transfer the user plans ahead of time.
class ScheduledTransfer extends Equatable {
  const ScheduledTransfer({
    required this.id,
    required this.recipientName,
    required this.accountNumber,
    required this.amount,
    required this.scheduledFor,
    required this.frequency,
  });

  final String id;
  final String recipientName;
  final String accountNumber;
  final double amount;
  final DateTime scheduledFor;
  final ScheduledTransferFrequency frequency;

  String get frequencyLabel => switch (frequency) {
    ScheduledTransferFrequency.once => 'One-time',
    ScheduledTransferFrequency.weekly => 'Weekly',
    ScheduledTransferFrequency.monthly => 'Monthly',
  };

  @override
  List<Object?> get props => [
    id,
    recipientName,
    accountNumber,
    amount,
    scheduledFor,
    frequency,
  ];
}

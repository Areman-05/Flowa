import '../../domain/entities/scheduled_transfer.dart';
import '../../domain/repositories/scheduled_transfer_repository.dart';

class MockScheduledTransferRepository implements ScheduledTransferRepository {
  MockScheduledTransferRepository({List<ScheduledTransfer>? seed})
    : _items = List<ScheduledTransfer>.from(seed ?? _defaults);

  final List<ScheduledTransfer> _items;

  static final List<ScheduledTransfer> _defaults = [
    ScheduledTransfer(
      id: 'sched-1',
      recipientName: 'Emma Parker',
      accountNumber: '1476584951012345',
      amount: 25,
      scheduledFor: DateTime(2026, 3, 5, 9),
      frequency: ScheduledTransferFrequency.once,
    ),
    ScheduledTransfer(
      id: 'sched-2',
      recipientName: 'Mega\'s World',
      accountNumber: '1476584957480102',
      amount: 120,
      scheduledFor: DateTime(2026, 3, 1, 12),
      frequency: ScheduledTransferFrequency.monthly,
    ),
  ];

  @override
  Future<List<ScheduledTransfer>> getAll() async {
    final items = List<ScheduledTransfer>.from(_items)
      ..sort((a, b) => a.scheduledFor.compareTo(b.scheduledFor));
    return items;
  }
}

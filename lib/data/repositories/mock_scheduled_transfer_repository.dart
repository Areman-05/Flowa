import '../../domain/entities/scheduled_transfer.dart';
import '../../domain/repositories/scheduled_transfer_repository.dart';

class MockScheduledTransferRepository implements ScheduledTransferRepository {
  MockScheduledTransferRepository({List<ScheduledTransfer>? seed})
    : _items = List<ScheduledTransfer>.from(seed ?? const []);

  final List<ScheduledTransfer> _items;

  @override
  Future<List<ScheduledTransfer>> getAll() async {
    final items = List<ScheduledTransfer>.from(_items)
      ..sort((a, b) => a.scheduledFor.compareTo(b.scheduledFor));
    return items;
  }
}

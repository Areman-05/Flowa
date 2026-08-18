import '../entities/scheduled_transfer.dart';

/// Contract for queued Send transfers.
abstract class ScheduledTransferRepository {
  Future<List<ScheduledTransfer>> getAll();
}

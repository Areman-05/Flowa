import '../entities/inbox_notification.dart';

/// Contract for the in-app notification inbox.
abstract class InboxRepository {
  Future<List<InboxNotification>> getAll();

  Future<int> unreadCount();

  Future<void> markRead(String id);

  Future<void> markAllRead();

  Future<void> push(InboxNotification notification);
}

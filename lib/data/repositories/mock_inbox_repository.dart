import '../../domain/entities/inbox_notification.dart';
import '../../domain/repositories/inbox_repository.dart';

class MockInboxRepository implements InboxRepository {
  MockInboxRepository({List<InboxNotification>? seed})
    : _items = List<InboxNotification>.from(seed ?? const []);

  final List<InboxNotification> _items;

  @override
  Future<List<InboxNotification>> getAll() async {
    final items = List<InboxNotification>.from(_items)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return items;
  }

  @override
  Future<int> unreadCount() async {
    return _items.where((item) => !item.isRead).length;
  }

  @override
  Future<void> markRead(String id) async {
    final index = _items.indexWhere((item) => item.id == id);
    if (index < 0) {
      return;
    }
    _items[index] = _items[index].copyWith(isRead: true);
  }

  @override
  Future<void> markAllRead() async {
    for (var i = 0; i < _items.length; i++) {
      _items[i] = _items[i].copyWith(isRead: true);
    }
  }

  @override
  Future<void> push(InboxNotification notification) async {
    _items.insert(0, notification);
  }
}

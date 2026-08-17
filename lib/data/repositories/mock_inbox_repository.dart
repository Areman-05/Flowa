import '../../domain/entities/inbox_notification.dart';
import '../../domain/repositories/inbox_repository.dart';

class MockInboxRepository implements InboxRepository {
  MockInboxRepository({List<InboxNotification>? seed})
    : _items = List<InboxNotification>.from(seed ?? _defaults);

  final List<InboxNotification> _items;

  static final List<InboxNotification> _defaults = [
    InboxNotification(
      id: 'n1',
      title: 'Money request from Emma',
      body: 'Emma asked for \$25.00 for dinner. Review before you send.',
      kind: InboxNotificationKind.moneyRequest,
      createdAt: DateTime(2026, 3, 1, 18, 12),
      actionLabel: 'Review',
    ),
    InboxNotification(
      id: 'n2',
      title: 'Apple payment processed',
      body: '\$343.81 left your Main Visa account.',
      kind: InboxNotificationKind.transaction,
      createdAt: DateTime(2026, 3, 1, 15, 43),
    ),
    InboxNotification(
      id: 'n3',
      title: 'New device sign-in',
      body: 'A login was detected. Confirm this was you.',
      kind: InboxNotificationKind.security,
      createdAt: DateTime(2026, 2, 28, 9, 4),
      actionLabel: 'Review',
    ),
    InboxNotification(
      id: 'n4',
      title: 'Cashback offer',
      body: 'Promotional offer — muted by default in settings.',
      kind: InboxNotificationKind.promotion,
      createdAt: DateTime(2026, 2, 27, 12),
      isRead: true,
    ),
  ];

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
}

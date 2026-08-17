import 'package:equatable/equatable.dart';

enum InboxNotificationKind { transaction, moneyRequest, security, promotion }

class InboxNotification extends Equatable {
  const InboxNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.kind,
    required this.createdAt,
    this.isRead = false,
    this.actionLabel,
  });

  final String id;
  final String title;
  final String body;
  final InboxNotificationKind kind;
  final DateTime createdAt;
  final bool isRead;
  final String? actionLabel;

  bool get isActionable => actionLabel != null && actionLabel!.isNotEmpty;

  InboxNotification copyWith({bool? isRead}) {
    return InboxNotification(
      id: id,
      title: title,
      body: body,
      kind: kind,
      createdAt: createdAt,
      isRead: isRead ?? this.isRead,
      actionLabel: actionLabel,
    );
  }

  @override
  List<Object?> get props => [
    id,
    title,
    body,
    kind,
    createdAt,
    isRead,
    actionLabel,
  ];
}

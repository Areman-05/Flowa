import 'package:flutter/material.dart';

import '../../../core/utils/flowa_formatters.dart';
import '../../../core/utils/flowa_services.dart';
import '../../../design_system/tokens/flowa_colors.dart';
import '../../../design_system/tokens/flowa_spacing.dart';
import '../../../domain/entities/inbox_notification.dart';
import '../../../shared/navigation/flowa_routes.dart';
import '../../../shared/widgets/flowa_states.dart';
import '../../send_money/presentation/send_money_page.dart';
import '../../support/presentation/support_center_page.dart';

class NotificationInboxPage extends StatefulWidget {
  const NotificationInboxPage({super.key});

  @override
  State<NotificationInboxPage> createState() => _NotificationInboxPageState();
}

class _NotificationInboxPageState extends State<NotificationInboxPage> {
  List<InboxNotification> _items = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final items = await FlowaServices.inboxRepository.getAll();
    if (!mounted) {
      return;
    }
    setState(() {
      _items = items;
      _loading = false;
    });
  }

  Future<void> _open(InboxNotification item) async {
    await FlowaServices.inboxRepository.markRead(item.id);
    if (!mounted) {
      return;
    }
    if (item.kind == InboxNotificationKind.moneyRequest) {
      await pushFlowaRoute<void>(context, const SendMoneyPage());
    } else if (item.kind == InboxNotificationKind.security) {
      await pushFlowaRoute<void>(context, const SupportCenterPage());
    }
    await _load();
  }

  IconData _iconFor(InboxNotificationKind kind) {
    return switch (kind) {
      InboxNotificationKind.transaction => Icons.receipt_long_outlined,
      InboxNotificationKind.moneyRequest => Icons.south_west_rounded,
      InboxNotificationKind.security => Icons.shield_outlined,
      InboxNotificationKind.promotion => Icons.local_offer_outlined,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          TextButton(
            onPressed: () async {
              await FlowaServices.inboxRepository.markAllRead();
              await _load();
            },
            child: const Text('Mark all'),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
          ? const FlowaEmptyState(
              title: 'No alerts',
              message: 'Transaction and security alerts will show up here.',
              icon: Icons.notifications_none_rounded,
            )
          : ListView.separated(
              padding: FlowaSpacing.screenPadding,
              itemCount: _items.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(height: FlowaSpacing.sm),
              itemBuilder: (context, index) {
                final item = _items[index];
                return Material(
                  color: item.isRead
                      ? FlowaColors.surface
                      : FlowaColors.primarySoft,
                  borderRadius: FlowaRadii.mdAll,
                  child: ListTile(
                    shape: const RoundedRectangleBorder(
                      borderRadius: FlowaRadii.mdAll,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: FlowaColors.surface,
                      child: Icon(
                        _iconFor(item.kind),
                        color: FlowaColors.primary,
                      ),
                    ),
                    title: Text(item.title),
                    subtitle: Text(
                      '${item.body}\n${FlowaFormatters.transactionStamp(item.createdAt)}',
                    ),
                    isThreeLine: true,
                    trailing: item.isActionable
                        ? Text(
                            item.actionLabel!,
                            style: const TextStyle(
                              color: FlowaColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          )
                        : null,
                    onTap: () => _open(item),
                  ),
                );
              },
            ),
    );
  }
}

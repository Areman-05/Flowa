import 'package:flutter/material.dart';

import '../../../core/utils/flowa_formatters.dart';
import '../../../core/utils/flowa_services.dart';
import '../../../design_system/components/flowa_actions.dart';
import '../../../design_system/components/flowa_icon.dart';
import '../../../design_system/components/flowa_screen.dart';
import '../../../design_system/tokens/flowa_colors.dart';
import '../../../design_system/tokens/flowa_spacing.dart';
import '../../../design_system/tokens/flowa_typography.dart';
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

  FlowaGlyph _glyphFor(InboxNotificationKind kind) {
    return switch (kind) {
      InboxNotificationKind.transaction => FlowaGlyph.receipt,
      InboxNotificationKind.moneyRequest => FlowaGlyph.arrowDown,
      InboxNotificationKind.security => FlowaGlyph.lock,
      InboxNotificationKind.promotion => FlowaGlyph.spark,
    };
  }

  @override
  Widget build(BuildContext context) {
    return FlowaScreen(
      title: 'Avisos',
      actions: [
        FlowaIconAction(
          glyph: FlowaGlyph.check,
          tooltip: 'Marcar todas',
          onTap: () async {
            await FlowaServices.inboxRepository.markAllRead();
            await _load();
          },
        ),
      ],
      child: RefreshIndicator(
        onRefresh: _load,
        color: FlowaColors.mint,
        backgroundColor: FlowaColors.inkHigh,
        child: _loading
            ? const Center(
                child: CircularProgressIndicator(color: FlowaColors.mint),
              )
            : _items.isEmpty
                ? ListView(
                    children: const [
                      FlowaEmptyState(
                        title: 'Sin alertas',
                        message: 'Aquí verás avisos de pagos y seguridad.',
                        glyph: FlowaGlyph.bell,
                      ),
                    ],
                  )
                : ListView.builder(
                    itemCount: _items.length,
                    itemBuilder: (context, index) {
                      final item = _items[index];
                      return FlowaPressScale(
                        onTap: () => _open(item),
                        haptic: false,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Row(
                            children: [
                              FlowaIconOrb(
                                glyph: _glyphFor(item.kind),
                                background: item.isRead
                                    ? FlowaColors.inkHigh
                                    : FlowaColors.mint,
                                foreground: item.isRead
                                    ? FlowaColors.bone
                                    : FlowaColors.mintInk,
                              ),
                              const SizedBox(width: FlowaSpacing.sm),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item.title, style: FlowaType.titleSm()),
                                    const SizedBox(height: 3),
                                    Text(item.body, style: FlowaType.bodySm()),
                                    const SizedBox(height: 3),
                                    Text(
                                      FlowaFormatters.transactionStamp(
                                        item.createdAt,
                                      ),
                                      style: FlowaType.micro(),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}

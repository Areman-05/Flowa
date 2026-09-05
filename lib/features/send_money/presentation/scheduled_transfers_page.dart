import 'package:flutter/material.dart';

import '../../../core/utils/flowa_formatters.dart';
import '../../../core/utils/flowa_services.dart';
import '../../../design_system/components/flowa_actions.dart';
import '../../../design_system/components/flowa_icon.dart';
import '../../../design_system/components/flowa_screen.dart';
import '../../../design_system/tokens/flowa_colors.dart';
import '../../../design_system/tokens/flowa_typography.dart';
import '../../../domain/entities/scheduled_transfer.dart';
import '../../../shared/widgets/flowa_states.dart';

class ScheduledTransfersPage extends StatefulWidget {
  const ScheduledTransfersPage({super.key});

  @override
  State<ScheduledTransfersPage> createState() => _ScheduledTransfersPageState();
}

class _ScheduledTransfersPageState extends State<ScheduledTransfersPage> {
  List<ScheduledTransfer> _items = const [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final items = await FlowaServices.scheduledTransferRepository.getAll();
    if (!mounted) {
      return;
    }
    setState(() {
      _items = items;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FlowaScreen(
      title: 'Programadas',
      child: _loading
          ? const Center(
              child: CircularProgressIndicator(color: FlowaColors.mint),
            )
          : _items.isEmpty
              ? const FlowaEmptyState(
                  title: 'Nada programado',
                  message: 'Las transferencias en cola aparecerán aquí.',
                  glyph: FlowaGlyph.clock,
                )
              : ListView.builder(
                  itemCount: _items.length,
                  itemBuilder: (context, index) {
                    final item = _items[index];
                    return FlowaMenuRow(
                      glyph: FlowaGlyph.clock,
                      title: item.recipientName,
                      subtitle:
                          '${item.frequencyLabel} · ${FlowaFormatters.transactionStamp(item.scheduledFor)}',
                      trailing: Text(
                        FlowaFormatters.currency(item.amount),
                        style: FlowaType.titleSm(color: FlowaColors.mint),
                      ),
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '${item.recipientName}: '
                              '${FlowaFormatters.currency(item.amount)}',
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
    );
  }
}

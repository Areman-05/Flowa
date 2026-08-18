import 'package:flutter/material.dart';

import '../../../core/utils/flowa_formatters.dart';
import '../../../core/utils/flowa_services.dart';
import '../../../design_system/tokens/flowa_colors.dart';
import '../../../design_system/tokens/flowa_spacing.dart';
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
    return Scaffold(
      appBar: AppBar(title: const Text('Scheduled transfers')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _items.isEmpty
          ? const FlowaEmptyState(
              title: 'Nothing scheduled',
              message: 'Queued bank transfers will appear here.',
              icon: Icons.schedule_outlined,
            )
          : ListView.separated(
              padding: FlowaSpacing.screenPadding,
              itemCount: _items.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: FlowaSpacing.sm),
              itemBuilder: (context, index) {
                final item = _items[index];
                return ListTile(
                  shape: const RoundedRectangleBorder(
                    borderRadius: FlowaRadii.mdAll,
                    side: BorderSide(color: FlowaColors.border),
                  ),
                  title: Text(item.recipientName),
                  subtitle: Text(
                    '${item.frequencyLabel} · '
                    '${FlowaFormatters.transactionStamp(item.scheduledFor)}',
                  ),
                  trailing: Text(
                    FlowaFormatters.currency(item.amount),
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                );
              },
            ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/utils/flowa_formatters.dart';
import '../../../core/utils/flowa_haptics.dart';
import '../../../core/utils/flowa_services.dart';
import '../../../core/utils/receive_request.dart';
import '../../../design_system/components/flowa_motion.dart';
import '../../../design_system/tokens/flowa_colors.dart';
import '../../../design_system/tokens/flowa_spacing.dart';
import '../../../domain/entities/finance_entities.dart';
import '../../../shared/widgets/flowa_buttons.dart';
import '../../../shared/widgets/flowa_dialogs.dart';

/// Receive / request money screen.
class ReceivePage extends StatefulWidget {
  const ReceivePage({super.key});

  @override
  State<ReceivePage> createState() => _ReceivePageState();
}

class _ReceivePageState extends State<ReceivePage> {
  Account? _account;
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final account = await FlowaServices.accountRepository.getPrimaryAccount();
    if (!mounted) {
      return;
    }
    setState(() => _account = account);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _copyAccountNumber(Account account) async {
    await Clipboard.setData(ClipboardData(text: account.maskedNumber));
    await FlowaHaptics.selection();
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Account number copied.')));
  }

  Future<void> _shareRequest() async {
    final amount = double.tryParse(_amountController.text) ?? 0;
    final account = _account;
    if (amount <= 0 || account == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter an amount to request.')),
      );
      return;
    }

    final message = ReceiveRequest.build(
      account: account,
      amount: amount,
      note: _noteController.text,
    );

    final confirmed = await showFlowaPreviewDialog(
      context: context,
      title: 'Preview request',
      message: message,
      confirmLabel: 'Share request',
    );
    if (!confirmed || !mounted) {
      return;
    }

    await Clipboard.setData(ClipboardData(text: message));
    await FlowaHaptics.light();
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Request ${FlowaFormatters.currency(amount)} copied to clipboard.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final account = _account;

    return Scaffold(
      appBar: AppBar(title: const Text('Receive')),
      body: SafeArea(
        child: account == null
            ? const Padding(
                padding: FlowaSpacing.screenPadding,
                child: FlowaListSkeleton(itemCount: 3),
              )
            : ListView(
                padding: FlowaSpacing.screenPadding,
                children: [
                  Container(
                    padding: FlowaSpacing.cardPadding,
                    decoration: const BoxDecoration(
                      color: FlowaColors.actionReceive,
                      borderRadius: FlowaRadii.lgAll,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Your receive account',
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                        const SizedBox(height: FlowaSpacing.xs),
                        Text(
                          account.maskedNumber,
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: FlowaSpacing.xs),
                        Text(
                          'Share this account to get paid faster.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: FlowaSpacing.sm),
                        TextButton.icon(
                          onPressed: () => _copyAccountNumber(account),
                          icon: const Icon(Icons.copy_outlined, size: 18),
                          label: const Text('Copy account number'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: FlowaSpacing.xl),
                  TextField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+\.?\d{0,2}'),
                      ),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Request Amount',
                      prefixText: '\$ ',
                    ),
                  ),
                  const SizedBox(height: FlowaSpacing.sm),
                  TextField(
                    controller: _noteController,
                    decoration: const InputDecoration(
                      labelText: 'Note (optional)',
                    ),
                  ),
                  const SizedBox(height: FlowaSpacing.xxl),
                  FlowaPrimaryButton(
                    label: 'Create request',
                    onPressed: _shareRequest,
                  ),
                ],
              ),
      ),
    );
  }
}

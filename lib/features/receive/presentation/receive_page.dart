import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/utils/flowa_formatters.dart';
import '../../../core/utils/flowa_services.dart';
import '../../../design_system/tokens/flowa_colors.dart';
import '../../../design_system/tokens/flowa_spacing.dart';
import '../../../domain/entities/finance_entities.dart';
import '../../../shared/widgets/flowa_buttons.dart';

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

  void _shareRequest() {
    final amount = double.tryParse(_amountController.text) ?? 0;
    if (amount <= 0 || _account == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter an amount to request.')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Request ${FlowaFormatters.currency(amount)} ready to share '
          '(**** ${_account!.lastFour})',
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
            ? const Center(child: CircularProgressIndicator())
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
                      ],
                    ),
                  ),
                  const SizedBox(height: FlowaSpacing.xl),
                  TextField(
                    controller: _amountController,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
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

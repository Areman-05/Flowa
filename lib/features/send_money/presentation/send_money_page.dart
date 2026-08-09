import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/utils/flowa_services.dart';
import '../../../design_system/components/flowa_visa_card.dart';
import '../../../design_system/tokens/flowa_colors.dart';
import '../../../design_system/tokens/flowa_spacing.dart';
import '../../../domain/entities/finance_entities.dart';
import '../../../shared/navigation/flowa_routes.dart';
import '../../../shared/widgets/flowa_buttons.dart';
import '../../transfers/presentation/transfer_success_page.dart';

/// Send Money flow — visually distinct from Top-Up (purple source card).
class SendMoneyPage extends StatefulWidget {
  const SendMoneyPage({super.key});

  @override
  State<SendMoneyPage> createState() => _SendMoneyPageState();
}

class _SendMoneyPageState extends State<SendMoneyPage> {
  Account? _account;
  bool _balanceVisible = true;
  final _accountNumberController = TextEditingController();
  final _accountNameController = TextEditingController();
  final _noteController = TextEditingController();
  final _amountController = TextEditingController();

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
    _accountNumberController.dispose();
    _accountNameController.dispose();
    _noteController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final amount = double.tryParse(_amountController.text) ?? 0;
    if (_accountNumberController.text.isEmpty ||
        _accountNameController.text.isEmpty ||
        amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Fill recipient details and a valid amount.')),
      );
      return;
    }

    if (!mounted) {
      return;
    }
    await pushFlowaRoute<void>(
      context,
      TransferSuccessPage(
        title: 'Money sent',
        amount: amount,
        subtitle: 'Delivered to ${_accountNameController.text}',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final account = _account;

    return Scaffold(
      appBar: AppBar(title: const Text('Send Money')),
      body: SafeArea(
        child: account == null
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: FlowaSpacing.screenPadding,
                children: [
                  Text(
                    'Send Money From',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: FlowaSpacing.sm),
                  FlowaVisaCard(
                    account: account,
                    balanceVisible: _balanceVisible,
                    onToggleVisibility: () {
                      setState(() => _balanceVisible = !_balanceVisible);
                    },
                    height: 160,
                  ),
                  const SizedBox(height: FlowaSpacing.xl),
                  Text(
                    'Send Money To',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: FlowaSpacing.sm),
                  TextField(
                    controller: _accountNumberController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Account Number',
                    ),
                  ),
                  const SizedBox(height: FlowaSpacing.sm),
                  TextField(
                    controller: _accountNameController,
                    decoration: const InputDecoration(
                      labelText: 'Account Name',
                    ),
                  ),
                  const SizedBox(height: FlowaSpacing.sm),
                  TextField(
                    controller: _noteController,
                    decoration: const InputDecoration(
                      labelText: 'Note for Other',
                    ),
                  ),
                  const SizedBox(height: FlowaSpacing.xl),
                  Text(
                    'Send Money Amount',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: FlowaSpacing.sm),
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
                      prefixText: '\$ ',
                      hintText: '0.00',
                    ),
                  ),
                  const SizedBox(height: FlowaSpacing.xxl),
                  FlowaPrimaryButton(
                    label: 'Continue',
                    onPressed: _submit,
                  ),
                  const SizedBox(height: FlowaSpacing.sm),
                  Text(
                    'This screen is for bank transfers, not mobile top-ups.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: FlowaColors.textSecondary,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/utils/flowa_formatters.dart';
import '../../../core/utils/flowa_services.dart';
import '../../../design_system/components/flowa_amount_chips.dart';
import '../../../design_system/components/flowa_visa_card.dart';
import '../../../design_system/tokens/flowa_colors.dart';
import '../../../design_system/tokens/flowa_spacing.dart';
import '../../../domain/entities/finance_entities.dart';
import '../../../shared/widgets/flowa_buttons.dart';
import '../../../shared/widgets/flowa_dialogs.dart';

/// Top-Up flow — gold source card + confirmation to avoid Send confusion.
class TopUpPage extends StatefulWidget {
  const TopUpPage({super.key});

  @override
  State<TopUpPage> createState() => _TopUpPageState();
}

class _TopUpPageState extends State<TopUpPage> {
  Account? _account;
  bool _balanceVisible = true;
  double? _selectedChip;
  final _numberController = TextEditingController(text: '1475894586');
  final _amountController = TextEditingController(text: '150.00');
  static const _maxLimit = 100;

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
    _numberController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  double get _amount => double.tryParse(_amountController.text) ?? 0;

  bool get _aboveLimit => _amount > _maxLimit;

  Future<void> _continue() async {
    if (_numberController.text.isEmpty || _amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Enter a top-up number and amount.')),
      );
      return;
    }

    final confirmed = await showFlowaConfirmationDialog(
      context: context,
      title: 'Are you sure this is a Top-Up?',
      message:
          'You are topping up a phone/operator number, not sending money to a bank account. Confirm to avoid accidental transfers.',
      confirmLabel: 'Top Up Now',
    );

    if (!confirmed || !mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Top-up ${FlowaFormatters.currency(_amount)} to ${_numberController.text}',
        ),
      ),
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final account = _account;

    return Scaffold(
      appBar: AppBar(title: const Text('Top-Up')),
      body: SafeArea(
        child: account == null
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: FlowaSpacing.screenPadding,
                children: [
                  Text(
                    'Top Up From',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: FlowaSpacing.sm),
                  FlowaVisaCard(
                    account: account,
                    balanceVisible: _balanceVisible,
                    onToggleVisibility: () {
                      setState(() => _balanceVisible = !_balanceVisible);
                    },
                    style: FlowaCardStyle.gold,
                    height: 150,
                  ),
                  const SizedBox(height: FlowaSpacing.xl),
                  Text(
                    'Top-up to',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: FlowaSpacing.sm),
                  TextField(
                    controller: _numberController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Number',
                      suffixIcon: Icon(Icons.contacts_outlined),
                    ),
                  ),
                  const SizedBox(height: FlowaSpacing.xl),
                  Text(
                    'Top-up Amount',
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
                    onChanged: (_) => setState(() => _selectedChip = null),
                    decoration: const InputDecoration(
                      prefixText: '\$ ',
                    ),
                  ),
                  const SizedBox(height: FlowaSpacing.md),
                  FlowaAmountChips(
                    values: const [20, 50, 80, 100],
                    selected: _selectedChip,
                    onSelected: (value) {
                      setState(() {
                        _selectedChip = value;
                        _amountController.text = value.toStringAsFixed(2);
                      });
                    },
                  ),
                  if (_aboveLimit) ...[
                    const SizedBox(height: FlowaSpacing.md),
                    const FlowaInlineAlert(
                      message:
                          'This transaction is above your maximum limit. Learn more.',
                      actionLabel: 'Learn more',
                    ),
                  ],
                  const SizedBox(height: FlowaSpacing.xxl),
                  FlowaPrimaryButton(
                    label: 'Continue',
                    onPressed: _continue,
                  ),
                  const SizedBox(height: FlowaSpacing.sm),
                  Text(
                    'Top-Up is for mobile/operator recharge only.',
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

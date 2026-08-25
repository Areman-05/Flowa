import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/utils/flowa_services.dart';
import '../../../design_system/components/flowa_actions.dart';
import '../../../design_system/components/flowa_amount_chips.dart';
import '../../../design_system/components/flowa_screen.dart';
import '../../../design_system/components/flowa_visa_card.dart';
import '../../../design_system/tokens/flowa_colors.dart';
import '../../../design_system/tokens/flowa_spacing.dart';
import '../../../domain/entities/finance_entities.dart';
import '../../../shared/navigation/flowa_routes.dart';
import '../../../shared/widgets/flowa_dialogs.dart';
import '../../transfers/presentation/transfer_success_page.dart';

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
  final _numberController = TextEditingController();
  final _amountController = TextEditingController();
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
        const SnackBar(content: Text('Introduce un número e importe.')),
      );
      return;
    }

    final confirmed = await showFlowaConfirmationDialog(
      context: context,
      title: '¿Confirmas que es una recarga?',
      message:
          'Vas a recargar un número de teléfono/operador, no a enviar dinero a una cuenta bancaria.',
      confirmLabel: 'Recargar ahora',
    );

    if (!confirmed || !mounted) {
      return;
    }

    await FlowaServices.transactionRepository.add(
      TransactionItem(
        id: 'tx-${DateTime.now().millisecondsSinceEpoch}',
        merchant: 'Recarga ${_numberController.text}',
        amount: _amount,
        occurredAt: DateTime.now(),
        direction: TransactionDirection.debit,
        category: 'Recarga',
      ),
    );
    await FlowaServices.accountRepository.applyBalanceDelta(-_amount);

    if (!mounted) {
      return;
    }
    await pushFlowaRoute<void>(
      context,
      TransferSuccessPage(
        title: 'Recarga realizada',
        amount: _amount,
        subtitle: 'Recargado ${_numberController.text}',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final account = _account;

    return FlowaScreen(
      title: 'Recargar',
      footer: account == null
          ? null
          : FlowaAcidButton(label: 'Continuar', onPressed: _continue),
      child: account == null
          ? const Center(
              child: CircularProgressIndicator(color: FlowaColors.mint),
            )
          : ListView(
              children: [
                  Text(
                    'Recargar desde',
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
                  ),
                  const SizedBox(height: FlowaSpacing.xl),
                  Text(
                    'Recargar a',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: FlowaSpacing.sm),
                  TextField(
                    controller: _numberController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Número',
                      suffixIcon: Icon(Icons.contacts_outlined),
                    ),
                  ),
                  const SizedBox(height: FlowaSpacing.xl),
                  Text(
                    'Importe',
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
                      prefixText: '€ ',
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
                          'Esta operación supera tu límite máximo.',
                      actionLabel: 'Más info',
                    ),
                  ],
                  const SizedBox(height: FlowaSpacing.sm),
                  Text(
                    'La recarga es solo para móvil/operador.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: FlowaColors.textSecondary,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
    );
  }
}

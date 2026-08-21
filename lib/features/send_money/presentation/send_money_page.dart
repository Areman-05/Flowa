import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/utils/flowa_services.dart';
import '../../../design_system/components/flowa_visa_card.dart';
import '../../../design_system/tokens/flowa_colors.dart';
import '../../../design_system/tokens/flowa_spacing.dart';
import '../../../domain/entities/finance_entities.dart';
import '../../../domain/entities/payee_contact.dart';
import '../../../shared/navigation/flowa_routes.dart';
import '../../../shared/widgets/flowa_buttons.dart';
import '../../contacts/presentation/contacts_page.dart';
import 'scheduled_transfers_page.dart';
import 'send_review_page.dart';

/// Send Money flow — visually distinct from Top-Up (purple source card).
class SendMoneyPage extends StatefulWidget {
  const SendMoneyPage({super.key});

  @override
  State<SendMoneyPage> createState() => _SendMoneyPageState();
}

class _SendMoneyPageState extends State<SendMoneyPage> {
  Account? _account;
  List<PayeeContact> _contacts = const [];
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
    final results = await Future.wait([
      FlowaServices.accountRepository.getPrimaryAccount(),
      FlowaServices.contactRepository.getAll(),
    ]);
    if (!mounted) {
      return;
    }
    setState(() {
      _account = results[0] as Account;
      _contacts = results[1] as List<PayeeContact>;
    });
  }

  @override
  void dispose() {
    _accountNumberController.dispose();
    _accountNameController.dispose();
    _noteController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _pickContact() async {
    final contact = await pushFlowaRoute<PayeeContact>(
      context,
      const ContactsPage(selectMode: true),
    );
    if (contact == null || !mounted) {
      return;
    }
    setState(() {
      _accountNameController.text = contact.name;
      _accountNumberController.text = contact.accountNumber;
    });
    await _load();
  }

  Future<void> _submit() async {
    final amount = double.tryParse(_amountController.text) ?? 0;
    if (_accountNumberController.text.isEmpty ||
        _accountNameController.text.isEmpty ||
        amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Completa el destinatario y un importe válido.'),
        ),
      );
      return;
    }

    await pushFlowaRoute<void>(
      context,
      SendReviewPage(
        recipientName: _accountNameController.text,
        accountNumber: _accountNumberController.text,
        amount: amount,
        note: _noteController.text,
      ),
    );
    await _load();
  }

  @override
  Widget build(BuildContext context) {
    final account = _account;

    return Scaffold(
      appBar: AppBar(title: const Text('Enviar dinero')),
      body: SafeArea(
        child: account == null
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                padding: FlowaSpacing.screenPadding,
                children: [
                  Text(
                    'Enviar desde',
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
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Enviar a',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: _pickContact,
                        icon: const Icon(Icons.contacts_outlined, size: 18),
                        label: const Text('Contactos'),
                      ),
                    ],
                  ),
                  const SizedBox(height: FlowaSpacing.sm),
                  if (_contacts.isNotEmpty)
                    Wrap(
                      spacing: FlowaSpacing.sm,
                      runSpacing: FlowaSpacing.sm,
                      children: [
                        for (final contact in _contacts.take(6))
                          ActionChip(
                            avatar: Icon(
                              contact.kind == PayeeKind.business
                                  ? Icons.apartment_outlined
                                  : Icons.person_outline,
                              size: 16,
                            ),
                            label: Text(contact.name),
                            onPressed: () {
                              setState(() {
                                _accountNameController.text = contact.name;
                                _accountNumberController.text =
                                    contact.accountNumber;
                              });
                            },
                          ),
                      ],
                    )
                  else
                    Text(
                      'Aún no tienes contactos. Añade personas o empresas.',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  const SizedBox(height: FlowaSpacing.sm),
                  TextField(
                    controller: _accountNumberController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Número de cuenta',
                    ),
                  ),
                  const SizedBox(height: FlowaSpacing.sm),
                  TextField(
                    controller: _accountNameController,
                    decoration: const InputDecoration(
                      labelText: 'Nombre del destinatario',
                    ),
                  ),
                  const SizedBox(height: FlowaSpacing.sm),
                  TextField(
                    controller: _noteController,
                    decoration: const InputDecoration(
                      labelText: 'Nota (opcional)',
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
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r'^\d+\.?\d{0,2}'),
                      ),
                    ],
                    decoration: const InputDecoration(
                      prefixText: '€ ',
                      hintText: '0,00',
                    ),
                  ),
                  const SizedBox(height: FlowaSpacing.xxl),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      onPressed: () => pushFlowaRoute<void>(
                        context,
                        const ScheduledTransfersPage(),
                      ),
                      icon: const Icon(Icons.schedule_outlined),
                      label: const Text('Transferencias programadas'),
                    ),
                  ),
                  const SizedBox(height: FlowaSpacing.sm),
                  FlowaPrimaryButton(label: 'Continuar', onPressed: _submit),
                  const SizedBox(height: FlowaSpacing.sm),
                  Text(
                    'Esta pantalla es para transferencias bancarias, no recargas.',
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

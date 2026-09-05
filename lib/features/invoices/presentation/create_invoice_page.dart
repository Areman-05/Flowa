import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import '../../../core/utils/flowa_alerts.dart';
import '../../../core/utils/flowa_haptics.dart';
import '../../../core/utils/flowa_services.dart';
import '../../../design_system/components/flowa_actions.dart';
import '../../../design_system/components/flowa_screen.dart';
import '../../../design_system/tokens/flowa_colors.dart';
import '../../../design_system/tokens/flowa_spacing.dart';
import '../../../design_system/tokens/flowa_typography.dart';
import '../../../domain/entities/freelance_entities.dart';
import '../../../domain/entities/payee_contact.dart';
import '../../../shared/navigation/flowa_routes.dart';
import '../../contacts/presentation/contacts_page.dart';
import '../../more/presentation/widgets/more_service_ui.dart';

/// Create or edit a client cobro — demo persistence via [FreelanceRepository].
class CreateInvoicePage extends StatefulWidget {
  const CreateInvoicePage({super.key, this.existing});

  final Invoice? existing;

  @override
  State<CreateInvoicePage> createState() => _CreateInvoicePageState();
}

class _CreateInvoicePageState extends State<CreateInvoicePage> {
  final _client = TextEditingController();
  final _concept = TextEditingController();
  final _amount = TextEditingController();

  late DateTime _dueAt;
  bool _saving = false;
  String? _clientError;
  String? _amountError;
  String? _formError;

  bool get _isEdit => widget.existing != null;

  /// Paid cobro: metadata only; does not rewind saldo / movs.
  bool get _isPaidEdit => widget.existing?.status == InvoiceStatus.paid;

  /// Open cobro (pendiente / vencida stored as sent).
  bool get _isOpenEdit =>
      widget.existing != null &&
      widget.existing!.status == InvoiceStatus.sent;

  bool get _metadataOnlyEdit => _isPaidEdit || _isOpenEdit;

  @override
  void initState() {
    super.initState();
    final existing = widget.existing;
    if (existing != null) {
      _client.text = existing.client;
      _concept.text = existing.concept;
      _amount.text = existing.amount.toStringAsFixed(2).replaceAll('.', ',');
      _dueAt = DateUtils.dateOnly(existing.dueAt);
    } else {
      final today = DateUtils.dateOnly(DateTime.now());
      _dueAt = today.add(const Duration(days: 14));
    }
  }

  @override
  void dispose() {
    _client.dispose();
    _concept.dispose();
    _amount.dispose();
    super.dispose();
  }

  double? get _parsedAmount {
    final raw = _amount.text.trim().replaceAll(',', '.');
    if (raw.isEmpty) {
      return null;
    }
    return double.tryParse(raw);
  }

  int? get _selectedQuickDays {
    final today = DateUtils.dateOnly(DateTime.now());
    final days = DateUtils.dateOnly(_dueAt).difference(today).inDays;
    if (days == 7 || days == 14 || days == 30) {
      return days;
    }
    return null;
  }

  void _setDueInDays(int days) {
    final today = DateUtils.dateOnly(DateTime.now());
    setState(() => _dueAt = today.add(Duration(days: days)));
  }

  Future<void> _pickDueDate() async {
    final today = DateUtils.dateOnly(DateTime.now());
    final first = _isPaidEdit ? DateTime(today.year - 2) : today;
    final initial = _dueAt.isBefore(first) ? first : _dueAt;
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: first,
      lastDate: today.add(const Duration(days: 365 * 3)),
      helpText: 'Fecha de vencimiento',
      cancelText: 'Cancelar',
      confirmText: 'Elegir',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: FlowaColors.mint,
              onPrimary: FlowaColors.mintInk,
              surface: FlowaColors.inkHigh,
              onSurface: FlowaColors.bone,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() => _dueAt = DateUtils.dateOnly(picked));
    }
  }

  Future<void> _pickContact() async {
    final contact = await pushFlowaRoute<PayeeContact>(
      context,
      const ContactsPage(
        selectMode: true,
        selectHint: 'Toca un contacto para usarlo como cliente.',
      ),
    );
    if (contact == null || !mounted) {
      return;
    }
    setState(() {
      _client.text = contact.name;
      _clientError = null;
    });
  }

  bool _validate() {
    final client = _client.text.trim();
    final amount = _parsedAmount;
    String? clientError;
    String? amountError;

    if (client.isEmpty) {
      clientError = 'Indica el cliente';
    }
    if (amount == null || amount <= 0) {
      amountError = 'Importe no válido';
    }

    setState(() {
      _clientError = clientError;
      _amountError = amountError;
      _formError = null;
    });
    return clientError == null && amountError == null;
  }

  Future<String?> _nextNumber() async {
    final existing = await FlowaServices.freelanceRepository.getInvoices();
    final numbered =
        existing.where((i) => i.number != null && i.number!.isNotEmpty);
    return 'FAC-${DateTime.now().year}-'
        '${(numbered.length + 1).toString().padLeft(3, '0')}';
  }

  Future<void> _saveMetadata() async {
    if (!_validate()) {
      return;
    }
    final existing = widget.existing;
    if (existing == null) {
      return;
    }

    setState(() => _saving = true);

    try {
      final saved = await FlowaServices.freelanceRepository.updateInvoice(
        existing.copyWith(
          client: _client.text.trim(),
          concept: _concept.text.trim().isEmpty
              ? 'Servicios'
              : _concept.text.trim(),
          amount: _parsedAmount!,
          dueAt: _dueAt,
          status: existing.status,
        ),
      );
      await FlowaHaptics.success();
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop(saved);
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _formError = 'No se pudo guardar el cobro';
        _saving = false;
      });
    }
  }

  Future<void> _save({required bool asPending}) async {
    if (!_validate()) {
      return;
    }

    setState(() => _saving = true);

    try {
      final client = _client.text.trim();
      final concept = _concept.text.trim();
      final amount = _parsedAmount!;
      final now = DateTime.now();
      final existing = widget.existing;

      final Invoice saved;
      if (existing != null) {
        var next = existing.copyWith(
          client: client,
          concept: concept.isEmpty ? 'Servicios' : concept,
          amount: amount,
          dueAt: _dueAt,
          status: asPending ? InvoiceStatus.sent : InvoiceStatus.draft,
        );
        if (asPending && (next.number == null || next.number!.isEmpty)) {
          next = next.copyWith(number: await _nextNumber());
        }
        if (!asPending) {
          next = next.copyWith(clearNumber: true);
        }
        saved = await FlowaServices.freelanceRepository.updateInvoice(next);
      } else {
        saved = await FlowaServices.freelanceRepository.addInvoice(
          Invoice(
            id: 'inv-${now.millisecondsSinceEpoch}',
            client: client,
            concept: concept.isEmpty ? 'Servicios' : concept,
            amount: amount,
            issuedAt: now,
            dueAt: _dueAt,
            status: asPending ? InvoiceStatus.sent : InvoiceStatus.draft,
            number: asPending ? await _nextNumber() : null,
          ),
        );
      }

      await FlowaHaptics.success();
      if (asPending &&
          (existing == null || existing.status == InvoiceStatus.draft)) {
        await FlowaAlerts.cobroPending(saved);
      }
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop(saved);
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() {
        _formError = 'No se pudo guardar el cobro';
        _saving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final dueLabel = DateFormat('d MMMM yyyy', 'es_ES').format(_dueAt);
    final quickDays = _selectedQuickDays;

    return FlowaScreen(
      title: _isEdit ? 'Editar cobro' : 'Nuevo cobro',
      footer: Column(
        children: [
          if (_formError != null) ...[
            Text(
              _formError!,
              style: FlowaType.bodySm(color: FlowaColors.danger),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: FlowaSpacing.sm),
          ],
          if (_metadataOnlyEdit) ...[
            FlowaAcidButton(
              label: 'Guardar cambios',
              loading: _saving,
              onPressed: _saving ? null : _saveMetadata,
            ),
          ] else ...[
            FlowaAcidButton(
              label: 'Crear cobro',
              loading: _saving,
              onPressed: _saving ? null : () => _save(asPending: true),
            ),
            const SizedBox(height: FlowaSpacing.sm),
            FlowaGhostButton(
              label: 'Guardar borrador',
              onPressed: _saving ? null : () => _save(asPending: false),
              compact: true,
            ),
          ],
        ],
      ),
      child: ListView(
        children: [
          Text(
            _isPaidEdit
                ? 'Puedes corregir datos. El saldo y el movimiento '
                    'ya registrados no se recalculan.'
                : 'Lo que un cliente te debe. Luego lo cobras desde Por cobrar.',
            style: FlowaType.bodySm(color: FlowaColors.boneMuted),
          ),
          const SizedBox(height: FlowaSpacing.xl),
          TextField(
            controller: _client,
            style: moreFieldStyle,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            decoration: moreInputDecoration(
              label: 'Cliente',
              hint: 'Nombre o empresa',
              prefixIcon: Icons.person_outline_rounded,
            ).copyWith(
              errorText: _clientError,
              suffixIcon: IconButton(
                tooltip: 'Elegir de contactos',
                onPressed: _pickContact,
                icon: const Icon(
                  Icons.contacts_outlined,
                  color: FlowaColors.mint,
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerLeft,
            child: FlowaPressScale(
              onTap: _pickContact,
              child: Text(
                'Elegir de mis contactos',
                style: FlowaType.micro(color: FlowaColors.mint),
              ),
            ),
          ),
          const SizedBox(height: FlowaSpacing.md),
          TextField(
            controller: _concept,
            style: moreFieldStyle,
            textCapitalization: TextCapitalization.sentences,
            textInputAction: TextInputAction.next,
            decoration: moreInputDecoration(
              label: 'Concepto',
              hint: 'Diseño, consultoría…',
              prefixIcon: Icons.notes_outlined,
            ),
          ),
          const SizedBox(height: FlowaSpacing.md),
          TextField(
            controller: _amount,
            style: moreFieldStyle,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
            ],
            decoration: moreInputDecoration(
              label: 'Importe (€)',
              hint: '0,00',
              prefixIcon: Icons.euro_outlined,
            ).copyWith(errorText: _amountError),
          ),
          const SizedBox(height: FlowaSpacing.xl),
          FlowaPressScale(
            onTap: _pickDueDate,
            child: InputDecorator(
              decoration: moreInputDecoration(
                label: 'Fecha de vencimiento',
                prefixIcon: Icons.calendar_today_outlined,
              ),
              child: Text(dueLabel, style: moreFieldStyle),
            ),
          ),
          const SizedBox(height: FlowaSpacing.md),
          Text(
            'Atajos',
            style: FlowaType.bodySm(color: FlowaColors.boneMuted),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              for (final days in const [7, 14, 30]) ...[
                FlowaFilterChip(
                  label: '$days d',
                  selected: quickDays == days,
                  onTap: () => _setDueInDays(days),
                ),
                if (days != 30) const SizedBox(width: 8),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

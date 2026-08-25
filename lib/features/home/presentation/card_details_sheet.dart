import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/utils/flowa_haptics.dart';
import '../../../design_system/components/flowa_glass.dart';
import '../../../design_system/tokens/flowa_colors.dart';
import '../../../design_system/tokens/flowa_spacing.dart';
import '../../../domain/entities/finance_entities.dart';

Future<void> showCardDetailsSheet(BuildContext context, Account account) {
  return showFlowaGlassSheet<void>(
    context: context,
    builder: (context) => _CardDetailsBody(account: account),
  );
}

class _CardDetailsBody extends StatefulWidget {
  const _CardDetailsBody({required this.account});

  final Account account;

  @override
  State<_CardDetailsBody> createState() => _CardDetailsBodyState();
}

class _CardDetailsBodyState extends State<_CardDetailsBody> {
  bool _cvcVisible = false;

  Future<void> _copyNumber() async {
    await Clipboard.setData(
      ClipboardData(text: widget.account.maskedNumber),
    );
    await FlowaHaptics.selection();
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Número copiado.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Center(
          child: Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.only(bottom: FlowaSpacing.md),
            decoration: BoxDecoration(
              color: FlowaColors.border,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
        ),
        Text('Detalles de la tarjeta', style: textTheme.titleLarge),
        const SizedBox(height: FlowaSpacing.md),
        _DetailRow(
          label: 'Número',
          value: widget.account.maskedNumber,
          trailing: IconButton(
            icon: const Icon(Icons.copy_outlined, size: 18),
            onPressed: _copyNumber,
          ),
        ),
        _DetailRow(
          label: 'Marca',
          value: widget.account.brand,
        ),
        _DetailRow(
          label: 'Caduca',
          value: widget.account.expiryLabel,
        ),
        Row(
          children: [
            Expanded(
              child: Text('CVC', style: textTheme.bodyMedium),
            ),
            Text(
              _cvcVisible ? '123' : '•••',
              style: textTheme.titleMedium,
            ),
            IconButton(
              icon: Icon(
                _cvcVisible ? Icons.visibility_off : Icons.visibility,
                size: 18,
                color: FlowaColors.textSecondary,
              ),
              onPressed: () => setState(() => _cvcVisible = !_cvcVisible),
            ),
          ],
        ),
        const SizedBox(height: FlowaSpacing.sm),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.trailing,
  });

  final String label;
  final String value;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: FlowaSpacing.md),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ),
          Text(value, style: Theme.of(context).textTheme.titleMedium),
          ?trailing,
        ],
      ),
    );
  }
}

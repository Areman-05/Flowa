import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/utils/flowa_haptics.dart';
import '../../../design_system/tokens/flowa_colors.dart';
import '../../../design_system/tokens/flowa_spacing.dart';
import '../../../domain/entities/finance_entities.dart';

Future<void> showCardDetailsSheet(BuildContext context, Account account) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(FlowaRadii.xl)),
    ),
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
      const SnackBar(content: Text('Card number copied.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Padding(
      padding: FlowaSpacing.screenPadding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Card details', style: textTheme.titleLarge),
          const SizedBox(height: FlowaSpacing.md),
          _DetailRow(
            label: 'Number',
            value: widget.account.maskedNumber,
            trailing: IconButton(
              icon: const Icon(Icons.copy_outlined, size: 18),
              onPressed: _copyNumber,
            ),
          ),
          _DetailRow(
            label: 'Brand',
            value: widget.account.brand,
          ),
          _DetailRow(
            label: 'Expires',
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
          const SizedBox(height: FlowaSpacing.xl),
        ],
      ),
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
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../core/utils/flowa_formatters.dart';
import '../../../core/utils/flowa_haptics.dart';
import '../../../design_system/components/flowa_actions.dart';
import '../../../design_system/components/flowa_icon.dart';
import '../../../design_system/components/flowa_screen.dart';
import '../../../design_system/tokens/flowa_colors.dart';
import '../../../design_system/tokens/flowa_spacing.dart';
import '../../../design_system/tokens/flowa_typography.dart';

class TransferSuccessPage extends StatefulWidget {
  const TransferSuccessPage({
    required this.title,
    required this.amount,
    required this.subtitle,
    super.key,
  });

  final String title;
  final double amount;
  final String subtitle;

  @override
  State<TransferSuccessPage> createState() => _TransferSuccessPageState();
}

class _TransferSuccessPageState extends State<TransferSuccessPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _scale = CurvedAnimation(parent: _controller, curve: Curves.elasticOut);
    _controller.forward();
    FlowaHaptics.success();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FlowaScreen(
      title: '',
      showBack: false,
      footer: FlowaAcidButton(
        label: 'Listo',
        onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
      ),
      child: Column(
        children: [
          const Spacer(),
          ScaleTransition(
            scale: _scale,
            child: const FlowaIconOrb(
              glyph: FlowaGlyph.check,
              size: 88,
              background: FlowaColors.mint,
              foreground: FlowaColors.mintInk,
            ),
          ),
          const SizedBox(height: FlowaSpacing.xl),
          Text(widget.title, style: FlowaType.micro()),
          const SizedBox(height: FlowaSpacing.sm),
          Text(
            FlowaFormatters.currency(widget.amount),
            style: FlowaType.figureXl(),
          ),
          const SizedBox(height: FlowaSpacing.sm),
          Text(
            widget.subtitle,
            style: FlowaType.body(color: FlowaColors.mint),
            textAlign: TextAlign.center,
          ),
          const Spacer(),
        ],
      ),
    );
  }
}

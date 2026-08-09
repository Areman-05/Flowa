import 'package:flutter/material.dart';

import '../../../core/utils/flowa_formatters.dart';
import '../../../core/utils/flowa_haptics.dart';
import '../../../design_system/tokens/flowa_colors.dart';
import '../../../design_system/tokens/flowa_spacing.dart';
import '../../../shared/widgets/flowa_buttons.dart';

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
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: FlowaSpacing.screenPadding,
          child: Column(
            children: [
              const Spacer(),
              ScaleTransition(
                scale: _scale,
                child: const CircleAvatar(
                  radius: 42,
                  backgroundColor: FlowaColors.actionReceive,
                  child: Icon(
                    Icons.check_rounded,
                    size: 44,
                    color: FlowaColors.success,
                  ),
                ),
              ),
              const SizedBox(height: FlowaSpacing.xl),
              Text(
                widget.title,
                style: Theme.of(context).textTheme.headlineMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: FlowaSpacing.sm),
              Text(
                FlowaFormatters.currency(widget.amount),
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: FlowaColors.primary,
                    ),
              ),
              const SizedBox(height: FlowaSpacing.sm),
              Text(
                widget.subtitle,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              FlowaPrimaryButton(
                label: 'Done',
                onPressed: () => Navigator.of(context).popUntil(
                  (route) => route.isFirst,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

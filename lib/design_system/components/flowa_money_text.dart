import 'package:flutter/material.dart';

import '../../core/constants/flowa_constants.dart';
import '../../core/utils/flowa_formatters.dart';
import '../../core/utils/flowa_runtime.dart';
import '../tokens/flowa_colors.dart';
import '../tokens/flowa_motion_tokens.dart';
import '../tokens/flowa_typography.dart';

/// The hero money figure.
///
/// Euros are set huge and tight; cents and the currency symbol drop to a
/// quieter size. Digits are tabular, so a counting animation never makes the
/// layout jitter.
class FlowaFigure extends StatelessWidget {
  const FlowaFigure({
    required this.amount,
    super.key,
    this.size = FlowaFigureSize.xl,
    this.color = FlowaColors.bone,
    this.animate = true,
    this.masked = false,
    this.signed = false,
  });

  final double amount;
  final FlowaFigureSize size;
  final Color color;
  final bool animate;
  final bool masked;
  final bool signed;

  @override
  Widget build(BuildContext context) {
    if (masked) {
      // Dots at figure weight read as content rather than as a covered number,
      // so the placeholder is dimmed and set tighter than the real amount.
      return Text(
        '••••••',
        style: _integerStyle.copyWith(
          color: color.withValues(alpha: 0.28),
          letterSpacing: -2,
        ),
      );
    }

    if (!animate || FlowaRuntime.isWidgetTest) {
      return _render(amount);
    }

    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0, end: amount),
      duration: FlowaMotion.epic,
      curve: FlowaMotion.expoOut,
      builder: (context, value, _) => _render(value),
    );
  }

  TextStyle get _integerStyle => switch (size) {
        FlowaFigureSize.xl => FlowaType.figureXl(color: color),
        FlowaFigureSize.lg => FlowaType.figureLg(color: color),
        FlowaFigureSize.md => FlowaType.figureMd(color: color),
      };

  double get _tailSize => switch (size) {
        FlowaFigureSize.xl => 24,
        FlowaFigureSize.lg => 17,
        FlowaFigureSize.md => 13,
      };

  Widget _render(double value) {
    final parts = FlowaFormatters.amountParts(value);
    final prefix = !signed
        ? ''
        : value < 0
            ? '−'
            : '+';
    final tailStyle = FlowaType.figureMd(
      color: color.withValues(alpha: 0.45),
    ).copyWith(fontSize: _tailSize, letterSpacing: -0.4);

    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('$prefix${parts.integer}', style: _integerStyle),
        Padding(
          padding: EdgeInsets.only(top: _tailSize * 0.35),
          child: Text(
            ',${parts.fraction} ${FlowaConstants.currencySymbol}',
            style: tailStyle,
          ),
        ),
      ],
    );
  }
}

enum FlowaFigureSize { xl, lg, md }

/// Signed amount for list rows. Incoming money is the only thing in a list
/// allowed to use the accent colour; outgoing money stays neutral, because
/// spending is not an error state.
class FlowaAmountText extends StatelessWidget {
  const FlowaAmountText({
    required this.signedAmount,
    super.key,
    this.masked = false,
  });

  final double signedAmount;
  final bool masked;

  @override
  Widget build(BuildContext context) {
    if (masked) {
      return Text('••••', style: FlowaType.amountMd(color: FlowaColors.boneFaint));
    }

    final incoming = signedAmount > 0;
    final parts = FlowaFormatters.amountParts(signedAmount);
    final sign = incoming ? '+' : '−';

    return Text(
      '$sign${parts.integer},${parts.fraction} '
      '${FlowaConstants.currencySymbol}',
      style: FlowaType.amountMd(
        color: incoming ? FlowaColors.acid : FlowaColors.bone,
      ),
    );
  }
}

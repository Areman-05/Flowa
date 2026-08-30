import 'package:flutter/material.dart';

import '../../../core/utils/flowa_haptics.dart';
import '../../../design_system/components/flowa_actions.dart';
import '../../../design_system/components/flowa_icon.dart';
import '../../../design_system/components/flowa_screen.dart';
import '../../../design_system/tokens/flowa_colors.dart';
import '../../../design_system/tokens/flowa_spacing.dart';
import '../../../design_system/tokens/flowa_typography.dart';
import 'card_profile.dart';

class CardPinPage extends StatefulWidget {
  const CardPinPage({required this.profile, super.key});

  final CardProfile profile;

  @override
  State<CardPinPage> createState() => _CardPinPageState();
}

class _CardPinPageState extends State<CardPinPage> {
  late String _pin = widget.profile.cardPin;
  bool _visible = false;
  bool _changing = false;
  String _draft = '';

  void _append(String digit) {
    if (!_changing || _draft.length >= 4) {
      return;
    }
    FlowaHaptics.selection();
    setState(() => _draft += digit);
    if (_draft.length == 4) {
      setState(() {
        _pin = _draft;
        _draft = '';
        _changing = false;
        _visible = true;
      });
      FlowaHaptics.success();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('PIN de tarjeta actualizado.')),
      );
    }
  }

  void _backspace() {
    if (_draft.isEmpty) {
      return;
    }
    setState(() => _draft = _draft.substring(0, _draft.length - 1));
  }

  Future<void> _done() async {
    Navigator.of(context).pop(widget.profile.copyWith(cardPin: _pin));
  }

  @override
  Widget build(BuildContext context) {
    return FlowaScreen(
      title: 'PIN',
      footer: FlowaAcidButton(
        label: _changing ? 'Cancelar' : 'Listo',
        onPressed: _changing
            ? () => setState(() {
                  _changing = false;
                  _draft = '';
                })
            : _done,
      ),
      child: Column(
        children: [
          const Spacer(),
          Text(
            widget.profile.account.displayName,
            textAlign: TextAlign.center,
            style: FlowaType.titleSm(),
          ),
          const SizedBox(height: 4),
          Text(
            '•••• ${widget.profile.account.lastFour}',
            style: FlowaType.bodySm(),
          ),
          const SizedBox(height: FlowaSpacing.xxl),
          Text(
            _changing ? 'Nuevo PIN' : 'Tu PIN',
            style: FlowaType.micro(),
          ),
          const SizedBox(height: FlowaSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (var i = 0; i < 4; i++) ...[
                if (i > 0) const SizedBox(width: 14),
                _PinDot(
                  filled: !_changing || i < _draft.length,
                  digit: !_changing && _visible ? _pin[i] : null,
                  active: _changing && i == _draft.length,
                ),
              ],
            ],
          ),
          const SizedBox(height: FlowaSpacing.xl),
          if (!_changing)
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FlowaGhostButton(
                  label: _visible ? 'Ocultar' : 'Mostrar',
                  compact: true,
                  expand: false,
                  onPressed: () => setState(() => _visible = !_visible),
                ),
                const SizedBox(width: FlowaSpacing.sm),
                FlowaAcidButton(
                  label: 'Cambiar',
                  compact: true,
                  expand: false,
                  onPressed: () => setState(() {
                    _changing = true;
                    _draft = '';
                    _visible = false;
                  }),
                ),
              ],
            )
          else
            Text(
              'Introduce 4 dígitos',
              style: FlowaType.bodySm(),
            ),
          const Spacer(),
          if (_changing) ...[
            _Pad(onDigit: _append, onBackspace: _backspace),
            const SizedBox(height: FlowaSpacing.md),
          ],
        ],
      ),
    );
  }
}

class _PinDot extends StatelessWidget {
  const _PinDot({
    required this.filled,
    this.digit,
    this.active = false,
  });

  final bool filled;
  final String? digit;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 56,
      height: 56,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: FlowaColors.inkHigh,
        shape: BoxShape.circle,
        border: Border.all(
          color: active
              ? FlowaColors.mint
              : filled
                  ? FlowaColors.mint.withValues(alpha: 0.55)
                  : FlowaColors.hairlineStrong,
          width: active ? 1.5 : 1,
        ),
      ),
      child: digit != null
          ? Text(digit!, style: FlowaType.figureMd())
          : AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              width: filled ? 12 : 0,
              height: filled ? 12 : 0,
              decoration: const BoxDecoration(
                color: FlowaColors.mint,
                shape: BoxShape.circle,
              ),
            ),
    );
  }
}

class _Pad extends StatelessWidget {
  const _Pad({required this.onDigit, required this.onBackspace});

  final ValueChanged<String> onDigit;
  final VoidCallback onBackspace;

  @override
  Widget build(BuildContext context) {
    const keys = [
      ['1', '2', '3'],
      ['4', '5', '6'],
      ['7', '8', '9'],
      ['', '0', '⌫'],
    ];
    return Column(
      children: [
        for (final row in keys)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                for (final key in row)
                  SizedBox(
                    width: 72,
                    height: 72,
                    child: key.isEmpty
                        ? const SizedBox.shrink()
                        : FlowaPressScale(
                            onTap: () {
                              if (key == '⌫') {
                                onBackspace();
                              } else {
                                onDigit(key);
                              }
                            },
                            child: Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: key == '⌫'
                                    ? Colors.transparent
                                    : FlowaColors.inkHigh,
                                shape: BoxShape.circle,
                              ),
                              child: key == '⌫'
                                  ? const FlowaIcon(
                                      FlowaGlyph.arrowLeft,
                                      size: 22,
                                    )
                                  : Text(key, style: FlowaType.titleLg()),
                            ),
                          ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/utils/flowa_haptics.dart';
import '../../../core/utils/flowa_pin.dart';
import '../../../core/utils/flowa_services.dart';
import '../../../design_system/components/flowa_actions.dart';
import '../../../design_system/components/flowa_icon.dart';
import '../../../design_system/components/flowa_screen.dart';
import '../../../design_system/components/flowa_texture.dart';
import '../../../design_system/tokens/flowa_colors.dart';
import '../../../design_system/tokens/flowa_spacing.dart';
import '../../../design_system/tokens/flowa_typography.dart';

class PinUnlockPage extends StatefulWidget {
  const PinUnlockPage({required this.onUnlocked, super.key});

  final VoidCallback onUnlocked;

  @override
  State<PinUnlockPage> createState() => _PinUnlockPageState();
}

class _PinUnlockPageState extends State<PinUnlockPage> {
  String _attempt = '';
  String? _error;

  Future<void> _append(String digit) async {
    if (_attempt.length >= FlowaPin.length) {
      return;
    }
    await FlowaHaptics.selection();
    setState(() {
      _attempt += digit;
      _error = null;
    });
    if (_attempt.length == FlowaPin.length) {
      await _verify();
    }
  }

  Future<void> _verify() async {
    final stored = await FlowaServices.preferencesRepository.getPinCode();
    if (FlowaPin.matches(stored: stored, attempt: _attempt)) {
      widget.onUnlocked();
      return;
    }
    await FlowaHaptics.light();
    setState(() {
      _error = 'PIN incorrecto';
      _attempt = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: FlowaColors.ink,
        body: FlowaCanvas(
          mist: false,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: FlowaSpacing.gutter,
              ),
              child: Column(
                children: [
                  const Spacer(),
                  const FlowaIcon(
                    FlowaGlyph.lock,
                    size: 36,
                    color: FlowaColors.mint,
                  ),
                  const SizedBox(height: FlowaSpacing.md),
                  Text('Introduce tu PIN', style: FlowaType.titleLg()),
                  const SizedBox(height: FlowaSpacing.sm),
                  Text(
                    'Bloqueo de la app',
                    style: FlowaType.body(color: FlowaColors.boneMuted),
                  ),
                  const SizedBox(height: FlowaSpacing.xl),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var i = 0; i < FlowaPin.length; i++)
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: i < _attempt.length
                                ? FlowaColors.mint
                                : FlowaColors.hairlineStrong,
                          ),
                        ),
                    ],
                  ),
                  if (_error != null) ...[
                    const SizedBox(height: FlowaSpacing.md),
                    Text(
                      _error!,
                      style: FlowaType.body(color: FlowaColors.danger),
                    ),
                  ],
                  const Spacer(),
                  _PinKeypad(
                    onDigit: _append,
                    onDelete: () {
                      if (_attempt.isEmpty) {
                        return;
                      }
                      setState(
                        () => _attempt =
                            _attempt.substring(0, _attempt.length - 1),
                      );
                    },
                  ),
                  const SizedBox(height: FlowaSpacing.xl),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class PinSetupPage extends StatefulWidget {
  const PinSetupPage({super.key});

  @override
  State<PinSetupPage> createState() => _PinSetupPageState();
}

class _PinSetupPageState extends State<PinSetupPage> {
  final _controller = TextEditingController();
  bool _enabled = false;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final enabled = await FlowaServices.preferencesRepository.isPinEnabled();
    final code = await FlowaServices.preferencesRepository.getPinCode();
    if (!mounted) {
      return;
    }
    setState(() {
      _enabled = enabled;
      _controller.text = code;
      _loading = false;
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_enabled) {
      await FlowaServices.preferencesRepository.setPinEnabled(false);
      if (!mounted) {
        return;
      }
      Navigator.of(context).pop();
      return;
    }
    final error = FlowaPin.validate(_controller.text);
    if (error != null) {
      setState(() => _error = error);
      return;
    }
    await FlowaServices.preferencesRepository.setPinCode(_controller.text);
    await FlowaServices.preferencesRepository.setPinEnabled(true);
    await FlowaServices.preferencesRepository.setBiometricEnabled(false);
    if (!mounted) {
      return;
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return FlowaScreen(
      title: 'Bloqueo',
      footer: FlowaAcidButton(label: 'Guardar', onPressed: _save),
      child: _loading
          ? const Center(
              child: CircularProgressIndicator(color: FlowaColors.mint),
            )
          : ListView(
              children: [
                Material(
                  color: Colors.transparent,
                  child: SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: Text(
                      'Pedir PIN al abrir',
                      style: FlowaType.titleSm(),
                    ),
                    subtitle: Text(
                      'Protege la app después del onboarding',
                      style: FlowaType.bodySm(color: FlowaColors.boneMuted),
                    ),
                    value: _enabled,
                    activeThumbColor: FlowaColors.mintInk,
                    activeTrackColor: FlowaColors.mint,
                    onChanged: (value) => setState(() => _enabled = value),
                  ),
                ),
                if (_enabled) ...[
                  const SizedBox(height: FlowaSpacing.md),
                  TextField(
                    controller: _controller,
                    keyboardType: TextInputType.number,
                    obscureText: true,
                    maxLength: FlowaPin.length,
                    style: FlowaType.titleSm(),
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: InputDecoration(
                      labelText: 'PIN de 4 dígitos',
                      errorText: _error,
                    ),
                  ),
                ],
              ],
            ),
    );
  }
}

class _PinKeypad extends StatelessWidget {
  const _PinKeypad({required this.onDigit, required this.onDelete});

  final ValueChanged<String> onDigit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    const keys = ['1', '2', '3', '4', '5', '6', '7', '8', '9', '', '0', 'del'];
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 3,
      childAspectRatio: 1.6,
      children: [
        for (final key in keys)
          if (key.isEmpty)
            const SizedBox.shrink()
          else
            TextButton(
              onPressed: key == 'del' ? onDelete : () => onDigit(key),
              child: Text(
                key == 'del' ? '⌫' : key,
                style: FlowaType.titleLg(),
              ),
            ),
      ],
    );
  }
}

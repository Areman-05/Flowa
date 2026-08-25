import 'package:flutter/material.dart';

import '../../../core/utils/flowa_haptics.dart';
import '../../../core/utils/flowa_password.dart';
import '../../../core/utils/flowa_services.dart';
import '../../../core/utils/flowa_validators.dart';
import '../../../design_system/components/flowa_actions.dart';
import '../../../design_system/components/flowa_fields.dart';
import '../../../design_system/components/flowa_primitives.dart';
import '../../../design_system/tokens/flowa_colors.dart';
import '../../../design_system/tokens/flowa_motion_tokens.dart';
import '../../../design_system/tokens/flowa_spacing.dart';
import '../../../design_system/tokens/flowa_typography.dart';
import 'widgets/auth_scaffold.dart';

/// Registration as four short questions.
///
/// The last one is the product pitch disguised as a setup step: choosing what
/// share of every payment gets locked away for tax means the account is
/// already doing its job before the user sees the balance.
class RegisterPage extends StatefulWidget {
  const RegisterPage({required this.onAuthenticated, super.key});

  final VoidCallback onAuthenticated;

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

enum _Step { name, email, password, reserve }

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();

  _Step _step = _Step.name;
  String? _error;
  bool _loading = false;
  bool _reveal = false;
  double _reserveRate = 0.25;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  int get _index => _Step.values.indexOf(_step);

  bool get _canAdvance => switch (_step) {
        _Step.name => _name.text.trim().length >= 2,
        _Step.email => FlowaValidators.email(_email.text) == null,
        _Step.password => FlowaPassword.isStrong(_password.text),
        _Step.reserve => true,
      };

  void _back() {
    if (_index == 0) {
      return;
    }
    FlowaHaptics.selection();
    setState(() {
      _error = null;
      _step = _Step.values[_index - 1];
    });
  }

  Future<void> _advance() async {
    final message = switch (_step) {
      _Step.name => _name.text.trim().length >= 2
          ? null
          : 'Necesitamos al menos dos letras',
      _Step.email => FlowaValidators.email(_email.text) == null
          ? null
          : 'Ese email no parece válido',
      _Step.password => FlowaPassword.validationMessage(_password.text),
      _Step.reserve => null,
    };

    if (message != null) {
      setState(() => _error = message);
      return;
    }

    if (_step != _Step.reserve) {
      await FlowaHaptics.selection();
      setState(() {
        _error = null;
        _step = _Step.values[_index + 1];
      });
      return;
    }

    await _submit();
  }

  Future<void> _submit() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await FlowaServices.authRepository.register(
        fullName: _name.text.trim(),
        email: _email.text.trim(),
        password: _password.text,
      );
      FlowaServices.resetUserData();
      await FlowaServices.freelanceRepository.setReserveRate(_reserveRate);
      await FlowaHaptics.success();
      widget.onAuthenticated();
    } catch (error) {
      if (mounted) {
        setState(() => _error = error.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthScaffold(
      kicker: _kicker,
      question: _question,
      step: _index,
      stepCount: _Step.values.length,
      onBack: _index == 0 ? null : _back,
      actions: FlowaAcidButton(
        label: _step == _Step.reserve ? 'Crear mi cuenta' : 'Continuar',
        icon: _step == _Step.reserve
            ? Icons.check_rounded
            : Icons.arrow_forward_rounded,
        loading: _loading,
        onPressed: _canAdvance ? _advance : null,
      ),
      footer: Text(
        'Tu cuenta se guarda cifrada en este dispositivo.',
        textAlign: TextAlign.center,
        style: FlowaType.micro(),
      ),
      child: AnimatedSwitcher(
        duration: FlowaMotion.base,
        switchInCurve: FlowaMotion.expoOut,
        switchOutCurve: FlowaMotion.exit,
        transitionBuilder: (child, animation) => FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.08),
              end: Offset.zero,
            ).animate(animation),
            child: child,
          ),
        ),
        child: KeyedSubtree(key: ValueKey(_step), child: _body()),
      ),
    );
  }

  String get _kicker => switch (_step) {
        _Step.name => 'Empecemos',
        _Step.email => 'Contacto',
        _Step.password => 'Seguridad',
        _Step.reserve => 'Lo importante',
      };

  String get _question => switch (_step) {
        _Step.name => '¿Cómo\nte llamas?',
        _Step.email => '¿Dónde te\nescribimos?',
        _Step.password => 'Protege\ntu dinero.',
        _Step.reserve => '¿Cuánto\napartas para\nHacienda?',
      };

  Widget _body() {
    switch (_step) {
      case _Step.name:
        return FlowaBigField(
          controller: _name,
          label: 'Nombre y apellidos',
          hint: 'Pablo Álvarez',
          autofocus: true,
          textCapitalization: TextCapitalization.words,
          error: _error,
          onChanged: (_) => setState(() => _error = null),
          onSubmitted: (_) => _advance(),
        );

      case _Step.email:
        return FlowaBigField(
          controller: _email,
          label: 'Email',
          hint: 'hola@estudio.com',
          autofocus: true,
          keyboardType: TextInputType.emailAddress,
          error: _error,
          onChanged: (_) => setState(() => _error = null),
          onSubmitted: (_) => _advance(),
        );

      case _Step.password:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            FlowaBigField(
              controller: _password,
              label: 'Contraseña',
              hint: '••••••••',
              autofocus: true,
              obscure: !_reveal,
              textInputAction: TextInputAction.done,
              error: _error,
              onChanged: (_) => setState(() => _error = null),
              onSubmitted: (_) => _advance(),
              trailing: GestureDetector(
                onTap: () => setState(() => _reveal = !_reveal),
                behavior: HitTestBehavior.opaque,
                child: Padding(
                  padding: const EdgeInsets.only(
                    left: FlowaSpacing.sm,
                    bottom: 10,
                  ),
                  child: Icon(
                    _reveal
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: 20,
                    color: FlowaColors.boneFaint,
                  ),
                ),
              ),
            ),
            const SizedBox(height: FlowaSpacing.md),
            FlowaStrengthMeter(
              score: FlowaStrengthMeter.scoreFor(_password.text),
            ),
            const SizedBox(height: FlowaSpacing.md),
            Text(
              'Mínimo ${FlowaPassword.minLength} caracteres con letras y '
              'números.',
              style: FlowaType.bodySm(),
            ),
          ],
        );

      case _Step.reserve:
        return _ReserveStep(
          rate: _reserveRate,
          onChanged: (value) => setState(() => _reserveRate = value),
        );
    }
  }
}

/// Auto-reserve setup. The figures update live so the percentage stops being
/// abstract before it is confirmed.
class _ReserveStep extends StatelessWidget {
  const _ReserveStep({required this.rate, required this.onChanged});

  final double rate;
  final ValueChanged<double> onChanged;

  static const double _sampleInvoice = 3400;

  @override
  Widget build(BuildContext context) {
    final reserved = _sampleInvoice * rate;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${(rate * 100).round()}',
              style: FlowaType.figureXl(color: FlowaColors.acid),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(
                '%',
                style: FlowaType.figureMd(color: FlowaColors.acid),
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const FlowaMicroLabel('De una factura de 3.400 €'),
                  const SizedBox(height: 4),
                  Text(
                    '${reserved.round()} € al bote',
                    style: FlowaType.titleMd(),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: FlowaSpacing.lg),
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 2,
            activeTrackColor: FlowaColors.acid,
            inactiveTrackColor: FlowaColors.hairline,
            thumbColor: FlowaColors.acid,
            overlayColor: FlowaColors.acidVeil,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
            overlayShape: const RoundSliderOverlayShape(overlayRadius: 18),
            tickMarkShape: SliderTickMarkShape.noTickMark,
          ),
          child: Slider(
            value: rate,
            max: 0.45,
            divisions: 9,
            onChanged: (value) {
              FlowaHaptics.selection();
              onChanged(value);
            },
          ),
        ),
        const SizedBox(height: FlowaSpacing.xs),
        const FlowaRule(),
        const SizedBox(height: FlowaSpacing.md),
        Text(
          'La mayoría de autónomos en España aparta entre un 20 % y un 30 %. '
          'Puedes cambiarlo cuando quieras.',
          style: FlowaType.bodySm(),
        ),
      ],
    );
  }
}

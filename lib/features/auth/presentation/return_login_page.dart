import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../core/utils/flowa_haptics.dart';
import '../../../core/utils/flowa_services.dart';
import '../../../design_system/components/flowa_actions.dart';
import '../../../design_system/components/flowa_fields.dart';
import '../../../design_system/components/flowa_icon.dart';
import '../../../design_system/components/flowa_mark.dart';
import '../../../design_system/components/flowa_primitives.dart';
import '../../../design_system/components/flowa_texture.dart';
import '../../../design_system/tokens/flowa_colors.dart';
import '../../../design_system/tokens/flowa_spacing.dart';
import '../../../design_system/tokens/flowa_typography.dart';

/// Unlock screen for a device that already has an account.
///
/// The app knows who is holding the phone, so it says so: the greeting is the
/// hero and the password is the only remaining input. A wrong attempt shakes
/// the field rather than pushing an error banner into the layout.
class ReturnLoginPage extends StatefulWidget {
  const ReturnLoginPage({required this.onAuthenticated, super.key});

  final VoidCallback onAuthenticated;

  @override
  State<ReturnLoginPage> createState() => _ReturnLoginPageState();
}

class _ReturnLoginPageState extends State<ReturnLoginPage>
    with SingleTickerProviderStateMixin {
  final TextEditingController _password = TextEditingController();
  late final AnimationController _shake;

  String? _firstName;
  String? _email;
  String? _error;
  bool _loading = false;
  bool _reveal = false;

  @override
  void initState() {
    super.initState();
    _shake = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _loadIdentity();
  }

  Future<void> _loadIdentity() async {
    final user = await FlowaServices.authRepository.currentUser();
    if (!mounted || user == null) {
      return;
    }
    setState(() {
      _firstName = user.fullName.trim().split(RegExp(r'\s+')).first;
      _email = _maskEmail(user.email);
    });
  }

  static String _maskEmail(String email) {
    final at = email.indexOf('@');
    if (at <= 1) {
      return email;
    }
    final head = email.substring(0, 1);
    final tail = email.substring(at);
    return '$head${'•' * (at - 1)}$tail';
  }

  @override
  void dispose() {
    _password.dispose();
    _shake.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_password.text.isEmpty) {
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await FlowaServices.authRepository.unlockWithPassword(_password.text);
      await FlowaHaptics.success();
      widget.onAuthenticated();
    } catch (error) {
      if (!mounted) {
        return;
      }
      await FlowaHaptics.light();
      _password.clear();
      setState(() => _error = error.toString());
      await _shake.forward(from: 0);
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FlowaColors.ink,
      body: FlowaCanvas(
        mist: false,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: FlowaSpacing.gutter,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: FlowaSpacing.lg),
                const FlowaFlowGlyph(size: 34),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: FlowaSpacing.huge),
                        const FlowaMicroLabel('Bienvenido de vuelta', dot: true),
                        const SizedBox(height: FlowaSpacing.md),
                        Text(
                          _firstName == null ? 'Hola.' : 'Hola,\n$_firstName.',
                          style: FlowaType.editorialXl(),
                        ),
                        if (_email != null) ...[
                          const SizedBox(height: FlowaSpacing.sm),
                          Text(_email!, style: FlowaType.amountSm()),
                        ],
                        const SizedBox(height: FlowaSpacing.giant),
                        _Shake(
                          animation: _shake,
                          child: FlowaBigField(
                            controller: _password,
                            label: 'Contraseña',
                            hint: '••••••••',
                            obscure: !_reveal,
                            autofocus: true,
                            textInputAction: TextInputAction.go,
                            error: _error,
                            onChanged: (_) {
                              if (_error != null) {
                                setState(() => _error = null);
                              }
                            },
                            onSubmitted: (_) => _submit(),
                            trailing: GestureDetector(
                              behavior: HitTestBehavior.opaque,
                              onTap: () => setState(() => _reveal = !_reveal),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  left: FlowaSpacing.sm,
                                  bottom: 10,
                                ),
                                child: FlowaIcon(
                                  _reveal
                                      ? FlowaGlyph.eyeOff
                                      : FlowaGlyph.eye,
                                  size: 20,
                                  color: FlowaColors.boneFaint,
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: FlowaSpacing.xxl),
                      ],
                    ),
                  ),
                ),
                FlowaAcidButton(
                  label: 'Entrar',
                  glyph: FlowaGlyph.arrowRight,
                  loading: _loading,
                  onPressed: _submit,
                ),
                const SizedBox(height: FlowaSpacing.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Damped horizontal oscillation used to reject a wrong password.
class _Shake extends StatelessWidget {
  const _Shake({required this.animation, required this.child});

  final Animation<double> animation;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, inner) {
        final t = animation.value;
        final damping = 1 - Curves.easeOut.transform(t);
        final offset = math.sin(t * math.pi * 6) * 10 * damping;
        return Transform.translate(offset: Offset(offset, 0), child: inner);
      },
      child: child,
    );
  }
}

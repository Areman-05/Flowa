import 'package:flutter/material.dart';

import '../../../core/utils/flowa_services.dart';
import '../../../core/utils/flowa_validators.dart';
import '../../../design_system/components/flowa_actions.dart';
import '../../../design_system/components/flowa_icon.dart';
import '../../../design_system/components/flowa_screen.dart';
import '../../../design_system/tokens/flowa_colors.dart';
import '../../../design_system/tokens/flowa_spacing.dart';
import '../../../design_system/tokens/flowa_typography.dart';

class ConnectPayPalPage extends StatefulWidget {
  const ConnectPayPalPage({super.key});

  @override
  State<ConnectPayPalPage> createState() => _ConnectPayPalPageState();
}

class _ConnectPayPalPageState extends State<ConnectPayPalPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _connect() async {
    final emailError = FlowaValidators.email(_emailController.text);
    final passwordError = FlowaValidators.requiredLabel(
      _passwordController.text,
      field: 'Contraseña',
    );
    if (emailError != null || passwordError != null) {
      setState(() => _error = emailError ?? passwordError);
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final wallet = await FlowaServices.walletRepository.connectPayPal(
        email: _emailController.text,
        password: _passwordController.text,
      );
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Conectado: ${wallet.displayName ?? 'PayPal'}'),
        ),
      );
      Navigator.of(context).pop(wallet);
    } catch (error) {
      if (!mounted) {
        return;
      }
      setState(() {
        _loading = false;
        _error = error.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return FlowaScreen(
      title: 'Conectar PayPal',
      footer: FlowaAcidButton(
        label: 'Conectar',
        loading: _loading,
        onPressed: _connect,
      ),
      child: ListView(
        children: [
          const SizedBox(height: FlowaSpacing.xl),
          const Center(
            child: FlowaIcon(
              FlowaGlyph.card,
              size: 48,
              color: FlowaColors.mint,
            ),
          ),
          const SizedBox(height: FlowaSpacing.sm),
          Text(
            'PayPal',
            textAlign: TextAlign.center,
            style: FlowaType.titleLg(),
          ),
          const SizedBox(height: FlowaSpacing.xs),
          Text(
            'Demo local: la conexión se guarda solo en este dispositivo.',
            textAlign: TextAlign.center,
            style: FlowaType.bodySm(color: FlowaColors.boneMuted),
          ),
          const SizedBox(height: FlowaSpacing.xxl),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            style: FlowaType.titleSm(),
            decoration: const InputDecoration(
              labelText: 'Email o móvil',
            ),
          ),
          const SizedBox(height: FlowaSpacing.sm),
          TextField(
            controller: _passwordController,
            obscureText: _obscure,
            style: FlowaType.titleSm(),
            decoration: InputDecoration(
              labelText: 'Contraseña',
              suffixIcon: IconButton(
                onPressed: () => setState(() => _obscure = !_obscure),
                icon: FlowaIcon(
                  _obscure ? FlowaGlyph.eye : FlowaGlyph.eyeOff,
                  size: 20,
                  color: FlowaColors.boneMuted,
                ),
              ),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: FlowaSpacing.sm),
            Text(
              _error!,
              style: FlowaType.bodySm(color: FlowaColors.danger),
            ),
          ],
          const SizedBox(height: FlowaSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const FlowaIcon(
                FlowaGlyph.lock,
                size: 16,
                color: FlowaColors.boneFaint,
              ),
              const SizedBox(width: FlowaSpacing.xs),
              Text(
                'Inicio de sesión simulado para la demo.',
                style: FlowaType.bodySm(color: FlowaColors.boneFaint),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

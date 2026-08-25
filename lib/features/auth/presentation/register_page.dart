import 'package:flutter/material.dart';

import '../../../core/utils/flowa_services.dart';
import '../../../data/datasources/mock_finance_data.dart';
import '../../../data/repositories/mock_account_repository.dart';
import '../../../design_system/tokens/flowa_colors.dart';
import '../../../design_system/tokens/flowa_spacing.dart';
import 'widgets/auth_controls.dart';
import 'widgets/auth_shell.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({required this.onAuthenticated, super.key});

  final VoidCallback onAuthenticated;

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  String? _error;
  bool _loading = false;
  bool _obscure = true;

  static const _fieldGap = FlowaSpacing.lg;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_passwordController.text != _confirmController.text) {
      setState(() => _error = 'Las contraseñas no coinciden');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final user = await FlowaServices.authRepository.register(
        fullName: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
      );
      FlowaServices.resetUserData();
      final accountRepo = FlowaServices.accountRepository;
      if (accountRepo is MockAccountRepository) {
        accountRepo.bootstrapUser(
          MockFinanceData.profileFromAuth(
            id: user.id,
            fullName: user.fullName,
            email: user.email,
          ),
        );
      }
      widget.onAuthenticated();
    } catch (error) {
      setState(() => _error = error.toString());
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthShell(
      showBack: true,
      showWordmark: false,
      markSize: 56,
      title: 'Crear cuenta',
      tagline:
          'Crea tu cuenta y empieza a mover dinero\ncon claridad y control.',
      form: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            decoration: authFieldDecoration(
              label: 'Nombre completo',
              prefixIcon: const Icon(
                Icons.person_outline_rounded,
                color: FlowaColors.textTertiary,
              ),
            ),
          ),
          const SizedBox(height: _fieldGap),
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            decoration: authFieldDecoration(
              label: 'Email',
              prefixIcon: const Icon(
                Icons.mail_outline_rounded,
                color: FlowaColors.textTertiary,
              ),
            ),
          ),
          const SizedBox(height: _fieldGap),
          TextField(
            controller: _passwordController,
            obscureText: _obscure,
            textInputAction: TextInputAction.next,
            decoration: authFieldDecoration(
              label: 'Contraseña',
              prefixIcon: const Icon(
                Icons.lock_outline_rounded,
                color: FlowaColors.textTertiary,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscure
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: FlowaColors.textTertiary,
                ),
                onPressed: () => setState(() => _obscure = !_obscure),
              ),
            ),
          ),
          const SizedBox(height: _fieldGap),
          TextField(
            controller: _confirmController,
            obscureText: _obscure,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _loading ? null : _submit(),
            decoration: authFieldDecoration(
              label: 'Confirmar contraseña',
              prefixIcon: const Icon(
                Icons.verified_user_outlined,
                color: FlowaColors.textTertiary,
              ),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: FlowaSpacing.sm),
            Text(
              _error!,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: FlowaColors.danger,
                  ),
            ),
          ],
        ],
      ),
      actions: AuthPrimaryButton(
        label: _loading ? 'Creando…' : 'Crear cuenta',
        loading: _loading,
        onPressed: _loading ? null : _submit,
      ),
      footer: Text(
        'Tu cuenta se guarda en este dispositivo.',
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.bodySmall,
      ),
    );
  }
}

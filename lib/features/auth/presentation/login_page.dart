import 'package:flutter/material.dart';

import '../../../core/utils/flowa_services.dart';
import '../../../data/datasources/mock_finance_data.dart';
import '../../../data/repositories/mock_account_repository.dart';
import '../../../design_system/tokens/flowa_colors.dart';
import '../../../design_system/tokens/flowa_spacing.dart';
import 'register_page.dart';
import 'widgets/auth_controls.dart';
import 'widgets/auth_shell.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({required this.onAuthenticated, super.key});

  final VoidCallback onAuthenticated;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _error;
  bool _loading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final user = await FlowaServices.authRepository.login(
        email: _emailController.text,
        password: _passwordController.text,
      );
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
      tagline: 'Claridad lunar para tu dinero.\nPremium. Preciso. Tuyo.',
      form: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            textInputAction: TextInputAction.next,
            decoration: authFieldDecoration(
              label: 'Email',
              prefixIcon: const Icon(
                Icons.mail_outline_rounded,
                color: FlowaColors.textTertiary,
              ),
            ),
          ),
          const SizedBox(height: FlowaSpacing.lg),
          TextField(
            controller: _passwordController,
            obscureText: _obscure,
            autofillHints: const [AutofillHints.password],
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _loading ? null : _submit(),
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
      actions: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AuthPrimaryButton(
            label: _loading ? 'Entrando…' : 'Entrar',
            loading: _loading,
            onPressed: _loading ? null : _submit,
          ),
          const SizedBox(height: FlowaSpacing.sm),
          TextButton(
            onPressed: _loading
                ? null
                : () {
                    Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => RegisterPage(
                          onAuthenticated: widget.onAuthenticated,
                        ),
                      ),
                    );
                  },
            child: Text.rich(
              TextSpan(
                style: Theme.of(context).textTheme.bodyMedium,
                children: const [
                  TextSpan(text: '¿Nuevo en Flowa? '),
                  TextSpan(
                    text: 'Crear cuenta',
                    style: TextStyle(
                      color: FlowaColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

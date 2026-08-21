import 'package:flutter/material.dart';

import '../../../core/constants/flowa_constants.dart';
import '../../../core/utils/flowa_services.dart';
import '../../../data/repositories/mock_account_repository.dart';
import '../../../data/datasources/mock_finance_data.dart';
import '../../../design_system/tokens/flowa_colors.dart';
import '../../../design_system/tokens/flowa_spacing.dart';
import '../../../shared/widgets/flowa_buttons.dart';
import 'register_page.dart';

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
    return Scaffold(
      backgroundColor: FlowaColors.background,
      body: SafeArea(
        child: ListView(
          padding: FlowaSpacing.screenPadding,
          children: [
            const SizedBox(height: FlowaSpacing.xxl),
            Text(
              FlowaConstants.appName,
              style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: FlowaColors.primary,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            const SizedBox(height: FlowaSpacing.sm),
            Text(
              'Inicia sesión para gestionar tu dinero',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: FlowaSpacing.xl),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              autofillHints: const [AutofillHints.email],
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: FlowaSpacing.sm),
            TextField(
              controller: _passwordController,
              obscureText: _obscure,
              autofillHints: const [AutofillHints.password],
              decoration: InputDecoration(
                labelText: 'Contraseña',
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscure ? Icons.visibility_outlined : Icons.visibility_off,
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
            const SizedBox(height: FlowaSpacing.xl),
            FlowaPrimaryButton(
              label: _loading ? 'Entrando…' : 'Entrar',
              onPressed: _loading ? null : _submit,
            ),
            const SizedBox(height: FlowaSpacing.sm),
            FlowaSecondaryButton(
              label: 'Crear cuenta',
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
            ),
          ],
        ),
      ),
    );
  }
}

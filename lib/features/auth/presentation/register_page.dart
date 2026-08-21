import 'package:flutter/material.dart';

import '../../../core/utils/flowa_services.dart';
import '../../../data/datasources/mock_finance_data.dart';
import '../../../data/repositories/mock_account_repository.dart';
import '../../../design_system/tokens/flowa_colors.dart';
import '../../../design_system/tokens/flowa_spacing.dart';
import '../../../shared/widgets/flowa_buttons.dart';

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
    return Scaffold(
      appBar: AppBar(title: const Text('Crear cuenta')),
      backgroundColor: FlowaColors.background,
      body: SafeArea(
        child: ListView(
          padding: FlowaSpacing.screenPadding,
          children: [
            Text(
              'Tu dinero, con tus datos',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: FlowaSpacing.xs),
            Text(
              'Empiezas con la cuenta vacía. Tú añades contactos, empresas y movimientos.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: FlowaSpacing.xl),
            TextField(
              controller: _nameController,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(labelText: 'Nombre completo'),
            ),
            const SizedBox(height: FlowaSpacing.sm),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: FlowaSpacing.sm),
            TextField(
              controller: _passwordController,
              obscureText: _obscure,
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
            const SizedBox(height: FlowaSpacing.sm),
            TextField(
              controller: _confirmController,
              obscureText: _obscure,
              decoration: const InputDecoration(
                labelText: 'Confirmar contraseña',
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
              label: _loading ? 'Creando…' : 'Registrarme',
              onPressed: _loading ? null : _submit,
            ),
          ],
        ),
      ),
    );
  }
}

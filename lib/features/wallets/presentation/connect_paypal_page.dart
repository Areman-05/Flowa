import 'package:flutter/material.dart';

import '../../../core/utils/flowa_services.dart';
import '../../../core/utils/flowa_validators.dart';
import '../../../design_system/tokens/flowa_colors.dart';
import '../../../design_system/tokens/flowa_spacing.dart';
import '../../../shared/widgets/flowa_buttons.dart';

class ConnectPayPalPage extends StatefulWidget {
  const ConnectPayPalPage({super.key});

  @override
  State<ConnectPayPalPage> createState() => _ConnectPayPalPageState();
}

class _ConnectPayPalPageState extends State<ConnectPayPalPage> {
  final _emailController = TextEditingController(text: 'john@gmail.com');
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
      field: 'Password',
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
        SnackBar(content: Text('Connected ${wallet.displayName ?? 'PayPal'}')),
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
    return Scaffold(
      appBar: AppBar(title: const Text('Connect PayPal')),
      body: SafeArea(
        child: ListView(
          padding: FlowaSpacing.screenPadding,
          children: [
            const SizedBox(height: FlowaSpacing.xl),
            const Icon(
              Icons.account_balance_wallet_rounded,
              size: 64,
              color: Color(0xFF003087),
            ),
            const SizedBox(height: FlowaSpacing.sm),
            Text(
              'PayPal',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: const Color(0xFF003087),
                    fontWeight: FontWeight.w800,
                  ),
            ),
            const SizedBox(height: FlowaSpacing.xxl),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email or Mobile Number',
              ),
            ),
            const SizedBox(height: FlowaSpacing.sm),
            TextField(
              controller: _passwordController,
              obscureText: _obscure,
              decoration: InputDecoration(
                labelText: 'Password',
                suffixIcon: IconButton(
                  onPressed: () => setState(() => _obscure = !_obscure),
                  icon: Icon(
                    _obscure ? Icons.visibility_off : Icons.visibility,
                  ),
                ),
              ),
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () {},
                child: const Text('Forgot password?'),
              ),
            ),
            if (_error != null) ...[
              Text(
                _error!,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: FlowaColors.danger,
                    ),
              ),
              const SizedBox(height: FlowaSpacing.sm),
            ],
            FlowaPrimaryButton(
              label: 'Log In',
              isLoading: _loading,
              onPressed: _connect,
            ),
            const SizedBox(height: FlowaSpacing.md),
            const Row(
              children: [
                Expanded(child: Divider()),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: FlowaSpacing.sm),
                  child: Text('or'),
                ),
                Expanded(child: Divider()),
              ],
            ),
            const SizedBox(height: FlowaSpacing.md),
            FlowaSecondaryButton(
              label: 'Create Account',
              onPressed: () {},
            ),
            const SizedBox(height: FlowaSpacing.xl),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.lock_outline, size: 16),
                const SizedBox(width: FlowaSpacing.xs),
                Text(
                  'Secure login handled by PayPal.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

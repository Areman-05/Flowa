import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/flowa_constants.dart';
import '../../../core/utils/flowa_services.dart';
import '../../../design_system/tokens/flowa_colors.dart';
import '../../../design_system/tokens/flowa_spacing.dart';
import '../../../shared/widgets/flowa_buttons.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({required this.onFinished, super.key});

  final VoidCallback onFinished;

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _controller = PageController();
  int _index = 0;

  static const _slides = [
    (
      title: 'Claridad primero',
      body:
          'Ve tu saldo, actividad reciente y próximas acciones de un vistazo.',
      icon: Icons.visibility_outlined,
    ),
    (
      title: 'Enviar no es recargar',
      body:
          'Flujos distintos y confirmaciones te ayudan a evitar errores caros.',
      icon: Icons.verified_user_outlined,
    ),
    (
      title: 'Tú tienes el control',
      body:
          'Subcuentas, contactos, empresas y alertas para organizar tu dinero.',
      icon: Icons.account_tree_outlined,
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await FlowaServices.preferencesRepository.completeOnboarding();
    widget.onFinished();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: FlowaColors.background,
      body: SafeArea(
        child: Padding(
          padding: FlowaSpacing.screenPadding,
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _finish,
                  child: AnimatedOpacity(
                    opacity: _index == _slides.length - 1 ? 0 : 1,
                    duration: FlowaConstants.defaultAnimationDuration,
                    child: const Text('Saltar'),
                  ),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: _slides.length,
                  onPageChanged: (value) {
                    setState(() => _index = value);
                    HapticFeedback.selectionClick();
                  },
                  itemBuilder: (context, index) {
                    final item = _slides[index];
                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 48,
                          backgroundColor: FlowaColors.primarySoft,
                          child: Icon(
                            item.icon,
                            size: 40,
                            color: FlowaColors.primary,
                          ),
                        ),
                        const SizedBox(height: FlowaSpacing.xl),
                        Text(
                          item.title,
                          style: Theme.of(context).textTheme.headlineMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: FlowaSpacing.sm),
                        Text(
                          item.body,
                          style: Theme.of(context).textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    );
                  },
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < _slides.length; i++)
                    AnimatedContainer(
                      duration: FlowaConstants.defaultAnimationDuration,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      width: i == _index ? 18 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: i == _index
                            ? FlowaColors.primary
                            : FlowaColors.border,
                        borderRadius: BorderRadius.circular(FlowaRadii.pill),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: FlowaSpacing.xl),
              FlowaPrimaryButton(
                label: _index == _slides.length - 1
                    ? 'Empezar'
                    : 'Continuar',
                onPressed: () async {
                  if (_index == _slides.length - 1) {
                    await _finish();
                    return;
                  }
                  await _controller.nextPage(
                    duration: FlowaConstants.defaultAnimationDuration,
                    curve: Curves.easeOutCubic,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

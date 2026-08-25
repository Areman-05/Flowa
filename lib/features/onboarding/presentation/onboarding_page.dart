import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/utils/flowa_services.dart';
import '../../../design_system/components/flowa_actions.dart';
import '../../../design_system/components/flowa_icon.dart';
import '../../../design_system/components/flowa_texture.dart';
import '../../../design_system/tokens/flowa_colors.dart';
import '../../../design_system/tokens/flowa_motion_tokens.dart';
import '../../../design_system/tokens/flowa_spacing.dart';
import '../../../design_system/tokens/flowa_typography.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({required this.onFinished, super.key});

  final VoidCallback onFinished;

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _controller = PageController();
  int _index = 0;

  static const _pages = [
    _Slide(
      kicker: '01  Saldo real',
      title: 'Lo que puedes gastar, no lo que pone el banco.',
      body:
          'Flowa aparta impuestos y recibos. En la tarjeta ves solo lo tuyo.',
    ),
    _Slide(
      kicker: '02  Movimientos',
      title: 'Enviar, cobrar y el bote, a un toque.',
      body:
          'Accesos rápidos como en un banco de verdad, pensados para facturas.',
    ),
    _Slide(
      kicker: '03  Control',
      title: 'Gastos, facturas e historial en la misma vista.',
      body:
          'Dos tarjetas de resumen y una lista clara. Nada de menús escondidos.',
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

  Future<void> _next() async {
    if (_index == _pages.length - 1) {
      await _finish();
      return;
    }
    await _controller.nextPage(
      duration: FlowaMotion.slow,
      curve: FlowaMotion.expoOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final last = _index == _pages.length - 1;

    return Scaffold(
      backgroundColor: FlowaColors.ink,
      body: FlowaCanvas(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              FlowaSpacing.gutter,
              FlowaSpacing.md,
              FlowaSpacing.gutter,
              FlowaSpacing.lg,
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      '${_index + 1} / ${_pages.length}',
                      style: FlowaType.micro(color: FlowaColors.boneMuted),
                    ),
                    const Spacer(),
                    if (!last)
                      GestureDetector(
                        onTap: _finish,
                        child: Text(
                          'Saltar',
                          style: FlowaType.micro(color: FlowaColors.mint),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: FlowaSpacing.xl),
                Expanded(
                  child: PageView.builder(
                    controller: _controller,
                    onPageChanged: (value) {
                      setState(() => _index = value);
                      HapticFeedback.selectionClick();
                    },
                    itemCount: _pages.length,
                    itemBuilder: (context, i) => _OnboardVisual(
                      index: i,
                      slide: _pages[i],
                    ),
                  ),
                ),
                const SizedBox(height: FlowaSpacing.lg),
                Row(
                  children: [
                    for (var i = 0; i < _pages.length; i++)
                      Container(
                        width: i == _index ? 22 : 8,
                        height: 8,
                        margin: const EdgeInsets.only(right: 6),
                        decoration: BoxDecoration(
                          color: i == _index
                              ? FlowaColors.mint
                              : FlowaColors.inkHigh,
                          borderRadius: FlowaRadii.pillAll,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: FlowaSpacing.xl),
                FlowaAcidButton(
                  label: last ? 'Empezar' : 'Continuar',
                  onPressed: _next,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Slide {
  const _Slide({
    required this.kicker,
    required this.title,
    required this.body,
  });

  final String kicker;
  final String title;
  final String body;
}

class _OnboardVisual extends StatelessWidget {
  const _OnboardVisual({required this.index, required this.slide});

  final int index;
  final _Slide slide;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              color: FlowaColors.inkHigh,
              borderRadius: FlowaRadii.xlAll,
            ),
            padding: const EdgeInsets.all(FlowaSpacing.lg),
            child: index == 0
                ? const _MiniCard()
                : index == 1
                    ? const _MiniActions()
                    : const _MiniBento(),
          ),
        ),
        const SizedBox(height: FlowaSpacing.xl),
        Text(slide.kicker, style: FlowaType.micro(color: FlowaColors.mint)),
        const SizedBox(height: FlowaSpacing.sm),
        Text(slide.title, style: FlowaType.editorialMd()),
        const SizedBox(height: FlowaSpacing.sm),
        Text(slide.body, style: FlowaType.body()),
      ],
    );
  }
}

class _MiniCard extends StatelessWidget {
  const _MiniCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: FlowaColors.cardFace,
        borderRadius: FlowaRadii.lgAll,
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text('Flowa', style: FlowaType.titleSm(color: FlowaColors.mintInk)),
              const Spacer(),
              const FlowaIcon(FlowaGlyph.card, color: FlowaColors.mintInk),
            ],
          ),
          const Spacer(),
          Text(
            'Disponible de verdad',
            style: FlowaType.micro(color: FlowaColors.mintInk.withValues(alpha: 0.7)),
          ),
          Text('4.733,10 €', style: FlowaType.figureLg(color: FlowaColors.mintInk)),
        ],
      ),
    );
  }
}

class _MiniActions extends StatelessWidget {
  const _MiniActions();

  @override
  Widget build(BuildContext context) {
    const items = [
      (FlowaGlyph.arrowDown, 'Ingresar'),
      (FlowaGlyph.transfer, 'Enviar'),
      (FlowaGlyph.vault, 'Bote'),
      (FlowaGlyph.chart, 'Análisis'),
    ];
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            for (final item in items)
              Column(
                children: [
                  Container(
                    width: 58,
                    height: 58,
                    decoration: const BoxDecoration(
                      color: FlowaColors.ink,
                      shape: BoxShape.circle,
                    ),
                    alignment: Alignment.center,
                    child: FlowaIcon(item.$1, color: FlowaColors.mint),
                  ),
                  const SizedBox(height: 8),
                  Text(item.$2, style: FlowaType.micro()),
                ],
              ),
          ],
        ),
      ],
    );
  }
}

class _MiniBento extends StatelessWidget {
  const _MiniBento();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Row(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: FlowaColors.ink,
                    borderRadius: FlowaRadii.mdAll,
                  ),
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Gastos', style: FlowaType.micro()),
                      const Spacer(),
                      Text('1.679 €', style: FlowaType.figureMd()),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: FlowaColors.ink,
                    borderRadius: FlowaRadii.mdAll,
                  ),
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Pendiente', style: FlowaType.micro()),
                      const Spacer(),
                      const Row(
                        children: [
                          _Dot(FlowaColors.mint),
                          _Dot(FlowaColors.inkPressed),
                          _Dot(FlowaColors.mint),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Dot extends StatelessWidget {
  const _Dot(this.color);

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      margin: const EdgeInsets.only(right: 6),
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

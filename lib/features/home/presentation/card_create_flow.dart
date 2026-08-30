import 'package:flutter/material.dart';

import '../../../core/utils/flowa_haptics.dart';
import '../../../design_system/components/flowa_actions.dart';
import '../../../design_system/components/flowa_card_face.dart';
import '../../../design_system/components/flowa_screen.dart';
import '../../../design_system/components/flowa_visa_card.dart';
import '../../../design_system/tokens/flowa_colors.dart';
import '../../../design_system/tokens/flowa_spacing.dart';
import '../../../design_system/tokens/flowa_typography.dart';
import '../../../domain/entities/finance_entities.dart';
import 'card_profile.dart';

/// Multi-step “pedir tarjeta” flow: tipo → color → patrón → confirmar.
Future<CardProfile?> showCreateCardFlow(BuildContext context) {
  return Navigator.of(context).push<CardProfile>(
    MaterialPageRoute(builder: (_) => const _CreateCardPage()),
  );
}

class _CreateCardPage extends StatefulWidget {
  const _CreateCardPage();

  @override
  State<_CreateCardPage> createState() => _CreateCardPageState();
}

class _CreateCardPageState extends State<_CreateCardPage> {
  int _step = 0;
  final _name = TextEditingController(text: 'Tarjeta personal');
  String _kind = 'débito';
  FlowaCardTint _tint = FlowaCardTint.turquoise;
  FlowaCardPattern _pattern = FlowaCardPattern.none;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  CardProfile _buildProfile() {
    final stamp = DateTime.now().millisecondsSinceEpoch;
    final last = (8800 + (stamp % 999)).toString().padLeft(4, '0');
    return CardProfile.fromAccount(
      account: Account(
        id: 'extra-$stamp',
        displayName: _name.text.trim().isEmpty
            ? 'Tarjeta nueva'
            : _name.text.trim(),
        maskedNumber: '**** **** **** $last',
        availableBalance: 0,
        expiryLabel: '12/29',
        brand: 'VISA',
      ),
      style: _tint,
      pattern: _pattern,
      caption: _kind == 'crédito' ? 'Límite disponible' : 'Saldo disponible',
      amount: 0,
    );
  }

  Future<void> _next() async {
    if (_step < 3) {
      await FlowaHaptics.selection();
      setState(() => _step += 1);
      return;
    }
    await FlowaHaptics.success();
    if (!mounted) {
      return;
    }
    Navigator.of(context).pop(_buildProfile());
  }

  void _back() {
    if (_step == 0) {
      Navigator.of(context).pop();
      return;
    }
    setState(() => _step -= 1);
  }

  @override
  Widget build(BuildContext context) {
    final titles = ['Tipo', 'Color', 'Patrón', 'Confirmar'];
    final profile = _buildProfile();

    return FlowaScreen(
      title: titles[_step],
      onBack: _back,
      footer: FlowaAcidButton(
        label: _step == 3 ? 'Añadir a cartera' : 'Continuar',
        onPressed: _next,
      ),
      child: ListView(
        children: [
          _StepDots(step: _step, total: 4),
          const SizedBox(height: FlowaSpacing.xl),
          if (_step == 0) ...[
            Text('¿Qué tarjeta quieres?', style: FlowaType.titleSm()),
            const SizedBox(height: FlowaSpacing.sm),
            TextField(
              controller: _name,
              style: FlowaType.body(),
              decoration: InputDecoration(
                hintText: 'Nombre de la tarjeta',
                filled: true,
                fillColor: FlowaColors.inkHigh,
                border: OutlineInputBorder(
                  borderRadius: FlowaRadii.lgAll,
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            const SizedBox(height: FlowaSpacing.md),
            Row(
              children: [
                Expanded(
                  child: _KindChip(
                    label: 'Débito',
                    selected: _kind == 'débito',
                    onTap: () => setState(() => _kind = 'débito'),
                  ),
                ),
                const SizedBox(width: FlowaSpacing.sm),
                Expanded(
                  child: _KindChip(
                    label: 'Crédito',
                    selected: _kind == 'crédito',
                    onTap: () => setState(() => _kind = 'crédito'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: FlowaSpacing.sm),
            Text(
              'Como en BBVA o Santander: primero decides el tipo y el nombre.',
              style: FlowaType.bodySm(),
            ),
          ] else if (_step == 1) ...[
            Text('Elige un color', style: FlowaType.titleSm()),
            const SizedBox(height: FlowaSpacing.md),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                for (final tint in FlowaCardTint.values)
                  _ColorSwatch(
                    tint: tint,
                    selected: _tint == tint,
                    onTap: () => setState(() => _tint = tint),
                  ),
              ],
            ),
          ] else if (_step == 2) ...[
            Text('Patrón artístico', style: FlowaType.titleSm()),
            const SizedBox(height: 4),
            Text(
              'Opcional — estilo Revolut: geométrico o liso.',
              style: FlowaType.bodySm(),
            ),
            const SizedBox(height: FlowaSpacing.md),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final pattern in FlowaCardPattern.values)
                  _PatternChip(
                    pattern: pattern,
                    tint: _tint,
                    selected: _pattern == pattern,
                    onTap: () => setState(() => _pattern = pattern),
                  ),
              ],
            ),
          ] else ...[
            Text('Así quedará', style: FlowaType.titleSm()),
            const SizedBox(height: FlowaSpacing.md),
            FlowaVisaCard(
              account: profile.account,
              style: profile.style,
              pattern: profile.pattern,
              caption: profile.caption,
              amount: 0,
            ),
            const SizedBox(height: FlowaSpacing.md),
            Text(
              '${profile.account.displayName} · ${_kind[0].toUpperCase()}${_kind.substring(1)} · ${_tint.label} · ${_pattern.label}',
              style: FlowaType.bodySm(),
            ),
          ],
          if (_step < 3) ...[
            const SizedBox(height: FlowaSpacing.xxl),
            IgnorePointer(
              child: Opacity(
                opacity: 0.9,
                child: FlowaVisaCard(
                  account: profile.account,
                  style: profile.style,
                  pattern: profile.pattern,
                  caption: profile.caption,
                  amount: 0,
                  height: 168,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StepDots extends StatelessWidget {
  const _StepDots({required this.step, required this.total});

  final int step;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < total; i++) ...[
          if (i > 0) const SizedBox(width: 6),
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              height: 3,
              decoration: BoxDecoration(
                color: i <= step ? FlowaColors.mint : FlowaColors.inkHigh,
                borderRadius: BorderRadius.circular(99),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _KindChip extends StatelessWidget {
  const _KindChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FlowaPressScale(
      onTap: onTap,
      child: Container(
        height: 52,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? FlowaColors.mint : FlowaColors.inkHigh,
          borderRadius: FlowaRadii.lgAll,
        ),
        child: Text(
          label,
          style: FlowaType.label(
            color: selected ? FlowaColors.mintInk : FlowaColors.bone,
          ),
        ),
      ),
    );
  }
}

class _ColorSwatch extends StatelessWidget {
  const _ColorSwatch({
    required this.tint,
    required this.selected,
    required this.onTap,
  });

  final FlowaCardTint tint;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FlowaPressScale(
      onTap: onTap,
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: tint.fill,
              shape: BoxShape.circle,
              border: Border.all(
                color: selected ? FlowaColors.mint : FlowaColors.hairlineStrong,
                width: selected ? 2.5 : 1,
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(tint.label, style: FlowaType.micro()),
        ],
      ),
    );
  }
}

class _PatternChip extends StatelessWidget {
  const _PatternChip({
    required this.pattern,
    required this.tint,
    required this.selected,
    required this.onTap,
  });

  final FlowaCardPattern pattern;
  final FlowaCardTint tint;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FlowaPressScale(
      onTap: onTap,
      child: Container(
        width: 96,
        height: 72,
        decoration: BoxDecoration(
          color: tint.fill,
          borderRadius: FlowaRadii.mdAll,
          border: Border.all(
            color: selected ? FlowaColors.mint : FlowaColors.hairlineStrong,
            width: selected ? 2 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (pattern != FlowaCardPattern.none)
              CustomPaint(
                painter: FlowaCardPatternPainter(
                  pattern: pattern,
                  ink: tint.foreground.withValues(alpha: 0.22),
                ),
              ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                width: double.infinity,
                color: Colors.black.withValues(alpha: 0.35),
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  pattern.label,
                  textAlign: TextAlign.center,
                  style: FlowaType.micro(color: FlowaColors.bone),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

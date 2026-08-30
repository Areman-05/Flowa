import 'package:flutter/material.dart';

import '../../../core/utils/flowa_formatters.dart';
import '../../../core/utils/flowa_haptics.dart';
import '../../../design_system/components/flowa_actions.dart';
import '../../../design_system/components/flowa_icon.dart';
import '../../../design_system/components/flowa_screen.dart';
import '../../../design_system/tokens/flowa_colors.dart';
import '../../../design_system/tokens/flowa_spacing.dart';
import '../../../design_system/tokens/flowa_typography.dart';
import 'card_profile.dart';

class CardLimitsPage extends StatefulWidget {
  const CardLimitsPage({required this.profile, super.key});

  final CardProfile profile;

  @override
  State<CardLimitsPage> createState() => _CardLimitsPageState();
}

class _CardLimitsPageState extends State<CardLimitsPage> {
  late double _daily = widget.profile.dailyLimit;
  late double _monthly = widget.profile.monthlyLimit;
  late bool _online = widget.profile.onlineEnabled;
  late bool _contactless = widget.profile.contactlessEnabled;

  Future<void> _save() async {
    await FlowaHaptics.success();
    if (!mounted) {
      return;
    }
    Navigator.of(context).pop(
      widget.profile.copyWith(
        dailyLimit: _daily,
        monthlyLimit: _monthly,
        onlineEnabled: _online,
        contactlessEnabled: _contactless,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FlowaScreen(
      title: 'Límites',
      footer: FlowaAcidButton(label: 'Guardar límites', onPressed: _save),
      child: ListView(
        children: [
          Container(
            padding: const EdgeInsets.all(FlowaSpacing.lg),
            decoration: const BoxDecoration(
              color: FlowaColors.inkHigh,
              borderRadius: FlowaRadii.xxlAll,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.profile.account.displayName,
                        style: FlowaType.titleSm(),
                      ),
                    ),
                    const FlowaIcon(FlowaGlyph.card, size: 18),
                  ],
                ),
                const SizedBox(height: FlowaSpacing.md),
                Text(
                  FlowaFormatters.currency(_daily),
                  style: FlowaType.figureMd(),
                ),
                const SizedBox(height: 4),
                Text(
                  'Límite diario · •••• ${widget.profile.account.lastFour}',
                  style: FlowaType.bodySm(),
                ),
              ],
            ),
          ),
          const SizedBox(height: FlowaSpacing.xl),
          Text('Tus límites', style: FlowaType.titleSm()),
          const SizedBox(height: FlowaSpacing.sm),
          _LimitCard(
            title: 'Diario',
            value: _daily,
            min: 100,
            max: 5000,
            onChanged: (v) => setState(() => _daily = v),
          ),
          const SizedBox(height: FlowaSpacing.sm),
          _LimitCard(
            title: 'Mensual',
            value: _monthly,
            min: 500,
            max: 20000,
            onChanged: (v) => setState(() => _monthly = v),
          ),
          const SizedBox(height: FlowaSpacing.xl),
          Text('Canales', style: FlowaType.titleSm()),
          const SizedBox(height: FlowaSpacing.sm),
          _ToggleCard(
            title: 'Compras online',
            subtitle: 'Pagos en internet y apps',
            value: _online,
            onChanged: (v) => setState(() => _online = v),
          ),
          const SizedBox(height: FlowaSpacing.sm),
          _ToggleCard(
            title: 'Contactless',
            subtitle: 'Pagos sin contacto',
            value: _contactless,
            onChanged: (v) => setState(() => _contactless = v),
          ),
        ],
      ),
    );
  }
}

class _LimitCard extends StatelessWidget {
  const _LimitCard({
    required this.title,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
  });

  final String title;
  final double value;
  final double min;
  final double max;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      decoration: const BoxDecoration(
        color: FlowaColors.inkHigh,
        borderRadius: FlowaRadii.xlAll,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(title, style: FlowaType.titleSm()),
              const Spacer(),
              Text(
                FlowaFormatters.currency(value),
                style: FlowaType.titleMd(),
              ),
            ],
          ),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
            ),
            child: Slider(
              value: value.clamp(min, max),
              min: min,
              max: max,
              divisions: ((max - min) / 50).round(),
              activeColor: FlowaColors.mint,
              inactiveColor: FlowaColors.inkPressed,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

class _ToggleCard extends StatelessWidget {
  const _ToggleCard({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: FlowaColors.inkHigh,
      borderRadius: FlowaRadii.xlAll,
      clipBehavior: Clip.antiAlias,
      child: SwitchListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        title: Text(title, style: FlowaType.titleSm()),
        subtitle: Text(subtitle, style: FlowaType.bodySm()),
        value: value,
        activeThumbColor: FlowaColors.mintInk,
        activeTrackColor: FlowaColors.mint,
        onChanged: onChanged,
      ),
    );
  }
}

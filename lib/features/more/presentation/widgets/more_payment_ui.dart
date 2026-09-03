import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/utils/flowa_formatters.dart';
import '../../../../design_system/components/flowa_actions.dart';
import '../../../../design_system/components/flowa_amount_chips.dart';
import '../../../../design_system/components/flowa_visa_card.dart';
import '../../../../design_system/tokens/flowa_colors.dart';
import '../../../../design_system/tokens/flowa_spacing.dart';
import '../../../../design_system/tokens/flowa_typography.dart';
import '../../../home/presentation/card_profile.dart';
import '../../domain/more_service_catalog.dart';
import '../more_payment_helper.dart';

/// Subtle neon glow for selected / hero accent states.
List<BoxShadow> moreNeonGlow(Color accent, {double intensity = 0.14}) => [
      BoxShadow(
        color: accent.withValues(alpha: intensity),
        blurRadius: 20,
        spreadRadius: -4,
      ),
      BoxShadow(
        color: accent.withValues(alpha: intensity * 0.5),
        blurRadius: 40,
        spreadRadius: -8,
        offset: const Offset(0, 6),
      ),
    ];

/// Card panel — fintech dashboard grouping surface.
class MoreFintechCard extends StatelessWidget {
  const MoreFintechCard({
    required this.child,
    super.key,
    this.accent,
    this.padding = const EdgeInsets.all(18),
  });

  final Widget child;
  final Color? accent;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final glow = accent;
    return Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: FlowaColors.inkHigh,
        borderRadius: FlowaRadii.xxlAll,
        border: Border.all(
          color: glow != null
              ? glow.withValues(alpha: 0.20)
              : FlowaColors.hairlineStrong,
        ),
      ),
      child: child,
    );
  }
}

/// Pill chip with optional neon accent when selected.
class MoreNeonPill extends StatelessWidget {
  const MoreNeonPill({
    required this.label,
    required this.selected,
    required this.onTap,
    super.key,
    this.accent = FlowaColors.mint,
    this.leading,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color accent;
  final Widget? leading;

  @override
  Widget build(BuildContext context) {
    return FlowaPressScale(
      onTap: onTap,
      scale: 0.96,
      haptic: false,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? accent.withValues(alpha: 0.14) : FlowaColors.inkHigh,
          borderRadius: FlowaRadii.pillAll,
          border: Border.all(
            color: selected ? accent : FlowaColors.hairlineStrong,
          ),
          boxShadow: selected ? moreNeonGlow(accent, intensity: 0.12) : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (leading != null) ...[leading!, const SizedBox(width: 8)],
            Text(
              label,
              style: FlowaType.titleSm(
                color: selected ? accent : FlowaColors.boneMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Accent + copy per bill service so each payment flow feels distinct.
({Color accent, IconData icon, List<String> hints}) billPayTheme(
  MoreBillService service,
) {
  return switch (service.title) {
    'Móvil' => (
        accent: const Color(0xFF00A9E0),
        icon: Icons.smartphone_rounded,
        hints: const ['Recarga al instante', 'Sin permanencia'],
      ),
    'Suministros' => (
        accent: const Color(0xFFE87722),
        icon: Icons.bolt_rounded,
        hints: const ['Luz, gas y agua', 'Pago seguro'],
      ),
    'Internet' => (
        accent: const Color(0xFF6B7FD7),
        icon: Icons.wifi_rounded,
        hints: const ['Fibra y móvil', 'Factura unificada'],
      ),
    'TV' => (
        accent: const Color(0xFF9A7EC8),
        icon: Icons.tv_rounded,
        hints: const ['Streaming y paquetes', 'Renovación mensual'],
      ),
    _ => (
        accent: FlowaColors.mint,
        icon: Icons.receipt_long_rounded,
        hints: const ['Pago rápido', 'Sin comisión'],
      ),
  };
}

/// Compact hero banner for payment flows — accent strip + icon + copy.
class MorePaymentHero extends StatelessWidget {
  const MorePaymentHero({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accent,
    super.key,
    this.badges = const [],
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Color accent;
  final List<String> badges;

  @override
  Widget build(BuildContext context) {
    return MoreFintechCard(
      accent: accent,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.14),
                  borderRadius: FlowaRadii.lgAll,
                  boxShadow: moreNeonGlow(accent, intensity: 0.18),
                ),
                alignment: Alignment.center,
                child: Icon(icon, size: 24, color: accent),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: FlowaType.titleMd()),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: FlowaType.bodySm(color: FlowaColors.boneMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (badges.isNotEmpty) ...[
            const SizedBox(height: 14),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final badge in badges)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: accent.withValues(alpha: 0.10),
                      borderRadius: FlowaRadii.pillAll,
                      border: Border.all(color: accent.withValues(alpha: 0.22)),
                    ),
                    child: Text(
                      badge,
                      style: FlowaType.micro(color: accent),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Numbered section wrapper for multi-step payment forms.
class MoreFormStep extends StatelessWidget {
  const MoreFormStep({
    required this.step,
    required this.title,
    required this.child,
    super.key,
    this.subtitle,
  });

  final int step;
  final String title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 10),
          child: Row(
            children: [
              Container(
                width: 22,
                height: 22,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: FlowaColors.mint.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                  boxShadow: moreNeonGlow(FlowaColors.mint, intensity: 0.08),
                ),
                child: Text(
                  '$step',
                  style: FlowaType.micro(color: FlowaColors.mint),
                ),
              ),
              const SizedBox(width: 10),
              Text(title, style: FlowaType.titleSm()),
              if (subtitle != null) ...[
                const SizedBox(width: 8),
                Text(
                  subtitle!,
                  style: FlowaType.bodySm(color: FlowaColors.boneFaint),
                ),
              ],
            ],
          ),
        ),
        MoreFintechCard(child: child),
      ],
    );
  }
}

/// Horizontal provider picker with brand colour strip.
class MoreProviderRail extends StatelessWidget {
  const MoreProviderRail({
    required this.providers,
    required this.selectedId,
    required this.onSelected,
    super.key,
  });

  final List<MoreProvider> providers;
  final String? selectedId;
  final ValueChanged<MoreProvider> onSelected;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final provider in providers)
          FlowaPressScale(
            onTap: () => onSelected(provider),
            child: Builder(
              builder: (context) {
                final selected = provider.id == selectedId;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  padding: const EdgeInsets.fromLTRB(6, 6, 14, 6),
                  decoration: BoxDecoration(
                    color: selected
                        ? provider.tone.withValues(alpha: 0.12)
                        : FlowaColors.inkSurface,
                    borderRadius: FlowaRadii.pillAll,
                    border: Border.all(
                      color: selected
                          ? provider.tone
                          : FlowaColors.hairlineStrong,
                    ),
                    boxShadow: selected
                        ? moreNeonGlow(provider.tone, intensity: 0.14)
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: provider.tone.withValues(alpha: 0.18),
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          providerInitial(provider),
                          style: FlowaType.micro(color: provider.tone),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        provider.name,
                        style: FlowaType.titleSm(
                          color: selected
                              ? FlowaColors.bone
                              : FlowaColors.boneMuted,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
      ],
    );
  }
}

/// Muted one-liner under the screen title — no hero card needed.
class MoreContextLine extends StatelessWidget {
  const MoreContextLine(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: FlowaType.body(color: FlowaColors.boneMuted),
    );
  }
}

/// Section label used inside varied layouts.
class MoreFieldLabel extends StatelessWidget {
  const MoreFieldLabel(this.text, {super.key, this.subtitle});

  final String text;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Text(text, style: FlowaType.titleSm()),
          if (subtitle != null) ...[
            const SizedBox(width: 8),
            Text(subtitle!, style: FlowaType.bodySm(color: FlowaColors.boneFaint)),
          ],
        ],
      ),
    );
  }
}

/// 2-column provider grid — used by Suministros / Internet.
class MoreProviderGrid extends StatelessWidget {
  const MoreProviderGrid({
    required this.providers,
    required this.selectedId,
    required this.onSelected,
    super.key,
  });

  final List<MoreProvider> providers;
  final String? selectedId;
  final ValueChanged<MoreProvider> onSelected;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        childAspectRatio: 2.4,
      ),
      itemCount: providers.length,
      itemBuilder: (context, index) {
        final provider = providers[index];
        final selected = provider.id == selectedId;
        return FlowaPressScale(
          onTap: () => onSelected(provider),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: selected
                  ? provider.tone.withValues(alpha: 0.12)
                  : FlowaColors.inkHigh,
              borderRadius: FlowaRadii.lgAll,
              border: Border.all(
                color: selected ? provider.tone : FlowaColors.hairlineStrong,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: provider.tone.withValues(alpha: 0.16),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    providerInitial(provider),
                    style: FlowaType.micro(color: provider.tone),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    provider.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: FlowaType.titleSm(
                      color: selected ? FlowaColors.bone : FlowaColors.boneMuted,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Vertical radio-style provider list — used by TV / Internet.
class MoreProviderList extends StatelessWidget {
  const MoreProviderList({
    required this.providers,
    required this.selectedId,
    required this.onSelected,
    super.key,
    this.subtitleFor,
  });

  final List<MoreProvider> providers;
  final String? selectedId;
  final ValueChanged<MoreProvider> onSelected;
  final String Function(MoreProvider provider)? subtitleFor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < providers.length; i++) ...[
          FlowaPressScale(
            onTap: () => onSelected(providers[i]),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: providers[i].id == selectedId
                    ? providers[i].tone.withValues(alpha: 0.10)
                    : FlowaColors.inkHigh,
                borderRadius: FlowaRadii.lgAll,
                border: Border.all(
                  color: providers[i].id == selectedId
                      ? providers[i].tone
                      : FlowaColors.hairlineStrong,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: providers[i].tone.withValues(alpha: 0.16),
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      providerInitial(providers[i]),
                      style: FlowaType.titleSm(color: providers[i].tone),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(providers[i].name, style: FlowaType.titleSm()),
                        if (subtitleFor != null) ...[
                          const SizedBox(height: 2),
                          Text(
                            subtitleFor!(providers[i]),
                            style: FlowaType.bodySm(color: FlowaColors.boneMuted),
                          ),
                        ],
                      ],
                    ),
                  ),
                  if (providers[i].id == selectedId)
                    Icon(Icons.check_circle_rounded, size: 20, color: providers[i].tone),
                ],
              ),
            ),
          ),
          if (i < providers.length - 1) const SizedBox(height: 8),
        ],
      ],
    );
  }
}

/// Large utility type cards — Luz / Gas / Agua for Suministros.
class MoreUtilityTypePicker extends StatelessWidget {
  const MoreUtilityTypePicker({
    required this.selected,
    required this.onSelected,
    required this.accent,
    super.key,
  });

  final String? selected;
  final ValueChanged<String> onSelected;
  final Color accent;

  static const _types = [
    (label: 'Luz', icon: Icons.bolt_rounded),
    (label: 'Gas', icon: Icons.local_fire_department_outlined),
    (label: 'Agua', icon: Icons.water_drop_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (var i = 0; i < _types.length; i++) ...[
          if (i > 0) const SizedBox(width: 10),
          Expanded(
            child: FlowaPressScale(
              onTap: () => onSelected(_types[i].label),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  color: selected == _types[i].label
                      ? accent.withValues(alpha: 0.12)
                      : FlowaColors.inkHigh,
                  borderRadius: FlowaRadii.xlAll,
                  border: Border.all(
                    color: selected == _types[i].label
                        ? accent
                        : FlowaColors.hairlineStrong,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      _types[i].icon,
                      size: 26,
                      color: selected == _types[i].label ? accent : FlowaColors.boneMuted,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _types[i].label,
                      style: FlowaType.titleSm(
                        color: selected == _types[i].label
                            ? accent
                            : FlowaColors.boneMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Amount field + chips inside a panel.
class MoreAmountPanel extends StatelessWidget {
  const MoreAmountPanel({
    required this.controller,
    required this.chips,
    required this.selectedChip,
    required this.onChipSelected,
    super.key,
    this.label = 'Importe',
    this.prefix = '€ ',
  });

  final TextEditingController controller;
  final List<double> chips;
  final double? selectedChip;
  final ValueChanged<double> onChipSelected;
  final String label;
  final String prefix;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          style: FlowaType.figureLg(color: FlowaColors.mint),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
          ],
          decoration: InputDecoration(
            labelText: label,
            labelStyle: FlowaType.bodySm(color: FlowaColors.boneMuted),
            floatingLabelStyle: FlowaType.titleSm(color: FlowaColors.mint),
            prefixText: prefix,
            prefixStyle: FlowaType.figureLg(color: FlowaColors.mint),
            filled: true,
            fillColor: FlowaColors.inkSurface,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 20,
            ),
            border: OutlineInputBorder(
              borderRadius: FlowaRadii.xlAll,
              borderSide: const BorderSide(color: FlowaColors.hairlineStrong),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: FlowaRadii.xlAll,
              borderSide: const BorderSide(color: FlowaColors.hairlineStrong),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: FlowaRadii.xlAll,
              borderSide: const BorderSide(color: FlowaColors.mint),
            ),
          ),
        ),
        const SizedBox(height: FlowaSpacing.sm),
        FlowaAmountChips(
          values: chips,
          selected: selectedChip,
          onSelected: onChipSelected,
        ),
      ],
    );
  }
}

/// Horizontal filter pills shared by catalog screens.
class MoreFilterRail extends StatelessWidget {
  const MoreFilterRail({
    required this.options,
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final List<String> options;
  final String selected;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: options.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final label = options[index];
          return MoreNeonPill(
            label: label,
            selected: label == selected,
            onTap: () => onSelected(label),
          );
        },
      ),
    );
  }
}

/// Static pay-from card. Tap opens the picker — no carousel.
class MorePayFromCard extends StatelessWidget {
  const MorePayFromCard({
    required this.card,
    required this.onTap,
    super.key,
    this.remaining,
  });

  final CardProfile card;
  final VoidCallback onTap;
  final double? remaining;

  @override
  Widget build(BuildContext context) {
    return FlowaPressScale(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Pagar con', style: FlowaType.titleMd()),
          const SizedBox(height: 12),
          FlowaVisaCard(
            account: card.account,
            style: card.style,
            pattern: card.pattern,
            caption: card.caption,
            amount: card.account.availableBalance,
            height: 188,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: remaining == null
                    ? Text(
                        'Toca la tarjeta para cambiar',
                        style: FlowaType.body(color: FlowaColors.boneMuted),
                      )
                    : Text(
                        'Después: ${FlowaFormatters.currency(remaining!)}',
                        style: FlowaType.titleSm(
                          color: remaining! < 0
                              ? FlowaColors.danger
                              : FlowaColors.boneMuted,
                        ),
                      ),
              ),
              Text(
                'Cambiar',
                style: FlowaType.titleMd(color: FlowaColors.mint),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

Future<CardProfile?> showMoreCardPicker({
  required BuildContext context,
  required List<CardProfile> cards,
  required CardProfile? selected,
}) {
  return showModalBottomSheet<CardProfile>(
    context: context,
    isScrollControlled: true,
    backgroundColor: FlowaColors.inkPressed,
    showDragHandle: true,
    builder: (context) {
      return DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.72,
        minChildSize: 0.45,
        maxChildSize: 0.94,
        builder: (context, scrollController) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Pagar con', style: FlowaType.titleMd()),
                const SizedBox(height: 4),
                Text(
                  'Elige una tarjeta de tu cartera',
                  style: FlowaType.bodySm(color: FlowaColors.boneMuted),
                ),
                const SizedBox(height: FlowaSpacing.md),
                Expanded(
                  child: ListView.separated(
                    controller: scrollController,
                    itemCount: cards.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: FlowaSpacing.md),
                    itemBuilder: (context, index) {
                      final card = cards[index];
                      final isSelected =
                          selected?.account.id == card.account.id;
                      return FlowaPressScale(
                        onTap: () => Navigator.pop(context, card),
                        child: Stack(
                          children: [
                            FlowaVisaCard(
                              account: card.account,
                              style: card.style,
                              pattern: card.pattern,
                              caption: card.caption,
                              amount: card.account.availableBalance,
                              height: 168,
                            ),
                            if (isSelected)
                              const Positioned(
                                top: 12,
                                right: 12,
                                child: Icon(
                                  Icons.check_circle_rounded,
                                  color: FlowaColors.mint,
                                  size: 28,
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}

/// Ticket-style receipt block for payment review.
class MorePaymentReceipt extends StatelessWidget {
  const MorePaymentReceipt({
    required this.rows,
    required this.total,
    super.key,
    this.footerLines = const [],
  });

  final List<({String label, String value})> rows;
  final String total;
  final List<String> footerLines;

  @override
  Widget build(BuildContext context) {
    return MoreFintechCard(
      child: Column(
        children: [
          for (final row in rows) ...[
            Row(
              children: [
                Text(
                  row.label,
                  style: FlowaType.bodySm(color: FlowaColors.boneMuted),
                ),
                const Spacer(),
                Text(row.value, style: FlowaType.body()),
              ],
            ),
            const SizedBox(height: 10),
          ],
          Divider(color: FlowaColors.hairlineStrong.withValues(alpha: 0.8)),
          const SizedBox(height: 10),
          Row(
            children: [
              Text('Total', style: FlowaType.titleSm()),
              const Spacer(),
              Text(
                total,
                style: FlowaType.titleMd(color: FlowaColors.mint),
              ),
            ],
          ),
          if (footerLines.isNotEmpty) ...[
            const SizedBox(height: 12),
            for (final line in footerLines)
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    line,
                    style: FlowaType.bodySm(color: FlowaColors.boneFaint),
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}

/// Live conversion panel for exchange flow.
class MoreExchangeCalculator extends StatelessWidget {
  const MoreExchangeCalculator({
    required this.fromCode,
    required this.toCode,
    required this.fromSymbol,
    required this.toSymbol,
    required this.converted,
    super.key,
  });

  final String fromCode;
  final String toCode;
  final String fromSymbol;
  final String toSymbol;
  final double converted;

  @override
  Widget build(BuildContext context) {
    return MoreFintechCard(
      accent: const Color(0xFF6890B8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recibirás aprox.',
                  style: FlowaType.bodySm(color: FlowaColors.boneMuted),
                ),
                const SizedBox(height: 4),
                Text(
                  '$toSymbol${converted.toStringAsFixed(2)}',
                  style: FlowaType.figureMd(color: FlowaColors.mint),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: FlowaColors.mint.withValues(alpha: 0.10),
              borderRadius: FlowaRadii.pillAll,
            ),
            child: Text(
              '$fromCode → $toCode',
              style: FlowaType.micro(color: FlowaColors.mint),
            ),
          ),
        ],
      ),
    );
  }
}

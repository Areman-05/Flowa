import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/utils/flowa_formatters.dart';
import '../../../core/utils/flowa_haptics.dart';
import '../../../design_system/components/flowa_actions.dart';
import '../../../design_system/components/flowa_card_face.dart';
import '../../../design_system/components/flowa_glass.dart';
import '../../../design_system/components/flowa_icon.dart';
import '../../../design_system/components/flowa_screen.dart';
import '../../../design_system/tokens/flowa_colors.dart';
import '../../../design_system/tokens/flowa_spacing.dart';
import '../../../design_system/tokens/flowa_typography.dart';
import '../../../shared/navigation/flowa_routes.dart';
import 'card_limits_page.dart';
import 'card_pin_page.dart';
import 'card_profile.dart';
import 'card_wallet_store.dart';

Future<void> showCardDetailsSheet(
  BuildContext context,
  CardProfile profile,
) {
  return pushFlowaRoute<void>(
    context,
    CardDetailsPage(profile: profile),
  );
}

/// Privat-style card details: visual card, quick actions, information panel.
class CardDetailsPage extends StatefulWidget {
  const CardDetailsPage({required this.profile, super.key});

  final CardProfile profile;

  @override
  State<CardDetailsPage> createState() => _CardDetailsPageState();
}

class _CardDetailsPageState extends State<CardDetailsPage> {
  late CardProfile _profile = widget.profile;
  bool _locked = false;
  bool _cvvVisible = false;

  Future<void> _copyNumber() async {
    await Clipboard.setData(ClipboardData(text: _profile.pan));
    await FlowaHaptics.selection();
    if (!mounted) {
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Número copiado.')),
    );
  }

  void _toast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _openLimits() async {
    final updated = await pushFlowaRoute<CardProfile>(
      context,
      CardLimitsPage(profile: _profile),
    );
    if (updated != null && mounted) {
      setState(() => _profile = updated);
      CardWalletStore.instance.update(updated);
      _toast('Límites actualizados.');
    }
  }

  Future<void> _openPin() async {
    final updated = await pushFlowaRoute<CardProfile>(
      context,
      CardPinPage(profile: _profile),
    );
    if (updated != null && mounted) {
      setState(() => _profile = updated);
      CardWalletStore.instance.update(updated);
    }
  }

  Future<void> _openMore() async {
    await showFlowaGlassSheet<void>(
      context: context,
      builder: (sheetContext) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: FlowaSpacing.md),
                decoration: BoxDecoration(
                  color: FlowaColors.border,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),
            ),
            Text('Más opciones', style: FlowaType.titleMd()),
            const SizedBox(height: FlowaSpacing.sm),
            FlowaMenuRow(
              glyph: FlowaGlyph.card,
              title: 'Copiar número',
              onTap: () async {
                Navigator.pop(sheetContext);
                await _copyNumber();
              },
            ),
            FlowaMenuRow(
              glyph: FlowaGlyph.eye,
              title: _cvvVisible ? 'Ocultar CVV' : 'Mostrar CVV',
              onTap: () {
                Navigator.pop(sheetContext);
                setState(() => _cvvVisible = !_cvvVisible);
              },
            ),
            FlowaMenuRow(
              glyph: FlowaGlyph.lock,
              title: _locked ? 'Desbloquear tarjeta' : 'Bloquear tarjeta',
              onTap: () {
                Navigator.pop(sheetContext);
                setState(() => _locked = !_locked);
                FlowaHaptics.selection();
                _toast(
                  _locked ? 'Tarjeta bloqueada.' : 'Tarjeta desbloqueada.',
                );
              },
            ),
            FlowaMenuRow(
              glyph: FlowaGlyph.receipt,
              title: 'Pedir reposición',
              onTap: () {
                Navigator.pop(sheetContext);
                _toast('Solicitud de reposición enviada.');
              },
            ),
            FlowaMenuRow(
              glyph: FlowaGlyph.bell,
              title: 'Denunciar pérdida',
              onTap: () {
                Navigator.pop(sheetContext);
                setState(() => _locked = true);
                _toast('Tarjeta bloqueada y denuncia registrada.');
              },
            ),
            const SizedBox(height: FlowaSpacing.sm),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final account = _profile.account;
    return FlowaScreen(
      title: account.displayName,
      padding: const EdgeInsets.fromLTRB(
        FlowaSpacing.gutter,
        0,
        FlowaSpacing.gutter,
        FlowaSpacing.lg,
      ),
      child: ListView(
        children: [
          _DetailCardFace(
            profile: _profile,
            locked: _locked,
          ),
          const SizedBox(height: FlowaSpacing.sm),
          Text(
            _profile.caption,
            style: FlowaType.bodySm(),
          ),
          Text(
            FlowaFormatters.currency(account.availableBalance),
            style: FlowaType.figureMd(),
          ),
          const SizedBox(height: FlowaSpacing.xl),
          Row(
            children: [
              _QuickAction(
                glyph: FlowaGlyph.lock,
                label: _locked ? 'Desbloquear' : 'Bloquear',
                onTap: () {
                  setState(() => _locked = !_locked);
                  FlowaHaptics.selection();
                  _toast(
                    _locked ? 'Tarjeta bloqueada.' : 'Tarjeta desbloqueada.',
                  );
                },
              ),
              _QuickAction(
                glyph: FlowaGlyph.clock,
                label: 'Límites',
                onTap: _openLimits,
              ),
              _QuickAction(
                glyph: FlowaGlyph.pin,
                label: 'PIN',
                mark: '∗∗∗',
                onTap: _openPin,
              ),
              _QuickAction(
                glyph: FlowaGlyph.more,
                label: 'Más',
                onTap: _openMore,
              ),
            ],
          ),
          const SizedBox(height: FlowaSpacing.xl),
          Container(
            padding: const EdgeInsets.fromLTRB(18, 18, 18, 8),
            decoration: const BoxDecoration(
              color: FlowaColors.inkHigh,
              borderRadius: FlowaRadii.xxlAll,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Información de la tarjeta', style: FlowaType.titleSm()),
                const SizedBox(height: FlowaSpacing.md),
                _InfoRow(
                  glyph: FlowaGlyph.card,
                  label: 'Número',
                  value: _profile.formattedPan,
                  onTap: _copyNumber,
                ),
                _InfoRow(
                  glyph: FlowaGlyph.clock,
                  label: 'Caducidad',
                  value: account.expiryLabel,
                ),
                _InfoRow(
                  glyph: FlowaGlyph.lock,
                  label: 'CVV',
                  value: _cvvVisible ? _profile.cvv : '•••',
                  onTap: () => setState(() => _cvvVisible = !_cvvVisible),
                ),
                _InfoRow(
                  glyph: FlowaGlyph.chart,
                  label: 'Límite diario',
                  value: FlowaFormatters.compact(_profile.dailyLimit),
                  onTap: _openLimits,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailCardFace extends StatelessWidget {
  const _DetailCardFace({
    required this.profile,
    required this.locked,
  });

  final CardProfile profile;
  final bool locked;

  @override
  Widget build(BuildContext context) {
    final account = profile.account;
    final tint = profile.style;
    final foreground = tint.foreground;
    final sheen = tint.sheen;

    return AspectRatio(
      aspectRatio: 1.68,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: FlowaRadii.xlAll,
          border: tint.needsEdge
              ? Border.all(color: tint.edge, width: 1)
              : null,
        ),
        child: ClipRRect(
          borderRadius: FlowaRadii.xlAll,
          child: Stack(
            fit: StackFit.expand,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: tint.fill,
                  gradient: sheen == null
                      ? null
                      : LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [sheen, tint.fill, tint.fill],
                          stops: const [0, 0.45, 1],
                        ),
                ),
              ),
              if (profile.pattern != FlowaCardPattern.none)
                Positioned.fill(
                  child: CustomPaint(
                    painter: FlowaCardPatternPainter(
                      pattern: profile.pattern,
                      ink: foreground.withValues(alpha: 0.14),
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.fromLTRB(22, 20, 22, 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Flowa',
                          style: FlowaType.titleSm(color: foreground).copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                          ),
                        ),
                      const Spacer(),
                      if (locked)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: FlowaColors.danger.withValues(alpha: 0.18),
                            borderRadius: FlowaRadii.pillAll,
                          ),
                          child: Text(
                            'Bloqueada',
                            style: FlowaType.micro(color: FlowaColors.danger),
                          ),
                        )
                      else
                        FlowaIcon(FlowaGlyph.card, size: 20, color: foreground),
                    ],
                  ),
                  const SizedBox(height: FlowaSpacing.md),
                  Row(
                    children: [
                      Container(
                        width: 38,
                        height: 28,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(6),
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              foreground.withValues(alpha: 0.55),
                              foreground.withValues(alpha: 0.22),
                            ],
                          ),
                          border: Border.all(
                            color: foreground.withValues(alpha: 0.35),
                          ),
                        ),
                      ),
                      const SizedBox(width: FlowaSpacing.sm),
                      FlowaIcon(
                        FlowaGlyph.spark,
                        size: 18,
                        color: foreground.withValues(alpha: 0.75),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    profile.formattedPan,
                    style: FlowaType.titleMd(color: foreground).copyWith(
                      letterSpacing: 1.4,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: FlowaSpacing.md),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Titular',
                              style: FlowaType.micro(
                                color: foreground.withValues(alpha: 0.7),
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              account.displayName,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: FlowaType.titleSm(color: foreground),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Caduca',
                            style: FlowaType.micro(
                              color: foreground.withValues(alpha: 0.7),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            account.expiryLabel,
                            style: FlowaType.titleSm(color: foreground),
                          ),
                        ],
                      ),
                      const SizedBox(width: FlowaSpacing.lg),
                      Text(
                        account.brand,
                        style: FlowaType.titleMd(color: foreground).copyWith(
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.6,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
        ),
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({
    required this.glyph,
    required this.label,
    required this.onTap,
    this.mark,
  });

  final FlowaGlyph glyph;
  final String label;
  final VoidCallback onTap;
  final String? mark;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: FlowaPressScale(
        onTap: onTap,
        scale: 0.94,
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: const BoxDecoration(
                color: FlowaColors.inkHigh,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: mark == null
                  ? FlowaIcon(glyph, size: 26)
                  : Text(
                      mark!,
                      style: FlowaType.titleSm().copyWith(
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
            ),
            const SizedBox(height: FlowaSpacing.xs),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: FlowaType.micro(color: FlowaColors.boneMuted),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.glyph,
    required this.label,
    required this.value,
    this.onTap,
  });

  final FlowaGlyph glyph;
  final String label;
  final String value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return FlowaPressScale(
      onTap: onTap,
      enabled: onTap != null,
      haptic: onTap != null,
      scale: 0.99,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Row(
          children: [
            FlowaIconOrb(
              glyph: glyph,
              size: 40,
              background: FlowaColors.ink,
              foreground: FlowaColors.bone,
            ),
            const SizedBox(width: FlowaSpacing.sm),
            Expanded(
              child: Text(label, style: FlowaType.bodySm()),
            ),
            Flexible(
              child: Text(
                value,
                textAlign: TextAlign.right,
                style: FlowaType.titleSm(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

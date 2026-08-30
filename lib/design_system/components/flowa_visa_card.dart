import 'package:flutter/material.dart';

import '../../core/utils/flowa_formatters.dart';
import '../../domain/entities/finance_entities.dart';
import '../tokens/flowa_spacing.dart';
import '../tokens/flowa_typography.dart';
import 'flowa_card_face.dart';
import 'flowa_icon.dart';

/// Legacy name kept so older imports keep compiling.
typedef FlowaCardStyle = FlowaCardTint;

/// Hero payment card — solid tint + optional geometric pattern.
class FlowaVisaCard extends StatelessWidget {
  const FlowaVisaCard({
    required this.account,
    super.key,
    this.style = FlowaCardTint.turquoise,
    this.pattern = FlowaCardPattern.none,
    this.height = 196,
    this.isFrozen = false,
    this.onToggleFreeze,
    this.caption = 'Disponible de verdad',
    this.amount,
  });

  final Account account;
  final FlowaCardTint style;
  final FlowaCardPattern pattern;
  final double height;
  final bool isFrozen;
  final VoidCallback? onToggleFreeze;
  final String caption;
  final double? amount;

  @override
  Widget build(BuildContext context) {
    final tint = style;
    final fg = tint.foreground;
    final value = amount ?? account.availableBalance;
    final sheen = tint.sheen;

    return Semantics(
      label: '${account.displayName} ${account.brand} card',
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: FlowaRadii.xlAll,
          border: tint.needsEdge
              ? Border.all(color: tint.edge, width: 1)
              : null,
        ),
        child: ClipRRect(
          borderRadius: FlowaRadii.xlAll,
          child: SizedBox(
            height: height,
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
                if (pattern != FlowaCardPattern.none)
                  Positioned.fill(
                    child: CustomPaint(
                      painter: FlowaCardPatternPainter(
                        pattern: pattern,
                        ink: fg.withValues(alpha: 0.14),
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(22, 16, 22, 14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Flowa',
                            style: FlowaType.titleSm(color: fg).copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.3,
                              height: 1,
                            ),
                          ),
                          const Spacer(),
                          FlowaIcon(FlowaGlyph.card, size: 24, color: fg),
                        ],
                      ),
                      const SizedBox(height: FlowaSpacing.xs),
                      _Chip(color: fg),
                      const Spacer(),
                      Text(
                        isFrozen ? 'Tarjeta congelada' : caption,
                        style: FlowaType.micro(
                          color: fg.withValues(alpha: 0.7),
                        ).copyWith(height: 1),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Expanded(
                            child: Text(
                              FlowaFormatters.currency(value),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: FlowaType.figureLg(color: fg)
                                  .copyWith(height: 1),
                            ),
                          ),
                          Text(
                            account.brand,
                            style: FlowaType.titleMd(color: fg).copyWith(
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
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.color});

  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 38,
      height: 28,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(6),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            color.withValues(alpha: 0.55),
            color.withValues(alpha: 0.22),
          ],
        ),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
    );
  }
}

/// Deck of up to three real cards — front + two coloured peeks behind.
/// Order is fixed here; reorder only inside Cartera with long-press drag.
class FlowaCardDeck extends StatelessWidget {
  const FlowaCardDeck({
    required this.cards,
    required this.onOpen,
    super.key,
    this.cardHeight = 196,
  });

  /// Ordered front → back. Only the first three are drawn.
  final List<({Account account, FlowaCardTint tint, FlowaCardPattern pattern, String caption, double amount})>
      cards;
  final VoidCallback onOpen;
  final double cardHeight;

  @override
  Widget build(BuildContext context) {
    final deck = cards.take(3).toList(growable: false);
    if (deck.isEmpty) {
      return const SizedBox.shrink();
    }

    const peek = 10.0;
    const stepInset = 12.0;
    final behind = deck.length - 1;
    final extra = behind * peek;
    final front = deck.first;

    return SizedBox(
      height: cardHeight + extra,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          for (var i = behind; i >= 1; i--)
            Positioned(
              top: (behind - i) * peek,
              left: i * stepInset,
              right: i * stepInset,
              height: cardHeight,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: deck[i].tint.fill,
                  borderRadius: FlowaRadii.xlAll,
                  border: deck[i].tint.needsEdge
                      ? Border.all(color: deck[i].tint.edge)
                      : null,
                ),
              ),
            ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: cardHeight,
            child: GestureDetector(
              onTap: onOpen,
              child: FlowaVisaCard(
                account: front.account,
                style: front.tint,
                pattern: front.pattern,
                caption: front.caption,
                amount: front.amount,
                height: cardHeight,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

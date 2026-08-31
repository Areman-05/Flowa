import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';

import '../../../design_system/components/flowa_actions.dart';
import '../../../design_system/components/flowa_icon.dart';
import '../../../design_system/components/flowa_screen.dart';
import '../../../design_system/tokens/flowa_colors.dart';
import '../../../design_system/tokens/flowa_spacing.dart';
import '../../../design_system/tokens/flowa_typography.dart';
import '../../../domain/entities/support_article.dart';
import '../../../shared/navigation/flowa_routes.dart';
import '../../../shared/widgets/flowa_states.dart';
import '../../ai_assistant/presentation/ai_assistant_page.dart';
import 'support_article_detail_page.dart';
import 'support_chat_page.dart';

class SupportCenterPage extends StatefulWidget {
  const SupportCenterPage({super.key});

  @override
  State<SupportCenterPage> createState() => _SupportCenterPageState();
}

class _SupportCenterPageState extends State<SupportCenterPage> {
  String _query = '';
  String _category = 'Todos';

  List<SupportArticle> get _filtered {
    final q = _query.trim().toLowerCase();
    var items = SupportCatalog.articles;
    if (_category != 'Todos') {
      items = items.where((a) => a.category == _category).toList();
    }
    if (q.isEmpty) {
      return items;
    }
    return items
        .where(
          (article) =>
              article.title.toLowerCase().contains(q) ||
              article.teaser.toLowerCase().contains(q) ||
              article.category.toLowerCase().contains(q),
        )
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final items = _filtered;
    final categories = [
      'Todos',
      ...SupportCatalog.articles.map((a) => a.category).toSet(),
    ];

    return FlowaScreen(
      title: 'Soporte',
      child: Column(
        children: [
          TextField(
            onChanged: (value) => setState(() => _query = value),
            style: FlowaType.body(),
            decoration: InputDecoration(
              hintText: 'Buscar en la ayuda',
              hintStyle: FlowaType.body(color: FlowaColors.boneMuted),
              prefixIcon: const Icon(Icons.search, color: FlowaColors.boneMuted),
              filled: true,
              fillColor: FlowaColors.inkHigh,
            ),
          ),
          const SizedBox(height: FlowaSpacing.md),
          const _ContactSection(),
          const SizedBox(height: FlowaSpacing.md),
          SizedBox(
            height: 38,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final label = categories[index];
                final selected = label == _category;
                return FlowaPressScale(
                  onTap: () => setState(() => _category = label),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: selected ? FlowaColors.mint : FlowaColors.inkHigh,
                      borderRadius: FlowaRadii.pillAll,
                      border: Border.all(
                        color: selected
                            ? FlowaColors.mint
                            : FlowaColors.hairlineStrong,
                      ),
                    ),
                    child: Text(
                      label,
                      style: FlowaType.bodySm(
                        color: selected
                            ? FlowaColors.mintInk
                            : FlowaColors.boneMuted,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: FlowaSpacing.md),
          Expanded(
            child: items.isEmpty
                ? const FlowaEmptyState(
                    title: 'Sin artículos',
                    message: 'Prueba otra palabra o categoría.',
                    glyph: FlowaGlyph.search,
                  )
                : ListView.separated(
                    itemCount: items.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: FlowaSpacing.sm),
                    itemBuilder: (context, index) {
                      final article = items[index];
                      return _ArticleRow(
                        article: article,
                        onTap: () => pushFlowaRoute<void>(
                          context,
                          SupportArticleDetailPage(article: article),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _ArticleRow extends StatelessWidget {
  const _ArticleRow({required this.article, required this.onTap});

  final SupportArticle article;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FlowaPressScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: FlowaColors.inkHigh,
          borderRadius: FlowaRadii.lgAll,
          border: Border.all(color: FlowaColors.hairlineStrong),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    article.category,
                    style: FlowaType.bodySm(color: FlowaColors.mint),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    article.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: FlowaType.titleSm(),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    article.teaser,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: FlowaType.bodySm(color: FlowaColors.boneMuted),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const FlowaLucideIcon(
              LucideIcons.chevron_right,
              size: 20,
              color: FlowaColors.boneMuted,
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactSection extends StatelessWidget {
  const _ContactSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _SupportActionCard(
                icon: LucideIcons.message_circle,
                label: 'Chat en vivo',
                subtitle: 'Respuesta ~1 min',
                accent: FlowaColors.mint,
                onTap: () => pushFlowaRoute<void>(
                  context,
                  const SupportChatPage(),
                ),
              ),
            ),
            const SizedBox(width: FlowaSpacing.sm),
            Expanded(
              child: _SupportActionCard(
                icon: LucideIcons.sparkles,
                label: 'Asistente IA',
                subtitle: 'Ayuda al instante',
                accent: Color(0xFF9A7EC8),
                onTap: () => pushFlowaRoute<void>(
                  context,
                  const AiAssistantPage(),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: FlowaSpacing.sm),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Email: soporte@flowa.app'),
                      behavior: SnackBarBehavior.fixed,
                    ),
                  );
                },
                icon: const Icon(Icons.email_outlined),
                label: const Text('Escríbenos'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: FlowaColors.bone,
                  side: const BorderSide(color: FlowaColors.hairlineStrong),
                  minimumSize: Size.zero,
                  padding: const EdgeInsets.symmetric(vertical: FlowaSpacing.sm),
                ),
              ),
            ),
            const SizedBox(width: FlowaSpacing.sm),
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('¡Gracias por tu valoración!'),
                      behavior: SnackBarBehavior.fixed,
                    ),
                  );
                },
                icon: const Icon(Icons.star_outline),
                label: const Text('Valorar app'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: FlowaColors.bone,
                  side: const BorderSide(color: FlowaColors.hairlineStrong),
                  minimumSize: Size.zero,
                  padding: const EdgeInsets.symmetric(vertical: FlowaSpacing.sm),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _SupportActionCard extends StatelessWidget {
  const _SupportActionCard({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.accent,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String subtitle;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return FlowaPressScale(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: FlowaColors.inkHigh,
          borderRadius: FlowaRadii.lgAll,
          border: Border.all(color: FlowaColors.hairlineStrong),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.14),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: FlowaLucideIcon(icon, size: 20, color: accent),
            ),
            const SizedBox(height: 10),
            Text(label, style: FlowaType.titleSm()),
            Text(
              subtitle,
              style: FlowaType.bodySm(color: FlowaColors.boneMuted),
            ),
          ],
        ),
      ),
    );
  }
}

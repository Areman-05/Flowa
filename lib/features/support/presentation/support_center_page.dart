import 'package:flutter/material.dart';

import '../../../design_system/tokens/flowa_colors.dart';
import '../../../design_system/tokens/flowa_spacing.dart';
import '../../../domain/entities/support_article.dart';
import '../../../shared/widgets/flowa_states.dart';

class SupportCenterPage extends StatefulWidget {
  const SupportCenterPage({super.key});

  @override
  State<SupportCenterPage> createState() => _SupportCenterPageState();
}

class _SupportCenterPageState extends State<SupportCenterPage> {
  String _query = '';

  List<SupportArticle> get _filtered {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) {
      return SupportCatalog.articles;
    }
    return SupportCatalog.articles
        .where(
          (article) =>
              article.title.toLowerCase().contains(q) ||
              article.summary.toLowerCase().contains(q) ||
              article.category.toLowerCase().contains(q),
        )
        .toList(growable: false);
  }

  @override
  Widget build(BuildContext context) {
    final items = _filtered;
    return Scaffold(
      appBar: AppBar(title: const Text('Support')),
      body: SafeArea(
        child: Padding(
          padding: FlowaSpacing.screenPadding,
          child: Column(
            children: [
              TextField(
                onChanged: (value) => setState(() => _query = value),
                decoration: const InputDecoration(
                  hintText: 'Search help articles',
                  prefixIcon: Icon(Icons.search),
                ),
              ),
              const SizedBox(height: FlowaSpacing.md),
              Expanded(
                child: items.isEmpty
                    ? const FlowaEmptyState(
                        title: 'No articles found',
                        message: 'Try another keyword or browse categories.',
                        icon: Icons.support_agent,
                      )
                    : ListView.separated(
                        itemCount: items.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: FlowaSpacing.sm),
                        itemBuilder: (context, index) {
                          final article = items[index];
                          return Material(
                            color: FlowaColors.surface,
                            borderRadius: FlowaRadii.mdAll,
                            child: ListTile(
                              shape: const RoundedRectangleBorder(
                                borderRadius: FlowaRadii.mdAll,
                                side: BorderSide(color: FlowaColors.border),
                              ),
                              title: Text(article.title),
                              subtitle: Text(article.summary),
                              isThreeLine: true,
                              trailing: Chip(
                                label: Text(article.category),
                                visualDensity: VisualDensity.compact,
                              ),
                              onTap: () {
                                showModalBottomSheet<void>(
                                  context: context,
                                  showDragHandle: true,
                                  builder: (context) {
                                    return Padding(
                                      padding: FlowaSpacing.screenPadding,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            article.title,
                                            style: Theme.of(context)
                                                .textTheme
                                                .titleLarge,
                                          ),
                                          const SizedBox(
                                            height: FlowaSpacing.sm,
                                          ),
                                          Text(article.summary),
                                          const SizedBox(
                                            height: FlowaSpacing.xl,
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                );
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

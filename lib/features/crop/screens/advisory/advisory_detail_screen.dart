import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/farm_app_bar.dart';
import '../../../../shared/widgets/farm_scaffold.dart';
import '../../../../shared/widgets/loading_shimmer.dart';
import '../../models/advisory_content.dart';
import '../../providers/crop_providers.dart';

// ── Category helpers (kept local to avoid cross-file coupling) ────────────────

Color _categoryColor(String category) => switch (category) {
      'crop_tip' => AppColors.success,
      'pest_guide' => AppColors.secondary,
      'climate_advice' => AppColors.tertiary,
      'market_insight' => AppColors.rabbitColor,
      _ => AppColors.primary,
    };

Color _categoryContainerColor(String category) => switch (category) {
      'crop_tip' => AppColors.successContainer,
      'pest_guide' => AppColors.secondaryContainer,
      'climate_advice' => AppColors.tertiaryContainer,
      'market_insight' => AppColors.rabbitColorContainer,
      _ => AppColors.primaryContainer,
    };

String _categoryLabel(String category) => switch (category) {
      'crop_tip' => 'Crop Tips',
      'pest_guide' => 'Pest Guides',
      'climate_advice' => 'Climate',
      'market_insight' => 'Market',
      _ => category,
    };

// ── Screen ────────────────────────────────────────────────────────────────────

class AdvisoryDetailScreen extends ConsumerWidget {
  const AdvisoryDetailScreen({super.key, required this.articleId});

  final String articleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allAsync = ref.watch(advisoryContentProvider(null));

    return allAsync.when(
      loading: () => FarmScaffold(
        appBar: FarmAppBar(title: 'Advisory'),
        body: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: LoadingShimmer.list(count: 6, itemHeight: 80),
        ),
      ),
      error: (e, _) => FarmScaffold(
        appBar: FarmAppBar(title: 'Advisory'),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Text(
              'Failed to load article: $e',
              style: const TextStyle(color: AppColors.error),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
      data: (articles) {
        AdvisoryContent? content;
        try {
          content = articles.firstWhere((a) => a.id == articleId);
        } catch (_) {
          content = null;
        }

        if (content == null) {
          return FarmScaffold(
            appBar: FarmAppBar(title: 'Advisory'),
            body: const Center(child: Text('Article not found.')),
          );
        }

        final related = articles
            .where(
                (a) => a.category == content!.category && a.id != articleId)
            .take(2)
            .toList();

        return _DetailView(content: content, related: related);
      },
    );
  }
}

// ── Detail View ───────────────────────────────────────────────────────────────

class _DetailView extends StatelessWidget {
  const _DetailView({required this.content, required this.related});

  final AdvisoryContent content;
  final List<AdvisoryContent> related;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    final catColor = _categoryColor(content.category);
    final catBg = _categoryContainerColor(content.category);
    final catLabel = _categoryLabel(content.category);
    final dateFmt = DateFormat('d MMM yyyy');

    return FarmScaffold(
      body: CustomScrollView(
        slivers: [
          // ── Sliver app bar ────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            leading: const BackButton(),
            backgroundColor: catBg,
            foregroundColor: catColor,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                catLabel,
                style: TextStyle(
                  color: catColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
              background: Container(
                color: catBg,
                child: Center(
                  child: Icon(
                    _iconForCategory(content.category),
                    size: AppSpacing.iconXl,
                    color: catColor.withAlpha(80),
                  ),
                ),
              ),
            ),
          ),

          // ── Article body ──────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category badge + date
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm,
                          vertical: AppSpacing.xs,
                        ),
                        decoration: BoxDecoration(
                          color: catBg,
                          borderRadius: AppRadius.chip,
                        ),
                        child: Text(
                          catLabel,
                          style: tt.labelSmall?.copyWith(
                            color: catColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        dateFmt.format(content.publishedAt),
                        style: tt.labelSmall
                            ?.copyWith(color: cs.onSurfaceVariant),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Title
                  Text(
                    content.title,
                    style: tt.headlineMedium
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  // Tags
                  if (content.tags.isNotEmpty) ...[
                    Wrap(
                      spacing: AppSpacing.xs,
                      runSpacing: AppSpacing.xs,
                      children: content.tags.map((tag) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: cs.surfaceContainerHighest,
                            borderRadius: AppRadius.chip,
                          ),
                          child: Text(
                            tag,
                            style: tt.labelSmall
                                ?.copyWith(color: cs.onSurfaceVariant),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],

                  const Divider(),
                  const SizedBox(height: AppSpacing.md),

                  // Body text with simple **bold** markdown rendering
                  SelectableText.rich(
                    _parseBoldMarkdown(content.body, tt),
                  ),

                  // Related articles
                  if (related.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xl),
                    Container(
                      width: 3,
                      height: 18,
                      decoration: BoxDecoration(
                        color: cs.primary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Related Articles',
                      style: tt.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    ...related.map(
                        (r) => _RelatedArticleCard(content: r)),
                  ],
                  const SizedBox(height: AppSpacing.xxl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Parse text with `**bold**` markers into a [TextSpan] tree.
TextSpan _parseBoldMarkdown(String text, TextTheme tt) {
  final parts = text.split('**');
  final spans = <InlineSpan>[];

  for (var i = 0; i < parts.length; i++) {
    final isBold = i.isOdd;
    spans.add(TextSpan(
      text: parts[i],
      style: tt.bodyMedium?.copyWith(
        fontWeight: isBold ? FontWeight.w700 : FontWeight.normal,
      ),
    ));
  }

  return TextSpan(children: spans);
}

IconData _iconForCategory(String category) => switch (category) {
      'crop_tip' => Icons.eco_outlined,
      'pest_guide' => Icons.bug_report_outlined,
      'climate_advice' => Icons.cloud_outlined,
      'market_insight' => Icons.show_chart_rounded,
      _ => Icons.article_outlined,
    };

// ── Related Article Card ──────────────────────────────────────────────────────

class _RelatedArticleCard extends StatelessWidget {
  const _RelatedArticleCard({required this.content});

  final AdvisoryContent content;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    final catColor = _categoryColor(content.category);
    final catBg = _categoryContainerColor(content.category);
    final catLabel = _categoryLabel(content.category);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
        elevation: 1,
        child: InkWell(
          onTap: () =>
              context.push(AppRoutes.cropAdvisoryDetailPath(content.id)),
          borderRadius: AppRadius.card,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: catBg,
                    borderRadius: AppRadius.chip,
                  ),
                  child: Text(
                    catLabel,
                    style: tt.labelSmall?.copyWith(
                      color: catColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    content.title,
                    style: tt.bodyMedium
                        ?.copyWith(fontWeight: FontWeight.w500),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: AppSpacing.iconSm,
                  color: cs.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

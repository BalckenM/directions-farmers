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

// ── Category helpers ──────────────────────────────────────────────────────────

const _categoryFilters = <String, String?>{
  'All': null,
  'Crop Tips': 'crop_tip',
  'Pest Guides': 'pest_guide',
  'Climate': 'climate_advice',
  'Market': 'market_insight',
};

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

class AdvisoryHubScreen extends ConsumerStatefulWidget {
  const AdvisoryHubScreen({super.key});

  @override
  ConsumerState<AdvisoryHubScreen> createState() => _AdvisoryHubScreenState();
}

class _AdvisoryHubScreenState extends ConsumerState<AdvisoryHubScreen> {
  String _selectedFilterLabel = 'All';
  String _searchQuery = '';

  String? get _selectedCategory =>
      _categoryFilters[_selectedFilterLabel];

  @override
  Widget build(BuildContext context) {
    final contentAsync =
        ref.watch(advisoryContentProvider(_selectedCategory));

    return FarmScaffold(
      appBar: const FarmAppBar(title: 'Advisory Hub'),
      body: Column(
        children: [
          // ── Search bar ──────────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.sm,
            ),
            child: TextFormField(
              decoration: InputDecoration(
                hintText: 'Search articles…',
                prefixIcon: const Icon(Icons.search_rounded),
                border:
                    OutlineInputBorder(borderRadius: AppRadius.input),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                isDense: true,
              ),
              onChanged: (v) => setState(() => _searchQuery = v.trim()),
            ),
          ),

          // ── Category filter chips ────────────────────────────────────────
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md),
              children: _categoryFilters.keys.map((label) {
                final selected = _selectedFilterLabel == label;
                return Padding(
                  padding:
                      const EdgeInsets.only(right: AppSpacing.sm),
                  child: FilterChip(
                    label: Text(label),
                    selected: selected,
                    onSelected: (_) =>
                        setState(() => _selectedFilterLabel = label),
                    showCheckmark: false,
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // ── Content ──────────────────────────────────────────────────────
          Expanded(
            child: contentAsync.when(
              loading: () => Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: LoadingShimmer.list(count: 4, itemHeight: 120),
              ),
              error: (e, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Text(
                    'Failed to load articles: $e',
                    style:
                        const TextStyle(color: AppColors.error),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              data: (articles) {
                final filtered = _searchQuery.isEmpty
                    ? articles
                    : articles
                        .where((a) =>
                            a.title.toLowerCase().contains(
                                _searchQuery.toLowerCase()) ||
                            a.summary.toLowerCase().contains(
                                _searchQuery.toLowerCase()))
                        .toList();

                if (filtered.isEmpty) {
                  return const Center(
                    child: Text('No articles found.'),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  itemCount: filtered.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, i) => _ArticleCard(
                    content: filtered[i],
                    onTap: () => context.push(
                        AppRoutes.cropAdvisoryDetailPath(
                            filtered[i].id)),
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

// ── Article Card ──────────────────────────────────────────────────────────────

class _ArticleCard extends StatelessWidget {
  const _ArticleCard({required this.content, required this.onTap});

  final AdvisoryContent content;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    final catColor = _categoryColor(content.category);
    final catBg = _categoryContainerColor(content.category);
    final catLabel = _categoryLabel(content.category);
    final dateFmt = DateFormat('d MMM yyyy');

    return Card(
      shape:
          RoundedRectangleBorder(borderRadius: AppRadius.card),
      elevation: 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.card,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Category badge ─────────────────────────────────────────
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
                  const Spacer(),
                  Text(
                    dateFmt.format(content.publishedAt),
                    style: tt.labelSmall?.copyWith(
                        color: cs.onSurfaceVariant),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),

              // ── Title ──────────────────────────────────────────────────
              Text(
                content.title,
                style: tt.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: AppSpacing.xs),

              // ── Summary ────────────────────────────────────────────────
              Text(
                content.summary,
                style: tt.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),

              // ── Tags ───────────────────────────────────────────────────
              if (content.tags.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
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
                        style: tt.labelSmall?.copyWith(
                            color: cs.onSurfaceVariant),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

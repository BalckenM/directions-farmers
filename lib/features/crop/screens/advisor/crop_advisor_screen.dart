import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/farm_app_bar.dart';
import '../../../../shared/widgets/farm_scaffold.dart';
import '../../../../shared/widgets/loading_shimmer.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../models/advisor_models.dart';
import '../../providers/crop_providers.dart';

class CropAdvisorScreen extends ConsumerWidget {
  const CropAdvisorScreen({super.key});

  static const _farmId = 'FARM-001';

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final briefingAsync =
        ref.watch(dailyAdvisorBriefingProvider(_farmId));

    return FarmScaffold(
      appBar: FarmAppBar(title: 'Crop AI Advisor'),
      body: CustomScrollView(
        slivers: [
          // ── Hero banner ────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: _HeroBanner(),
          ),

          // ── Daily briefing ─────────────────────────────────────────────────
          const SliverToBoxAdapter(
            child: SectionHeader(title: "Today's Farm Briefing"),
          ),
          briefingAsync.when(
            loading: () => SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: LoadingShimmer.list(count: 3, itemHeight: 100),
              ),
            ),
            error: (e, _) => SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Text(
                  'Failed to load briefing: $e',
                  style: const TextStyle(color: AppColors.error),
                ),
              ),
            ),
            data: (responses) => SliverList(
              delegate: SliverChildBuilderDelegate(
                (ctx, i) => Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    0,
                    AppSpacing.md,
                    AppSpacing.sm,
                  ),
                  child: _BriefingCard(
                    response: responses[i],
                    onTap: () => context.push(
                      AppRoutes.cropAdvisorChat,
                      extra: responses[i],
                    ),
                  ),
                ),
                childCount: responses.length,
              ),
            ),
          ),

          // ── Ask about a topic ──────────────────────────────────────────────
          const SliverToBoxAdapter(
            child: SectionHeader(title: 'Ask the Advisor'),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              0,
              AppSpacing.md,
              AppSpacing.md,
            ),
            sliver: SliverGrid.builder(
              gridDelegate:
                  const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: AppSpacing.sm,
                crossAxisSpacing: AppSpacing.sm,
                childAspectRatio: 2.0,
              ),
              itemCount: AdvisorTopic.values.length,
              itemBuilder: (ctx, i) {
                final topic = AdvisorTopic.values[i];
                return _TopicCard(
                  topic: topic,
                  onTap: () => _navigateToChat(context, topic),
                );
              },
            ),
          ),

          // ── Disclaimer ─────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                0,
                AppSpacing.md,
                AppSpacing.xxl,
              ),
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.sm),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .surfaceContainerLow,
                  borderRadius: AppRadius.card,
                ),
                child: Text(
                  'The 4Directions Crop Advisor provides data-driven recommendations '
                  'based on your farm context and established agricultural best '
                  'practices for South Africa. Always consult a registered '
                  'agricultural advisor (Pr. Agric) for formal recommendations.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context)
                            .colorScheme
                            .onSurfaceVariant,
                        fontSize: 11,
                      ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToChat(BuildContext context, AdvisorTopic topic) {
    // Build a placeholder query context using mock farm data.
    final query = AdvisorQuery(
      id: 'Q-${topic.name}-${DateTime.now().millisecondsSinceEpoch}',
      topic: topic,
      context: const AdvisorContext(
        farmId: _farmId,
        rainfallMm7d: 8.2,
        currentTempC: 23.4,
        frostRisk: false,
        sprayWindowLabel: 'suitable',
        province: 'Limpopo',
      ),
      askedAt: DateTime.now(),
    );
    context.push(AppRoutes.cropAdvisorChat, extra: query);
  }
}

// ── Hero banner ───────────────────────────────────────────────────────────────

class _HeroBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.all(AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.cropGreen, Color(0xFF1B5E20)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadius.card,
        boxShadow: [
          BoxShadow(
            color: AppColors.cropGreen.withAlpha(80),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Your Farm AI Advisor',
                  style: tt.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Data-driven advice for your specific farm conditions — '
                  'weather, pests, crops, and market timing.',
                  style: tt.bodySmall?.copyWith(
                    color: Colors.white.withAlpha(204),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(30),
                    borderRadius: AppRadius.chip,
                    border:
                        Border.all(color: Colors.white.withAlpha(60)),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.location_on_rounded,
                          size: 12, color: Colors.white),
                      SizedBox(width: 4),
                      Text(
                        'Polokwane, Limpopo · FARM-001',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          const Icon(
            Icons.agriculture_rounded,
            size: 64,
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}

// ── Briefing card ─────────────────────────────────────────────────────────────

class _BriefingCard extends StatelessWidget {
  const _BriefingCard({required this.response, required this.onTap});

  final AdvisorResponse response;
  final VoidCallback onTap;

  Color get _confidenceColor => switch (response.confidence) {
        AdvisorConfidence.high => AppColors.success,
        AdvisorConfidence.medium => AppColors.warning,
        AdvisorConfidence.low => AppColors.onSurfaceVariant,
      };

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final topRec = response.recommendations.firstOrNull;

    return Material(
      color: cs.surfaceContainerLow,
      borderRadius: AppRadius.card,
      child: InkWell(
        borderRadius: AppRadius.card,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            borderRadius: AppRadius.card,
            border: Border.all(color: cs.outlineVariant),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xs + 2,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.cropGreen.withAlpha(20),
                      borderRadius: AppRadius.chip,
                    ),
                    child: Text(
                      response.topic.label,
                      style: TextStyle(
                        color: AppColors.cropGreen,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xs + 2,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: _confidenceColor.withAlpha(20),
                      borderRadius: AppRadius.chip,
                    ),
                    child: Text(
                      response.confidence.label,
                      style: TextStyle(
                        color: _confidenceColor,
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  const Icon(Icons.arrow_forward_ios_rounded,
                      size: 12, color: AppColors.onSurfaceVariant),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                response.headline,
                style: tt.bodyMedium
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              if (topRec != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    _priorityDot(topRec.priority),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        topRec.title,
                        style: tt.bodySmall
                            ?.copyWith(color: cs.onSurfaceVariant),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
              if (response.recommendations.length > 1) ...[
                const SizedBox(height: 4),
                Text(
                  '+${response.recommendations.length - 1} more recommendations',
                  style: tt.labelSmall?.copyWith(
                    color: AppColors.cropGreen,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _priorityDot(AdvisorPriority p) {
    final color = switch (p) {
      AdvisorPriority.immediate => AppColors.error,
      AdvisorPriority.soon => AppColors.warning,
      AdvisorPriority.planned => AppColors.success,
    };
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

// ── Topic card ────────────────────────────────────────────────────────────────

class _TopicCard extends StatelessWidget {
  const _TopicCard({required this.topic, required this.onTap});

  final AdvisorTopic topic;
  final VoidCallback onTap;

  IconData get _icon => switch (topic) {
        AdvisorTopic.planting => Icons.spa_rounded,
        AdvisorTopic.irrigation => Icons.water_drop_rounded,
        AdvisorTopic.fertilization => Icons.eco_rounded,
        AdvisorTopic.pestManagement => Icons.pest_control_rounded,
        AdvisorTopic.weatherPlanning => Icons.cloud_rounded,
        AdvisorTopic.harvestReadiness => Icons.agriculture_rounded,
        AdvisorTopic.marketTiming => Icons.trending_up_rounded,
        AdvisorTopic.soilHealth => Icons.terrain_rounded,
        AdvisorTopic.generalFarming => Icons.grass_rounded,
      };

  Color get _color => switch (topic) {
        AdvisorTopic.planting => AppColors.cropGreen,
        AdvisorTopic.irrigation => AppColors.tertiary,
        AdvisorTopic.fertilization => AppColors.success,
        AdvisorTopic.pestManagement => AppColors.error,
        AdvisorTopic.weatherPlanning => AppColors.primary,
        AdvisorTopic.harvestReadiness => AppColors.secondary,
        AdvisorTopic.marketTiming => AppColors.warning,
        AdvisorTopic.soilHealth => AppColors.cropGreenDark,
        AdvisorTopic.generalFarming => AppColors.cropGreen,
      };

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final color = _color;

    return Material(
      color: cs.surfaceContainerLow,
      borderRadius: AppRadius.card,
      child: InkWell(
        borderRadius: AppRadius.card,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm,
            vertical: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            borderRadius: AppRadius.card,
            border: Border.all(color: color.withAlpha(60)),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: color.withAlpha(20),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(_icon, size: 16, color: color),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  topic.label,
                  style: tt.labelMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: cs.onSurface,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(Icons.chevron_right_rounded,
                  size: 16, color: cs.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

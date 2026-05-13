import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/farm_date_utils.dart';
import '../../../core/utils/number_utils.dart';
import '../../../core/constants/livestock_constants.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/farm_app_bar.dart';
import '../../../shared/widgets/farm_scaffold.dart';
import '../../../shared/widgets/loading_shimmer.dart';
import '../../../shared/widgets/offline_sync_indicator.dart';
import '../../../shared/widgets/section_header.dart';
import '../models/dashboard_summary.dart';
import '../providers/dashboard_providers.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(dashboardSummaryProvider);
    final hour = DateTime.now().hour;
    final greeting = hour < 12
        ? 'Good morning'
        : hour < 17
            ? 'Good afternoon'
            : 'Good evening';

    return FarmScaffold(
      appBar: FarmAppBar(
        title: '4Directions Farm',
        actions: [
          const OfflineSyncIndicator(),
          IconButton(
            icon: Badge(
              smallSize: 8,
              backgroundColor: AppColors.error,
              child: Icon(
                Icons.notifications_outlined,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            tooltip: 'Notifications',
            onPressed: () => context.push(AppRoutes.recordAlerts),
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
      body: summaryAsync.when(
        loading: () => LoadingShimmer.list(count: 6),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.pagePaddingHorizontal),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off_rounded,
                    size: 48, color: AppColors.error),
                const SizedBox(height: AppSpacing.md),
                Text('Failed to load dashboard',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: AppSpacing.sm),
                Text(err.toString(),
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: AppColors.error),
                    textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
        data: (summary) => _CommandContent(
          summary: summary,
          greeting: greeting,
        ),
      ),
    );
  }
}

class _CommandContent extends StatelessWidget {
  const _CommandContent({
    required this.summary,
    required this.greeting,
  });
  final DashboardSummary summary;
  final String greeting;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {},
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          // 1. Urgent alerts strip
          if (summary.recentHealthAlerts > 0)
            SliverToBoxAdapter(
              child: _UrgentAlertsStrip(alertCount: summary.recentHealthAlerts),
            ),

          // 2. Today's snapshot card
          SliverToBoxAdapter(
            child: _TodaySnapshotCard(
              summary: summary,
              greeting: greeting,
            ),
          ),

          // 3. KPI scroll strip
          SliverToBoxAdapter(child: _KpiScrollStrip(summary: summary)),

          // 4. Quick actions
          SliverToBoxAdapter(child: _QuickActionsSection()),

          // 5. Herd at a glance
          SliverToBoxAdapter(
            child: SectionHeader(
              title: 'Herd at a Glance',
              actionLabel: 'Manage',
              onAction: () => context.go(AppRoutes.livestock),
            ),
          ),
          SliverToBoxAdapter(
            child: _HerdOverview(summaries: summary.speciesSummaries),
          ),

          // 6. Farm activity feed
          SliverToBoxAdapter(
            child: SectionHeader(
              title: 'Farm Activity',
              actionLabel: 'View all',
              onAction: () => context.push(AppRoutes.record),
            ),
          ),
          SliverToBoxAdapter(child: _ActivityFeed(summary: summary)),

          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxl)),
        ],
      ),
    );
  }
}

// ── Urgent alerts strip ───────────────────────────────────────────────────────

class _UrgentAlertsStrip extends StatelessWidget {
  const _UrgentAlertsStrip({required this.alertCount});
  final int alertCount;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Material(
      color: AppColors.errorContainer,
      child: InkWell(
        onTap: () => context.push(AppRoutes.recordAlerts),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.pagePaddingHorizontal,
            vertical: 10,
          ),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: AppColors.error.withAlpha(22),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: const Icon(Icons.warning_amber_rounded,
                    color: AppColors.error, size: 16),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  '$alertCount animal${alertCount > 1 ? 's' : ''} '
                  '${alertCount > 1 ? 'need' : 'needs'} attention',
                  style: tt.bodyMedium?.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                'View →',
                style: tt.labelMedium?.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Today's snapshot card ─────────────────────────────────────────────────────

class _TodaySnapshotCard extends StatelessWidget {
  const _TodaySnapshotCard({
    required this.summary,
    required this.greeting,
  });
  final DashboardSummary summary;
  final String greeting;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.pagePaddingHorizontal,
        AppSpacing.md,
        AppSpacing.pagePaddingHorizontal,
        AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2E7D32), Color(0xFF1A5E20)],
        ),
        borderRadius: AppRadius.card,
        boxShadow: AppShadows.level2,
      ),
      clipBehavior: Clip.hardEdge,
      child: Stack(
        children: [
          // Watermark icons
          Positioned(
            right: -18,
            bottom: -16,
            child: Icon(Icons.agriculture_rounded,
                size: 140, color: Colors.white.withAlpha(13)),
          ),
          Positioned(
            right: 80,
            top: -25,
            child: Icon(Icons.eco_rounded,
                size: 80, color: Colors.white.withAlpha(8)),
          ),

          // Content
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Greeting + weather
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            greeting,
                            style: tt.bodySmall?.copyWith(
                              color: Colors.white.withAlpha(200),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            summary.farmName,
                            style: tt.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.3,
                              height: 1.15,
                            ),
                          ),
                        ],
                      ),
                    ),
                    _WeatherChip(),
                  ],
                ),
                const SizedBox(height: 8),

                // Location + status
                Row(
                  children: [
                    Icon(Icons.location_on_outlined,
                        size: 12, color: Colors.white.withAlpha(140)),
                    const SizedBox(width: 3),
                    Expanded(
                      child: Text(
                        summary.farmLocation,
                        style: tt.bodySmall?.copyWith(
                            color: Colors.white.withAlpha(140)),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _StatusPill(
                        label: 'Operational', color: const Color(0xFF69F0AE)),
                  ],
                ),
                const SizedBox(height: 8),
                Container(height: 1, color: Colors.white.withAlpha(20)),
                const SizedBox(height: 8),

                // Date + tasks row
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        FarmDateUtils.formatDate(FarmDateUtils.today),
                        style: tt.labelSmall?.copyWith(
                          color: Colors.white.withAlpha(140),
                          fontSize: 10,
                        ),
                      ),
                    ),
                    _StatusPill(
                      label: '3 tasks pending',
                      color: AppColors.secondaryLight,
                      icon: Icons.task_alt_rounded,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WeatherChip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(22),
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: Colors.white.withAlpha(40)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.cloud_queue_rounded,
              color: Colors.white, size: 18),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '19°C',
                style: tt.labelLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  height: 1.1,
                ),
              ),
              Text(
                'Partly Cloudy',
                style: tt.labelSmall?.copyWith(
                  color: Colors.white.withAlpha(200),
                  fontSize: 9,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({
    required this.label,
    required this.color,
    this.icon,
  });
  final String label;
  final Color color;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(25),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: Colors.white.withAlpha(50)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: color, size: 10),
            const SizedBox(width: 4),
          ] else ...[
            Container(
              width: 5,
              height: 5,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: tt.labelSmall?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

// ── KPI scroll strip ──────────────────────────────────────────────────────────

class _KpiScrollStrip extends StatelessWidget {
  const _KpiScrollStrip({required this.summary});
  final DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    final healthyCount =
        summary.totalAnimals - summary.recentHealthAlerts;
    final healthPct = summary.totalAnimals > 0
        ? ((healthyCount / summary.totalAnimals) * 100).round()
        : 100;

    final chips = [
      _KpiChip(
        icon: Icons.pets_rounded,
        color: AppColors.primary,
        value: NumberUtils.formatInt(summary.totalAnimals),
        label: 'Animals',
      ),
      _KpiChip(
        icon: Icons.medical_services_rounded,
        color: summary.recentHealthAlerts > 0
            ? AppColors.error
            : AppColors.success,
        value: '${summary.recentHealthAlerts}',
        label: 'Alerts',
      ),
      _KpiChip(
        icon: Icons.favorite_rounded,
        color: AppColors.secondary,
        value: '${summary.recentBreedingEvents}',
        label: 'Breeding',
      ),
      _KpiChip(
        icon: Icons.grid_view_rounded,
        color: AppColors.tertiary,
        value: '${summary.speciesCount}',
        label: 'Species',
      ),
      _KpiChip(
        icon: Icons.verified_rounded,
        color: AppColors.success,
        value: '$healthPct%',
        label: 'Healthy',
      ),
    ];

    return SizedBox(
      height: 78,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.pagePaddingHorizontal,
        ),
        itemCount: chips.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (_, i) => chips[i],
      ),
    );
  }
}

class _KpiChip extends StatelessWidget {
  const _KpiChip({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
  });
  final IconData icon;
  final Color color;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      width: 88,
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: AppRadius.card,
        border: Border.all(color: color.withAlpha(60), width: 1),
        boxShadow: AppShadows.level1,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: color.withAlpha(20),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icon, color: color, size: 14),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: AppTypography.kpiValue.copyWith(
                  fontSize: 16,
                  color: cs.onSurface,
                  height: 1,
                  letterSpacing: -0.3,
                ),
              ),
              Text(
                label,
                style: tt.labelSmall?.copyWith(
                  color: cs.onSurfaceVariant,
                  fontSize: 9,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Quick actions ─────────────────────────────────────────────────────────────

class _QuickActionsSection extends StatelessWidget {
  const _QuickActionsSection();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pagePaddingHorizontal,
        AppSpacing.sm,
        AppSpacing.pagePaddingHorizontal,
        AppSpacing.md,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _QuickActionTile(
                  icon: Icons.add_circle_rounded,
                  label: 'Add Animal',
                  sublabel: 'Register livestock',
                  color: AppColors.primary,
                  onTap: () =>
                      context.push(AppRoutes.addAnimalPath('cattle')),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _QuickActionTile(
                  icon: Icons.edit_note_rounded,
                  label: 'Log Event',
                  sublabel: 'Health, weight, breed',
                  color: AppColors.tertiary,
                  onTap: () => context.push(AppRoutes.record),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: _QuickActionTile(
                  icon: Icons.bar_chart_rounded,
                  label: 'Insights',
                  sublabel: 'Analytics & reports',
                  color: AppColors.secondary,
                  onTap: () => context.go(AppRoutes.insights),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _QuickActionTile(
                  icon: Icons.notifications_active_rounded,
                  label: 'Alerts',
                  sublabel: 'Farm notifications',
                  color: AppColors.error,
                  onTap: () => context.push(AppRoutes.recordAlerts),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: _QuickActionTile(
                  icon: Icons.eco_rounded,
                  label: 'Crop Farming',
                  sublabel: 'Plan, grow, harvest',
                  color: const Color(0xFF16A34A),
                  onTap: () => context.push(AppRoutes.crop),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              const Expanded(child: SizedBox()),
            ],
          ),
        ],
      ),
    );
  }
}

class _QuickActionTile extends StatelessWidget {
  const _QuickActionTile({
    required this.icon,
    required this.label,
    required this.sublabel,
    required this.color,
    this.onTap,
  });
  final IconData icon;
  final String label;
  final String sublabel;
  final Color color;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.card,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: cs.surfaceContainerLow,
            borderRadius: AppRadius.card,
            border: Border.all(
                color: cs.outlineVariant.withAlpha(80), width: 1),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withAlpha(20),
                  borderRadius: AppRadius.button,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      label,
                      style: tt.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                    Text(
                      sublabel,
                      style: tt.labelSmall?.copyWith(
                        color: cs.onSurfaceVariant,
                        fontSize: 10,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
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

// ── Herd overview ─────────────────────────────────────────────────────────────

class _HerdOverview extends StatelessWidget {
  const _HerdOverview({required this.summaries});
  final List<SpeciesSummary> summaries;

  @override
  Widget build(BuildContext context) {
    if (summaries.isEmpty) {
      return const EmptyState(
        title: 'No livestock yet',
        subtitle: 'Add your first animal to get started.',
      );
    }
    return SizedBox(
      height: 116,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.pagePaddingHorizontal,
        ),
        itemCount: summaries.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, i) =>
            _SpeciesHerdCard(summary: summaries[i]),
      ),
    );
  }
}

class _SpeciesHerdCard extends StatelessWidget {
  const _SpeciesHerdCard({required this.summary});
  final SpeciesSummary summary;

  static IconData _watermarkIcon(String species) {
    switch (species.toLowerCase()) {
      case 'cattle':
        return Icons.water_drop_rounded;
      case 'poultry':
        return Icons.egg_rounded;
      case 'sheep':
        return Icons.cloud_rounded;
      case 'goats':
        return Icons.landscape_rounded;
      case 'pigs':
        return Icons.eco_rounded;
      case 'horses':
        return Icons.directions_run_rounded;
      default:
        return Icons.pets_rounded;
    }
  }

  static String _emoji(String species) {
    switch (species.toLowerCase()) {
      case 'cattle':
        return '🐄';
      case 'sheep':
        return '🐑';
      case 'goats':
        return '🐐';
      case 'pigs':
        return '🐷';
      case 'horses':
        return '🐴';
      case 'poultry':
        return '🐓';
      case 'rabbits':
        return '🐇';
      case 'aquaculture':
        return '🐟';
      case 'bees':
        return '🐝';
      default:
        return '🐾';
    }
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final accent = AppColors.forSpecies(summary.species);
    final containerColor = AppColors.containerForSpecies(summary.species);

    return GestureDetector(
      onTap: () =>
          context.go(AppRoutes.livestockSpeciesPath(summary.species)),
      child: Container(
        width: 130,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [containerColor, accent.withAlpha(30)],
          ),
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(color: accent.withAlpha(55), width: 1),
          boxShadow: AppShadows.level1,
        ),
        clipBehavior: Clip.hardEdge,
        child: Stack(
          children: [
            Positioned(
              right: -10,
              bottom: -8,
              child: Icon(_watermarkIcon(summary.species),
                  size: 64, color: accent.withAlpha(22)),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: Colors.white.withAlpha(140),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Center(
                          child: Text(
                            _emoji(summary.species),
                            style: const TextStyle(fontSize: 18, height: 1),
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: summary.alertCount > 0
                              ? AppColors.errorContainer
                              : Colors.white.withAlpha(140),
                          borderRadius: BorderRadius.circular(AppRadius.xs),
                        ),
                        child: Text(
                          summary.alertCount > 0
                              ? '${summary.alertCount}!'
                              : '✓',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: summary.alertCount > 0
                                ? AppColors.error
                                : AppColors.success,
                          ),
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${summary.headCount}',
                        style: AppTypography.kpiValue.copyWith(
                          fontSize: 22,
                          color: accent,
                          height: 1,
                        ),
                      ),
                      Text(
                        LivestockConstants.displayName(summary.species),
                        style: tt.labelSmall?.copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF424242),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        '${summary.headCount} head',
                        style: tt.labelSmall?.copyWith(
                          fontSize: 9,
                          color: const Color(0xFF757575),
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
    );
  }
}

// ── Activity feed ─────────────────────────────────────────────────────────────

class _ActivityFeed extends StatelessWidget {
  const _ActivityFeed({required this.summary});
  final DashboardSummary summary;

  static const _items = [
    _ActivityItem(
      icon: Icons.monitor_weight_rounded,
      iconColor: AppColors.tertiary,
      iconBg: AppColors.tertiaryContainer,
      title: 'Weight recorded',
      subtitle: 'Goat #G-007 · 23.4 kg',
      timestamp: '2h ago',
    ),
    _ActivityItem(
      icon: Icons.health_and_safety_rounded,
      iconColor: AppColors.success,
      iconBg: AppColors.successContainer,
      title: 'Vaccination complete',
      subtitle: '12 cattle · FMD booster',
      timestamp: '5h ago',
    ),
    _ActivityItem(
      icon: Icons.water_drop_rounded,
      iconColor: AppColors.primary,
      iconBg: AppColors.primaryContainer,
      title: 'Milk collected',
      subtitle: '3 cows · 42.3 L total',
      timestamp: '6h ago',
    ),
    _ActivityItem(
      icon: Icons.add_circle_rounded,
      iconColor: AppColors.secondary,
      iconBg: AppColors.secondaryContainer,
      title: 'New animal registered',
      subtitle: 'Bull #B-012 · Holstein · Paddock A',
      timestamp: 'Yesterday',
    ),
    _ActivityItem(
      icon: Icons.favorite_rounded,
      iconColor: Color(0xFFE91E63),
      iconBg: Color(0xFFFCE4EC),
      title: 'Breeding event logged',
      subtitle: 'Cow #C-014 · Mating recorded',
      timestamp: 'Yesterday',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pagePaddingHorizontal,
        0,
        AppSpacing.pagePaddingHorizontal,
        AppSpacing.md,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: AppRadius.card,
          border: Border.all(color: cs.outlineVariant, width: 1),
          boxShadow: AppShadows.level1,
        ),
        child: Column(
          children: [
            for (int i = 0; i < _items.length; i++) ...[
              _ActivityTile(item: _items[i]),
              if (i < _items.length - 1)
                Divider(
                  height: 1,
                  indent: 52 + AppSpacing.md,
                  color: cs.outlineVariant,
                ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ActivityItem {
  const _ActivityItem({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.timestamp,
  });
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;
  final String timestamp;
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({required this.item});
  final _ActivityItem item;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 10,
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: item.iconBg,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(item.icon, color: item.iconColor, size: 18),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  item.subtitle,
                  style: tt.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                    height: 1.3,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            item.timestamp,
            style: tt.labelSmall?.copyWith(
              color: cs.onSurfaceVariant,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

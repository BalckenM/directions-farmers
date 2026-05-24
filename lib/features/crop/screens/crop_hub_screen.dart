import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/farm_app_bar.dart';
import '../../../shared/widgets/farm_scaffold.dart';
import '../../../shared/widgets/loading_shimmer.dart';
import '../../../shared/widgets/section_header.dart';
import '../models/advisory_content.dart';
import '../models/crop_season.dart';
import '../models/crop_task.dart';
import '../models/planting_plan.dart';
import '../models/weather_alert.dart';
import '../providers/crop_providers.dart';
import '../widgets/crop_illustration.dart';

// ── Quick-action config ───────────────────────────────────────────────────────
//
// Catalog is NOT a top-level action — it lives inside the field/plan flow.
// Weather is NOT a quick action — it is embedded as a banner in this screen.

class _QuickAction {
  const _QuickAction(
      {required this.label, required this.icon, required this.route,
      this.color = AppColors.cropGreen});
  final String label;
  final IconData icon;
  final String route;
  final Color color;
}

final List<_QuickAction> _quickActions = [
  _QuickAction(
      label: 'My Fields',
      icon: Icons.crop_square_rounded,
      route: AppRoutes.cropFields),
  _QuickAction(
      label: 'Season Plan',
      icon: Icons.event_note_rounded,
      route: AppRoutes.cropSeasons,
      color: AppColors.tertiary),
  _QuickAction(
      label: 'Calendar',
      icon: Icons.calendar_month_rounded,
      route: AppRoutes.cropCalendar,
      color: AppColors.secondary),
  _QuickAction(
      label: 'AI Advisor',
      icon: Icons.agriculture_rounded,
      route: AppRoutes.cropAiAdvisor,
      color: AppColors.cropGreen),
  _QuickAction(
      label: 'Leaf Scanner',
      icon: Icons.biotech_rounded,
      route: AppRoutes.cropDiseaseScanner,
      color: AppColors.success),
  _QuickAction(
      label: 'Tasks',
      icon: Icons.task_alt_rounded,
      route: AppRoutes.cropTasks,
      color: AppColors.warning),
  _QuickAction(
      label: 'Pests & Spray',
      icon: Icons.pest_control_rounded,
      route: AppRoutes.cropPests,
      color: AppColors.error),
  _QuickAction(
      label: 'Expenses',
      icon: Icons.account_balance_wallet_rounded,
      route: AppRoutes.cropExpenses,
      color: AppColors.secondary),
  _QuickAction(
      label: 'Harvest',
      icon: Icons.agriculture_rounded,
      route: AppRoutes.cropHarvest),
  _QuickAction(
      label: 'Sales',
      icon: Icons.sell_rounded,
      route: AppRoutes.cropSales,
      color: AppColors.success),
  _QuickAction(
      label: 'Profitability',
      icon: Icons.trending_up_rounded,
      route: AppRoutes.cropProfitability,
      color: AppColors.tertiary),
];

// ── Screen ────────────────────────────────────────────────────────────────────

class CropHubScreen extends ConsumerWidget {
  const CropHubScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fieldsAsync = ref.watch(cropFieldsProvider(null));
    final tasksAsync = ref.watch(openCropTasksProvider);
    final alertsAsync = ref.watch(actionRequiredAlertsProvider);
    final seasonsAsync = ref.watch(seasonsProvider(null));
    final plansAsync = ref.watch(plantingPlansProvider(null));
    final cropsAsync = ref.watch(cropsProvider(null));
    final weatherAsync = ref.watch(weatherAlertsProvider(null));

    final Map<String, String> cropNames = {
      for (final c in cropsAsync.value ?? []) c.id: c.name,
    };
    final Map<String, String> fieldNames = {
      for (final f in fieldsAsync.value ?? []) f.id: f.name,
    };
    final activePlans = (plansAsync.value ?? [])
        .where((p) => p.isActive)
        .toList();

    return FarmScaffold(
      appBar: FarmAppBar(
        title: 'Crop Farming',
        subtitle: 'AgriFlow SA',
        leading: Builder(
          builder: (ctx) => IconButton(
            icon: const Icon(Icons.menu_rounded),
            onPressed: () => Scaffold.of(ctx).openDrawer(),
          ),
        ),
        actions: [
          // Advisory shortcut — catalog accessible from field planning
          IconButton(
            icon: const Icon(Icons.tips_and_updates_outlined),
            tooltip: 'Advisory',
            onPressed: () => context.push(AppRoutes.cropAdvisory),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // ── 1. Season header ───────────────────────────────────────────────
          SliverToBoxAdapter(
            child: _SeasonHeader(seasonsAsync: seasonsAsync),
          ),

          // ── 2. Weather banner (inline — not a separate screen link) ────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.pagePaddingHorizontal,
                AppSpacing.md,
                AppSpacing.pagePaddingHorizontal,
                0,
              ),
              child: _WeatherBanner(weatherAsync: weatherAsync),
            ),
          ),

          // ── 3. KPI row ─────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: _KpiRow(
              fieldsAsync: fieldsAsync,
              tasksAsync: tasksAsync,
              alertsAsync: alertsAsync,
              seasonsAsync: seasonsAsync,
            ),
          ),

          // ── 4. Growing Now ─────────────────────────────────────────────────
          if (activePlans.isNotEmpty || plansAsync.isLoading) ...[
            SliverToBoxAdapter(
              child: SectionHeader(
                title: 'Growing Now',
                actionLabel: 'All Fields',
                onAction: () => context.push(AppRoutes.cropFields),
              ),
            ),
            SliverToBoxAdapter(
              child: _GrowingNowScroll(
                plansAsync: plansAsync,
                cropNames: cropNames,
                fieldNames: fieldNames,
              ),
            ),
          ],

          // ── 5. Upcoming Tasks ──────────────────────────────────────────────
          SliverToBoxAdapter(
            child: SectionHeader(
              title: 'Upcoming Tasks',
              actionLabel: 'All Tasks',
              onAction: () => context.push(AppRoutes.cropTasks),
            ),
          ),
          SliverToBoxAdapter(
            child: _TasksSection(
              tasksAsync: tasksAsync,
              fieldNames: fieldNames,
            ),
          ),

          // ── 6. Crop Health & Alerts ────────────────────────────────────────
          SliverToBoxAdapter(
            child: SectionHeader(
              title: 'Crop Health & Alerts',
              actionLabel: 'View All',
              onAction: () => context.push(AppRoutes.cropPests),
            ),
          ),
          SliverToBoxAdapter(
            child: _AlertsSection(alertsAsync: alertsAsync),
          ),

          // ── 7. Quick Actions ───────────────────────────────────────────────
          SliverToBoxAdapter(
            child: SectionHeader(title: 'Farm Operations'),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.pagePaddingHorizontal,
              0,
              AppSpacing.pagePaddingHorizontal,
              AppSpacing.md,
            ),
            sliver: SliverGrid.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                mainAxisSpacing: AppSpacing.sm,
                crossAxisSpacing: AppSpacing.sm,
                childAspectRatio: 0.85,
              ),
              itemCount: _quickActions.length,
              itemBuilder: (ctx, i) =>
                  _QuickActionCard(action: _quickActions[i]),
            ),
          ),

          // ── 8. Latest Advisory ─────────────────────────────────────────────
          SliverToBoxAdapter(
            child: SectionHeader(
              title: 'Latest Advisory',
              actionLabel: 'Browse All',
              onAction: () => context.push(AppRoutes.cropAdvisory),
            ),
          ),
          SliverToBoxAdapter(
            child: const _AdvisorySection(),
          ),

          const SliverPadding(
            padding: EdgeInsets.only(bottom: AppSpacing.xxl),
          ),
        ],
      ),
    );
  }
}

// ── Season Header ─────────────────────────────────────────────────────────────

class _SeasonHeader extends StatelessWidget {
  const _SeasonHeader({required this.seasonsAsync});
  final AsyncValue<dynamic> seasonsAsync;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    final CropSeason? activeSeason = (seasonsAsync.whenOrNull(
      data: (seasons) {
        final active = (seasons as List).where((s) => s.isActive).toList();
        return active.isNotEmpty ? active.first : null;
      },
    ) as CropSeason?);

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.cropGreen, AppColors.cropGreenDark],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (activeSeason != null) ...[
                  Text(
                    activeSeason.name,
                    style: tt.titleLarge?.copyWith(
                      color: AppColors.onPrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${_capitalize(activeSeason.seasonType)} Season · Active',
                    style: tt.bodySmall?.copyWith(
                      color: AppColors.onPrimary.withAlpha(191),
                    ),
                  ),
                ] else ...[
                  Text(
                    'No Active Season',
                    style: tt.titleLarge?.copyWith(
                      color: AppColors.onPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Tap Season Plan to start a new season',
                    style: tt.bodySmall?.copyWith(
                      color: AppColors.onPrimary.withAlpha(191),
                    ),
                  ),
                ],
              ],
            ),
          ),
          GestureDetector(
            onTap: () {
              if (activeSeason != null) {
                context.push(AppRoutes.cropSeasonDetail, extra: activeSeason);
              } else {
                context.push(AppRoutes.addCropSeason);
              }
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
              decoration: BoxDecoration(
                color: AppColors.onPrimary.withAlpha(30),
                borderRadius: AppRadius.chip,
                border: Border.all(
                    color: AppColors.onPrimary.withAlpha(60)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.spa_rounded,
                      color: AppColors.onPrimary, size: 13),
                  const SizedBox(width: 4),
                  Text(
                    'Crop Season',
                    style: tt.labelSmall?.copyWith(
                      color: AppColors.onPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1).replaceAll('_', ' ');
}

// ── Weather Banner ────────────────────────────────────────────────────────────
// Compact inline weather — NOT a separate screen quick action.
// Tap "Full Forecast" to open the full weather screen.

class _WeatherBanner extends StatelessWidget {
  const _WeatherBanner({required this.weatherAsync});
  final AsyncValue<List<WeatherAlert>> weatherAsync;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    final alertCount = weatherAsync.whenOrNull(
          data: (alerts) =>
              alerts.where((a) => a.isActive).length,
        ) ??
        0;

    final hasSprayWarning = weatherAsync.whenOrNull(
          data: (alerts) => alerts.any(
            (a) =>
                a.alertType == WeatherAlertType.sprayUnsuitable &&
                a.isActive,
          ),
        ) ??
        false;

    return Builder(
      builder: (context) => GestureDetector(
        onTap: () => context.push(AppRoutes.cropWeather),
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: AppSpacing.sm + 2),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF1E40AF).withAlpha(230),
                const Color(0xFF1D4ED8).withAlpha(200),
              ],
            ),
            borderRadius: AppRadius.card,
          ),
          child: Row(
            children: [
              // Temperature + condition
              const Icon(Icons.wb_sunny_rounded,
                  color: Color(0xFFFDE68A), size: 32),
              const SizedBox(width: AppSpacing.sm),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(
                        '28°C',
                        style: tt.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        '· Mostly Sunny',
                        style: tt.bodySmall?.copyWith(
                          color: Colors.white.withAlpha(204),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(
                        hasSprayWarning
                            ? Icons.warning_amber_rounded
                            : Icons.check_circle_outline_rounded,
                        size: 12,
                        color: hasSprayWarning
                            ? const Color(0xFFFDE68A)
                            : const Color(0xFF86EFAC),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        hasSprayWarning
                            ? 'Spray: Unsuitable'
                            : 'Spray: Suitable',
                        style: TextStyle(
                          fontSize: 11,
                          color: hasSprayWarning
                              ? const Color(0xFFFDE68A)
                              : const Color(0xFF86EFAC),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Spacer(),
              // Alert count
              if (alertCount > 0) ...[
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(30),
                    borderRadius: AppRadius.chip,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.warning_amber_rounded,
                          size: 12, color: Color(0xFFFDE68A)),
                      const SizedBox(width: 3),
                      Text(
                        '$alertCount alert${alertCount == 1 ? '' : 's'}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
              ],
              // Full forecast button
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(30),
                  borderRadius: AppRadius.chip,
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Forecast',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(width: 2),
                    Icon(Icons.arrow_forward_rounded,
                        size: 12, color: Colors.white),
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

// ── KPI Row ───────────────────────────────────────────────────────────────────

class _KpiRow extends StatelessWidget {
  const _KpiRow({
    required this.fieldsAsync,
    required this.tasksAsync,
    required this.alertsAsync,
    required this.seasonsAsync,
  });

  final AsyncValue<dynamic> fieldsAsync;
  final AsyncValue<dynamic> tasksAsync;
  final AsyncValue<dynamic> alertsAsync;
  final AsyncValue<dynamic> seasonsAsync;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.pagePaddingHorizontal,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          _KpiCard(
            icon: Icons.crop_square_rounded,
            label: 'Fields',
            value: fieldsAsync.whenOrNull(
                data: (v) => '${(v as List).length}'),
            color: AppColors.cropGreen,
          ),
          const SizedBox(width: AppSpacing.sm),
          _KpiCard(
            icon: Icons.task_alt_rounded,
            label: 'Open Tasks',
            value: tasksAsync.whenOrNull(
                data: (v) => '${(v as List).length}'),
            color: AppColors.warning,
          ),
          const SizedBox(width: AppSpacing.sm),
          _KpiCard(
            icon: Icons.warning_amber_rounded,
            label: 'Alerts',
            value: alertsAsync.whenOrNull(
                data: (v) => '${(v as List).length}'),
            color: AppColors.error,
          ),
          const SizedBox(width: AppSpacing.sm),
          _KpiCard(
            icon: Icons.calendar_today_rounded,
            label: 'Seasons',
            value: seasonsAsync.whenOrNull(
                data: (v) => '${(v as List).length}'),
            color: AppColors.tertiary,
          ),
        ],
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String? value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.xs, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLow,
          borderRadius: AppRadius.card,
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: color.withAlpha(20),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 15),
            ),
            const SizedBox(height: AppSpacing.xs),
            if (value == null)
              const SizedBox(
                  width: 20, height: 14, child: LinearProgressIndicator())
            else
              Text(
                value!,
                style: tt.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: color,
                  fontSize: 17,
                ),
              ),
            const SizedBox(height: 1),
            Text(
              label,
              style: tt.labelSmall?.copyWith(
                fontSize: 9,
                color: cs.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Growing Now ───────────────────────────────────────────────────────────────
// Horizontal scrollable list of active planting plans with growth progress.
// Tapping a card opens PlantedCropDetailScreen.

class _GrowingNowScroll extends StatelessWidget {
  const _GrowingNowScroll({
    required this.plansAsync,
    required this.cropNames,
    required this.fieldNames,
  });

  final AsyncValue<List<PlantingPlan>> plansAsync;
  final Map<String, String> cropNames;
  final Map<String, String> fieldNames;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 148,
      child: plansAsync.when(
        loading: () => ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.pagePaddingHorizontal),
          itemCount: 3,
          separatorBuilder: (context, index) => const SizedBox(width: AppSpacing.sm),
          itemBuilder: (context, index) =>
              const SizedBox(width: 180, child: LoadingShimmer(height: 140)),
        ),
        error: (error, stack) => const SizedBox.shrink(),
        data: (plans) {
          final active = plans.where((p) => p.isActive).toList();
          if (active.isEmpty) {
            return Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.pagePaddingHorizontal),
              child: _GrowingNowEmpty(),
            );
          }
          return ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.pagePaddingHorizontal,
              0,
              AppSpacing.pagePaddingHorizontal,
              AppSpacing.sm,
            ),
            itemCount: active.length,
            separatorBuilder: (context, index) =>
                const SizedBox(width: AppSpacing.sm),
            itemBuilder: (ctx, i) => _GrowingCropCard(
              plan: active[i],
              cropName: cropNames[active[i].cropId] ?? active[i].cropId,
              fieldName:
                  fieldNames[active[i].fieldId] ?? active[i].fieldId,
            ),
          );
        },
      ),
    );
  }
}

class _GrowingCropCard extends StatelessWidget {
  const _GrowingCropCard({
    required this.plan,
    required this.cropName,
    required this.fieldName,
  });

  final PlantingPlan plan;
  final String cropName;
  final String fieldName;

  double get _progress {
    final start = plan.plannedPlantingDate;
    final end = plan.plannedHarvestDate;
    if (start == null || end == null) return 0.0;
    final now = DateTime.now();
    if (now.isBefore(start)) return 0.0;
    final total = end.difference(start).inDays;
    if (total <= 0) return 1.0;
    return (now.difference(start).inDays / total).clamp(0.0, 1.0);
  }

  String get _stageName {
    final p = _progress;
    if (p < 0.12) return 'Germination';
    if (p < 0.28) return 'Seedling';
    if (p < 0.55) return 'Vegetative';
    if (p < 0.72) return 'Flowering';
    if (p < 0.90) return 'Grain Fill';
    return 'Maturity';
  }

  int? get _daysToHarvest {
    final end = plan.plannedHarvestDate;
    if (end == null) return null;
    final d = end.difference(DateTime.now()).inDays;
    return d < 0 ? 0 : d;
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final progress = _progress;
    final pct = (progress * 100).round();
    final days = _daysToHarvest;

    return GestureDetector(
      onTap: () => context.push(
          AppRoutes.plantedCropDetailPath(plan.fieldId, plan.id)),
      child: Container(
        width: 180,
        padding: const EdgeInsets.all(AppSpacing.sm + 2),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLow,
          borderRadius: AppRadius.card,
          border: Border.all(
              color: AppColors.cropGreen.withAlpha(76)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Botanical crop illustration
                CropIllustration(
                  cropName: cropName,
                  growthProgress: progress,
                  size: 52,
                  showSoil: false,
                  showLabel: false,
                ),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cropName,
                        style: tt.bodySmall?.copyWith(
                            fontWeight: FontWeight.w700),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        fieldName,
                        style: tt.labelSmall?.copyWith(
                            color: cs.onSurfaceVariant, fontSize: 10),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            // Stage name + percentage
            Row(
              children: [
                Text(
                  _stageName,
                  style: tt.labelSmall?.copyWith(
                    color: AppColors.cropGreen,
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                  ),
                ),
                const Spacer(),
                Text(
                  '$pct%',
                  style: tt.labelSmall?.copyWith(
                    color: AppColors.cropGreen,
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 5,
                backgroundColor: cs.outlineVariant,
                valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.cropGreen),
              ),
            ),
            if (days != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (days == 0) ...[
                    Icon(
                      Icons.agriculture_rounded,
                      size: 11,
                      color: AppColors.secondary,
                    ),
                    const SizedBox(width: 2),
                  ],
                  Text(
                    days == 0 ? 'Ready to harvest' : '$days days to harvest',
                    style: tt.labelSmall?.copyWith(
                      color: days == 0 ? AppColors.secondary : cs.onSurfaceVariant,
                      fontSize: 10,
                      fontWeight: days == 0 ? FontWeight.w700 : FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _GrowingNowEmpty extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: () => context.push(AppRoutes.cropFields),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLow,
          borderRadius: AppRadius.card,
          border: Border.all(
              color: AppColors.cropGreen.withAlpha(51),
              style: BorderStyle.solid),
        ),
        child: Row(
          children: [
            Icon(Icons.add_circle_outline_rounded,
                color: AppColors.cropGreen.withAlpha(153), size: 32),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('No crops planted yet',
                      style: tt.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w700)),
                  Text(
                    'Go to My Fields to start a planting plan',
                    style: tt.bodySmall
                        ?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_rounded,
                color: AppColors.cropGreen, size: 18),
          ],
        ),
      ),
    );
  }
}

// ── Quick Action Card ─────────────────────────────────────────────────────────

class _QuickActionCard extends StatelessWidget {
  const _QuickActionCard({required this.action});
  final _QuickAction action;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Material(
      color: cs.surfaceContainerLow,
      borderRadius: AppRadius.card,
      child: InkWell(
        borderRadius: AppRadius.card,
        onTap: () => context.push(action.route),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xs),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: action.color.withAlpha(20),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(action.icon, color: action.color, size: 18),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                action.label,
                style: tt.labelSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 10,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Tasks Section ─────────────────────────────────────────────────────────────

class _TasksSection extends StatelessWidget {
  const _TasksSection(
      {required this.tasksAsync, required this.fieldNames});

  final AsyncValue<List<CropTask>> tasksAsync;
  final Map<String, String> fieldNames;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pagePaddingHorizontal,
        0,
        AppSpacing.pagePaddingHorizontal,
        AppSpacing.md,
      ),
      child: tasksAsync.when(
        loading: () => LoadingShimmer.list(count: 3, itemHeight: 64),
        error: (error, stack) => const _EmptyState(
          icon: Icons.task_alt_rounded,
          message: 'Unable to load tasks',
          color: AppColors.onSurfaceVariant,
        ),
        data: (tasks) {
          if (tasks.isEmpty) {
            return const _EmptyState(
              icon: Icons.task_alt_rounded,
              message: 'All caught up — no open tasks',
              color: AppColors.cropGreen,
            );
          }
          final sorted = [...tasks]
            ..sort((a, b) => a.dueDate.compareTo(b.dueDate));
          return Column(
            children: sorted
                .take(4)
                .map((t) => Padding(
                      padding:
                          const EdgeInsets.only(bottom: AppSpacing.xs),
                      child: _TaskTile(task: t, fieldNames: fieldNames),
                    ))
                .toList(),
          );
        },
      ),
    );
  }
}

class _TaskTile extends StatelessWidget {
  const _TaskTile({required this.task, required this.fieldNames});
  final CropTask task;
  final Map<String, String> fieldNames;

  Color _priorityColor(TaskPriority p) => switch (p) {
        TaskPriority.urgent => AppColors.error,
        TaskPriority.high => AppColors.warning,
        TaskPriority.medium => AppColors.secondary,
        TaskPriority.low => AppColors.success,
      };

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final pColor = _priorityColor(task.priority);
    final isOverdue = task.isOverdue;
    final fieldName = task.fieldId != null
        ? fieldNames[task.fieldId!]
        : null;

    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    final dateLabel =
        '${task.dueDate.day} ${months[task.dueDate.month - 1]}';

    return Material(
      color: cs.surfaceContainerLow,
      borderRadius: AppRadius.card,
      child: InkWell(
        borderRadius: AppRadius.card,
        onTap: () =>
            context.push(AppRoutes.cropTaskDetailPath(task.id)),
        child: Container(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: AppSpacing.sm + 2),
          decoration: BoxDecoration(
            borderRadius: AppRadius.card,
            border: Border.all(
              color: isOverdue
                  ? AppColors.error.withAlpha(80)
                  : cs.outlineVariant,
            ),
          ),
          child: Row(
            children: [
              // Priority indicator
              Container(
                width: 4,
                height: 36,
                decoration: BoxDecoration(
                  color: pColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: tt.bodySmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_rounded,
                          size: 11,
                          color: isOverdue
                              ? AppColors.error
                              : cs.onSurfaceVariant,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          dateLabel,
                          style: tt.labelSmall?.copyWith(
                            color: isOverdue
                                ? AppColors.error
                                : cs.onSurfaceVariant,
                            fontSize: 10,
                            fontWeight: isOverdue
                                ? FontWeight.w700
                                : FontWeight.w400,
                          ),
                        ),
                        if (fieldName != null) ...[
                          Text(
                            ' · $fieldName',
                            style: tt.labelSmall?.copyWith(
                              color: cs.onSurfaceVariant,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs + 2, vertical: 3),
                decoration: BoxDecoration(
                  color: pColor.withAlpha(20),
                  borderRadius: AppRadius.chip,
                ),
                child: Text(
                  task.priority.label,
                  style: tt.labelSmall?.copyWith(
                    color: pColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 9,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Alerts Section ────────────────────────────────────────────────────────────

class _AlertsSection extends StatelessWidget {
  const _AlertsSection({required this.alertsAsync});
  final AsyncValue<List<WeatherAlert>> alertsAsync;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pagePaddingHorizontal,
        0,
        AppSpacing.pagePaddingHorizontal,
        AppSpacing.md,
      ),
      child: alertsAsync.when(
        loading: () => LoadingShimmer.list(count: 2, itemHeight: 72),
        error: (error, stack) => const _EmptyState(
          icon: Icons.check_circle_outline_rounded,
          message: 'Unable to load alerts',
          color: AppColors.onSurfaceVariant,
        ),
        data: (alerts) {
          if (alerts.isEmpty) {
            return const _EmptyState(
              icon: Icons.check_circle_outline_rounded,
              message: 'No active alerts — all clear',
              color: AppColors.success,
            );
          }
          return Column(
            children: alerts
                .take(3)
                .map((a) => Padding(
                      padding:
                          const EdgeInsets.only(bottom: AppSpacing.xs),
                      child: _AlertTile(alert: a),
                    ))
                .toList(),
          );
        },
      ),
    );
  }
}

class _AlertTile extends StatelessWidget {
  const _AlertTile({required this.alert});
  final WeatherAlert alert;

  Color get _severityColor => switch (alert.severity.toLowerCase()) {
        'critical' || 'extreme' => AppColors.error,
        'high' => AppColors.warning,
        _ => AppColors.tertiary,
      };

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final color = _severityColor;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm + 2),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: AppRadius.card,
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.xs + 2, vertical: 3),
            decoration: BoxDecoration(
              color: color.withAlpha(20),
              borderRadius: AppRadius.chip,
            ),
            child: Text(
              alert.severity.toUpperCase(),
              style: tt.labelSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w700,
                fontSize: 9,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  alert.title,
                  style: tt.bodySmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  alert.message,
                  style: tt.bodySmall?.copyWith(
                    color: cs.onSurfaceVariant,
                    fontSize: 11,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Advisory Section ──────────────────────────────────────────────────────────

class _AdvisorySection extends ConsumerWidget {
  const _AdvisorySection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final advisoryAsync = ref.watch(latestAdvisoryProvider);

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pagePaddingHorizontal,
        0,
        AppSpacing.pagePaddingHorizontal,
        AppSpacing.md,
      ),
      child: advisoryAsync.when(
        loading: () => LoadingShimmer.list(count: 1, itemHeight: 100),
        error: (error, stack) => const _EmptyState(
          icon: Icons.tips_and_updates_rounded,
          message: 'Unable to load advisory',
          color: AppColors.onSurfaceVariant,
        ),
        data: (advisory) {
          if (advisory == null) {
            return const _EmptyState(
              icon: Icons.tips_and_updates_rounded,
              message: 'No advisory available',
              color: AppColors.cropGreen,
            );
          }
          return _AdvisoryCard(advisory: advisory);
        },
      ),
    );
  }
}

class _AdvisoryCard extends StatelessWidget {
  const _AdvisoryCard({required this.advisory});
  final AdvisoryContent advisory;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Material(
      color: cs.surfaceContainerLow,
      borderRadius: AppRadius.card,
      child: InkWell(
        borderRadius: AppRadius.card,
        onTap: () => context.push(AppRoutes.cropAdvisory),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.cropGreen.withAlpha(20),
                      borderRadius: AppRadius.chip,
                    ),
                    child: Text(
                      advisory.categoryLabel,
                      style: tt.labelSmall?.copyWith(
                        color: AppColors.cropGreen,
                        fontWeight: FontWeight.w700,
                        fontSize: 9,
                      ),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Read More',
                    style: tt.labelSmall?.copyWith(
                      color: AppColors.cropGreen,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Icon(Icons.arrow_forward_rounded,
                      size: 14, color: AppColors.cropGreen),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                advisory.title,
                style:
                    tt.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                advisory.summary,
                style: tt.bodySmall
                    ?.copyWith(color: cs.onSurfaceVariant),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Shared helpers ────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.message,
    required this.color,
  });

  final IconData icon;
  final String message;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: AppRadius.card,
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        children: [
          Icon(icon, size: 28, color: color.withAlpha(120)),
          const SizedBox(height: AppSpacing.sm),
          Text(
            message,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: cs.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

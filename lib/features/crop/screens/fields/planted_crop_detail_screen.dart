import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/farm_app_bar.dart';
import '../../../../shared/widgets/farm_scaffold.dart';
import '../../../../shared/widgets/loading_shimmer.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/status_chip.dart';
import '../../models/calendar_event.dart';
import '../../models/crop.dart';
import '../../models/crop_expense.dart';
import '../../models/harvest_record.dart';
import '../../models/planting_plan.dart';
import '../../providers/crop_providers.dart';
import '../../widgets/crop_illustration.dart';
import '../../widgets/field_visualization.dart';

// ── Screen ────────────────────────────────────────────────────────────────────

class PlantedCropDetailScreen extends ConsumerWidget {
  const PlantedCropDetailScreen({super.key, required this.planId});

  final String planId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plansAsync = ref.watch(plantingPlansProvider(null));

    return plansAsync.when(
      loading: () => FarmScaffold(
        appBar: FarmAppBar(title: 'Crop Progress'),
        body: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: LoadingShimmer.list(count: 6, itemHeight: 80),
        ),
      ),
      error: (e, _) => FarmScaffold(
        appBar: FarmAppBar(title: 'Crop Progress'),
        body: Center(
          child: Text('Error: $e',
              style: const TextStyle(color: AppColors.error)),
        ),
      ),
      data: (plans) {
        final matches = plans.where((p) => p.id == planId);
        if (matches.isEmpty) {
          return FarmScaffold(
            appBar: FarmAppBar(title: 'Crop Progress'),
            body: const Center(child: Text('Crop not found.')),
          );
        }
        return _PlantedCropView(plan: matches.first);
      },
    );
  }
}

// ── Detail View ───────────────────────────────────────────────────────────────

class _PlantedCropView extends ConsumerWidget {
  const _PlantedCropView({required this.plan});

  final PlantingPlan plan;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cropAsync = ref.watch(cropByIdProvider(plan.cropId));
    final fieldAsync = ref.watch(cropFieldByIdProvider(plan.fieldId));
    final eventsAsync = ref.watch(calendarEventsProvider(plan.fieldId));
    final pestsAsync = ref.watch(pestObservationsProvider(plan.fieldId));
    final seasonsAsync = ref.watch(seasonsProvider(null));
    final harvestAsync = ref.watch(harvestRecordsProvider(plan.fieldId));
    final expensesAsync = ref.watch(cropExpensesProvider(null));

    // Derived yield & cost metrics
    final harvests = (harvestAsync.value ?? [])
        .where((h) => h.planId == plan.id)
        .toList();
    final expenses = (expensesAsync.value ?? [])
        .where((e) => e.planId == plan.id)
        .toList();
    final totalYieldTons =
        harvests.fold<double>(0.0, (s, h) => s + h.actualYieldTons);
    final totalAreaHa =
        harvests.fold<double>(0.0, (s, h) => s + h.areaHarvestedHa);
    final actualYieldTHa =
        totalAreaHa > 0 ? totalYieldTons / totalAreaHa : null;
    final totalCostZar =
        expenses.fold<double>(0.0, (s, e) => s + e.amountZar);
    final costPerTon =
        totalYieldTons > 0 ? totalCostZar / totalYieldTons : null;

    final crop = cropAsync.value;
    final field = fieldAsync.value;
    final seasons = seasonsAsync.value ?? [];
    final seasonMatches = seasons.where((s) => s.id == plan.seasonId);
    final season = seasonMatches.isNotEmpty ? seasonMatches.first : null;

    final cropName = crop?.name ?? plan.cropId;
    final fieldName = field?.name ?? plan.fieldId;

    // Growth progress
    final progress = _growthProgress(plan);
    final currentStage = _currentStage(progress);

    return FarmScaffold(
      body: CustomScrollView(
        slivers: [
          // ── Sliver App Bar — field visualization hero ─────────────────
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            backgroundColor: AppColors.cropGreen,
            foregroundColor: AppColors.onPrimary,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                cropName,
                style: const TextStyle(
                  color: AppColors.onPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                  shadows: [Shadow(color: Colors.black45, blurRadius: 4)],
                ),
              ),
              collapseMode: CollapseMode.pin,
              background: FieldVisualizationWidget(
                cropName: cropName,
                growthProgress: progress,
                height: 240,
                fieldName: fieldName,
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.xxl,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ── Crop illustration + growth stage bar ──────────────────
                Card(
                  shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Live crop illustration
                        CropIllustration(
                          cropName: cropName,
                          growthProgress: progress,
                          size: 110,
                          showSoil: true,
                          showLabel: true,
                        ),
                        const SizedBox(width: AppSpacing.md),
                        // Growth stage bar
                        Expanded(
                          child: GrowthStageBar(
                            progress: progress,
                            cropName: cropName,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // ── Growth Progress Card ───────────────────────────────────
                _GrowthProgressCard(plan: plan, progress: progress,
                    currentStage: currentStage),
                const SizedBox(height: AppSpacing.md),

                // ── Stage Timeline ─────────────────────────────────────────
                _StageTimeline(plan: plan, progress: progress),
                const SizedBox(height: AppSpacing.md),

                // ── Field & Season Info ────────────────────────────────────
                _InfoCard(
                  plan: plan,
                  fieldName: fieldName,
                  fieldHa: field?.sizeHectares,
                  seasonName: season?.name,
                  irrigationType: field?.irrigationLabel,
                ),
                const SizedBox(height: AppSpacing.md),

                // ── Crop Care ──────────────────────────────────────────────
                if (crop != null) ...[
                  _CropCareCard(crop: crop),
                  const SizedBox(height: AppSpacing.md),
                ],

                // ── Yield & Cost Metrics ──────────────────────────────────
                if (harvests.isNotEmpty || expenses.isNotEmpty) ...[
                  _YieldCostCard(
                    targetYieldTHa: plan.targetYieldTHa,
                    actualYieldTHa: actualYieldTHa,
                    totalYieldTons: totalYieldTons,
                    totalCostZar: totalCostZar,
                    costPerTon: costPerTon,
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],

                // ── Upcoming Activities ────────────────────────────────────
                SectionHeader(title: 'Field Activities'),
                const SizedBox(height: AppSpacing.xs),
                eventsAsync.when(
                  loading: () =>
                      LoadingShimmer.list(count: 3, itemHeight: 64),
                  error: (e, _) => _ErrorText(e.toString()),
                  data: (events) {
                    final upcoming = events
                        .where((e) => e.isPending || e.isOverdue)
                        .toList()
                      ..sort((a, b) =>
                          a.scheduledDate.compareTo(b.scheduledDate));
                    if (upcoming.isEmpty) {
                      return _EmptyText('No upcoming activities.');
                    }
                    return Column(
                      children: upcoming
                          .take(6)
                          .map((e) => _ActivityTile(event: e))
                          .toList(),
                    );
                  },
                ),
                const SizedBox(height: AppSpacing.md),

                // ── Pest Watch ─────────────────────────────────────────────
                SectionHeader(title: 'Pest Watch'),
                const SizedBox(height: AppSpacing.xs),
                pestsAsync.when(
                  loading: () =>
                      LoadingShimmer.list(count: 2, itemHeight: 64),
                  error: (e, _) => _ErrorText(e.toString()),
                  data: (pests) {
                    if (pests.isEmpty) {
                      return _EmptyText('No pest observations for this field.');
                    }
                    return Column(
                      children: pests
                          .take(5)
                          .map((p) => _PestTile(pest: p))
                          .toList(),
                    );
                  },
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Growth Logic ──────────────────────────────────────────────────────────────

double _growthProgress(PlantingPlan plan) {
  final start = plan.plannedPlantingDate;
  final end = plan.plannedHarvestDate;
  if (start == null || end == null) return 0.0;
  if (plan.isCompleted) return 1.0;
  final now = DateTime.now();
  if (now.isBefore(start)) return 0.0;
  final total = end.difference(start).inDays;
  if (total <= 0) return 1.0;
  final elapsed = now.difference(start).inDays;
  return (elapsed / total).clamp(0.0, 1.0);
}

class _StageData {
  const _StageData(this.name, this.description, this.icon, this.fromPct, this.toPct);
  final String name;
  final String description;
  final IconData icon;
  final double fromPct;
  final double toPct;
}

const List<_StageData> _growthStages = [
  _StageData('Germination', 'Seeds germinating, first shoots emerging',
      Icons.grass_rounded, 0.0, 0.12),
  _StageData('Seedling', 'Young plants establishing, early root development',
      Icons.spa_outlined, 0.12, 0.28),
  _StageData('Vegetative', 'Rapid leaf & stem growth, canopy development',
      Icons.eco_rounded, 0.28, 0.55),
  _StageData('Flowering', 'Tasseling, heading, and fruit set',
      Icons.local_florist_rounded, 0.55, 0.72),
  _StageData('Grain Fill', 'Kernels and fruits filling out',
      Icons.grain_rounded, 0.72, 0.90),
  _StageData('Maturity', 'Crop reaching maturity, ready for harvest',
      Icons.agriculture_rounded, 0.90, 1.01),
];

_StageData _currentStage(double progress) {
  for (final s in _growthStages) {
    if (progress < s.toPct) return s;
  }
  return _growthStages.last;
}

// ── Growth Progress Card ──────────────────────────────────────────────────────

class _GrowthProgressCard extends StatelessWidget {
  const _GrowthProgressCard({
    required this.plan,
    required this.progress,
    required this.currentStage,
  });

  final PlantingPlan plan;
  final double progress;
  final _StageData currentStage;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final fmt = DateFormat('d MMM yyyy');

    final start = plan.plannedPlantingDate;
    final end = plan.plannedHarvestDate;
    final now = DateTime.now();

    int? daysElapsed;
    int? totalDays;
    int? daysRemaining;

    if (start != null && end != null) {
      totalDays = end.difference(start).inDays;
      daysElapsed = now.difference(start).inDays.clamp(0, totalDays);
      daysRemaining = (end.difference(now).inDays).clamp(0, totalDays);
    }

    final pct = (progress * 100).round();

    return Card(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.cropGreen.withAlpha(26),
                    borderRadius: AppRadius.card,
                  ),
                  child: Icon(currentStage.icon,
                      color: AppColors.cropGreen, size: AppSpacing.iconMd),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        currentStage.name,
                        style: tt.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        currentStage.description,
                        style: tt.bodySmall
                            ?.copyWith(color: cs.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                Text(
                  '$pct%',
                  style: tt.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.cropGreen,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // Progress bar
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 12,
                backgroundColor: cs.surfaceContainerHighest,
                valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.cropGreen),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            // Date range
            Row(
              children: [
                if (start != null) ...[
                  Icon(Icons.eco_rounded,
                      size: 14, color: cs.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Text(
                    fmt.format(start),
                    style: tt.labelSmall
                        ?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ],
                const Spacer(),
                if (daysRemaining != null && daysRemaining > 0) ...[
                  Icon(Icons.timelapse_rounded,
                      size: 14, color: cs.onSurfaceVariant),
                  const SizedBox(width: 4),
                  Text(
                    '$daysRemaining days left',
                    style: tt.labelSmall
                        ?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ],
                const Spacer(),
                if (end != null) ...[
                  Icon(Icons.agriculture_rounded,
                      size: 14, color: AppColors.secondary),
                  const SizedBox(width: 4),
                  Text(
                    fmt.format(end),
                    style: tt.labelSmall?.copyWith(
                        color: AppColors.secondary,
                        fontWeight: FontWeight.w600),
                  ),
                ],
              ],
            ),

            // Day counter
            if (daysElapsed != null && totalDays != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Center(
                child: Text(
                  'Day $daysElapsed of $totalDays',
                  style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Stage Timeline ────────────────────────────────────────────────────────────

class _StageTimeline extends StatelessWidget {
  const _StageTimeline({required this.plan, required this.progress});

  final PlantingPlan plan;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final start = plan.plannedPlantingDate;
    final end = plan.plannedHarvestDate;
    final totalDays = (start != null && end != null)
        ? end.difference(start).inDays
        : null;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Growth Journey',
              style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: AppSpacing.md),
            ..._growthStages.asMap().entries.map((entry) {
              final idx = entry.key;
              final stage = entry.value;
              final isCompleted = progress >= stage.toPct;
              final isCurrent =
                  progress >= stage.fromPct && progress < stage.toPct;
              final isLast = idx == _growthStages.length - 1;

              Color dotColor;
              if (isCompleted || isCurrent) {
                dotColor = AppColors.cropGreen;
              } else {
                dotColor = cs.outlineVariant;
              }

              // Approximate stage start date
              String? stageDate;
              if (start != null && totalDays != null) {
                final stageDayOffset =
                    (stage.fromPct * totalDays).round();
                final stageStart =
                    start.add(Duration(days: stageDayOffset));
                stageDate = DateFormat('d MMM').format(stageStart);
              }

              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Dot + line column
                  SizedBox(
                    width: 24,
                    child: Column(
                      children: [
                        Container(
                          width: isCurrent ? 16 : 12,
                          height: isCurrent ? 16 : 12,
                          decoration: BoxDecoration(
                            color:
                                isCurrent ? AppColors.cropGreen : dotColor,
                            shape: BoxShape.circle,
                            border: isCurrent
                                ? Border.all(
                                    color: AppColors.cropGreen.withAlpha(76),
                                    width: 3,
                                  )
                                : null,
                          ),
                          child: isCompleted
                              ? const Icon(Icons.check,
                                  size: 8, color: Colors.white)
                              : null,
                        ),
                        if (!isLast)
                          Container(
                            width: 2,
                            height: 36,
                            color: isCompleted
                                ? AppColors.cropGreen.withAlpha(76)
                                : cs.outlineVariant,
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  // Content
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                          bottom: isLast ? 0 : AppSpacing.sm),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                stage.name,
                                style: tt.bodyMedium?.copyWith(
                                  fontWeight: isCurrent
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: isCurrent
                                      ? AppColors.cropGreen
                                      : isCompleted
                                          ? cs.onSurface
                                          : cs.onSurfaceVariant,
                                ),
                              ),
                              if (isCurrent) ...[
                                const SizedBox(width: AppSpacing.xs),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color:
                                        AppColors.cropGreen.withAlpha(26),
                                    borderRadius: AppRadius.chip,
                                  ),
                                  child: Text(
                                    'NOW',
                                    style: tt.labelSmall?.copyWith(
                                      color: AppColors.cropGreen,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 9,
                                    ),
                                  ),
                                ),
                              ],
                              if (stageDate != null) ...[
                                const Spacer(),
                                Text(
                                  stageDate,
                                  style: tt.labelSmall?.copyWith(
                                      color: cs.onSurfaceVariant),
                                ),
                              ],
                            ],
                          ),
                          Text(
                            stage.description,
                            style: tt.bodySmall?.copyWith(
                                color: cs.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}

// ── Info Card ─────────────────────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.plan,
    required this.fieldName,
    this.fieldHa,
    this.seasonName,
    this.irrigationType,
  });

  final PlantingPlan plan;
  final String fieldName;
  final double? fieldHa;
  final String? seasonName;
  final String? irrigationType;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Plantation Info',
                style:
                    tt.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: AppSpacing.md),
            _InfoRow(
              icon: Icons.grid_on_rounded,
              label: 'Field',
              value: fieldHa != null
                  ? '$fieldName  (${fieldHa!.toStringAsFixed(1)} ha)'
                  : fieldName,
            ),
            if (seasonName != null) ...[
              const Divider(height: AppSpacing.md),
              _InfoRow(
                icon: Icons.calendar_month_rounded,
                label: 'Season',
                value: seasonName!,
              ),
            ],
            if (irrigationType != null) ...[
              const Divider(height: AppSpacing.md),
              _InfoRow(
                icon: Icons.water_drop_outlined,
                label: 'Irrigation',
                value: irrigationType!,
              ),
            ],
            if (plan.targetYieldTHa != null) ...[
              const Divider(height: AppSpacing.md),
              _InfoRow(
                icon: Icons.trending_up_rounded,
                label: 'Target Yield',
                value: '${plan.targetYieldTHa!.toStringAsFixed(1)} t/ha',
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(
      {required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Row(
      children: [
        Icon(icon, size: AppSpacing.iconSm, color: AppColors.cropGreen),
        const SizedBox(width: AppSpacing.sm),
        Text(label,
            style:
                tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
        const Spacer(),
        Flexible(
          child: Text(
            value,
            style:
                tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
            textAlign: TextAlign.end,
          ),
        ),
      ],
    );
  }
}

// ── Crop Care Card ────────────────────────────────────────────────────────────

class _CropCareCard extends StatelessWidget {
  const _CropCareCard({required this.crop});

  final Crop crop;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    String capitalize(String s) =>
        s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Crop Care — ${crop.name}',
                style:
                    tt.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: AppSpacing.md),

            // Key metrics row
            Row(
              children: [
                _MetricChip(
                  icon: Icons.water_drop_rounded,
                  label: capitalize(crop.waterRequirement),
                  color: AppColors.tertiary,
                ),
                const SizedBox(width: AppSpacing.xs),
                _MetricChip(
                  icon: Icons.thermostat_rounded,
                  label:
                      '${crop.temperatureMinC.toInt()}–${crop.temperatureMaxC.toInt()}°C',
                  color: AppColors.warning,
                ),
                const SizedBox(width: AppSpacing.xs),
                _MetricChip(
                  icon: Icons.schedule_rounded,
                  label:
                      '${crop.maturityDaysMin}–${crop.maturityDaysMax} days',
                  color: AppColors.secondary,
                ),
              ],
            ),

            // Fertilizer NPK
            if (crop.fertilizerNKgHa != null ||
                crop.fertilizerPKgHa != null ||
                crop.fertilizerKKgHa != null) ...[
              const SizedBox(height: AppSpacing.md),
              Text('Fertilizer (kg/ha)',
                  style: tt.labelMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: AppSpacing.xs),
              Row(
                children: [
                  if (crop.fertilizerNKgHa != null)
                    _NpkBadge('N', crop.fertilizerNKgHa!,
                        AppColors.cropGreen),
                  if (crop.fertilizerPKgHa != null) ...[
                    const SizedBox(width: AppSpacing.xs),
                    _NpkBadge('P', crop.fertilizerPKgHa!,
                        AppColors.secondary),
                  ],
                  if (crop.fertilizerKKgHa != null) ...[
                    const SizedBox(width: AppSpacing.xs),
                    _NpkBadge('K', crop.fertilizerKKgHa!,
                        AppColors.tertiary),
                  ],
                ],
              ),
            ],

            // Expected yield
            if (crop.bestYieldTHa != null) ...[
              const Divider(height: AppSpacing.lg),
              _InfoRow(
                icon: Icons.assessment_outlined,
                label: 'Expected Yield',
                value: '${crop.bestYieldTHa!.toStringAsFixed(1)} t/ha',
              ),
            ],

            // Common pests
            if (crop.commonPests.isNotEmpty) ...[
              const Divider(height: AppSpacing.lg),
              Text('Watch for pests',
                  style: tt.labelMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                      fontWeight: FontWeight.w600)),
              const SizedBox(height: AppSpacing.xs),
              Wrap(
                spacing: AppSpacing.xs,
                runSpacing: AppSpacing.xs,
                children: crop.commonPests
                    .map((p) => Chip(
                          label: Text(p,
                              style: const TextStyle(fontSize: 11)),
                          padding: EdgeInsets.zero,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          visualDensity: VisualDensity.compact,
                          backgroundColor:
                              AppColors.errorContainer,
                          side: BorderSide.none,
                          labelStyle: TextStyle(
                              color: AppColors.error, fontSize: 11),
                        ))
                    .toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip(
      {required this.icon, required this.label, required this.color});

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.xs, horizontal: AppSpacing.xs),
        decoration: BoxDecoration(
          color: color.withAlpha(26),
          borderRadius: AppRadius.chip,
          border: Border.all(color: color.withAlpha(51)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: color),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                  fontSize: 11,
                  color: color,
                  fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _NpkBadge extends StatelessWidget {
  const _NpkBadge(this.letter, this.value, this.color);

  final String letter;
  final double value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: AppRadius.chip,
        border: Border.all(color: color.withAlpha(76)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            letter,
            style: TextStyle(
                fontWeight: FontWeight.w800,
                color: color,
                fontSize: 13),
          ),
          const SizedBox(width: 4),
          Text(
            value.toStringAsFixed(0),
            style:
                tt.bodySmall?.copyWith(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

// ── Yield & Cost Card ─────────────────────────────────────────────────────────

class _YieldCostCard extends StatelessWidget {
  const _YieldCostCard({
    required this.targetYieldTHa,
    required this.actualYieldTHa,
    required this.totalYieldTons,
    required this.totalCostZar,
    required this.costPerTon,
  });

  final double? targetYieldTHa;
  final double? actualYieldTHa;
  final double totalYieldTons;
  final double totalCostZar;
  final double? costPerTon;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final currFmt = NumberFormat.currency(
        locale: 'en_ZA', symbol: 'R ', decimalDigits: 0);

    // Yield vs target ratio
    double? yieldRatio;
    if (targetYieldTHa != null &&
        targetYieldTHa! > 0 &&
        actualYieldTHa != null) {
      yieldRatio = (actualYieldTHa! / targetYieldTHa!).clamp(0.0, 1.5);
    }

    final yieldColor = yieldRatio == null
        ? AppColors.onSurfaceVariant
        : yieldRatio >= 1.0
            ? AppColors.success
            : yieldRatio >= 0.8
                ? AppColors.warning
                : AppColors.error;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Performance Metrics',
                style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: AppSpacing.md),

            // Yield vs target row
            if (totalYieldTons > 0) ...[
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.xs),
                    decoration: BoxDecoration(
                      color: AppColors.cropGreen.withAlpha(26),
                      borderRadius: AppRadius.chip,
                    ),
                    child: const Icon(Icons.agriculture_rounded,
                        size: 16, color: AppColors.cropGreen),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Actual Yield',
                            style: tt.labelSmall
                                ?.copyWith(color: cs.onSurfaceVariant)),
                        Text(
                          '${totalYieldTons.toStringAsFixed(1)} t'
                          '${actualYieldTHa != null ? '  ·  ${actualYieldTHa!.toStringAsFixed(1)} t/ha' : ''}',
                          style: tt.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                  if (targetYieldTHa != null) ...[
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Target',
                            style: tt.labelSmall
                                ?.copyWith(color: cs.onSurfaceVariant)),
                        Text(
                          '${targetYieldTHa!.toStringAsFixed(1)} t/ha',
                          style: tt.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ],
                ],
              ),

              // Progress bar vs target
              if (yieldRatio != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: yieldRatio.clamp(0.0, 1.0),
                          minHeight: 8,
                          backgroundColor: cs.surfaceContainerHighest,
                          valueColor: AlwaysStoppedAnimation<Color>(yieldColor),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      '${(yieldRatio * 100).round()}%',
                      style: tt.labelSmall?.copyWith(
                          color: yieldColor, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
              ],
              const Divider(height: AppSpacing.lg),
            ],

            // Cost breakdown
            if (totalCostZar > 0) ...[
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.xs),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withAlpha(26),
                      borderRadius: AppRadius.chip,
                    ),
                    child: const Icon(Icons.payments_rounded,
                        size: 16, color: AppColors.secondary),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Total Cost',
                            style: tt.labelSmall
                                ?.copyWith(color: cs.onSurfaceVariant)),
                        Text(
                          currFmt.format(totalCostZar),
                          style: tt.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                  if (costPerTon != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('Cost / ton',
                            style: tt.labelSmall
                                ?.copyWith(color: cs.onSurfaceVariant)),
                        Text(
                          currFmt.format(costPerTon!),
                          style: tt.bodySmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.secondary,
                          ),
                        ),
                      ],
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

// ── Activity Tile ─────────────────────────────────────────────────────────────

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({required this.event});

  final CalendarEvent event;

  Color get _color =>
      event.isOverdue ? AppColors.error : AppColors.warning;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
        elevation: 0,
        color: cs.surfaceContainerLow,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: 0),
          leading: Icon(_activityIcon(event.activityType),
              color: _color, size: AppSpacing.iconMd),
          title: Text(
            event.activityType.label,
            style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            DateFormat('d MMM yyyy').format(event.scheduledDate),
            style:
                tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
          ),
          trailing: StatusChip(
              label: event.status.toUpperCase(),
              color: _color,
              small: true),
        ),
      ),
    );
  }

  IconData _activityIcon(dynamic type) {
    final label = type.toString().toLowerCase();
    if (label.contains('plant')) return Icons.eco_rounded;
    if (label.contains('harvest')) return Icons.agriculture_rounded;
    if (label.contains('spray') || label.contains('pest')) {
      return Icons.science_rounded;
    }
    if (label.contains('fertiliz')) return Icons.grass_rounded;
    if (label.contains('irrigat')) return Icons.water_drop_rounded;
    return Icons.task_alt_rounded;
  }
}

// ── Pest Tile ─────────────────────────────────────────────────────────────────

class _PestTile extends StatelessWidget {
  const _PestTile({required this.pest});

  final dynamic pest;

  Color _severityColor(String s) => switch (s) {
        'low' => AppColors.success,
        'medium' => AppColors.warning,
        'high' => AppColors.secondary,
        'critical' => AppColors.error,
        _ => AppColors.onSurfaceVariant,
      };

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final color = _severityColor(pest.severity as String);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
        elevation: 0,
        color: cs.surfaceContainerLow,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: 0),
          leading: Icon(Icons.bug_report_outlined,
              color: color, size: AppSpacing.iconMd),
          title: Text(
            pest.pestName as String,
            style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          subtitle: Row(
            children: [
              Text(
                pest.category as String,
                style: tt.bodySmall
                    ?.copyWith(color: cs.onSurfaceVariant),
              ),
              Text(' · ',
                  style: tt.bodySmall
                      ?.copyWith(color: cs.onSurfaceVariant)),
              Text(
                DateFormat('d MMM yyyy')
                    .format(pest.observedDate as DateTime),
                style: tt.bodySmall
                    ?.copyWith(color: cs.onSurfaceVariant),
              ),
            ],
          ),
          trailing: StatusChip(
              label: (pest.severity as String).toUpperCase(),
              color: color,
              small: true),
        ),
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

class _EmptyText extends StatelessWidget {
  const _EmptyText(this.message);
  final String message;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Text(message,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AppColors.onSurfaceVariant)),
      );
}

class _ErrorText extends StatelessWidget {
  const _ErrorText(this.message);
  final String message;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Text('Error: $message',
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: AppColors.error)),
      );
}

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
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/status_chip.dart';
import '../../models/crop_season.dart';
import '../../models/planting_plan.dart';
import '../../providers/crop_providers.dart';

class SeasonDetailScreen extends ConsumerWidget {
  const SeasonDetailScreen({super.key, required this.season});

  final CropSeason season;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final plansAsync    = ref.watch(plantingPlansProvider(null));
    final cropsAsync    = ref.watch(cropsProvider(null));
    final fieldsAsync   = ref.watch(cropFieldsProvider(null));
    final harvestsAsync = ref.watch(harvestRecordsProvider(null));
    final expensesAsync = ref.watch(cropExpensesProvider(null));

    final Map<String, String> cropNames = {
      for (final c in cropsAsync.value ?? []) c.id: c.name,
    };
    final Map<String, String> fieldNames = {
      for (final f in fieldsAsync.value ?? []) f.id: f.name,
    };

    final seasonPlans = (plansAsync.value ?? [])
        .where((p) => p.seasonId == season.id)
        .toList();

    // Harvest & expense totals for this season's plans
    final planIds = seasonPlans.map((p) => p.id).toSet();
    final harvests = (harvestsAsync.value ?? [])
        .where((h) => planIds.contains(h.planId))
        .toList();
    final expenses = (expensesAsync.value ?? [])
        .where((e) => planIds.contains(e.planId))
        .toList();

    final totalYield =
        harvests.fold<double>(0.0, (s, h) => s + h.actualYieldTons);
    final totalCost =
        expenses.fold<double>(0.0, (s, e) => s + e.amountZar);

    final dateFmt     = DateFormat('dd MMM yyyy');
    final currencyFmt =
        NumberFormat.currency(locale: 'en_ZA', symbol: 'R ', decimalDigits: 0);
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    final statusColor = season.isActive
        ? AppColors.success
        : season.isCompleted
            ? AppColors.tertiary
            : AppColors.onSurfaceVariant;

    final duration =
        season.endDate.difference(season.startDate).inDays;
    final elapsed = season.isActive
        ? DateTime.now().difference(season.startDate).inDays.clamp(0, duration)
        : season.isCompleted
            ? duration
            : 0;
    final progress = duration > 0 ? elapsed / duration : 0.0;

    return FarmScaffold(
      body: CustomScrollView(
        slivers: [
          // ── App Bar ─────────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: AppColors.cropGreen,
            foregroundColor: AppColors.onPrimary,
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_rounded),
                tooltip: 'Edit Season',
                onPressed: () =>
                    context.push(AppRoutes.editCropSeason, extra: season),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                season.name,
                style: const TextStyle(
                  color: AppColors.onPrimary,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.cropGreenDark, AppColors.cropGreen],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                        AppSpacing.md, AppSpacing.sm, AppSpacing.md, 48),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        StatusChip(
                          label: season.status.toUpperCase(),
                          color: statusColor,
                          small: true,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          _capitalize(season.seasonType),
                          style: TextStyle(
                            color: AppColors.onPrimary.withAlpha(191),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
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

                // ── Season progress card ─────────────────────────────────
                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.card),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _InfoRow(
                          icon: Icons.calendar_today_outlined,
                          label: 'Start',
                          value: dateFmt.format(season.startDate),
                        ),
                        const Divider(height: AppSpacing.md),
                        _InfoRow(
                          icon: Icons.event_rounded,
                          label: 'End',
                          value: dateFmt.format(season.endDate),
                        ),
                        const Divider(height: AppSpacing.md),
                        _InfoRow(
                          icon: Icons.timelapse_rounded,
                          label: 'Duration',
                          value: '$duration days',
                        ),
                        if (season.isActive) ...[
                          const Divider(height: AppSpacing.md),
                          Row(
                            mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Progress',
                                  style: tt.bodySmall?.copyWith(
                                      color: cs.onSurfaceVariant)),
                              Text(
                                '${(progress * 100).round()}%',
                                style: tt.bodySmall?.copyWith(
                                  color: AppColors.cropGreen,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 8,
                              backgroundColor: cs.outlineVariant,
                              valueColor:
                                  const AlwaysStoppedAnimation<Color>(
                                      AppColors.cropGreen),
                            ),
                          ),
                        ],
                        if (season.notes != null &&
                            season.notes!.isNotEmpty) ...[
                          const Divider(height: AppSpacing.md),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(Icons.notes_rounded,
                                  size: AppSpacing.iconSm,
                                  color: AppColors.onSurfaceVariant),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Text(
                                  season.notes!,
                                  style: tt.bodyMedium?.copyWith(
                                      color: cs.onSurfaceVariant),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // ── KPI row ──────────────────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: _KpiCard(
                        icon: Icons.crop_square_rounded,
                        label: 'Fields',
                        value: seasonPlans
                            .map((p) => p.fieldId)
                            .toSet()
                            .length
                            .toString(),
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: _KpiCard(
                        icon: Icons.spa_rounded,
                        label: 'Crops',
                        value: seasonPlans.length.toString(),
                        color: AppColors.cropGreen,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: _KpiCard(
                        icon: Icons.agriculture_rounded,
                        label: 'Yield (t)',
                        value: totalYield.toStringAsFixed(1),
                        color: AppColors.success,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: _KpiCard(
                        icon: Icons.payments_outlined,
                        label: 'Cost',
                        value: totalCost >= 1000
                            ? 'R${(totalCost / 1000).toStringAsFixed(0)}k'
                            : currencyFmt.format(totalCost),
                        color: AppColors.warning,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),

                // ── Planting Plans ───────────────────────────────────────
                SectionHeader(
                  title: 'Planting Plans',
                  actionLabel: 'Add Plan',
                  onAction: () =>
                      context.push(AppRoutes.addPlantingPlan),
                ),
                const SizedBox(height: AppSpacing.xs),
                if (plansAsync.isLoading)
                  LoadingShimmer.list(count: 3, itemHeight: 72)
                else if (seasonPlans.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.sm),
                    child: Text(
                      'No planting plans for this season yet.',
                      style: tt.bodyMedium
                          ?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  )
                else
                  ...seasonPlans.map(
                    (plan) => _PlanTile(
                      plan: plan,
                      cropName: cropNames[plan.cropId] ?? plan.cropId,
                      fieldName:
                          fieldNames[plan.fieldId] ?? plan.fieldId,
                    ),
                  ),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

// ── Info Row ──────────────────────────────────────────────────────────────────

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Row(
      children: [
        Icon(icon, size: AppSpacing.iconSm, color: AppColors.primary),
        const SizedBox(width: AppSpacing.sm),
        Text(label,
            style:
                tt.bodySmall?.copyWith(color: AppColors.onSurfaceVariant)),
        const Spacer(),
        Text(value,
            style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }
}

// ── KPI Card ──────────────────────────────────────────────────────────────────

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.sm, horizontal: AppSpacing.xs),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: AppRadius.card,
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: AppSpacing.iconSm),
          const SizedBox(height: AppSpacing.xs),
          Text(value,
              style: tt.titleSmall
                  ?.copyWith(fontWeight: FontWeight.w800, color: color)),
          Text(label,
              style: tt.labelSmall
                  ?.copyWith(color: cs.onSurfaceVariant, fontSize: 9)),
        ],
      ),
    );
  }
}

// ── Plan Tile ─────────────────────────────────────────────────────────────────

class _PlanTile extends StatelessWidget {
  const _PlanTile({
    required this.plan,
    required this.cropName,
    required this.fieldName,
  });
  final PlantingPlan plan;
  final String cropName;
  final String fieldName;

  Color _statusColor(String s) => switch (s) {
        'active'    => AppColors.success,
        'completed' => AppColors.tertiary,
        'cancelled' => AppColors.error,
        _           => AppColors.onSurfaceVariant,
      };

  @override
  Widget build(BuildContext context) {
    final tt  = Theme.of(context).textTheme;
    final cs  = Theme.of(context).colorScheme;
    final fmt = DateFormat('d MMM');

    return Card(
      elevation: 0,
      color: cs.surfaceContainerLow,
      shape:
          RoundedRectangleBorder(borderRadius: AppRadius.card),
      margin: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.xs),
        leading: Icon(Icons.spa_rounded,
            color: AppColors.cropGreen, size: AppSpacing.iconMd),
        title: Text(cropName,
            style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600)),
        subtitle: Text(
          '$fieldName'
          '${plan.plannedPlantingDate != null ? '  ·  ${fmt.format(plan.plannedPlantingDate!)}' : ''}',
          style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
        ),
        trailing: StatusChip(
          label: plan.status.toUpperCase(),
          color: _statusColor(plan.status),
          small: true,
        ),
      ),
    );
  }
}

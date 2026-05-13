import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/farm_scaffold.dart';
import '../../../../shared/widgets/loading_shimmer.dart';
import '../../data/crop_repository.dart';
import '../../models/crop_season.dart';
import '../../models/planting_plan.dart';
import '../../providers/crop_providers.dart';

class SeasonPlannerScreen extends ConsumerStatefulWidget {
  const SeasonPlannerScreen({super.key});

  @override
  ConsumerState<SeasonPlannerScreen> createState() =>
      _SeasonPlannerScreenState();
}

class _SeasonPlannerScreenState extends ConsumerState<SeasonPlannerScreen> {
  @override
  Widget build(BuildContext context) {
    final seasonsAsync = ref.watch(seasonsProvider(null));
    final plansAsync = ref.watch(plantingPlansProvider(null));
    final allPlans = plansAsync.value ?? [];

    return FarmScaffold(
      appBar: AppBar(
        title: const Text('Season Planner'),
      ),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_season_planner',
        onPressed: () => context.push(AppRoutes.addCropSeason),
        child: const Icon(Icons.add),
      ),
      body: seasonsAsync.when(
        loading: () => Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: LoadingShimmer.list(count: 5),
        ),
        error: (err, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline,
                  size: AppSpacing.iconXl, color: AppColors.error),
              const SizedBox(height: AppSpacing.sm),
              Text('Failed to load seasons',
                  style: Theme.of(context).textTheme.bodyLarge),
              const SizedBox(height: AppSpacing.xs),
              Text(err.toString(),
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: AppColors.onSurfaceVariant)),
            ],
          ),
        ),
        data: (seasons) {
          if (seasons.isEmpty) {
            return _EmptySeasons(
              onAdd: () => context.push(AppRoutes.addCropSeason),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: seasons.length,
            separatorBuilder: (_, _) =>
                const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              final season = seasons[index];
              final seasonPlans = allPlans
                  .where((p) => p.seasonId == season.id)
                  .toList();
              final fieldCount = seasonPlans.map((p) => p.fieldId).toSet().length;
              final cropCount = seasonPlans.map((p) => p.cropId).toSet().length;
              return _SeasonCard(
                season: season,
                fieldCount: fieldCount,
                cropCount: cropCount,
                onTap: () => _showSeasonDetails(context, season, seasonPlans),
                onEdit: () =>
                    context.push(AppRoutes.editCropSeason, extra: season),
                onDelete: () => _confirmDelete(context, season),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, CropSeason season) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Season'),
        content: Text('Delete "${season.name}"? This cannot be undone.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style:
                FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(cropRepositoryProvider).deleteSeason(season.id);
      ref.invalidate(seasonsProvider);
    }
  }

  void _showSeasonDetails(
    BuildContext context,
    CropSeason season,
    List<PlantingPlan> plans,
  ) {
    final fmt = DateFormat('dd MMM yyyy');
    final fieldCount = plans.map((p) => p.fieldId).toSet().length;
    final cropCount = plans.map((p) => p.cropId).toSet().length;
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.topOnly),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.lg,
            AppSpacing.md,
            AppSpacing.xl,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.outlineVariant,
                    borderRadius: AppRadius.chip,
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(
                season.name,
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: AppSpacing.md),
              _DetailRow(
                icon: Icons.calendar_today_outlined,
                label: 'Start',
                value: fmt.format(season.startDate),
              ),
              const SizedBox(height: AppSpacing.sm),
              _DetailRow(
                icon: Icons.event_outlined,
                label: 'End',
                value: fmt.format(season.endDate),
              ),
              const SizedBox(height: AppSpacing.sm),
              _DetailRow(
                icon: Icons.wb_sunny_outlined,
                label: 'Type',
                value: _seasonTypeLabel(season.seasonType),
              ),
              const SizedBox(height: AppSpacing.sm),
              _DetailRow(
                icon: Icons.grid_on_rounded,
                label: 'Fields',
                value: '$fieldCount field${fieldCount != 1 ? 's' : ''}',
              ),
              const SizedBox(height: AppSpacing.sm),
              _DetailRow(
                icon: Icons.eco_outlined,
                label: 'Crops',
                value: '$cropCount crop${cropCount != 1 ? 's' : ''}',
              ),
              if (season.notes != null && season.notes!.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                _DetailRow(
                  icon: Icons.notes_outlined,
                  label: 'Notes',
                  value: season.notes!,
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

String _seasonTypeLabel(String type) => switch (type) {
      'summer' => 'Summer',
      'winter' => 'Winter',
      'year_round' => 'Year Round',
      _ => type,
    };

class _SeasonCard extends StatelessWidget {
  const _SeasonCard({
    required this.season,
    required this.fieldCount,
    required this.cropCount,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final CropSeason season;
  final int fieldCount;
  final int cropCount;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final fmt = DateFormat('dd MMM yyyy');

    return Card(
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.card),
      child: InkWell(
        borderRadius: AppRadius.card,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      season.name,
                      style: tt.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _StatusChip(status: season.status),
                  const SizedBox(width: AppSpacing.xs),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert,
                        size: AppSpacing.iconSm,
                        color: AppColors.onSurfaceVariant),
                    itemBuilder: (_) => [
                      const PopupMenuItem(
                          value: 'edit',
                          child: ListTile(
                            leading: Icon(Icons.edit_outlined),
                            title: Text('Edit'),
                            dense: true,
                          )),
                      const PopupMenuItem(
                          value: 'delete',
                          child: ListTile(
                            leading:
                                Icon(Icons.delete_outline, color: AppColors.error),
                            title: Text('Delete',
                                style: TextStyle(color: AppColors.error)),
                            dense: true,
                          )),
                    ],
                    onSelected: (v) {
                      if (v == 'edit') onEdit();
                      if (v == 'delete') onDelete();
                    },
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                '${fmt.format(season.startDate)} – ${fmt.format(season.endDate)}',
                style: tt.bodyMedium
                    ?.copyWith(color: AppColors.onSurfaceVariant),
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  _SeasonTypeChip(type: season.seasonType),
                  const Spacer(),
                  if (fieldCount > 0) ...[
                    const Icon(Icons.grid_on_rounded,
                        size: AppSpacing.iconSm,
                        color: AppColors.onSurfaceVariant),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      '$fieldCount field${fieldCount != 1 ? 's' : ''}',
                      style: tt.bodySmall
                          ?.copyWith(color: AppColors.onSurfaceVariant),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    const Icon(Icons.eco_outlined,
                        size: AppSpacing.iconSm,
                        color: AppColors.onSurfaceVariant),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      '$cropCount crop${cropCount != 1 ? 's' : ''}',
                      style: tt.bodySmall
                          ?.copyWith(color: AppColors.onSurfaceVariant),
                    ),
                  ] else
                    Text(
                      'No plans yet',
                      style: tt.bodySmall
                          ?.copyWith(color: AppColors.onSurfaceVariant),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final (label, bg, fg) = switch (status) {
      'active' => (
          'Active',
          AppColors.successContainer,
          AppColors.onSuccessContainer
        ),
      'completed' => (
          'Completed',
          AppColors.surfaceContainerHighest,
          AppColors.onSurfaceVariant
        ),
      _ => (
          'Planned',
          AppColors.tertiaryContainer,
          AppColors.onTertiaryContainer
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadius.chip,
      ),
      child: Text(
        label,
        style: Theme.of(context)
            .textTheme
            .labelSmall
            ?.copyWith(color: fg, fontWeight: FontWeight.w600),
      ),
    );
  }
}

class _SeasonTypeChip extends StatelessWidget {
  const _SeasonTypeChip({required this.type});

  final String type;

  @override
  Widget build(BuildContext context) {
    final label = _seasonTypeLabel(type);
    final icon = switch (type) {
      'summer' => Icons.wb_sunny_outlined,
      'winter' => Icons.ac_unit_outlined,
      _ => Icons.loop_outlined,
    };

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: AppSpacing.iconSm, color: AppColors.secondary),
        const SizedBox(width: AppSpacing.xs),
        Text(
          label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.secondary,
                fontWeight: FontWeight.w600,
              ),
        ),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: AppSpacing.iconMd, color: AppColors.onSurfaceVariant),
        const SizedBox(width: AppSpacing.sm),
        SizedBox(
          width: 72,
          child: Text(
            label,
            style: tt.bodySmall
                ?.copyWith(color: AppColors.onSurfaceVariant),
          ),
        ),
        Expanded(
          child: Text(value, style: tt.bodyMedium),
        ),
      ],
    );
  }
}

class _EmptySeasons extends StatelessWidget {
  const _EmptySeasons({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.calendar_month_outlined,
              size: AppSpacing.iconXl,
              color: AppColors.onSurfaceVariant,
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No Seasons Yet',
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Add your first crop season to start planning.',
              textAlign: TextAlign.center,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: AppSpacing.lg),
            FilledButton.icon(
              onPressed: onAdd,
              icon: const Icon(Icons.add),
              label: const Text('Add Season'),
            ),
          ],
        ),
      ),
    );
  }
}

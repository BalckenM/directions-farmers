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
import '../../models/calendar_event.dart';
import '../../models/crop_field.dart';
import '../../models/pest_observation.dart';
import '../../models/planting_plan.dart';
import '../../providers/crop_providers.dart';
import '../../widgets/crop_illustration.dart';

// ── Screen ────────────────────────────────────────────────────────────────────

class FieldDetailScreen extends ConsumerWidget {
  const FieldDetailScreen({super.key, required this.fieldId});

  final String fieldId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fieldAsync = ref.watch(cropFieldByIdProvider(fieldId));
    final plansAsync = ref.watch(plantingPlansProvider(fieldId));
    final eventsAsync = ref.watch(calendarEventsProvider(fieldId));
    final pestsAsync = ref.watch(pestObservationsProvider(fieldId));
    final cropsAsync = ref.watch(cropsProvider(null));
    final Map<String, String> cropNames = {
      for (final c in cropsAsync.value ?? []) c.id: c.name,
    };

    // Show shimmer while field itself is loading
    if (fieldAsync.isLoading) {
      return FarmScaffold(
        appBar: FarmAppBar(title: 'Field Detail'),
        body: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: LoadingShimmer.list(count: 6, itemHeight: 80),
        ),
      );
    }

    if (fieldAsync.hasError || fieldAsync.value == null) {
      return FarmScaffold(
        appBar: FarmAppBar(title: 'Field Detail'),
        body: Center(
          child: Text(
            fieldAsync.hasError
                ? 'Error: ${fieldAsync.error}'
                : 'Field not found.',
            style: const TextStyle(color: AppColors.error),
          ),
        ),
      );
    }

    final field = fieldAsync.value!;

    return FarmScaffold(
      body: CustomScrollView(
        slivers: [
          // ── Sliver App Bar ──────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 160,
            pinned: true,
            backgroundColor: AppColors.primary,
            foregroundColor: AppColors.onPrimary,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                field.name,
                style: const TextStyle(
                  color: AppColors.onPrimary,
                  fontWeight: FontWeight.w800,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppColors.primaryDark, AppColors.primaryLight],
                  ),
                ),
              ),
            ),
          ),

          // ── Body content ────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: AppSpacing.md),

                // 1. Field Info Card
                _FieldInfoCard(field: field),

                const SizedBox(height: AppSpacing.md),

                // 2. Growing Crops
                SectionHeader(
                  title: 'Growing Crops',
                  actionLabel: 'Add Plan',
                  onAction: () =>
                      context.push(AppRoutes.addCropSeason),
                ),
                const SizedBox(height: AppSpacing.xs),
                plansAsync.when(
                  loading: () => Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md),
                    child: LoadingShimmer.list(count: 2, itemHeight: 72),
                  ),
                  error: (e, _) => _SectionError(message: e.toString()),
                  data: (plans) => plans.isEmpty
                      ? _NoCropsCard(fieldId: fieldId)
                      : Column(
                          children: plans
                              .map((p) => _PlanCard(
                                    plan: p,
                                    cropNames: cropNames,
                                    fieldId: fieldId,
                                  ))
                              .toList(),
                        ),
                ),

                const SizedBox(height: AppSpacing.md),

                // 3. Upcoming Activities
                const SectionHeader(title: 'Upcoming Activities'),
                const SizedBox(height: AppSpacing.xs),
                eventsAsync.when(
                  loading: () => Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md),
                    child: LoadingShimmer.list(count: 3, itemHeight: 64),
                  ),
                  error: (e, _) => _SectionError(message: e.toString()),
                  data: (events) {
                    final now = DateTime.now();
                    final filtered = events
                        .where((e) => e.isPending || e.isOverdue)
                        .toList()
                      ..sort((a, b) =>
                          a.scheduledDate.compareTo(b.scheduledDate));
                    final shown = filtered.take(5).toList();
                    if (shown.isEmpty) {
                      return _SectionEmpty(
                          message: 'No upcoming activities.');
                    }
                    return Column(
                      children: shown
                          .map((e) => _CalendarEventTile(event: e, now: now))
                          .toList(),
                    );
                  },
                ),

                const SizedBox(height: AppSpacing.md),

                // 4. Pest Observations
                SectionHeader(
                  title: 'Pest Observations',
                  actionLabel: 'View All',
                  onAction: () => context.push(AppRoutes.cropPests),
                ),
                const SizedBox(height: AppSpacing.xs),
                pestsAsync.when(
                  loading: () => Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md),
                    child: LoadingShimmer.list(count: 2, itemHeight: 64),
                  ),
                  error: (e, _) => _SectionError(message: e.toString()),
                  data: (pests) {
                    final shown = pests.take(3).toList();
                    if (shown.isEmpty) {
                      return _SectionEmpty(
                          message: 'No pest observations recorded.');
                    }
                    return Column(
                      children: shown
                          .map((p) => _PestObservationTile(pest: p))
                          .toList(),
                    );
                  },
                ),

                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Field Info Card ───────────────────────────────────────────────────────────

class _FieldInfoCard extends StatelessWidget {
  const _FieldInfoCard({required this.field});

  final CropField field;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
        elevation: 1,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _InfoRow(
                icon: Icons.square_foot_rounded,
                label: 'Size',
                value: '${field.sizeHectares.toStringAsFixed(2)} ha',
              ),
              const Divider(height: AppSpacing.md),
              _InfoRow(
                icon: Icons.layers_rounded,
                label: 'Soil Type',
                value: field.soilTypeLabel,
              ),
              const Divider(height: AppSpacing.md),
              _InfoRow(
                icon: Icons.water_drop_outlined,
                label: 'Irrigation',
                value: field.irrigationLabel,
              ),
              if (field.gpsCenter != null) ...[
                const Divider(height: AppSpacing.md),
                _InfoRow(
                  icon: Icons.location_on_outlined,
                  label: 'GPS',
                  value:
                      '${field.gpsCenter!.lat.toStringAsFixed(5)}, '
                      '${field.gpsCenter!.lng.toStringAsFixed(5)}',
                ),
              ],
              if (field.notes != null && field.notes!.isNotEmpty) ...[
                const Divider(height: AppSpacing.md),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.notes_rounded,
                      size: AppSpacing.iconSm,
                      color: AppColors.onSurfaceVariant,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        field.notes!,
                        style: tt.bodyMedium
                            ?.copyWith(color: AppColors.onSurfaceVariant),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
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
        Text(
          label,
          style: tt.bodySmall?.copyWith(color: AppColors.onSurfaceVariant),
        ),
        const Spacer(),
        Text(
          value,
          style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

// ── Plan Card ─────────────────────────────────────────────────────────────────

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.plan,
    required this.cropNames,
    required this.fieldId,
  });

  final PlantingPlan plan;
  final Map<String, String> cropNames;
  final String fieldId;

  Color _statusColor(String status) => switch (status) {
        'active' => AppColors.success,
        'completed' => AppColors.tertiary,
        'cancelled' => AppColors.error,
        _ => AppColors.onSurfaceVariant,
      };

  double _progress() {
    final start = plan.plannedPlantingDate;
    final end = plan.plannedHarvestDate;
    if (start == null || end == null) return 0.0;
    if (plan.isCompleted) return 1.0;
    final now = DateTime.now();
    if (now.isBefore(start)) return 0.0;
    final total = end.difference(start).inDays;
    if (total <= 0) return 1.0;
    return (now.difference(start).inDays / total).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final fmt = DateFormat('d MMM yyyy');
    final progress = _progress();
    final pct = (progress * 100).round();

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
        elevation: 0,
        color: cs.surfaceContainerLow,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => context.push(
              AppRoutes.plantedCropDetailPath(fieldId, plan.id)),
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Crop botanical illustration
                    CropIllustration(
                      cropName: cropNames[plan.cropId] ?? plan.cropId,
                      growthProgress: progress,
                      size: 48,
                      showSoil: false,
                      showLabel: false,
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        cropNames[plan.cropId] ?? plan.cropId,
                        style: tt.bodyMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                    ),
                    StatusChip(
                      label: plan.status.toUpperCase(),
                      color: _statusColor(plan.status),
                      small: true,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    const Icon(Icons.chevron_right_rounded,
                        size: 18, color: AppColors.onSurfaceVariant),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                // Growth progress bar
                if (plan.plannedPlantingDate != null &&
                    plan.plannedHarvestDate != null) ...[
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 6,
                            backgroundColor: cs.outlineVariant,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(
                              _statusColor(plan.status),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        '$pct%',
                        style: tt.labelSmall?.copyWith(
                          color: _statusColor(plan.status),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                ],
                Row(
                  children: [
                    if (plan.plannedPlantingDate != null)
                      _LabelValue(
                        label: 'Plant',
                        value: fmt.format(plan.plannedPlantingDate!),
                      ),
                    if (plan.plannedPlantingDate != null &&
                        plan.plannedHarvestDate != null)
                      const SizedBox(width: AppSpacing.md),
                    if (plan.plannedHarvestDate != null)
                      _LabelValue(
                        label: 'Harvest',
                        value: fmt.format(plan.plannedHarvestDate!),
                      ),
                    if (plan.targetYieldTHa != null) ...[
                      const Spacer(),
                      _LabelValue(
                        label: 'Target',
                        value:
                            '${plan.targetYieldTHa!.toStringAsFixed(1)} t/ha',
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Calendar Event Tile ───────────────────────────────────────────────────────

class _CalendarEventTile extends StatelessWidget {
  const _CalendarEventTile({required this.event, required this.now});

  final CalendarEvent event;
  final DateTime now;

  Color get _statusColor => event.isOverdue ? AppColors.error : AppColors.warning;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final fmt = DateFormat('d MMM yyyy');

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
        elevation: 0,
        color: cs.surfaceContainerLow,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: AppSpacing.xs),
          title: Text(
            event.activityType.label,
            style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            fmt.format(event.scheduledDate),
            style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
          ),
          trailing: StatusChip(
            label: event.status.toUpperCase(),
            color: _statusColor,
            small: true,
          ),
        ),
      ),
    );
  }
}

// ── Pest Observation Tile ─────────────────────────────────────────────────────

class _PestObservationTile extends StatelessWidget {
  const _PestObservationTile({required this.pest});

  final PestObservation pest;

  Color _severityColor(String severity) => switch (severity) {
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
    final fmt = DateFormat('d MMM yyyy');

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
        elevation: 0,
        color: cs.surfaceContainerLow,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: AppSpacing.xs),
          leading: Icon(
            Icons.bug_report_outlined,
            color: _severityColor(pest.severity),
            size: AppSpacing.iconMd,
          ),
          title: Text(
            pest.pestName,
            style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            fmt.format(pest.observedDate),
            style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
          ),
          trailing: StatusChip(
            label: pest.severity.toUpperCase(),
            color: _severityColor(pest.severity),
            small: true,
          ),
        ),
      ),
    );
  }
}

// ── Label + Value helper ──────────────────────────────────────────────────────

class _LabelValue extends StatelessWidget {
  const _LabelValue({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$label: ',
          style: tt.bodySmall?.copyWith(color: AppColors.onSurfaceVariant),
        ),
        Text(value, style: tt.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }
}

// ── Section helpers ───────────────────────────────────────────────────────────

// ── No Crops Card ─────────────────────────────────────────────────────────────
// Shown when a field has no planting plans yet.
// Gives direct access to the crop catalog to choose what to plant.

class _NoCropsCard extends StatelessWidget {
  const _NoCropsCard({required this.fieldId});
  final String fieldId;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLow,
          borderRadius: AppRadius.card,
          border: Border.all(
              color: AppColors.cropGreen.withAlpha(51)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.spa_outlined,
                    color: AppColors.cropGreen.withAlpha(153), size: 20),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'No crops planted yet',
                  style: tt.bodyMedium
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Browse the crop catalog to find the right crop for this '
              'field — check soil type, water requirements, and '
              'planting windows.',
              style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                OutlinedButton.icon(
                  onPressed: () =>
                      context.push(AppRoutes.cropCatalog),
                  icon: const Icon(Icons.menu_book_rounded, size: 16),
                  label: const Text('Browse Crop Catalog'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.cropGreen,
                    side: const BorderSide(color: AppColors.cropGreen),
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs),
                    textStyle: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                OutlinedButton.icon(
                  onPressed: () =>
                      context.push(AppRoutes.addCropSeason),
                  icon: const Icon(Icons.add_rounded, size: 16),
                  label: const Text('Add Plan'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs),
                    textStyle: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Section Empty ─────────────────────────────────────────────────────────────

class _SectionEmpty extends StatelessWidget {
  const _SectionEmpty({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      child: Text(
        message,
        style: tt.bodyMedium?.copyWith(color: AppColors.onSurfaceVariant),
      ),
    );
  }
}

class _SectionError extends StatelessWidget {
  const _SectionError({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      child: Text(
        'Error: $message',
        style: tt.bodySmall?.copyWith(color: AppColors.error),
      ),
    );
  }
}

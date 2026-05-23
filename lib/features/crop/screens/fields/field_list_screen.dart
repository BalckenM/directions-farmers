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
import '../../models/crop_field.dart';
import '../../models/planting_plan.dart';
import '../../providers/crop_providers.dart';
import '../../widgets/crop_illustration.dart';

// ── Screen ────────────────────────────────────────────────────────────────────

class FieldListScreen extends ConsumerWidget {
  const FieldListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fieldsAsync = ref.watch(cropFieldsProvider(null));
    final plansAsync  = ref.watch(plantingPlansProvider(null));
    final cropsAsync  = ref.watch(cropsProvider(null));

    final Map<String, String> cropNames = {
      for (final c in cropsAsync.value ?? []) c.id: c.name,
    };
    // Map fieldId → active planting plans
    final Map<String, List<PlantingPlan>> fieldPlans = {};
    for (final p in (plansAsync.value ?? [])) {
      if (p.isActive) {
        fieldPlans.putIfAbsent(p.fieldId, () => []).add(p);
      }
    }

    return FarmScaffold(
      appBar: const FarmAppBar(title: 'My Fields'),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push(AppRoutes.addCropField),
        tooltip: 'Add Field',
        child: const Icon(Icons.add),
      ),
      body: fieldsAsync.when(
        loading: () => Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: LoadingShimmer.list(count: 5, itemHeight: 96),
        ),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Text(
              'Failed to load fields: $error',
              style: TextStyle(color: AppColors.error),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (fields) {
          if (fields.isEmpty) {
            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(cropFieldsProvider);
                ref.invalidate(plantingPlansProvider);
                await ref.read(cropFieldsProvider(null).future);
              },
              child: ListView(
                children: [
                  _EmptyFieldsState(
                    onAddField: () => context.push(AppRoutes.addCropField),
                  ),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(cropFieldsProvider);
              ref.invalidate(plantingPlansProvider);
              await ref.read(cropFieldsProvider(null).future);
            },
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md,
              ),
              itemCount: fields.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) {
                final field = fields[index];
                return _FieldCard(
                  field: field,
                  activePlans: fieldPlans[field.id] ?? [],
                  cropNames: cropNames,
                  onTap: () =>
                      context.push(AppRoutes.cropFieldDetailPath(field.id)),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

// ── Field Card ────────────────────────────────────────────────────────────────

class _FieldCard extends StatelessWidget {
  const _FieldCard({
    required this.field,
    required this.onTap,
    required this.activePlans,
    required this.cropNames,
  });

  final CropField field;
  final VoidCallback onTap;
  final List<PlantingPlan> activePlans;
  final Map<String, String> cropNames;

  double _planProgress(PlantingPlan plan) {
    final start = plan.plannedPlantingDate;
    final end = plan.plannedHarvestDate;
    if (start == null || end == null) return 0.0;
    final now = DateTime.now();
    if (now.isBefore(start)) return 0.0;
    final total = end.difference(start).inDays;
    if (total <= 0) return 1.0;
    return (now.difference(start).inDays / total).clamp(0.0, 1.0);
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
      elevation: 1,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.card,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Name row + farm chip + trailing arrow
              Row(
                children: [
                  Expanded(
                    child: Text(
                      field.name,
                      style: tt.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _FarmIdChip(farmId: field.farmId),
                  const SizedBox(width: AppSpacing.sm),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: AppSpacing.iconSm,
                    color: cs.onSurfaceVariant,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              // Details row: size, soil type, irrigation type
              Row(
                children: [
                  _IconLabel(
                    icon: Icons.square_foot_rounded,
                    label: '${field.sizeHectares.toStringAsFixed(1)} ha',
                  ),
                  const SizedBox(width: AppSpacing.md),
                  _IconLabel(
                    icon: Icons.layers_rounded,
                    label: field.soilTypeLabel,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  _IconLabel(
                    icon: Icons.water_drop_outlined,
                    label: field.irrigationLabel,
                  ),
                ],
              ),
              // Planted crops row with botanical illustrations
              if (activePlans.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    for (final plan in activePlans.take(4)) ...[
                      CropIllustration(
                        cropName: cropNames[plan.cropId] ?? plan.cropId,
                        growthProgress: _planProgress(plan),
                        size: 36,
                        showSoil: false,
                        showLabel: false,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                    ],
                    Expanded(
                      child: Text(
                        activePlans
                            .map((p) => cropNames[p.cropId] ?? p.cropId)
                            .join(', '),
                        style: tt.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
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

// ── Farm ID Chip ──────────────────────────────────────────────────────────────

class _FarmIdChip extends StatelessWidget {
  const _FarmIdChip({required this.farmId});

  final String farmId;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHighest,
        borderRadius: AppRadius.chip,
        border: Border.all(color: AppColors.outlineVariant),
      ),
      child: Text(
        farmId.length > 8 ? '${farmId.substring(0, 8)}…' : farmId,
        style: tt.labelSmall?.copyWith(
          color: AppColors.onSurfaceVariant,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

// ── Icon + Label helper ────────────────────────────────────────────────────────

class _IconLabel extends StatelessWidget {
  const _IconLabel({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: AppSpacing.iconSm, color: cs.primary),
        const SizedBox(width: AppSpacing.xs),
        Text(
          label,
          style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
        ),
      ],
    );
  }
}

// ── Empty State ────────────────────────────────────────────────────────────────

class _EmptyFieldsState extends StatelessWidget {
  const _EmptyFieldsState({required this.onAddField});

  final VoidCallback onAddField;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.grass_rounded,
              size: AppSpacing.iconXl,
              color: cs.onSurfaceVariant.withAlpha(128),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No fields yet',
              style: tt.titleMedium?.copyWith(
                color: cs.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Add your first crop field to get started.',
              style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.lg),
            ElevatedButton.icon(
              onPressed: onAddField,
              icon: const Icon(Icons.add),
              label: const Text('Add Field'),
            ),
          ],
        ),
      ),
    );
  }
}

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
import '../../models/pest_observation.dart';
import '../../providers/crop_providers.dart';

class PestLogScreen extends ConsumerStatefulWidget {
  const PestLogScreen({super.key});

  @override
  ConsumerState<PestLogScreen> createState() => _PestLogScreenState();
}

class _PestLogScreenState extends ConsumerState<PestLogScreen> {
  String _categoryFilter = 'All';
  bool _highSeverityOnly = false;
  bool _openOnly = false;

  static const _categoryFilters = ['All', 'Pests', 'Diseases', 'Weeds'];

  List<PestObservation> _applyFilters(List<PestObservation> all) {
    return all.where((obs) {
      if (_categoryFilter == 'Pests' && obs.category != 'pest') return false;
      if (_categoryFilter == 'Diseases' && obs.category != 'disease') {
        return false;
      }
      if (_categoryFilter == 'Weeds' && obs.category != 'weed') return false;
      if (_highSeverityOnly &&
          obs.severity != 'high' &&
          obs.severity != 'critical') {
        return false;
      }
      if (_openOnly && !obs.isOpen) return false;
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final observationsAsync = ref.watch(pestObservationsProvider(null));
    final fieldsAsync = ref.watch(cropFieldsProvider(null));
    final Map<String, String> fieldNames = {
      for (final f in fieldsAsync.value ?? []) f.id: f.name,
    };

    return FarmScaffold(
      appBar: AppBar(
        title: const Text('Pest & Disease Log'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
        actions: [
          IconButton(
            onPressed: () => context.push(AppRoutes.addSprayRecord),
            icon: const Icon(Icons.science_rounded),
            tooltip: 'Log Spray',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.addPestObs),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Log Observation'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.onPrimary,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Filter chips ─────────────────────────────────────────────────
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              children: [
                ..._categoryFilters.map(
                  (f) => Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.xs),
                    child: FilterChip(
                      label: Text(f),
                      selected: _categoryFilter == f,
                      onSelected: (_) => setState(() => _categoryFilter = f),
                      selectedColor: AppColors.primaryContainer,
                      checkmarkColor: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                FilterChip(
                  label: const Text('High'),
                  selected: _highSeverityOnly,
                  onSelected: (v) => setState(() => _highSeverityOnly = v),
                  selectedColor: AppColors.errorContainer,
                  checkmarkColor: AppColors.error,
                ),
                const SizedBox(width: AppSpacing.xs),
                FilterChip(
                  label: const Text('Open'),
                  selected: _openOnly,
                  onSelected: (v) => setState(() => _openOnly = v),
                  selectedColor: AppColors.warningContainer,
                  checkmarkColor: AppColors.warning,
                ),
              ],
            ),
          ),

          // ── List ─────────────────────────────────────────────────────────
          Expanded(
            child: observationsAsync.when(
              loading: () => Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: LoadingShimmer.list(count: 4, itemHeight: 100),
              ),
              error: (e, _) => Center(
                child: Text(
                  'Failed to load observations: $e',
                  style: const TextStyle(color: AppColors.error),
                ),
              ),
              data: (all) {
                final filtered = _applyFilters(all);
                if (filtered.isEmpty) {
                  return const Center(
                    child: Text(
                      'No observations match the selected filters.',
                      style: TextStyle(color: AppColors.onSurfaceVariant),
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.xs,
                    AppSpacing.md,
                    AppSpacing.xxl,
                  ),
                  itemCount: filtered.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (context, index) {
                    final obs = filtered[index];
                    return Dismissible(
                      key: ValueKey(obs.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: AppSpacing.lg),
                        decoration: BoxDecoration(
                          color: AppColors.error,
                          borderRadius: AppRadius.card,
                        ),
                        child: const Icon(Icons.delete_rounded,
                            color: Colors.white),
                      ),
                      confirmDismiss: (_) async {
                        return await showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Delete Observation'),
                            content: Text(
                                'Remove "${obs.pestName}"? This cannot be undone.'),
                            actions: [
                              TextButton(
                                  onPressed: () =>
                                      Navigator.pop(ctx, false),
                                  child: const Text('Cancel')),
                              FilledButton(
                                onPressed: () =>
                                    Navigator.pop(ctx, true),
                                style: FilledButton.styleFrom(
                                    backgroundColor: AppColors.error),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        );
                      },
                      onDismissed: (_) async {
                        await ref
                            .read(cropRepositoryProvider)
                            .deletePestObservation(obs.id);
                        ref.invalidate(pestObservationsProvider);
                      },
                      child: GestureDetector(
                        onLongPress: () =>
                            context.push(AppRoutes.editPestObs, extra: obs),
                        child: _ObservationCard(
                          observation: obs,
                          fieldNames: fieldNames,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Observation Card ──────────────────────────────────────────────────────────

class _ObservationCard extends StatelessWidget {
  const _ObservationCard({required this.observation, required this.fieldNames});
  final PestObservation observation;
  final Map<String, String> fieldNames;

  Color get _categoryColor => switch (observation.category) {
        'pest' => AppColors.error,
        'disease' => AppColors.secondaryDark,
        _ => AppColors.success,
      };

  Color get _categoryContainerColor => switch (observation.category) {
        'pest' => AppColors.errorContainer,
        'disease' => AppColors.secondaryContainer,
        _ => AppColors.successContainer,
      };

  String get _categoryLabel => switch (observation.category) {
        'pest' => 'Pest',
        'disease' => 'Disease',
        _ => 'Weed',
      };

  Color get _severityColor => switch (observation.severity) {
        'critical' => AppColors.error,
        'high' => AppColors.secondaryDark,
        'moderate' => AppColors.warning,
        _ => AppColors.tertiary,
      };

  Color get _statusColor => switch (observation.status) {
        'open' => AppColors.warning,
        'treated' => AppColors.tertiary,
        _ => AppColors.success,
      };

  Color get _statusContainerColor => switch (observation.status) {
        'open' => AppColors.warningContainer,
        'treated' => AppColors.tertiaryContainer,
        _ => AppColors.successContainer,
      };

  String get _statusLabel => switch (observation.status) {
        'open' => 'Open',
        'treated' => 'Treated',
        _ => 'Resolved',
      };

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final dateFmt = DateFormat('dd MMM yyyy');

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row
            Row(
              children: [
                Expanded(
                  child: Text(
                    observation.pestName,
                    style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                // Status chip
                _SmallChip(
                  label: _statusLabel,
                  color: _statusColor,
                  containerColor: _statusContainerColor,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),

            // Category + Severity chips
            Wrap(
              spacing: AppSpacing.xs,
              children: [
                _SmallChip(
                  label: _categoryLabel,
                  color: _categoryColor,
                  containerColor: _categoryContainerColor,
                ),
                _SmallChip(
                  label: observation.severity.toUpperCase(),
                  color: _severityColor,
                  containerColor: _severityColor.withAlpha(31),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),

            // Field + Date
            Row(
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: AppSpacing.iconSm,
                  color: AppColors.onSurfaceVariant,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  fieldNames[observation.fieldId] ?? observation.fieldId,
                  style: tt.bodySmall
                      ?.copyWith(color: AppColors.onSurfaceVariant),
                ),
                const Spacer(),
                const Icon(
                  Icons.calendar_today_outlined,
                  size: AppSpacing.iconSm,
                  color: AppColors.onSurfaceVariant,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  dateFmt.format(observation.observedDate),
                  style: tt.bodySmall
                      ?.copyWith(color: AppColors.onSurfaceVariant),
                ),
              ],
            ),

            // Recommended action
            if (observation.recommendedAction != null) ...[
              const SizedBox(height: AppSpacing.sm),
              const Divider(height: 1, color: AppColors.outlineVariant),
              const SizedBox(height: AppSpacing.sm),
              Text(
                observation.recommendedAction!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: tt.bodySmall?.copyWith(
                  color: AppColors.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SmallChip extends StatelessWidget {
  const _SmallChip({
    required this.label,
    required this.color,
    required this.containerColor,
  });

  final String label;
  final Color color;
  final Color containerColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: containerColor,
        borderRadius: AppRadius.chip,
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

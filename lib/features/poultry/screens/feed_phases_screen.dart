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
import '../models/flock.dart';
import '../providers/poultry_providers.dart';
// feedPhaseDeleteProvider is in poultry_providers.dart

class FeedPhasesScreen extends ConsumerWidget {
  const FeedPhasesScreen({super.key, required this.flockId});

  final String flockId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flockAsync = ref.watch(flockDetailProvider(flockId));
    final phasesAsync = ref.watch(flockFeedPhasesProvider(flockId));

    final batchName =
        flockAsync.whenOrNull(data: (f) => f?.batchName) ?? 'Flock';
    final dayOfAge =
        flockAsync.whenOrNull(data: (f) => f?.dayOfAge) ?? 0;

    return FarmScaffold(
      drawer: null,
      appBar: FarmAppBar(
        title: 'Ration Schedule',
        subtitle: batchName,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.addFeedPhase(flockId)),
        backgroundColor: AppColors.poultryColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Phase'),
      ),
      body: phasesAsync.when(
        loading: () => const _LoadingList(),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (phases) {
          if (phases.isEmpty) {
            return _EmptyState(flockId: flockId);
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.pagePaddingHorizontal,
              AppSpacing.md,
              AppSpacing.pagePaddingHorizontal,
              AppSpacing.xxl + 80,
            ),
            itemCount: phases.length,
            separatorBuilder: (_, i) =>
                const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              final phase = phases[index];
              final isActive = phase.isActiveOnDay(dayOfAge);
              return _PhaseCard(phase: phase, isActive: isActive);
            },
          );
        },
      ),
    );
  }
}

// ── Phase Card ────────────────────────────────────────────────────────────────

class _PhaseCard extends ConsumerWidget {
  const _PhaseCard({required this.phase, required this.isActive});

  final FeedPhase phase;
  final bool isActive;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    return Card(
      elevation: isActive ? 2 : 0,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.card,
        side: BorderSide(
          color: isActive
              ? AppColors.poultryColor
              : theme.colorScheme.outlineVariant.withAlpha(80),
          width: isActive ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Day range badge ───────────────────────────────────────────
            Container(
              width: 60,
              padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.xs, horizontal: AppSpacing.xs),
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.poultryColor.withAlpha(25)
                    : theme.colorScheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Day',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: isActive
                          ? AppColors.poultryColor
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    '${phase.dayStart}–${phase.dayEnd}',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: isActive
                          ? AppColors.poultryColor
                          : theme.colorScheme.onSurface,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),

            // ── Phase details ─────────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          phase.phaseName,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete_outline,
                            size: 18,
                            color: theme.colorScheme.error.withAlpha(180)),
                        tooltip: 'Delete phase',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () async {
                          final confirmed = await showDialog<bool>(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('Delete Phase'),
                              content: Text(
                                  'Remove "${phase.phaseName}"? This cannot be undone.'),
                              actions: [
                                TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, false),
                                    child: const Text('Cancel')),
                                TextButton(
                                    onPressed: () =>
                                        Navigator.pop(context, true),
                                    style: TextButton.styleFrom(
                                        foregroundColor:
                                            theme.colorScheme.error),
                                    child: const Text('Delete')),
                              ],
                            ),
                          );
                          if (confirmed == true && context.mounted) {
                            ref
                                .read(feedPhaseDeleteProvider.notifier)
                                .delete(phase.id);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                  content: Text(
                                      '${phase.phaseName} removed')),
                            );
                          }
                        },
                      ),
                      if (isActive) ...[
                        const SizedBox(width: AppSpacing.xs),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.poultryColor,
                            borderRadius:
                                BorderRadius.circular(AppRadius.sm),
                          ),
                          child: Text(
                            'ACTIVE',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  _InfoRow(
                    icon: Icons.category_outlined,
                    label: FeedPhaseType.label(phase.feedType),
                  ),
                  if (phase.feedProduct != null) ...[
                    const SizedBox(height: 2),
                    _InfoRow(
                      icon: Icons.inventory_2_outlined,
                      label: phase.feedProduct!,
                    ),
                  ],
                  if (phase.targetIntakeGPerBirdPerDay != null) ...[
                    const SizedBox(height: 2),
                    _InfoRow(
                      icon: Icons.scale_outlined,
                      label:
                          '${phase.targetIntakeGPerBirdPerDay!.toStringAsFixed(0)} g / bird / day',
                    ),
                  ],
                  if (phase.notes != null && phase.notes!.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      phase.notes!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(icon, size: 14, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 4),
        Expanded(
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

// ── Empty State ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.flockId});

  final String flockId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.restaurant_menu_outlined,
                size: 56, color: Colors.grey.shade400),
            const SizedBox(height: AppSpacing.md),
            Text('No Ration Phases', style: theme.textTheme.titleMedium),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Tap + Add Phase to define the feed schedule for this batch.',
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Loading Skeleton ──────────────────────────────────────────────────────────

class _LoadingList extends StatelessWidget {
  const _LoadingList();

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.pagePaddingHorizontal),
      itemCount: 3,
      separatorBuilder: (_, i) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (ctx, i) => const LoadingShimmer(height: 90),
    );
  }
}

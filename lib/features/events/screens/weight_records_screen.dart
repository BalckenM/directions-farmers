import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_routes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/livestock_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/empty_state.dart';
import '../providers/events_providers.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/farm_app_bar.dart';
import '../../../shared/widgets/farm_scaffold.dart';
import '../../../shared/widgets/loading_shimmer.dart';
import '../models/weight_record.dart';

// ── Screen ───────────────────────────────────────────────────────────────────

class WeightRecordsScreen extends ConsumerWidget {
  const WeightRecordsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordsAsync = ref.watch(weightRecordsProvider);

    return FarmScaffold(
      appBar: const FarmAppBar(
        title: 'Weight Records',
        subtitle: 'Track growth over time',
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.addRecordWeight),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Record Weight'),
      ),
      body: recordsAsync.when(
        loading: () => LoadingShimmer.list(count: 8),
        error: (err, _) => ErrorState(
          message: err.toString(),
          onRetry: () => ref.invalidate(weightRecordsProvider),
        ),
        data: (records) {
          if (records.isEmpty) {
            return const EmptyState(
              title: 'No weight records',
              subtitle: 'Start recording animal weights to track growth.',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.pagePaddingHorizontal,
              AppSpacing.md,
              AppSpacing.pagePaddingHorizontal,
              AppSpacing.xxl,
            ),
            itemCount: records.length,
            itemBuilder: (context, i) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _WeightTile(record: records[i]),
            ),
          );
        },
      ),
    );
  }
}

class _WeightTile extends StatelessWidget {
  const _WeightTile({required this.record});
  final WeightRecord record;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final speciesColor = AppColors.forSpecies(record.animalType);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: AppRadius.card,
        boxShadow: AppShadows.level1,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: speciesColor.withAlpha(30),
              borderRadius: AppRadius.button,
            ),
            child: Icon(
              Icons.monitor_weight_rounded,
              color: speciesColor,
              size: 22,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record.animalId,
                  style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                Row(
                  children: [
                    Text(
                      LivestockConstants.displayName(record.animalType),
                      style: tt.labelSmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      record.weighDate,
                      style: tt.labelSmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                if (record.adgSinceLastKg != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'ADG: ${record.adgSinceLastKg!.toStringAsFixed(2)} kg/day',
                    style: tt.labelSmall?.copyWith(
                      color: record.adgSinceLastKg! > 0
                          ? AppColors.success
                          : AppColors.error,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${record.weightKg.toStringAsFixed(1)} kg',
                style: tt.titleMedium?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (record.bodyConditionScore != null)
                Text(
                  'BCS ${record.bodyConditionScore}',
                  style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

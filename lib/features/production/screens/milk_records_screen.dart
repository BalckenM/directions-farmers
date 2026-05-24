import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/router/app_routes.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../providers/production_providers.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/farm_app_bar.dart';
import '../../../shared/widgets/farm_scaffold.dart';
import '../../../shared/widgets/loading_shimmer.dart';
import '../models/milk_record.dart';

// ── Provider ─────────────────────────────────────────────────────────────────

final milkRecordsProvider =
    FutureProvider.autoDispose<List<MilkRecord>>((ref) =>
        ref.watch(productionRepositoryProvider).getMilkRecords());

// ── Screen ───────────────────────────────────────────────────────────────────

class MilkRecordsScreen extends ConsumerWidget {
  const MilkRecordsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordsAsync = ref.watch(milkRecordsProvider);

    return FarmScaffold(
      appBar: const FarmAppBar(
        title: 'Milk Records',
        subtitle: 'Daily yield tracking',
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.addRecordMilk),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Record Milking'),
      ),
      body: recordsAsync.when(
        loading: () => LoadingShimmer.list(count: 8),
        error: (err, _) => ErrorState(
          message: err.toString(),
          onRetry: () => ref.invalidate(milkRecordsProvider),
        ),
        data: (records) {
          if (records.isEmpty) {
            return const EmptyState(
              title: 'No milk records',
              subtitle: 'Start recording milk sessions here.',
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
              child: _MilkTile(record: records[i]),
            ),
          );
        },
      ),
    );
  }
}

class _MilkTile extends StatelessWidget {
  const _MilkTile({required this.record});
  final MilkRecord record;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

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
              color: AppColors.tertiary.withAlpha(30),
              borderRadius: AppRadius.button,
            ),
            child: const Icon(Icons.water_drop_rounded,
                color: AppColors.tertiary, size: 22),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(record.animalId,
                    style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
                Text(
                  '${record.sessionDate} · ${record.session}',
                  style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                ),
                if (record.fatPct != null || record.proteinPct != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    [
                      if (record.fatPct != null) 'Fat: ${record.fatPct!.toStringAsFixed(1)}%',
                      if (record.proteinPct != null)
                        'Protein: ${record.proteinPct!.toStringAsFixed(1)}%',
                    ].join(' · '),
                    style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ],
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${record.yieldLitres.toStringAsFixed(1)} L',
                style: tt.titleMedium?.copyWith(
                  color: AppColors.tertiary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (record.sccCellsPerMl != null)
                Text(
                  record.qualityIndicator,
                  style: tt.labelSmall?.copyWith(
                    color: record.qualityColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}


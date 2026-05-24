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
import '../models/egg_record.dart';

// ── Provider ─────────────────────────────────────────────────────────────────

final eggRecordsProvider =
    FutureProvider.autoDispose<List<EggRecord>>((ref) =>
        ref.watch(productionRepositoryProvider).getEggRecords());

// ── Screen ───────────────────────────────────────────────────────────────────

class EggRecordsScreen extends ConsumerWidget {
  const EggRecordsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordsAsync = ref.watch(eggRecordsProvider);

    return FarmScaffold(
      appBar: const FarmAppBar(
        title: 'Egg Records',
        subtitle: 'Daily collection tracking',
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.addRecordEggs),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Record Collection'),
      ),
      body: recordsAsync.when(
        loading: () => LoadingShimmer.list(count: 8),
        error: (err, _) => ErrorState(
          message: err.toString(),
          onRetry: () => ref.invalidate(eggRecordsProvider),
        ),
        data: (records) {
          if (records.isEmpty) {
            return const EmptyState(
              title: 'No egg records',
              subtitle: 'Start recording egg collections here.',
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
              child: _EggTile(record: records[i]),
            ),
          );
        },
      ),
    );
  }
}

class _EggTile extends StatelessWidget {
  const _EggTile({required this.record});
  final EggRecord record;

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
              color: AppColors.secondary.withAlpha(30),
              borderRadius: AppRadius.button,
            ),
            child: const Icon(Icons.egg_rounded,
                color: AppColors.secondary, size: 22),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(record.flockId,
                    style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
                Text(
                  '${record.collectionDate} · ${record.collectionSession}',
                  style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                ),
                if (record.eggsBroken != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Breakage: ${record.breakageRate.toStringAsFixed(1)}%',
                    style: tt.labelSmall?.copyWith(
                      color: record.breakageRate > 2
                          ? AppColors.error
                          : cs.onSurfaceVariant,
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
                '${record.eggsCollected}',
                style: tt.titleMedium?.copyWith(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text('eggs',
                  style: tt.labelSmall
                      ?.copyWith(color: cs.onSurfaceVariant)),
            ],
          ),
        ],
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../data/production_repository.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/farm_app_bar.dart';
import '../../../shared/widgets/farm_scaffold.dart';
import '../../../shared/widgets/loading_shimmer.dart';
import '../models/wool_record.dart';

// ── Provider ─────────────────────────────────────────────────────────────────

final woolRecordsProvider =
    FutureProvider.autoDispose<List<WoolRecord>>((ref) =>
        ref.watch(productionRepositoryProvider).getWoolRecords());

// ── Screen ───────────────────────────────────────────────────────────────────

class WoolRecordsScreen extends ConsumerWidget {
  const WoolRecordsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordsAsync = ref.watch(woolRecordsProvider);

    return FarmScaffold(
      appBar: const FarmAppBar(
        title: 'Wool & Mohair Records',
        subtitle: 'Shearing records & grading',
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.addRecordWool),
        icon: const Icon(Icons.content_cut_rounded),
        label: const Text('Record Shearing'),
      ),
      body: recordsAsync.when(
        loading: () => LoadingShimmer.list(count: 6),
        error: (err, _) => ErrorState(
          message: err.toString(),
          onRetry: () => ref.invalidate(woolRecordsProvider),
        ),
        data: (records) {
          if (records.isEmpty) {
            return const EmptyState(
              title: 'No shearing records',
              subtitle: 'Record wool or mohair shearing results here.',
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
              child: _WoolTile(record: records[i]),
            ),
          );
        },
      ),
    );
  }
}

// ── Tile ─────────────────────────────────────────────────────────────────────

class _WoolTile extends StatelessWidget {
  const _WoolTile({required this.record});

  final WoolRecord record;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isMohair = record.isMohair;
    final tileColor = isMohair
        ? AppColors.tertiaryContainer
        : AppColors.secondaryContainer;
    final chipColor = isMohair
        ? AppColors.tertiary
        : AppColors.secondary;

    return Card(
      elevation: 0,
      color: tileColor,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.card,
        side: BorderSide(
          color: theme.colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        record.shearingDate,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        record.animalId != null
                            ? 'Animal: ${record.animalId}'
                            : 'Group shear · ${record.animalCount ?? 0} animals',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: chipColor,
                    borderRadius: AppRadius.chip,
                  ),
                  child: Text(
                    isMohair ? 'Mohair' : 'Wool',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: 4,
              children: [
                _MetricChip(
                  label: '${record.greasyFleeceWeightKg.toStringAsFixed(1)} kg GFW',
                  icon: Icons.scale_rounded,
                ),
                if (record.woolMicron != null)
                  _MetricChip(
                    label: record.displayMicron,
                    icon: Icons.blur_on_rounded,
                  ),
                if (record.colorGrade != null)
                  _MetricChip(
                    label: 'Grade ${record.displayColorGrade}',
                    icon: Icons.grade_rounded,
                  ),
                if (record.pricePerKgZar != null)
                  _MetricChip(
                    label: 'R${record.pricePerKgZar!.toStringAsFixed(0)}/kg',
                    icon: Icons.payments_rounded,
                  ),
              ],
            ),
            if (record.estimatedValueZar != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Estimated value: R${record.estimatedValueZar!.toStringAsFixed(0)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            if (record.notes != null && record.notes!.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(
                record.notes!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: AppRadius.chip,
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}

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
import '../../../../shared/widgets/section_header.dart';
import '../../data/crop_repository.dart';
import '../../models/harvest_record.dart';
import '../../providers/crop_providers.dart';

class HarvestLogScreen extends ConsumerStatefulWidget {
  const HarvestLogScreen({super.key});

  @override
  ConsumerState<HarvestLogScreen> createState() => _HarvestLogScreenState();
}

class _HarvestLogScreenState extends ConsumerState<HarvestLogScreen> {
  @override
  Widget build(BuildContext context) {
    final harvestAsync = ref.watch(harvestRecordsProvider(null));
    final cropsAsync = ref.watch(cropsProvider(null));
    final fieldsAsync = ref.watch(cropFieldsProvider(null));
    final cropNames = <String, String>{for (final c in cropsAsync.value ?? []) c.id: c.name};
    final fieldNames = <String, String>{for (final f in fieldsAsync.value ?? []) f.id: f.name};

    return FarmScaffold(
      appBar: AppBar(
        title: const Text('Harvest Records'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.addCropHarvest),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Record'),
      ),
      body: harvestAsync.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(AppSpacing.md),
          child: LoadingShimmer(height: 140),
        ),
        error: (e, _) => Center(
          child: Text(
            'Failed to load harvest records: $e',
            style: const TextStyle(color: AppColors.error),
          ),
        ),
        data: (records) {
          final totalYield = records.fold<double>(
            0.0,
            (sum, r) => sum + r.actualYieldTons,
          );
          final avgYield = records.isEmpty
              ? 0.0
              : records.fold<double>(0.0, (sum, r) => sum + r.yieldTHa) /
                  records.length;
          final seasons = records.map((r) => r.planId).toSet().length;

          return CustomScrollView(
            slivers: [
              // ── Summary card ───────────────────────────────────────────
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: _SummaryCard(
                    totalYield: totalYield,
                    avgYield: avgYield,
                    seasons: seasons,
                  ),
                ),
              ),

              // ── Records header ─────────────────────────────────────────
              const SliverToBoxAdapter(
                child: SectionHeader(title: 'Harvest Records'),
              ),

              // ── Records list ───────────────────────────────────────────
              if (records.isEmpty)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.md),
                    child: Text(
                      'No harvest records yet.',
                      style: TextStyle(color: AppColors.onSurfaceVariant),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.xs,
                    AppSpacing.md,
                    AppSpacing.xxl,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final record = records[index];
                        return Padding(
                          padding:
                              const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: Dismissible(
                            key: ValueKey(record.id),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.only(
                                  right: AppSpacing.lg),
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
                                  title: const Text('Delete Record'),
                                  content: const Text(
                                      'Delete this harvest record? This cannot be undone.'),
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
                                  .deleteHarvestRecord(record.id);
                              ref.invalidate(harvestRecordsProvider);
                            },
                            child: GestureDetector(
                              onLongPress: () => context.push(
                                  AppRoutes.editHarvestRecord,
                                  extra: record),
                              child: _HarvestCard(
                                record: record,
                                cropNames: cropNames,
                                fieldNames: fieldNames,
                              ),
                            ),
                          ),
                        );
                      },
                      childCount: records.length,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

// ── Summary Card ─────────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.totalYield,
    required this.avgYield,
    required this.seasons,
  });

  final double totalYield;
  final double avgYield;
  final int seasons;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryDark, AppColors.primary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadius.card,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withAlpha(76),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _StatItem(
              label: 'Total Harvested',
              value: '${totalYield.toStringAsFixed(1)} t',
              tt: tt,
            ),
          ),
          _Divider(),
          Expanded(
            child: _StatItem(
              label: 'Avg Yield',
              value: '${avgYield.toStringAsFixed(1)} t/ha',
              tt: tt,
            ),
          ),
          _Divider(),
          Expanded(
            child: _StatItem(
              label: 'Seasons',
              value: '$seasons',
              tt: tt,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.label,
    required this.value,
    required this.tt,
  });

  final String label;
  final String value;
  final TextTheme tt;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: tt.titleLarge?.copyWith(
            color: AppColors.onPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          label,
          style: tt.labelSmall?.copyWith(
            color: AppColors.onPrimary.withAlpha(191),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 40,
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      color: AppColors.onPrimary.withAlpha(64),
    );
  }
}

// ── Harvest Card ──────────────────────────────────────────────────────────────

class _HarvestCard extends StatelessWidget {
  const _HarvestCard({
    required this.record,
    required this.cropNames,
    required this.fieldNames,
  });
  final HarvestRecord record;
  final Map<String, String> cropNames;
  final Map<String, String> fieldNames;

  Color _gradeColor(String? grade) => switch (grade?.toLowerCase()) {
        'a' || 'premium' || 'grade a' => AppColors.success,
        'b' || 'grade b' || 'good' => AppColors.tertiary,
        'c' || 'grade c' || 'average' => AppColors.warning,
        _ => AppColors.onSurfaceVariant,
      };

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final dateFmt = DateFormat('dd MMM yyyy');

    // For the progress bar: use yieldTHa as a proxy; cap at 10 t/ha for display
    const maxYield = 10.0;
    final progress = (record.yieldTHa / maxYield).clamp(0.0, 1.0);

    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        cropNames[record.cropId] ?? record.cropId,
                        style: tt.titleSmall
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        fieldNames[record.fieldId] ?? record.fieldId,
                        style: tt.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                // Yield t/ha
                Text(
                  '${record.yieldTHa.toStringAsFixed(1)} t/ha',
                  style: tt.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),

            // Date
            Row(
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: AppSpacing.iconSm,
                  color: cs.onSurfaceVariant,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  dateFmt.format(record.harvestDate),
                  style: tt.bodySmall
                      ?.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),

            // Yield progress bar (actual vs planned: visual only)
            Row(
              children: [
                Text(
                  'Yield',
                  style: tt.labelSmall
                      ?.copyWith(color: cs.onSurfaceVariant),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: ClipRRect(
                    borderRadius: AppRadius.chip,
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: AppColors.surfaceContainerHighest,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.primary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  '${record.actualYieldTons.toStringAsFixed(1)} t',
                  style: tt.labelSmall
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),

            // Chips row
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                if (record.qualityGrade != null)
                  _Chip(
                    label: 'Grade ${record.qualityGrade}',
                    color: _gradeColor(record.qualityGrade),
                  ),
                if (record.moisturePercent != null)
                  _Chip(
                    label:
                        '${record.moisturePercent!.toStringAsFixed(1)}% moisture',
                    color: AppColors.tertiary,
                  ),
              ],
            ),

            // Losses
            if (record.lossesTons != null && record.lossesTons! > 0) ...[
              const SizedBox(height: AppSpacing.sm),
              const Divider(height: 1, color: AppColors.outlineVariant),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    size: AppSpacing.iconSm,
                    color: AppColors.error,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      '${record.lossesTons!.toStringAsFixed(1)} tons lost'
                      '${record.lossReason != null ? ' — ${record.lossReason}' : ''}',
                      style: tt.bodySmall?.copyWith(
                        color: AppColors.error,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: color.withAlpha(31),
        borderRadius: AppRadius.chip,
        border: Border.all(color: color.withAlpha(76)),
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

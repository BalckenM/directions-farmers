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
import '../../models/spray_record.dart';
import '../../providers/crop_providers.dart';

class SprayListScreen extends ConsumerWidget {
  const SprayListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spraysAsync = ref.watch(sprayRecordsProvider(null));
    final fieldsAsync = ref.watch(cropFieldsProvider(null));
    final fieldNames = <String, String>{
      for (final f in fieldsAsync.value ?? []) f.id: f.name,
    };

    return FarmScaffold(
      appBar: const FarmAppBar(title: 'Spray Records'),
      floatingActionButton: FloatingActionButton(
        heroTag: 'fab_spray_list',
        onPressed: () => context.push(AppRoutes.addSprayRecord),
        tooltip: 'Log Spray',
        child: const Icon(Icons.add),
      ),
      body: spraysAsync.when(
        loading: () => Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: LoadingShimmer.list(count: 5, itemHeight: 96),
        ),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Text(
              'Failed to load spray records: $e',
              style: const TextStyle(color: AppColors.error),
              textAlign: TextAlign.center,
            ),
          ),
        ),
        data: (sprays) {
          if (sprays.isEmpty) {
            return RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(sprayRecordsProvider);
                await ref.read(sprayRecordsProvider(null).future);
              },
              child: ListView(
                children: const [_EmptySprayState()],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(sprayRecordsProvider);
              await ref.read(sprayRecordsProvider(null).future);
            },
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md,
              ),
              itemCount: sprays.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, index) => _SprayCard(
                spray: sprays[index],
                fieldName: fieldNames[sprays[index].fieldId],
                onDelete: () => _confirmDelete(context, ref, sprays[index]),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, WidgetRef ref, SprayRecord spray) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Spray Record'),
        content: Text(
            'Delete the spray record for "${spray.productName}"? This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(cropRepositoryProvider).deleteSprayRecord(spray.id);
      ref.invalidate(sprayRecordsProvider);
    }
  }
}

// ── Spray Card ────────────────────────────────────────────────────────────────

class _SprayCard extends StatelessWidget {
  const _SprayCard({
    required this.spray,
    required this.fieldName,
    required this.onDelete,
  });

  final SprayRecord spray;
  final String? fieldName;
  final VoidCallback onDelete;

  bool get _withholdingActive =>
      DateTime.now().isBefore(spray.reEntryDate);

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final fmt = DateFormat('dd MMM yyyy');

    return Card(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
      elevation: 1,
      child: InkWell(
        onTap: () => context.push(AppRoutes.sprayDetail, extra: spray),
        borderRadius: AppRadius.card,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Icon
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.xs),
                    decoration: BoxDecoration(
                      color: AppColors.tertiaryContainer,
                      borderRadius: AppRadius.chip,
                    ),
                    child: const Icon(
                      Icons.science_outlined,
                      size: AppSpacing.iconMd,
                      color: AppColors.onTertiaryContainer,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          spray.productName,
                          style: tt.titleSmall
                              ?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        if (fieldName != null)
                          Text(
                            fieldName!,
                            style: tt.bodySmall
                                ?.copyWith(color: cs.onSurfaceVariant),
                          ),
                      ],
                    ),
                  ),
                  // Withholding status chip
                  if (_withholdingActive)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
                      decoration: BoxDecoration(
                        color: AppColors.warningContainer,
                        borderRadius: AppRadius.chip,
                      ),
                      child: Text(
                        'PHI Active',
                        style: tt.labelSmall?.copyWith(
                            color: AppColors.onWarningContainer,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  const SizedBox(width: AppSpacing.xs),
                  // More menu
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert,
                        size: AppSpacing.iconSm,
                        color: cs.onSurfaceVariant),
                    onSelected: (v) {
                      if (v == 'edit') {
                        context.push(AppRoutes.editSprayRecord, extra: spray);
                      } else if (v == 'delete') {
                        onDelete();
                      }
                    },
                    itemBuilder: (_) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: ListTile(
                          leading: Icon(Icons.edit_outlined),
                          title: Text('Edit'),
                          dense: true,
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: ListTile(
                          leading: Icon(Icons.delete_outline,
                              color: AppColors.error),
                          title: Text('Delete',
                              style: TextStyle(color: AppColors.error)),
                          dense: true,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              // Details row
              Row(
                children: [
                  _Detail(
                    icon: Icons.calendar_today_outlined,
                    label: fmt.format(spray.sprayDate),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  _Detail(
                    icon: Icons.square_foot_rounded,
                    label: '${spray.areaSprayedHa.toStringAsFixed(1)} ha',
                  ),
                  const SizedBox(width: AppSpacing.md),
                  _Detail(
                    icon: Icons.opacity_outlined,
                    label: '${spray.dosagePerHa.toStringAsFixed(1)} L/ha',
                  ),
                ],
              ),
              // Withholding / re-entry dates
              const SizedBox(height: AppSpacing.xs),
              Row(
                children: [
                  Icon(Icons.timer_outlined,
                      size: AppSpacing.iconSm,
                      color: _withholdingActive
                          ? AppColors.warning
                          : cs.onSurfaceVariant),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    'Re-entry: ${fmt.format(spray.reEntryDate)}  '
                    '(${spray.withholdingDays}d PHI)',
                    style: tt.bodySmall?.copyWith(
                      color: _withholdingActive
                          ? AppColors.warning
                          : cs.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              if (spray.applicatorName != null) ...[
                const SizedBox(height: AppSpacing.xs),
                Row(
                  children: [
                    Icon(Icons.person_outline,
                        size: AppSpacing.iconSm,
                        color: cs.onSurfaceVariant),
                    const SizedBox(width: AppSpacing.xs),
                    Text(
                      spray.applicatorName!,
                      style: tt.bodySmall
                          ?.copyWith(color: cs.onSurfaceVariant),
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

// ── Detail row helper ─────────────────────────────────────────────────────────

class _Detail extends StatelessWidget {
  const _Detail({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: AppSpacing.iconSm, color: cs.onSurfaceVariant),
        const SizedBox(width: AppSpacing.xs),
        Text(label,
            style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
      ],
    );
  }
}

// ── Empty State ───────────────────────────────────────────────────────────────

class _EmptySprayState extends StatelessWidget {
  const _EmptySprayState();

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
            Icon(Icons.science_outlined,
                size: AppSpacing.iconXl,
                color: cs.onSurfaceVariant.withAlpha(128)),
            const SizedBox(height: AppSpacing.md),
            Text(
              'No spray records yet',
              style: tt.titleMedium?.copyWith(
                  color: cs.onSurfaceVariant, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Log your first spray application to track chemical use and withholding periods.',
              style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

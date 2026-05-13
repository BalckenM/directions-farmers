import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/farm_scaffold.dart';
import '../../../../shared/widgets/status_chip.dart';
import '../../models/harvest_record.dart';
import '../../providers/crop_providers.dart';

class HarvestDetailScreen extends ConsumerWidget {
  const HarvestDetailScreen({super.key, required this.record});

  final HarvestRecord record;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cropsAsync  = ref.watch(cropsProvider(null));
    final fieldsAsync = ref.watch(cropFieldsProvider(null));

    final cropName = (cropsAsync.value ?? [])
        .where((c) => c.id == record.cropId)
        .map((c) => c.name)
        .firstOrNull ?? record.cropId;
    final fieldName = (fieldsAsync.value ?? [])
        .where((f) => f.id == record.fieldId)
        .map((f) => f.name)
        .firstOrNull ?? record.fieldId;

    final dateFmt     = DateFormat('dd MMM yyyy');
    final currencyFmt =
        NumberFormat.currency(locale: 'en_ZA', symbol: 'R ', decimalDigits: 0);
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    final gradeColor = _gradeColor(record.qualityGrade);
    final lossPercent = record.actualYieldTons > 0 && record.lossesTons != null
        ? record.lossesTons! / (record.actualYieldTons + record.lossesTons!) * 100
        : null;

    return FarmScaffold(
      body: CustomScrollView(
        slivers: [
          // ── App Bar ───────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 140,
            pinned: true,
            backgroundColor: AppColors.success,
            foregroundColor: AppColors.onPrimary,
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_rounded),
                tooltip: 'Edit',
                onPressed: () =>
                    context.push(AppRoutes.editHarvestRecord, extra: record),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                cropName,
                style: const TextStyle(
                    color: AppColors.onPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 15),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF2E7D32), AppColors.success],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                        AppSpacing.md, AppSpacing.sm, AppSpacing.md, 48),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Icon(Icons.agriculture_rounded,
                            color: AppColors.onPrimary, size: 20),
                        const SizedBox(width: AppSpacing.xs),
                        Text(fieldName,
                            style: TextStyle(
                                color: AppColors.onPrimary.withAlpha(204),
                                fontSize: 12)),
                        if (record.qualityGrade != null) ...[
                          const SizedBox(width: AppSpacing.sm),
                          StatusChip(
                              label: 'Grade ${record.qualityGrade}',
                              color: gradeColor,
                              small: true),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          SliverPadding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.xxl),
            sliver: SliverList(
              delegate: SliverChildListDelegate([

                // ── Yield KPIs ───────────────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: _KpiCard(
                        icon: Icons.scale_rounded,
                        label: 'Yield',
                        value:
                            '${record.actualYieldTons.toStringAsFixed(1)} t',
                        color: AppColors.success,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: _KpiCard(
                        icon: Icons.crop_square_rounded,
                        label: 'Area',
                        value:
                            '${record.areaHarvestedHa.toStringAsFixed(1)} ha',
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: _KpiCard(
                        icon: Icons.trending_up_rounded,
                        label: 'Yield/ha',
                        value: '${record.yieldTHa.toStringAsFixed(1)} t/ha',
                        color: AppColors.tertiary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),

                // ── Details card ─────────────────────────────────────────
                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.card),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      children: [
                        _Row(
                          icon: Icons.calendar_today_outlined,
                          label: 'Harvest Date',
                          value: dateFmt.format(record.harvestDate),
                        ),
                        const Divider(height: AppSpacing.md),
                        _Row(
                          icon: Icons.spa_rounded,
                          label: 'Crop',
                          value: cropName,
                        ),
                        const Divider(height: AppSpacing.md),
                        _Row(
                          icon: Icons.crop_square_rounded,
                          label: 'Field',
                          value: fieldName,
                        ),
                        if (record.qualityGrade != null) ...[
                          const Divider(height: AppSpacing.md),
                          _Row(
                            icon: Icons.verified_rounded,
                            label: 'Quality Grade',
                            value: record.qualityGrade!,
                            valueColor: gradeColor,
                          ),
                        ],
                        if (record.moisturePercent != null) ...[
                          const Divider(height: AppSpacing.md),
                          _Row(
                            icon: Icons.water_drop_outlined,
                            label: 'Moisture',
                            value:
                                '${record.moisturePercent!.toStringAsFixed(1)}%',
                          ),
                        ],
                        if (record.storageLocation != null) ...[
                          const Divider(height: AppSpacing.md),
                          _Row(
                            icon: Icons.warehouse_rounded,
                            label: 'Storage',
                            value: record.storageLocation!,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // ── Losses card ──────────────────────────────────────────
                if (record.lossesTons != null) ...[
                  Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.card),
                    color: AppColors.error.withAlpha(12),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.warning_amber_rounded,
                                  color: AppColors.error,
                                  size: AppSpacing.iconSm),
                              const SizedBox(width: AppSpacing.xs),
                              Text('Post-Harvest Losses',
                                  style: tt.titleSmall?.copyWith(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.error)),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          _Row(
                            icon: Icons.remove_circle_outline_rounded,
                            label: 'Losses',
                            value:
                                '${record.lossesTons!.toStringAsFixed(2)} t'
                                '${lossPercent != null ? '  (${lossPercent.toStringAsFixed(1)}%)' : ''}',
                            valueColor: AppColors.error,
                          ),
                          if (record.lossReason != null) ...[
                            const Divider(height: AppSpacing.md),
                            _Row(
                              icon: Icons.info_outline_rounded,
                              label: 'Reason',
                              value: record.lossReason!,
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],

                // ── Notes ────────────────────────────────────────────────
                if (record.notes != null && record.notes!.isNotEmpty) ...[
                  Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.card),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.notes_rounded,
                              size: AppSpacing.iconSm,
                              color: AppColors.onSurfaceVariant),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: Text(record.notes!,
                                style: tt.bodyMedium?.copyWith(
                                    color: cs.onSurfaceVariant)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ]),
            ),
          ),
        ],
      ),
    );
  }

  Color _gradeColor(String? grade) {
    if (grade == null) return AppColors.onSurfaceVariant;
    return switch (grade.toUpperCase()) {
      'A' || '1' => AppColors.success,
      'B' || '2' => AppColors.tertiary,
      'C' || '3' => AppColors.warning,
      _          => AppColors.onSurfaceVariant,
    };
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.sm, horizontal: AppSpacing.xs),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: AppRadius.card,
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: AppSpacing.iconSm),
          const SizedBox(height: AppSpacing.xs),
          Text(value,
              textAlign: TextAlign.center,
              style: tt.labelMedium
                  ?.copyWith(fontWeight: FontWeight.w800, color: color)),
          Text(label,
              style: tt.labelSmall
                  ?.copyWith(color: cs.onSurfaceVariant, fontSize: 9)),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Row(
      children: [
        Icon(icon, size: AppSpacing.iconSm, color: AppColors.primary),
        const SizedBox(width: AppSpacing.sm),
        Text(label,
            style: tt.bodySmall
                ?.copyWith(color: AppColors.onSurfaceVariant)),
        const Spacer(),
        Text(value,
            style: tt.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600, color: valueColor)),
      ],
    );
  }
}

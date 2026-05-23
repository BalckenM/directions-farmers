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
import '../../models/spray_record.dart';
import '../../providers/crop_providers.dart';

class SprayDetailScreen extends ConsumerWidget {
  const SprayDetailScreen({super.key, required this.record});

  final SprayRecord record;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fieldsAsync = ref.watch(cropFieldsProvider(null));

    final fieldName = (fieldsAsync.value ?? [])
        .where((f) => f.id == record.fieldId)
        .map((f) => f.name)
        .firstOrNull ?? record.fieldId;

    final dateFmt = DateFormat('dd MMM yyyy');
    final now = DateTime.now();

    final reEntryPassed = record.reEntryDate.isBefore(now);
    final reEntryColor =
        reEntryPassed ? AppColors.success : AppColors.warning;
    final reEntryLabel =
        reEntryPassed ? 'Re-entry allowed' : 'Re-entry restricted';

    final outcomeColor = record.outcome != null
        ? _outcomeColor(record.outcome!)
        : AppColors.onSurfaceVariant;

    return FarmScaffold(
      body: CustomScrollView(
        slivers: [
          // ── App Bar ───────────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 140,
            pinned: true,
            leading: const BackButton(),
            backgroundColor: AppColors.secondaryDark,
            foregroundColor: AppColors.onPrimary,
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_rounded),
                tooltip: 'Edit',
                onPressed: () =>
                    context.push(AppRoutes.editSprayRecord, extra: record),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                record.productName,
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
                    colors: [Color(0xFF1A237E), AppColors.secondaryDark],
                  ),
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                        AppSpacing.md, AppSpacing.sm, AppSpacing.md, 48),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Icon(Icons.water_drop_rounded,
                            color: AppColors.onPrimary, size: 18),
                        const SizedBox(width: AppSpacing.xs),
                        Text(fieldName,
                            style: TextStyle(
                                color: AppColors.onPrimary.withAlpha(204),
                                fontSize: 12)),
                        const SizedBox(width: AppSpacing.sm),
                        StatusChip(
                          label: reEntryLabel,
                          color: reEntryColor,
                          small: true,
                        ),
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

                // ── Spray KPIs ───────────────────────────────────────────
                Row(
                  children: [
                    Expanded(
                      child: _KpiCard(
                        icon: Icons.crop_square_rounded,
                        label: 'Area',
                        value:
                            '${record.areaSprayedHa.toStringAsFixed(1)} ha',
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: _KpiCard(
                        icon: Icons.science_rounded,
                        label: 'Dosage',
                        value:
                            '${record.dosagePerHa.toStringAsFixed(1)} /ha',
                        color: AppColors.secondaryDark,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: _KpiCard(
                        icon: Icons.timer_rounded,
                        label: 'WHI',
                        value: '${record.withholdingDays} days',
                        color: AppColors.warning,
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
                          label: 'Spray Date',
                          value: dateFmt.format(record.sprayDate),
                        ),
                        const Divider(height: AppSpacing.md),
                        _Row(
                          icon: Icons.crop_square_rounded,
                          label: 'Field',
                          value: fieldName,
                        ),
                        const Divider(height: AppSpacing.md),
                        _Row(
                          icon: Icons.bubble_chart_rounded,
                          label: 'Product',
                          value: record.productName,
                        ),
                        const Divider(height: AppSpacing.md),
                        _Row(
                          icon: Icons.straighten_rounded,
                          label: 'Dosage/ha',
                          value:
                              '${record.dosagePerHa.toStringAsFixed(2)} L/ha',
                        ),
                        const Divider(height: AppSpacing.md),
                        _Row(
                          icon: Icons.crop_square_rounded,
                          label: 'Area sprayed',
                          value:
                              '${record.areaSprayedHa.toStringAsFixed(1)} ha',
                        ),
                        if (record.applicatorName != null) ...[
                          const Divider(height: AppSpacing.md),
                          _Row(
                            icon: Icons.person_outlined,
                            label: 'Applicator',
                            value: record.applicatorName!,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // ── Re-entry & WHI card ──────────────────────────────────
                Card(
                  shape: RoundedRectangleBorder(
                      borderRadius: AppRadius.card),
                  color: reEntryColor.withAlpha(12),
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      children: [
                        _Row(
                          icon: Icons.timer_outlined,
                          label: 'Withholding',
                          value: '${record.withholdingDays} days',
                        ),
                        const Divider(height: AppSpacing.md),
                        _Row(
                          icon: reEntryPassed
                              ? Icons.check_circle_rounded
                              : Icons.lock_clock_rounded,
                          label: 'Re-entry Date',
                          value: dateFmt.format(record.reEntryDate),
                          valueColor: reEntryColor,
                        ),
                        const Divider(height: AppSpacing.md),
                        _Row(
                          icon: reEntryPassed
                              ? Icons.check_circle_outline_rounded
                              : Icons.warning_amber_rounded,
                          label: 'Status',
                          value: reEntryLabel,
                          valueColor: reEntryColor,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

                // ── Outcome ──────────────────────────────────────────────
                if (record.outcome != null) ...[
                  Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.card),
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: _Row(
                        icon: Icons.assessment_outlined,
                        label: 'Outcome',
                        value: record.outcome!,
                        valueColor: outcomeColor,
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

  Color _outcomeColor(String outcome) {
    final o = outcome.toLowerCase();
    if (o.contains('effective') || o.contains('success') || o.contains('good')) {
      return AppColors.success;
    }
    if (o.contains('partial')) return AppColors.warning;
    if (o.contains('fail') || o.contains('poor')) return AppColors.error;
    return AppColors.onSurfaceVariant;
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
            style:
                tt.bodySmall?.copyWith(color: AppColors.onSurfaceVariant)),
        const Spacer(),
        Flexible(
          child: Text(value,
              textAlign: TextAlign.end,
              style: tt.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600, color: valueColor)),
        ),
      ],
    );
  }
}

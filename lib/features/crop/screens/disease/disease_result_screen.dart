import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/farm_app_bar.dart';
import '../../../../shared/widgets/farm_scaffold.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../models/disease_detection.dart';

class DiseaseResultScreen extends StatelessWidget {
  const DiseaseResultScreen({super.key, required this.result});

  final DiseaseDetectionResult result;

  @override
  Widget build(BuildContext context) {
    final top = result.topMatch;
    final disease = top.disease;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final headerColor = disease.category == DiseaseCategory.healthy
        ? AppColors.success
        : _severityColor(disease.severity);

    return FarmScaffold(
      appBar: FarmAppBar(
        title: 'Scan Results',
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.camera_alt_rounded, size: 16),
            label: const Text('Scan Again'),
            onPressed: () => context.pop(),
          ),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          // ── Top result banner ──────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(AppSpacing.md),
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: headerColor.withAlpha(20),
                borderRadius: AppRadius.card,
                border: Border.all(color: headerColor.withAlpha(80)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.sm),
                        decoration: BoxDecoration(
                          color: headerColor.withAlpha(30),
                          borderRadius: AppRadius.card,
                        ),
                        child: Icon(
                          _categoryIcon(disease.category),
                          color: headerColor,
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              disease.name,
                              style: tt.titleMedium?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: headerColor,
                              ),
                            ),
                            if (disease.scientificName != null)
                              Text(
                                disease.scientificName!,
                                style: tt.bodySmall?.copyWith(
                                  fontStyle: FontStyle.italic,
                                  color: cs.onSurfaceVariant,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      _Badge(
                        label: disease.category.label,
                        color: headerColor,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      if (disease.category != DiseaseCategory.healthy)
                        _Badge(
                          label: 'Severity: ${disease.severity.label}',
                          color: _severityColor(disease.severity),
                        ),
                      const SizedBox(width: AppSpacing.xs),
                      _Badge(
                        label:
                            '${top.confidenceLabel} Confidence (${(top.confidence * 100).round()}%)',
                        color: cs.outline,
                      ),
                    ],
                  ),
                  if (disease.requiresImmediateAction) ...[
                    const SizedBox(height: AppSpacing.sm),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: AppRadius.chip,
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.priority_high_rounded,
                              color: Colors.white, size: 14),
                          SizedBox(width: 4),
                          Text(
                            'Requires Immediate Action',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // ── Description ────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'About this condition',
                    style: tt.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    disease.description,
                    style: tt.bodyMedium
                        ?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ),

          // ── Visual symptoms ────────────────────────────────────────────────
          const SliverToBoxAdapter(
            child: SectionHeader(title: 'Visual Symptoms'),
          ),
          SliverToBoxAdapter(
            child: _InfoCard(
              icon: Icons.visibility_rounded,
              color: AppColors.secondary,
              body: disease.visualSymptoms,
            ),
          ),

          // ── How it spreads ─────────────────────────────────────────────────
          if (disease.category != DiseaseCategory.healthy &&
              disease.category != DiseaseCategory.nutrientDeficiency) ...[
            const SliverToBoxAdapter(
              child: SectionHeader(title: 'How It Spreads'),
            ),
            SliverToBoxAdapter(
              child: _InfoCard(
                icon: Icons.swap_horiz_rounded,
                color: AppColors.warning,
                body: disease.spread,
              ),
            ),
          ],

          // ── Treatments ─────────────────────────────────────────────────────
          if (disease.treatments.isNotEmpty) ...[
            const SliverToBoxAdapter(
              child: SectionHeader(title: 'Recommended Treatments'),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) => Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    0,
                    AppSpacing.md,
                    AppSpacing.sm,
                  ),
                  child: _TreatmentCard(
                      treatment: disease.treatments[index]),
                ),
                childCount: disease.treatments.length,
              ),
            ),
          ],

          // ── Prevention tips ────────────────────────────────────────────────
          if (disease.preventionTips.isNotEmpty) ...[
            const SliverToBoxAdapter(
              child: SectionHeader(title: 'Prevention Tips'),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.md,
                  0,
                  AppSpacing.md,
                  AppSpacing.md,
                ),
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.success.withAlpha(15),
                    borderRadius: AppRadius.card,
                    border: Border.all(
                        color: AppColors.success.withAlpha(50)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: disease.preventionTips
                        .map(
                          (tip) => Padding(
                            padding: const EdgeInsets.only(
                                bottom: AppSpacing.xs),
                            child: Row(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.check_circle_rounded,
                                    size: 14, color: AppColors.success),
                                const SizedBox(width: AppSpacing.xs),
                                Expanded(
                                  child: Text(
                                    tip,
                                    style: tt.bodySmall,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),
            ),
          ],

          // ── Other possible matches ─────────────────────────────────────────
          if (result.matches.length > 1) ...[
            const SliverToBoxAdapter(
              child: SectionHeader(title: 'Other Possible Matches'),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final match = result.matches[index + 1];
                  return Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      0,
                      AppSpacing.md,
                      AppSpacing.xs,
                    ),
                    child: _AlternativeMatchTile(match: match),
                  );
                },
                childCount:
                    (result.matches.length - 1).clamp(0, 3),
              ),
            ),
          ],

          // ── Disclaimer ─────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Text(
                'Scan performed ${DateFormat("dd MMM yyyy HH:mm").format(result.detectedAt)}. '
                'AI results are indicative only. Always consult a registered '
                'South African agricultural advisor for a definitive diagnosis '
                'and treatment plan.',
                style: tt.bodySmall?.copyWith(
                  color: cs.onSurfaceVariant,
                  fontSize: 11,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),

          // ── Scan again CTA ─────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                0,
                AppSpacing.md,
                AppSpacing.xxl,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.camera_alt_rounded),
                      label: const Text('Scan Another Leaf'),
                      onPressed: () => context.go(AppRoutes.cropDiseaseScanner),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: FilledButton.icon(
                      icon: const Icon(Icons.tips_and_updates_rounded),
                      label: const Text('Get Advice'),
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.cropGreen,
                      ),
                      onPressed: () => context.push(AppRoutes.cropAiAdvisor),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _severityColor(DiseaseSeverity s) => switch (s) {
        DiseaseSeverity.low => AppColors.success,
        DiseaseSeverity.moderate => AppColors.warning,
        DiseaseSeverity.high => AppColors.secondaryDark,
        DiseaseSeverity.critical => AppColors.error,
      };

  IconData _categoryIcon(DiseaseCategory c) => switch (c) {
        DiseaseCategory.fungal => Icons.blur_circular_rounded,
        DiseaseCategory.bacterial => Icons.coronavirus_rounded,
        DiseaseCategory.viral => Icons.bug_report_rounded,
        DiseaseCategory.pest => Icons.pest_control_rounded,
        DiseaseCategory.nutrientDeficiency => Icons.science_rounded,
        DiseaseCategory.healthy => Icons.check_circle_rounded,
      };
}

// ── Supporting widgets ────────────────────────────────────────────────────────

class _Badge extends StatelessWidget {
  const _Badge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs + 2,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: AppRadius.chip,
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.color,
    required this.body,
  });

  final IconData icon;
  final Color color;
  final String body;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        0,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: cs.surfaceContainerLow,
          borderRadius: AppRadius.card,
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 18, color: color),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                body,
                style: tt.bodyMedium?.copyWith(color: cs.onSurface),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TreatmentCard extends StatelessWidget {
  const _TreatmentCard({required this.treatment});

  final TreatmentOption treatment;

  Color get _typeColor => switch (treatment.type) {
        TreatmentType.chemical => AppColors.error,
        TreatmentType.biological => AppColors.success,
        TreatmentType.cultural => AppColors.tertiary,
      };

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final color = _typeColor;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: AppRadius.card,
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  treatment.name,
                  style: tt.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xs + 2,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: color.withAlpha(20),
                  borderRadius: AppRadius.chip,
                ),
                child: Text(
                  treatment.type.label,
                  style: TextStyle(
                    color: color,
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            treatment.description,
            style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: AppSpacing.sm),
          _DetailRow(
            label: 'Application',
            value: treatment.applicationMethod,
          ),
          _DetailRow(
            label: 'Timing',
            value: treatment.timing,
          ),
          if (treatment.saProducts != null &&
              treatment.saProducts!.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              'SA Registered Products:',
              style: tt.labelSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: cs.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 2),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: 2,
              children: treatment.saProducts!
                  .map(
                    (p) => Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.primary.withAlpha(15),
                        borderRadius: AppRadius.chip,
                        border: Border.all(
                            color: AppColors.primary.withAlpha(40)),
                      ),
                      child: Text(
                        p,
                        style: TextStyle(
                          color: AppColors.primary,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  )
                  .toList(),
            ),
          ],
          if (treatment.waitingDays > 0) ...[
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                const Icon(Icons.timer_rounded,
                    size: 12, color: AppColors.warning),
                const SizedBox(width: 4),
                Text(
                  'Pre-harvest interval: ${treatment.waitingDays} days',
                  style: tt.labelSmall?.copyWith(
                    color: AppColors.warning,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: RichText(
        text: TextSpan(
          style: tt.bodySmall?.copyWith(color: cs.onSurface),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            TextSpan(text: value),
          ],
        ),
      ),
    );
  }
}

class _AlternativeMatchTile extends StatelessWidget {
  const _AlternativeMatchTile({required this.match});

  final DiseaseMatch match;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final pct = (match.confidence * 100).round();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: AppRadius.card,
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  match.disease.name,
                  style: tt.bodySmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                Text(
                  match.disease.category.label,
                  style: tt.labelSmall
                      ?.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
          Text(
            '$pct%',
            style: tt.bodySmall?.copyWith(
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          SizedBox(
            width: 60,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(3),
              child: LinearProgressIndicator(
                value: match.confidence,
                minHeight: 6,
                backgroundColor: cs.outlineVariant,
                valueColor:
                    AlwaysStoppedAnimation<Color>(cs.onSurfaceVariant),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

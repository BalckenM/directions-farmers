import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/farm_app_bar.dart';
import '../../../shared/widgets/farm_scaffold.dart';
import '../../../shared/widgets/status_chip.dart';
import '../providers/alerts_provider.dart';

// ── Screen ───────────────────────────────────────────────────────────────────

class AlertsScreen extends ConsumerWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alerts = ref.watch(alertsProvider);
    final critical = alerts.where((a) => a.severity == AlertSeverity.critical).toList();
    final warnings = alerts.where((a) => a.severity == AlertSeverity.warning).toList();
    final info = alerts.where((a) => a.severity == AlertSeverity.info).toList();

    return FarmScaffold(
      appBar: FarmAppBar(
        title: 'Alerts & Reminders',
        subtitle: '${alerts.length} active alerts',
      ),
      body: alerts.isEmpty
          ? const EmptyState(
              title: 'No Alerts',
              subtitle: 'All up to date! Alerts and reminders will appear here.',
              icon: Icon(Icons.notifications_none_rounded, size: 64),
            )
          : ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.pagePaddingHorizontal,
                AppSpacing.md,
                AppSpacing.pagePaddingHorizontal,
                AppSpacing.xxl + 32,
              ),
              children: [
                if (critical.isNotEmpty) ...[
                  _SectionHeader(
                    label: 'Critical',
                    count: critical.length,
                    color: AppColors.error,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ...critical.map((a) => _AlertCard(alert: a)),
                  const SizedBox(height: AppSpacing.lg),
                ],
                if (warnings.isNotEmpty) ...[
                  _SectionHeader(
                    label: 'Warnings',
                    count: warnings.length,
                    color: AppColors.warning,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ...warnings.map((a) => _AlertCard(alert: a)),
                  const SizedBox(height: AppSpacing.lg),
                ],
                if (info.isNotEmpty) ...[
                  _SectionHeader(
                    label: 'Reminders',
                    count: info.length,
                    color: AppColors.info,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ...info.map((a) => _AlertCard(alert: a)),
                ],
              ],
            ),
    );
  }
}

// ── Private widgets ───────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.label,
    required this.count,
    required this.color,
  });

  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          label,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: color,
              ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
          decoration: BoxDecoration(
            color: color.withAlpha(20),
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Text(
            '$count',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
      ],
    );
  }
}

class _AlertCard extends StatelessWidget {
  const _AlertCard({required this.alert});
  final FarmAlert alert;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: AppRadius.card,
          border: Border.all(
            color: alert.severityColor.withAlpha(
              alert.severity == AlertSeverity.critical ? 80 : 30,
            ),
          ),
          boxShadow: AppShadows.level1,
        ),
        child: Row(
          children: [
            // Severity stripe
            Container(
              width: 4,
              height: 80,
              decoration: BoxDecoration(
                color: alert.severityColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  bottomLeft: Radius.circular(12),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            // Category icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: alert.severityColor.withAlpha(20),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(
                alert.categoryIcon,
                size: 20,
                color: alert.severityColor,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            alert.title,
                            style: tt.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        StatusChip(
                          label: alert.dueDate,
                          color: alert.severityColor,
                          icon: Icons.schedule_rounded,
                          small: true,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      alert.description,
                      style: tt.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (alert.animalTag != null) ...[
                      const SizedBox(height: AppSpacing.xs),
                      Row(
                        children: [
                          Icon(
                            Icons.label_outline_rounded,
                            size: 12,
                            color: cs.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            alert.animalTag!,
                            style: tt.labelSmall?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

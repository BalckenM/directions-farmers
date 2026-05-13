import 'package:flutter/material.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';

/// A KPI card displaying a metric [value], [label], and optional [trend] text.
///
/// Used in dashboard rows to surface key figures at a glance.
class StatCard extends StatelessWidget {
  const StatCard({
    super.key,
    required this.label,
    required this.value,
    this.unit,
    this.trend,
    this.trendPositive,
    this.icon,
    this.accentColor,
    this.onTap,
  });

  final String label;
  final String value;
  final String? unit;

  /// Short trend text e.g. '+12%' or '-3 kg'.
  final String? trend;

  /// `true` = green, `false` = red, `null` = neutral.
  final bool? trendPositive;
  final IconData? icon;
  final Color? accentColor;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final accent = accentColor ?? cs.primary;

    Color trendColor() {
      if (trendPositive == null) return cs.onSurfaceVariant;
      return trendPositive! ? const Color(0xFF2E7D32) : cs.error;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.zero,
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: AppRadius.card,
          border: Border.all(color: cs.outlineVariant, width: 1),
          boxShadow: AppShadows.level1,
        ),
        clipBehavior: Clip.antiAlias,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left accent bar
              Container(width: 4, color: accent),
              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          if (icon != null) ...[
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: accent.withAlpha(25),
                                borderRadius: AppRadius.button,
                              ),
                              child: Icon(icon, size: 16, color: accent),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                          ],
                          Expanded(
                            child: Text(
                              label,
                              style: tt.labelMedium?.copyWith(
                                  color: cs.onSurfaceVariant),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            value,
                            style: tt.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: cs.onSurface,
                              height: 1,
                            ),
                          ),
                          if (unit != null) ...[
                            const SizedBox(width: 4),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 2),
                              child: Text(
                                unit!,
                                style: tt.bodySmall?.copyWith(
                                    color: cs.onSurfaceVariant),
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (trend != null) ...[
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          trend!,
                          style: tt.labelSmall?.copyWith(
                            color: trendColor(),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

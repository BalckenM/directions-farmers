import 'package:flutter/material.dart';
import 'package:mobile_app/core/theme/app_typography.dart';
import 'package:mobile_app/core/theme/payroll_design_tokens.dart';

/// Large metric card showing a KPI value with optional trend indicator.
/// Used in dashboard/hub screens.
///
/// Example:
/// ```dart
/// PrKpiCard(
///   label: 'Total Net Pay',
///   value: 'R 124,500',
///   icon: Icons.payments_outlined,
///   iconColor: PayrollTokens.brand,
///   delta: '+R 3,200',
///   deltaPositive: true,
/// )
/// ```
class PrKpiCard extends StatelessWidget {
  const PrKpiCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    this.iconColor,
    this.delta,
    this.deltaPositive,
    this.subtitle,
    this.onTap,
    this.loading = false,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color? iconColor;

  /// Optional delta text e.g. '+R 3,200 vs last period'
  final String? delta;

  /// If true → green; if false → red; if null → gray
  final bool? deltaPositive;

  /// Small subtitle under value e.g. 'vs last month'
  final String? subtitle;
  final VoidCallback? onTap;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final Color effectiveIconColor = iconColor ?? PayrollTokens.brand;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(PayrollTokens.spacingMd),
        decoration: BoxDecoration(
          color: PayrollTokens.cardBg,
          borderRadius: PayrollTokens.radiusLg,
          border: Border.all(color: PayrollTokens.border),
          boxShadow: PayrollTokens.shadowSm,
        ),
        child: loading ? _buildSkeleton() : _buildContent(effectiveIconColor),
      ),
    );
  }

  Widget _buildContent(Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: PayrollTokens.radiusMd,
              ),
              child: Icon(icon, size: 18, color: color),
            ),
            const Spacer(),
            if (delta != null)
              _DeltaBadge(delta: delta!, positive: deltaPositive),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          value,
          style: AppTypography.textTheme.headlineSmall?.copyWith(
            color: PayrollTokens.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTypography.textTheme.bodySmall?.copyWith(
            color: PayrollTokens.textSecondary,
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: 4),
          Text(
            subtitle!,
            style: AppTypography.textTheme.labelSmall?.copyWith(
              color: PayrollTokens.textMuted,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildSkeleton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 34,
          width: 34,
          decoration: BoxDecoration(
            color: PayrollTokens.surfaceContainerHigh,
            borderRadius: PayrollTokens.radiusMd,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 28,
          width: 100,
          decoration: BoxDecoration(
            color: PayrollTokens.surfaceContainerHigh,
            borderRadius: PayrollTokens.radiusSm,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          height: 14,
          width: 80,
          decoration: BoxDecoration(
            color: PayrollTokens.surfaceContainer,
            borderRadius: PayrollTokens.radiusSm,
          ),
        ),
      ],
    );
  }
}

class _DeltaBadge extends StatelessWidget {
  const _DeltaBadge({required this.delta, this.positive});
  final String delta;
  final bool? positive;

  @override
  Widget build(BuildContext context) {
    final Color color = positive == null
        ? PayrollTokens.trendFlat
        : positive!
        ? PayrollTokens.trendUp
        : PayrollTokens.trendDown;
    final IconData arrow = positive == null
        ? Icons.remove
        : positive!
        ? Icons.trending_up_rounded
        : Icons.trending_down_rounded;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(arrow, size: 14, color: color),
        const SizedBox(width: 2),
        Text(
          delta,
          style: AppTypography.textTheme.labelSmall?.copyWith(
            color: color,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

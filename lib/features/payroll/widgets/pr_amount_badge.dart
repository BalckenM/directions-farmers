import 'package:flutter/material.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';

/// A styled amount/currency badge used in payroll summaries and list tiles.
class PrAmountBadge extends StatelessWidget {
  const PrAmountBadge({
    super.key,
    required this.amount,
    this.backgroundColor,
    this.textColor,
    this.large = false,
  });

  final String amount;
  final Color? backgroundColor;
  final Color? textColor;
  final bool large;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: large ? AppSpacing.md : AppSpacing.sm,
        vertical: large ? AppSpacing.sm : AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: backgroundColor ?? cs.primaryContainer,
        borderRadius: AppRadius.chip,
      ),
      child: Text(
        amount,
        style: (large ? tt.titleMedium : tt.bodyMedium)?.copyWith(
          fontWeight: FontWeight.w700,
          color: textColor ?? cs.onPrimaryContainer,
        ),
      ),
    );
  }
}

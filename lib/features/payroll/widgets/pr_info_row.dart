import 'package:flutter/material.dart';
import '../../../core/theme/app_spacing.dart';

/// A two-column label + value row used in detail/profile sections.
class PrInfoRow extends StatelessWidget {
  const PrInfoRow({
    super.key,
    required this.label,
    required this.value,
    this.labelWidth = 140,
    this.icon,
    this.valueColor,
    this.valueStyle,
  });

  final String label;
  final String value;
  final double labelWidth;
  final IconData? icon;
  final Color? valueColor;
  final TextStyle? valueStyle;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs + 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Icon(icon, size: 14, color: cs.onSurfaceVariant),
            ),
            const SizedBox(width: AppSpacing.xs),
          ],
          SizedBox(
            width: labelWidth,
            child: Text(
              label,
              style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: valueStyle ??
                  tt.bodyMedium?.copyWith(
                    color: valueColor ?? cs.onSurface,
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

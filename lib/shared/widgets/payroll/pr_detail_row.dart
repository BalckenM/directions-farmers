import 'package:flutter/material.dart';
import 'package:mobile_app/core/theme/app_typography.dart';
import 'package:mobile_app/core/theme/payroll_design_tokens.dart';

/// Label + value row pair for detail screens, payslips, etc.
/// Supports icons, copy-to-clipboard, and multi-line values.
///
/// Example:
/// ```dart
/// PrDetailRow(label: 'Employee', value: 'John Doe')
/// PrDetailRow(label: 'Net Pay', value: 'R 12,450.00', valueColor: PayrollTokens.statusSuccess)
/// PrDetailRow.widget(label: 'Status', child: PrStatusPill.payRun('approved'))
/// ```
class PrDetailRow extends StatelessWidget {
  const PrDetailRow({
    super.key,
    required this.label,
    required this.value,
    this.valueColor,
    this.labelIcon,
    this.bold = false,
    this.copyable = false,
    this.onTap,
  });

  factory PrDetailRow.widget({
    Key? key,
    required String label,
    required Widget child,
    IconData? labelIcon,
  }) => _PrDetailRowWidget(
    key: key,
    label: label,
    labelIcon: labelIcon,
    child: child,
  );

  final String label;
  final String value;
  final Color? valueColor;
  final IconData? labelIcon;
  final bool bold;
  final bool copyable;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: PayrollTokens.spacingMd,
        vertical: 10,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (labelIcon != null) ...[
            Padding(
              padding: const EdgeInsets.only(top: 1, right: 6),
              child: Icon(labelIcon, size: 14, color: PayrollTokens.textMuted),
            ),
          ],
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: AppTypography.textTheme.bodySmall?.copyWith(
                color: PayrollTokens.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: onTap,
              child: Text(
                value,
                style: AppTypography.textTheme.bodyMedium?.copyWith(
                  color: valueColor ?? PayrollTokens.textPrimary,
                  fontWeight: bold ? FontWeight.w600 : FontWeight.w400,
                ),
                textAlign: TextAlign.right,
              ),
            ),
          ),
          if (copyable) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () {
                // Clipboard handled by parent or via onTap
              },
              child: Icon(
                Icons.copy_all_outlined,
                size: 14,
                color: PayrollTokens.textMuted,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _PrDetailRowWidget extends PrDetailRow {
  const _PrDetailRowWidget({
    super.key,
    required super.label,
    required this.child,
    super.labelIcon,
  }) : super(value: '');

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: PayrollTokens.spacingMd,
        vertical: 10,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          if (labelIcon != null) ...[
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Icon(labelIcon, size: 14, color: PayrollTokens.textMuted),
            ),
          ],
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: AppTypography.textTheme.bodySmall?.copyWith(
                color: PayrollTokens.textSecondary,
              ),
            ),
          ),
          const Spacer(),
          child,
        ],
      ),
    );
  }
}

/// A divider specifically for PrDetailRow groups
class PrDetailDivider extends StatelessWidget {
  const PrDetailDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      color: PayrollTokens.border,
      indent: PayrollTokens.spacingMd,
      endIndent: PayrollTokens.spacingMd,
    );
  }
}

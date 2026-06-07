import 'package:flutter/material.dart';
import 'package:mobile_app/core/theme/app_typography.dart';
import 'package:mobile_app/core/theme/payroll_design_tokens.dart';

/// Section header with title + optional trailing action button.
/// Used to divide content areas on detail and form screens.
///
/// Example:
/// ```dart
/// PrSectionHeader(title: 'Earnings')
/// PrSectionHeader(title: 'Pay Components', action: TextButton(...))
/// PrSectionHeader.divider(title: 'Tax Details')
/// ```
class PrSectionHeader extends StatelessWidget {
  const PrSectionHeader({
    super.key,
    required this.title,
    this.action,
    this.subtitle,
    this.showDivider = true,
    this.padding,
    this.icon,
  });

  factory PrSectionHeader.divider({
    Key? key,
    required String title,
    Widget? action,
  }) => PrSectionHeader(
    key: key,
    title: title,
    action: action,
    showDivider: true,
  );

  factory PrSectionHeader.noLine({
    Key? key,
    required String title,
    String? subtitle,
    Widget? action,
  }) => PrSectionHeader(
    key: key,
    title: title,
    subtitle: subtitle,
    action: action,
    showDivider: false,
  );

  final String title;
  final Widget? action;
  final String? subtitle;
  final bool showDivider;
  final EdgeInsetsGeometry? padding;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          padding ??
          const EdgeInsets.symmetric(
            horizontal: PayrollTokens.spacingMd,
            vertical: PayrollTokens.spacingSm,
          ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 16, color: PayrollTokens.brand),
                const SizedBox(width: 6),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: AppTypography.textTheme.titleSmall?.copyWith(
                        color: PayrollTokens.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: AppTypography.textTheme.bodySmall?.copyWith(
                          color: PayrollTokens.textSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              ?action,
            ],
          ),
          if (showDivider) ...[
            const SizedBox(height: 8),
            Divider(height: 1, thickness: 1, color: PayrollTokens.border),
          ],
        ],
      ),
    );
  }
}

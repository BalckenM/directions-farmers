import 'package:flutter/material.dart';
import 'package:mobile_app/core/theme/app_typography.dart';
import 'package:mobile_app/core/theme/payroll_design_tokens.dart';

/// A compact rounded pill badge with semantic color.
/// Used for status fields throughout the payroll module.
///
/// Example:
/// ```dart
/// PrStatusPill(label: 'Approved', type: PrStatusType.success)
/// PrStatusPill.payRun('disbursed')
/// PrStatusPill.leave('pending')
/// ```
class PrStatusPill extends StatelessWidget {
  const PrStatusPill({
    super.key,
    required this.label,
    required this.foreground,
    required this.background,
    this.size = PrStatusPillSize.medium,
    this.icon,
  });

  factory PrStatusPill.payRun(String status, {Key? key}) {
    final (fg, bg) = PayrollTokens.payRunStatusColors(status);
    return PrStatusPill(
      key: key,
      label: _capitalize(status),
      foreground: fg,
      background: bg,
    );
  }

  factory PrStatusPill.leave(String status, {Key? key}) {
    final (fg, bg) = PayrollTokens.leaveStatusColors(status);
    return PrStatusPill(
      key: key,
      label: _capitalize(status),
      foreground: fg,
      background: bg,
    );
  }

  factory PrStatusPill.engagement(String type, {Key? key}) {
    final (fg, bg) = PayrollTokens.engagementColors(type);
    return PrStatusPill(
      key: key,
      label: _capitalize(type),
      foreground: fg,
      background: bg,
    );
  }

  factory PrStatusPill.success(String label, {Key? key}) => PrStatusPill(
        key: key,
        label: label,
        foreground: PayrollTokens.statusSuccess,
        background: PayrollTokens.statusSuccessContainer,
      );

  factory PrStatusPill.warning(String label, {Key? key}) => PrStatusPill(
        key: key,
        label: label,
        foreground: PayrollTokens.statusWarning,
        background: PayrollTokens.statusWarningContainer,
      );

  factory PrStatusPill.error(String label, {Key? key}) => PrStatusPill(
        key: key,
        label: label,
        foreground: PayrollTokens.statusError,
        background: PayrollTokens.statusErrorContainer,
      );

  factory PrStatusPill.info(String label, {Key? key}) => PrStatusPill(
        key: key,
        label: label,
        foreground: PayrollTokens.statusInfo,
        background: PayrollTokens.statusInfoContainer,
      );

  factory PrStatusPill.muted(String label, {Key? key}) => PrStatusPill(
        key: key,
        label: label,
        foreground: PayrollTokens.textSecondary,
        background: PayrollTokens.surfaceContainer,
      );

  final String label;
  final Color foreground;
  final Color background;
  final PrStatusPillSize size;
  final IconData? icon;

  static String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1).toLowerCase();

  @override
  Widget build(BuildContext context) {
    final (hPad, vPad, fontSize) = switch (size) {
      PrStatusPillSize.small => (6.0, 2.0, 11.0),
      PrStatusPillSize.medium => (8.0, 4.0, 12.0),
      PrStatusPillSize.large => (12.0, 6.0, 13.0),
    };

    return Container(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
      decoration: BoxDecoration(
        color: background,
        borderRadius: PayrollTokens.radiusFull,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: fontSize, color: foreground),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: AppTypography.textTheme.labelSmall?.copyWith(
              color: foreground,
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

enum PrStatusPillSize { small, medium, large }

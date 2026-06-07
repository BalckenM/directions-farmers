import 'package:flutter/material.dart';

import 'package:mobile_app/core/theme/app_typography.dart';
import 'package:mobile_app/core/theme/payroll_design_tokens.dart';

/// Inline error banner displayed when a data fetch or action fails.
/// Can be dismissible and include a retry button.
///
/// Example:
/// ```dart
/// PrErrorBanner(
///   message: 'Failed to load employees. Check your connection.',
///   onRetry: ref.invalidate(employeesProvider),
/// )
/// ```
class PrErrorBanner extends StatelessWidget {
  const PrErrorBanner({
    super.key,
    required this.message,
    this.title,
    this.onRetry,
    this.onDismiss,
    this.type = PrBannerType.error,
  });

  factory PrErrorBanner.warning({
    Key? key,
    required String message,
    String? title,
    VoidCallback? onRetry,
    VoidCallback? onDismiss,
  }) => PrErrorBanner(
    key: key,
    message: message,
    title: title,
    onRetry: onRetry,
    onDismiss: onDismiss,
    type: PrBannerType.warning,
  );

  factory PrErrorBanner.info({
    Key? key,
    required String message,
    String? title,
    VoidCallback? onDismiss,
  }) => PrErrorBanner(
    key: key,
    message: message,
    title: title,
    onDismiss: onDismiss,
    type: PrBannerType.info,
  );

  final String message;
  final String? title;
  final VoidCallback? onRetry;
  final VoidCallback? onDismiss;
  final PrBannerType type;

  @override
  Widget build(BuildContext context) {
    final (bg, border, iconColor, icon) = switch (type) {
      PrBannerType.error => (
        PayrollTokens.statusErrorContainer,
        PayrollTokens.statusError,
        PayrollTokens.statusError,
        Icons.error_outline_rounded,
      ),
      PrBannerType.warning => (
        PayrollTokens.statusWarningContainer,
        PayrollTokens.statusWarning,
        PayrollTokens.statusWarning,
        Icons.warning_amber_rounded,
      ),
      PrBannerType.info => (
        PayrollTokens.statusInfoContainer,
        PayrollTokens.statusInfo,
        PayrollTokens.statusInfo,
        Icons.info_outline_rounded,
      ),
    };

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: PayrollTokens.spacingMd,
        vertical: PayrollTokens.spacingSm,
      ),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: PayrollTokens.radiusMd,
        border: Border.all(color: border.withValues(alpha: 0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null)
                  Text(
                    title!,
                    style: AppTypography.textTheme.labelMedium?.copyWith(
                      color: iconColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                Text(
                  message,
                  style: AppTypography.textTheme.bodySmall?.copyWith(
                    color: PayrollTokens.textPrimary,
                  ),
                ),
                if (onRetry != null) ...[
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: onRetry,
                    child: Text(
                      'Try again',
                      style: AppTypography.textTheme.labelSmall?.copyWith(
                        color: iconColor,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                        decorationColor: iconColor,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (onDismiss != null) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: onDismiss,
              child: Icon(Icons.close_rounded, size: 16, color: iconColor),
            ),
          ],
        ],
      ),
    );
  }
}

enum PrBannerType { error, warning, info }

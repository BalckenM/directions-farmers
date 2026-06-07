import 'package:flutter/material.dart';

import 'package:mobile_app/core/theme/app_typography.dart';
import 'package:mobile_app/core/theme/payroll_design_tokens.dart';

/// Illustrated empty state widget for zero-data screens.
/// Placed inside list/table containers to inform users.
///
/// Example:
/// ```dart
/// PrEmptyState(
///   title: 'No employees yet',
///   subtitle: 'Add your first employee to get started',
///   icon: Icons.people_outline_rounded,
///   actionLabel: 'Add Employee',
///   onAction: () => context.push('/payroll/employees/new'),
/// )
/// ```
class PrEmptyState extends StatelessWidget {
  const PrEmptyState({
    super.key,
    required this.title,
    this.subtitle,
    this.icon = Icons.inbox_outlined,
    this.iconColor,
    this.actionLabel,
    this.onAction,
    this.secondaryActionLabel,
    this.onSecondaryAction,
    this.compact = false,
  });

  final String title;
  final String? subtitle;
  final IconData icon;
  final Color? iconColor;
  final String? actionLabel;
  final VoidCallback? onAction;
  final String? secondaryActionLabel;
  final VoidCallback? onSecondaryAction;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final Color effectiveIconColor = iconColor ?? PayrollTokens.textMuted;

    if (compact) return _buildCompact(effectiveIconColor);

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: effectiveIconColor.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(36),
              ),
              child: Icon(icon, size: 36, color: effectiveIconColor),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: AppTypography.textTheme.titleMedium?.copyWith(
                color: PayrollTokens.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: AppTypography.textTheme.bodyMedium?.copyWith(
                  color: PayrollTokens.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
            if (actionLabel != null) ...[
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: Text(actionLabel!),
              ),
            ],
            if (secondaryActionLabel != null) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: onSecondaryAction,
                child: Text(secondaryActionLabel!),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildCompact(Color iconColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      child: Row(
        children: [
          Icon(icon, size: 20, color: iconColor),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.textTheme.bodyMedium?.copyWith(
                    color: PayrollTokens.textSecondary,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: AppTypography.textTheme.bodySmall?.copyWith(
                      color: PayrollTokens.textMuted,
                    ),
                  ),
              ],
            ),
          ),
          if (actionLabel != null)
            TextButton(onPressed: onAction, child: Text(actionLabel!)),
        ],
      ),
    );
  }
}

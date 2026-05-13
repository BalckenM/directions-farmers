import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';

/// Displays the withdrawal period countdown for a veterinary product.
///
/// Colour-coded:
/// - > 7 days remaining → green (safe to sell/slaughter)
/// - 1–7 days remaining → amber (caution)
/// - ≤ 0 days (expired) → green "Cleared" state
///
/// Withdrawal periods are legally required in SA under the
/// Medicines and Related Substances Act 101 of 1965.
///
/// Usage:
/// ```dart
/// WithdrawalCountdown(
///   productName: 'Oxytetracycline 20%',
///   withdrawalEndDate: '15/06/2025',
///   daysRemaining: 12,
/// )
/// ```
class WithdrawalCountdown extends StatelessWidget {
  const WithdrawalCountdown({
    super.key,
    required this.productName,
    required this.withdrawalEndDate,
    required this.daysRemaining,
    this.compact = false,
  });

  /// Drug / product trade name.
  final String productName;

  /// End date string in DD/MM/YYYY format.
  final String withdrawalEndDate;

  /// Days remaining; 0 or negative means withdrawal has cleared.
  final int daysRemaining;

  /// If true, renders a minimal one-line chip instead of the full card.
  final bool compact;

  bool get _isCleared => daysRemaining <= 0;
  bool get _isCritical => !_isCleared && daysRemaining <= 3;
  bool get _isWarning => !_isCleared && daysRemaining <= 7;

  Color get _statusColor {
    if (_isCleared) return AppColors.success;
    if (_isCritical) return AppColors.error;
    if (_isWarning) return AppColors.warning;
    return AppColors.success;
  }

  Color get _bgColor {
    if (_isCleared) return AppColors.successContainer;
    if (_isCritical) return AppColors.errorContainer;
    if (_isWarning) return AppColors.warningContainer;
    return AppColors.successContainer;
  }

  IconData get _icon {
    if (_isCleared) return Icons.check_circle_outline;
    if (_isCritical) return Icons.do_not_disturb_on_outlined;
    if (_isWarning) return Icons.hourglass_bottom_outlined;
    return Icons.check_circle_outline;
  }

  String get _statusLabel {
    if (_isCleared) return 'Withdrawal cleared';
    if (_isCritical) return '$daysRemaining day${daysRemaining == 1 ? '' : 's'} remaining';
    if (_isWarning) return '$daysRemaining days remaining';
    return '$daysRemaining days remaining';
  }

  @override
  Widget build(BuildContext context) {
    if (compact) return _buildChip(context);
    return _buildCard(context);
  }

  Widget _buildChip(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: AppRadius.chip,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 4,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, size: 14, color: _statusColor),
          const SizedBox(width: 4),
          Text(
            _isCleared ? 'Cleared' : '${daysRemaining}d',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: _statusColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: _bgColor,
        borderRadius: AppRadius.card,
        border: Border.all(
          color: _statusColor.withValues(alpha: 0.4),
        ),
      ),
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(_icon, size: 16, color: _statusColor),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'Withdrawal Period',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: _statusColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                _statusLabel,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: _statusColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      productName,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurface,
                      ),
                    ),
                    if (!_isCleared) ...[
                      const SizedBox(height: 2),
                      Text(
                        'Do not slaughter / sell before $withdrawalEndDate',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: _statusColor,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (!_isCleared) ...[
                const SizedBox(width: AppSpacing.sm),
                _DaysRemainingBadge(
                  days: daysRemaining,
                  color: _statusColor,
                ),
              ],
            ],
          ),
          if (_isCritical) ...[
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  size: 12,
                  color: AppColors.error,
                ),
                const SizedBox(width: 4),
                Text(
                  'Do NOT slaughter — residue risk',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _DaysRemainingBadge extends StatelessWidget {
  const _DaysRemainingBadge({required this.days, required this.color});

  final int days;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color.withValues(alpha: 0.15),
        border: Border.all(color: color, width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$days',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            'days',
            style: TextStyle(
              fontSize: 9,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

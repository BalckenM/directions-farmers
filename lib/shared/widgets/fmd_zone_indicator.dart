import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../features/livestock/models/animal.dart' show FmdZone;

/// A small coloured chip indicating an animal's FMD zone classification.
///
/// Zones (DAFF):
/// - Protection Zone  → red   (highest restriction — active/suspected FMD area)
/// - Surveillance Zone → amber (buffer zone around protection zone)
/// - Free Zone        → green (recognised FMD-free — unrestricted movement)
///
/// Usage:
/// ```dart
/// FmdZoneIndicator(zone: animal.fmdZone ?? FmdZone.freeZone)
/// ```
class FmdZoneIndicator extends StatelessWidget {
  const FmdZoneIndicator({super.key, required this.zone});

  final FmdZone zone;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final Color bg;
    final Color fg;
    final IconData icon;
    final String label;

    switch (zone) {
      case FmdZone.protectionZone:
        bg = AppColors.errorContainer;
        fg = AppColors.error;
        icon = Icons.shield_outlined;
        label = 'FMD Protection Zone';
      case FmdZone.surveillanceZone:
        bg = AppColors.warningContainer;
        fg = AppColors.warning;
        icon = Icons.visibility_outlined;
        label = 'FMD Surveillance Zone';
      case FmdZone.freeZone:
        bg = AppColors.successContainer;
        fg = AppColors.success;
        icon = Icons.verified_user_outlined;
        label = 'FMD Free Zone';
    }

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadius.chip,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 4,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: fg),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: fg,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// A small badge indicating SA Studbook registration.
///
/// Shows the studbook number if supplied; otherwise shows "SA Studbook"
/// as a generic registration indicator.
///
/// Usage:
/// ```dart
/// if (animal.studBookNumber != null)
///   StudBookBadge(studBookNumber: animal.studBookNumber)
/// ```
class StudBookBadge extends StatelessWidget {
  const StudBookBadge({
    super.key,
    this.studBookNumber,
    this.compact = false,
  });

  final String? studBookNumber;

  /// When true, shows only a small star icon chip (for list tiles).
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (compact) {
      return Tooltip(
        message: studBookNumber != null
            ? 'SA Studbook: $studBookNumber'
            : 'SA Studbook registered',
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.tertiaryContainer,
            borderRadius: AppRadius.chip,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.star_rounded, size: 12, color: AppColors.tertiary),
              const SizedBox(width: 2),
              Text(
                'SB',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.tertiary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        color: AppColors.tertiaryContainer,
        borderRadius: AppRadius.chip,
        border: Border.all(
          color: AppColors.tertiary.withValues(alpha: 0.4),
        ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 4,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.star_rounded, size: 14, color: AppColors.tertiary),
          const SizedBox(width: 4),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'SA Studbook',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.tertiary.withValues(alpha: 0.8),
                  height: 1,
                ),
              ),
              if (studBookNumber != null)
                Text(
                  studBookNumber!,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: AppColors.tertiary,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_shadows.dart';

/// FAMACHA conjunctiva score selector for sheep and goats.
///
/// The FAMACHA chart assesses eye conjunctiva colour to estimate worm burden
/// (Haemonchus contortus — Barber's Pole Worm). Scores 1–5 from deep red
/// (healthy) to white (severely anaemic). Scores 4–5 require immediate
/// anthelmintic treatment.
///
/// Usage:
/// ```dart
/// FamachaScoreSelector(
///   value: famachaScore,
///   onChanged: (score) => setState(() => famachaScore = score),
/// )
/// ```
class FamachaScoreSelector extends StatelessWidget {
  const FamachaScoreSelector({
    super.key,
    required this.value,
    required this.onChanged,
    this.label = 'FAMACHA Score',
    this.enabled = true,
    this.showPhotoPrompt = true,
  });

  final int? value;
  final ValueChanged<int?> onChanged;
  final String label;
  final bool enabled;

  /// Whether to show the "Take photo of eye" prompt for scores 3+
  final bool showPhotoPrompt;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: List.generate(5, (i) {
            final score = i + 1;
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: i < 4 ? 6 : 0),
                child: _ScoreButton(
                  score: score,
                  isSelected: value == score,
                  isDark: isDark,
                  enabled: enabled,
                  onTap: () => onChanged(value == score ? null : score),
                ),
              ),
            );
          }),
        ),
        if (value != null) ...[
          const SizedBox(height: AppSpacing.sm),
          _FamachaActionBanner(score: value!, showPhotoPrompt: showPhotoPrompt),
        ],
      ],
    );
  }
}

class _ScoreButton extends StatelessWidget {
  const _ScoreButton({
    required this.score,
    required this.isSelected,
    required this.isDark,
    required this.enabled,
    required this.onTap,
  });

  final int score;
  final bool isSelected;
  final bool isDark;
  final bool enabled;
  final VoidCallback onTap;

  // FAMACHA colour palette — 1=healthy red, 5=severely anaemic white
  static const _colours = <int, Color>{
    1: Color(0xFFB71C1C), // Deep red — healthy
    2: Color(0xFFEF5350), // Red-pink
    3: Color(0xFFF48FB1), // Pink
    4: Color(0xFFFFCDD2), // Pink-white
    5: Color(0xFFFAFAFA), // White — severely anaemic
  };

  static const _labels = <int, String>{
    1: 'Red\n(Healthy)',
    2: 'Red-\nPink',
    3: 'Pink',
    4: 'Pink-\nWhite',
    5: 'White\n(Critical)',
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = _colours[score]!;
    final isCritical = score >= 4;

    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: AppRadius.button,
          border: Border.all(
            color: isSelected
                ? (isCritical ? AppColors.error : AppColors.primary)
                : theme.colorScheme.outlineVariant,
            width: isSelected ? 2.5 : 1,
          ),
          boxShadow: isSelected ? AppShadows.level2 : AppShadows.level0,
        ),
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$score',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: score >= 4 ? AppColors.error : AppColors.onSurface,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              _labels[score] ?? '',
              textAlign: TextAlign.center,
              style: theme.textTheme.labelSmall?.copyWith(
                color: score >= 4 ? AppColors.error : AppColors.onSurface.withValues(alpha: 0.8),
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FamachaActionBanner extends StatelessWidget {
  const _FamachaActionBanner({
    required this.score,
    required this.showPhotoPrompt,
  });

  final int score;
  final bool showPhotoPrompt;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    Color bgColor;
    Color textColor;
    IconData icon;
    String message;

    switch (score) {
      case 1:
      case 2:
        bgColor = AppColors.successContainer;
        textColor = AppColors.success;
        icon = Icons.check_circle_outline;
        message = score == 1
            ? 'Healthy — no treatment needed'
            : 'Acceptable — monitor closely';
      case 3:
        bgColor = AppColors.warningContainer;
        textColor = AppColors.warning;
        icon = Icons.warning_amber_outlined;
        message = 'Borderline — treat if BCS < 2 or concurrent dag/nasal discharge';
      case 4:
        bgColor = AppColors.errorContainer;
        textColor = AppColors.error;
        icon = Icons.medical_services_outlined;
        message = 'TREAT immediately with anthelmintic. Check drench rotation class.';
      case 5:
        bgColor = AppColors.error;
        textColor = Colors.white;
        icon = Icons.emergency_outlined;
        message = 'CRITICAL — urgent treatment. Consider iron dextran + B12. Call vet.';
      default:
        return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: AppRadius.card,
      ),
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: textColor, size: 16),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Text(
                  message,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: textColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          if (showPhotoPrompt && score >= 3) ...[
            const SizedBox(height: AppSpacing.xs),
            Row(
              children: [
                Icon(
                  Icons.camera_alt_outlined,
                  size: 14,
                  color: textColor.withValues(alpha: 0.8),
                ),
                const SizedBox(width: 4),
                Text(
                  'Recommended: photograph conjunctiva for records',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: textColor.withValues(alpha: 0.8),
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

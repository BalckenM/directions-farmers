import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_shadows.dart';

/// Dag (breech soiling) score selector for sheep — 0 to 5.
///
/// Dag score assesses breech soiling and flystrike risk. Score 3+ requires
/// action (crutching). Score 5 = active flystrike emergency.
///
/// High-risk season in SA: October–April (warm, humid periods).
/// Critical zones: Eastern Cape coastal, KZN Midlands, Western Cape valleys.
class DagScoreSelector extends StatelessWidget {
  const DagScoreSelector({
    super.key,
    required this.value,
    required this.onChanged,
    this.label = 'Dag Score (Breech Soiling)',
    this.enabled = true,
  });

  final int? value;
  final ValueChanged<int?> onChanged;
  final String label;
  final bool enabled;

  static const _labels = <int, String>{
    0: 'Clean',
    1: 'Slight\nStaining',
    2: 'Moist\nSoiling',
    3: 'Fresh\nFeces',
    4: 'Flystrike\nRisk',
    5: 'Active\nFlystrike',
  };

  // Colour gradient from clean green to flystrike red
  static const _colours = <int, Color>{
    0: Color(0xFF2E7D32), // green — clean
    1: Color(0xFF558B2F), // light green — slight staining
    2: Color(0xFFF9A825), // amber — moist soiling
    3: Color(0xFFF57F17), // orange — fresh feces (crutch 48h)
    4: Color(0xFFBF360C), // deep orange — immediate crutch
    5: Color(0xFFB71C1C), // red — active flystrike emergency
  };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelLarge?.copyWith(
            color: theme.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'High risk: Oct–Apr (warm/humid)',
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.outline,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: List.generate(6, (i) {
            return Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: i < 5 ? 4 : 0),
                child: _DagButton(
                  score: i,
                  label: _labels[i] ?? '',
                  colour: _colours[i]!,
                  isSelected: value == i,
                  enabled: enabled,
                  onTap: () => onChanged(value == i ? null : i),
                ),
              ),
            );
          }),
        ),
        if (value != null) ...[
          const SizedBox(height: AppSpacing.sm),
          _DagActionBanner(score: value!),
        ],
      ],
    );
  }
}

class _DagButton extends StatelessWidget {
  const _DagButton({
    required this.score,
    required this.label,
    required this.colour,
    required this.isSelected,
    required this.enabled,
    required this.onTap,
  });

  final int score;
  final String label;
  final Color colour;
  final bool isSelected;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: colour.withValues(alpha: 0.12),
          borderRadius: AppRadius.button,
          border: Border.all(
            color: isSelected ? colour : theme.colorScheme.outlineVariant,
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
                color: colour,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              textAlign: TextAlign.center,
              style: theme.textTheme.labelSmall?.copyWith(
                color: colour,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DagActionBanner extends StatelessWidget {
  const _DagActionBanner({required this.score});

  final int score;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    late Color bgColor;
    late Color textColor;
    late IconData icon;
    late String action;

    switch (score) {
      case 0:
        bgColor = AppColors.successContainer;
        textColor = AppColors.success;
        icon = Icons.check_circle_outline;
        action = 'Clean — normal management';
      case 1:
        bgColor = AppColors.successContainer;
        textColor = AppColors.success;
        icon = Icons.visibility_outlined;
        action = 'Slight staining — monitor';
      case 2:
        bgColor = AppColors.warningContainer;
        textColor = AppColors.warning;
        icon = Icons.warning_amber_outlined;
        action = 'Moist soiling — monitor; consider crutching';
      case 3:
        bgColor = AppColors.warningContainer;
        textColor = AppColors.warning;
        icon = Icons.content_cut_outlined;
        action = 'Fresh feces on wool — CRUTCH within 48 hours';
      case 4:
        bgColor = AppColors.errorContainer;
        textColor = AppColors.error;
        icon = Icons.priority_high_rounded;
        action = 'Flystrike risk zone — CRUTCH immediately + preventive treatment';
      case 5:
        bgColor = AppColors.error;
        textColor = Colors.white;
        icon = Icons.emergency_outlined;
        action = 'ACTIVE FLYSTRIKE — emergency treatment required; ISOLATE animal';
      default:
        return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: AppRadius.card,
      ),
      padding: const EdgeInsets.all(AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: textColor, size: 16),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Text(
              action,
              style: theme.textTheme.bodySmall?.copyWith(
                color: textColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

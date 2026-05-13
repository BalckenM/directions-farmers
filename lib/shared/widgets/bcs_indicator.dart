import 'package:flutter/material.dart';
import '../../../core/theme/app_spacing.dart';

/// Visualises a Body Condition Score on either a 5-point or 9-point scale.
///
/// Each step is rendered as a coloured dot: filled = achieved, outline = not.
/// Colour transitions green→amber→red to signal health implication.
class BcsIndicator extends StatelessWidget {
  const BcsIndicator({
    super.key,
    required this.score,
    this.maxScore = 5,
    this.label,
    this.dotSize = 14.0,
  }) : assert(maxScore == 5 || maxScore == 9,
            'maxScore must be 5 or 9');

  /// Current BCS value (1-based, e.g. 3 on a 1-5 scale).
  final double score;

  /// Scale size — 5 for most ruminants, 9 for horses.
  final int maxScore;

  final String? label;
  final double dotSize;

  Color _colorFor(int index) {
    final ratio = index / maxScore;
    if (ratio <= 0.35) return const Color(0xFF1B5E20); // dark green — thin
    if (ratio <= 0.55) return const Color(0xFF2E7D32); // mid green — ideal low
    if (ratio <= 0.70) return const Color(0xFF388E3C); // green — ideal
    if (ratio <= 0.85) return const Color(0xFFF57F17); // amber — over
    return const Color(0xFFB71C1C); // red — obese
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(label!, style: tt.labelMedium),
                Text(
                  '${score.toStringAsFixed(score.truncateToDouble() == score ? 0 : 1)} / $maxScore',
                  style: tt.labelSmall
                      ?.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(maxScore, (i) {
            final step = i + 1;
            final isFilled = score >= step - 0.25;
            final isPartial = score > i && score < step;
            final dotColor = _colorFor(step);

            return Padding(
              padding: EdgeInsets.only(right: i < maxScore - 1 ? 4 : 0),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: dotSize,
                height: dotSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isFilled
                      ? dotColor
                      : isPartial
                          ? dotColor.withAlpha(100)
                          : Colors.transparent,
                  border: Border.all(color: dotColor, width: 1.5),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}

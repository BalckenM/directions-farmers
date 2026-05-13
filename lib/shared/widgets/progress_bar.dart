import 'package:flutter/material.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';

/// A labelled linear progress bar with optional percentage display.
class ProgressBar extends StatelessWidget {
  const ProgressBar({
    super.key,
    required this.value,
    this.label,
    this.showPercent = true,
    this.color,
    this.height = 8.0,
  }) : assert(value >= 0 && value <= 1, 'value must be between 0 and 1');

  /// Progress between 0.0 and 1.0.
  final double value;
  final String? label;
  final bool showPercent;
  final Color? color;
  final double height;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final barColor = color ?? cs.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null || showPercent)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.xs),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                if (label != null)
                  Text(label!, style: tt.labelMedium),
                if (showPercent)
                  Text(
                    '${(value * 100).round()}%',
                    style: tt.labelSmall
                        ?.copyWith(color: cs.onSurfaceVariant),
                  ),
              ],
            ),
          ),
        ClipRRect(
          borderRadius: AppRadius.circular,
          child: LinearProgressIndicator(
            value: value,
            minHeight: height,
            backgroundColor: barColor.withAlpha(40),
            valueColor: AlwaysStoppedAnimation<Color>(barColor),
          ),
        ),
      ],
    );
  }
}

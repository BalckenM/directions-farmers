import 'package:flutter/material.dart';
import '../../../core/theme/app_spacing.dart';
import 'status_chip.dart';

/// A [Wrap]-based cloud of [StatusChip] widgets.
///
/// Ideal for displaying tag lists, filter chips, or any arbitrary label set.
class TagCloud extends StatelessWidget {
  const TagCloud({
    super.key,
    required this.tags,
    this.spacing = AppSpacing.xs,
    this.runSpacing = AppSpacing.xs,
    this.small = false,
  });

  final List<TagItem> tags;
  final double spacing;
  final double runSpacing;
  final bool small;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: spacing,
      runSpacing: runSpacing,
      children: tags
          .map((t) => StatusChip(
                label: t.label,
                color: t.color ?? Colors.grey,
                icon: t.icon,
                small: small,
              ))
          .toList(),
    );
  }
}

class TagItem {
  const TagItem({required this.label, this.color, this.icon});

  final String label;
  final Color? color; // defaults to AppColors.neutral in chip if null
  final IconData? icon;
}

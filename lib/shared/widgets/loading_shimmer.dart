import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';

/// Shimmer placeholder block. Use [LoadingShimmer.list] to build a column of
/// rounded rectangle skeletons that mimic a list of cards.
class LoadingShimmer extends StatelessWidget {
  const LoadingShimmer({
    super.key,
    this.width = double.infinity,
    this.height = 80,
    this.borderRadius,
  });

  final double width;
  final double height;
  final BorderRadius? borderRadius;

  /// Builds [count] stacked shimmer rows separated by [AppSpacing.md].
  static Widget list({int count = 5, double itemHeight = 80}) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(
          count,
          (i) => Padding(
            padding: EdgeInsets.only(
                bottom: i < count - 1 ? AppSpacing.md : 0),
            child: LoadingShimmer(height: itemHeight),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).colorScheme.surfaceContainerHighest;
    final highlight = Theme.of(context).colorScheme.surface;

    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: base,
          borderRadius: borderRadius ?? AppRadius.card,
        ),
      ),
    );
  }
}

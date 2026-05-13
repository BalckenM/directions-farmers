import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';

/// A tappable card for each livestock species shown on the home/dashboard.
///
/// Displays the SVG icon, species name, head count, and a coloured accent strip.
class SpeciesCard extends StatelessWidget {
  const SpeciesCard({
    super.key,
    required this.speciesCode,
    required this.speciesName,
    required this.count,
    required this.svgPath,
    required this.onTap,
    this.subtitle,
  });

  final String speciesCode;
  final String speciesName;
  final int count;
  final String svgPath;
  final VoidCallback onTap;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final accent = AppColors.forSpecies(speciesCode);
    final containerColor = AppColors.containerForSpecies(speciesCode);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: AppRadius.card,
          boxShadow: AppShadows.speciesCard(accent),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            // Coloured top accent strip
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 4,
              child: Container(color: accent),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.lg,
                AppSpacing.md,
                AppSpacing.md,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: containerColor,
                      borderRadius: AppRadius.button,
                    ),
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    child: SvgPicture.asset(
                      svgPath,
                      colorFilter:
                          ColorFilter.mode(accent, BlendMode.srcIn),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    speciesName,
                    style: tt.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '$count head',
                    style: tt.bodySmall
                        ?.copyWith(color: cs.onSurfaceVariant),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle!,
                      style: tt.labelSmall
                          ?.copyWith(color: cs.onSurfaceVariant),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

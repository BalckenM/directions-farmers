import 'package:flutter/material.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import 'avatar_widget.dart';
import 'status_chip.dart';

/// A card-style list tile for a single animal record.
///
/// Shows: avatar / species icon, animal name, tag ID, species chip,
/// health status chip, and weight value.
class AnimalListTile extends StatelessWidget {
  const AnimalListTile({
    super.key,
    required this.name,
    required this.tagId,
    required this.species,
    required this.speciesColor,
    required this.healthStatus,
    required this.healthColor,
    this.weight,
    this.weightUnit = 'kg',
    this.imageUrl,
    this.onTap,
  });

  final String name;
  final String tagId;
  final String species;
  final Color speciesColor;
  final String healthStatus;
  final Color healthColor;
  final double? weight;
  final String weightUnit;
  final String? imageUrl;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
      color: cs.surface,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.card,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              AvatarWidget(
                imageUrl: imageUrl,
                initials: name.isNotEmpty ? name[0].toUpperCase() : '?',
                backgroundColor: speciesColor.withAlpha(40),
                foregroundColor: speciesColor,
                radius: 24,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(name,
                        style: tt.titleSmall
                            ?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(
                      tagId,
                      style: tt.bodySmall
                          ?.copyWith(color: cs.onSurfaceVariant),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        StatusChip(
                          label: species,
                          color: speciesColor,
                          small: true,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        StatusChip(
                          label: healthStatus,
                          color: healthColor,
                          small: true,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (weight != null) ...[
                const SizedBox(width: AppSpacing.sm),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      weight!.toStringAsFixed(1),
                      style: tt.titleMedium
                          ?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    Text(weightUnit,
                        style: tt.labelSmall
                            ?.copyWith(color: cs.onSurfaceVariant)),
                  ],
                ),
              ],
              const SizedBox(width: AppSpacing.xs),
              Icon(Icons.chevron_right_rounded,
                  color: cs.onSurfaceVariant, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

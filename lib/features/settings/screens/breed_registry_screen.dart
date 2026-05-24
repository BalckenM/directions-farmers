import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/farm_app_bar.dart';
import '../../../shared/widgets/farm_scaffold.dart';
import '../providers/settings_ui_providers.dart';

// ── Mock data ─────────────────────────────────────────────────────────────────

class _Breed {
  final String name;
  final String origin;
  final String purpose;
  final String description;

  const _Breed({
    required this.name,
    required this.origin,
    required this.purpose,
    required this.description,
  });
}

const _breedsBySpecies = {
  'Cattle': [
    _Breed(
      name: 'Afrikaner',
      origin: 'South Africa',
      purpose: 'Beef',
      description:
          'Indigenous SA breed. Hardy, heat-tolerant, well adapted to harsh conditions. Red to brownish coat.',
    ),
    _Breed(
      name: 'Nguni',
      origin: 'South Africa',
      purpose: 'Beef / Dual-purpose',
      description:
          'Ancient indigenous breed. Multi-coloured markings. Excellent disease resistance and fertility.',
    ),
    _Breed(
      name: 'Bonsmara',
      origin: 'South Africa',
      purpose: 'Beef',
      description:
          '5/8 Afrikaner, 3/8 Hereford/Shorthorn. Highly productive in subtropical conditions.',
    ),
    _Breed(
      name: 'Drakensberger',
      origin: 'South Africa',
      purpose: 'Beef',
      description:
          'Black-coloured, medium-framed. Adapted to high-altitude and sour bushveld regions.',
    ),
    _Breed(
      name: 'Brahman',
      origin: 'USA (Zebu origin)',
      purpose: 'Beef',
      description:
          'Heat-tolerant, tick-resistant. Widely used in cross-breeding programs for hybrid vigour.',
    ),
    _Breed(
      name: 'Simmentaler',
      origin: 'Switzerland',
      purpose: 'Dual-purpose',
      description:
          'Large-framed breed. Good growth rates and milk production. Popular in SA feedlots.',
    ),
  ],
  'Sheep': [
    _Breed(
      name: 'Merino',
      origin: 'Spain / Australia',
      purpose: 'Wool / Dual-purpose',
      description:
          'Fine wool producer. Adapted to semi-arid regions. Dominant wool breed in the Karoo.',
    ),
    _Breed(
      name: 'Dorper',
      origin: 'South Africa',
      purpose: 'Meat',
      description:
          'Dorset Horn × Blackhead Persian. Hardy, fast-growing, self-shedding coat. Excellent meat.',
    ),
    _Breed(
      name: 'Meatmaster',
      origin: 'South Africa',
      purpose: 'Meat',
      description:
          'Multi-breed composite. Low maintenance, good kidding percentages, adapted to extensive veld.',
    ),
    _Breed(
      name: 'Karakul',
      origin: 'Central Asia',
      purpose: 'Pelt / Dual-purpose',
      description:
          'Produces astrakhan (Persian lamb) pelt. Extremely drought-tolerant. Fat-tailed breed.',
    ),
  ],
  'Goats': [
    _Breed(
      name: 'Boer Goat',
      origin: 'South Africa',
      purpose: 'Meat',
      description:
          'World-renowned meat goat. White body with brown head. Fast-growing, excellent carcass quality.',
    ),
    _Breed(
      name: 'Savanna',
      origin: 'South Africa',
      purpose: 'Meat',
      description:
          'White-coated meat breed. Hardy, adapted to dry bushveld. Strong maternal instinct.',
    ),
    _Breed(
      name: 'Kalahari Red',
      origin: 'South Africa',
      purpose: 'Meat',
      description:
          'Reddish-brown pigmentation provides UV and tick resistance. Ideal for arid Kalahari conditions.',
    ),
    _Breed(
      name: 'Saanen',
      origin: 'Switzerland',
      purpose: 'Dairy',
      description:
          'Highest milk-producing dairy goat. White-coated. Used in commercial goat dairy farms.',
    ),
  ],
  'Pigs': [
    _Breed(
      name: 'Large White',
      origin: 'United Kingdom',
      purpose: 'Pork / Bacon',
      description:
          'Most widely used commercial pig breed. Lean carcass, strong growth rates, good litter size.',
    ),
    _Breed(
      name: 'Landrace',
      origin: 'Denmark',
      purpose: 'Bacon',
      description:
          'Long-bodied, lean bacon producer. Good maternal traits. Widely used in cross-breeding.',
    ),
    _Breed(
      name: 'Duroc',
      origin: 'USA',
      purpose: 'Pork',
      description:
          'Reddish coat. Excellent feed conversion, docile temperament. Popular terminal sire breed.',
    ),
  ],
  'Poultry': [
    _Breed(
      name: 'Potchefstroom Koekoek',
      origin: 'South Africa',
      purpose: 'Dual-purpose',
      description:
          'Indigenous SA breed. Black-and-white barred plumage. Hardy, good layer in extensive systems.',
    ),
    _Breed(
      name: 'Ross 308 Broiler',
      origin: 'United Kingdom',
      purpose: 'Meat',
      description:
          'Industry-standard broiler. Rapid growth, efficient feed conversion. Reaches 2 kg in 35 days.',
    ),
    _Breed(
      name: 'Lohmann Brown',
      origin: 'Germany',
      purpose: 'Eggs',
      description:
          'Commercial laying hybrid. 300+ eggs per year. Well adapted to cage and free-range systems.',
    ),
    _Breed(
      name: 'Boschveld Chicken',
      origin: 'South Africa',
      purpose: 'Dual-purpose',
      description:
          'Composite SA indigenous breed. Disease-tolerant, thrives under low-input extensive conditions.',
    ),
  ],
};

final _speciesIcons = {
  'Cattle': Icons.set_meal_rounded,
  'Sheep': Icons.pets_rounded,
  'Goats': Icons.agriculture_rounded,
  'Pigs': Icons.cruelty_free_rounded,
  'Poultry': Icons.egg_rounded,
};

final _speciesColors = {
  'Cattle': AppColors.primary,
  'Sheep': AppColors.info,
  'Goats': AppColors.secondary,
  'Pigs': AppColors.warning,
  'Poultry': const Color(0xFF8B4513),
};

// ── Screen ────────────────────────────────────────────────────────────────────

class BreedRegistryScreen extends ConsumerWidget {
  const BreedRegistryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedSpeciesProvider);
    final cs = Theme.of(context).colorScheme;

    return FarmScaffold(
      appBar: const FarmAppBar(
        title: 'Breed Registry',
        subtitle: 'Registered breeds and standards',
      ),
      body: Column(
        children: [
          // Species tab bar
          Container(
            color: cs.surface,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              child: Row(
                children: _breedsBySpecies.keys.map((species) {
                  final isSelected = selected == species;
                  final color = _speciesColors[species] ?? AppColors.primary;
                  return Padding(
                    padding: const EdgeInsets.only(right: AppSpacing.sm),
                    child: GestureDetector(
                      onTap: () => ref
                          .read(selectedSpeciesProvider.notifier)
                          .set(species),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm,
                        ),
                        decoration: BoxDecoration(
                          color: isSelected ? color : color.withAlpha(18),
                          borderRadius: AppRadius.chip,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              _speciesIcons[species] ?? Icons.category_rounded,
                              size: 16,
                              color: isSelected ? Colors.white : color,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              species,
                              style: TextStyle(
                                color: isSelected ? Colors.white : color,
                                fontWeight: isSelected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const Divider(height: 1),
          // Breed list
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: _breedsBySpecies[selected]?.length ?? 0,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (context, i) {
                final breed = _breedsBySpecies[selected]![i];
                final color = _speciesColors[selected] ?? AppColors.primary;
                return _BreedCard(breed: breed, color: color);
              },
            ),
          ),
        ],
      ),
    );
  }
}

// ── Breed card ────────────────────────────────────────────────────────────────

class _BreedCard extends StatelessWidget {
  const _BreedCard({required this.breed, required this.color});
  final _Breed breed;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: AppRadius.card,
        boxShadow: AppShadows.level1,
        border: Border.all(color: cs.outlineVariant),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  breed.name,
                  style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: color.withAlpha(18),
                  borderRadius: AppRadius.chip,
                ),
                child: Text(
                  breed.purpose,
                  style: tt.labelSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 13,
                color: cs.onSurfaceVariant,
              ),
              const SizedBox(width: 4),
              Text(
                breed.origin,
                style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(breed.description, style: tt.bodySmall),
        ],
      ),
    );
  }
}

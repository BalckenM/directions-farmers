import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/livestock_constants.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/farm_app_bar.dart';
import '../../../shared/widgets/farm_scaffold.dart';
import '../../../shared/widgets/animal_search_bar.dart';
import '../../../shared/widgets/loading_shimmer.dart';
import '../models/animal.dart';
import '../providers/livestock_providers.dart';

enum _ViewMode { list, grid }

// ── Screen ────────────────────────────────────────────────────────────────────

class SpeciesListScreen extends ConsumerStatefulWidget {
  const SpeciesListScreen({super.key, required this.species});
  final String species;

  @override
  ConsumerState<SpeciesListScreen> createState() => _SpeciesListScreenState();
}

class _SpeciesListScreenState extends ConsumerState<SpeciesListScreen> {
  String _search = '';
  _ViewMode _viewMode = _ViewMode.list;
  String _statusFilter = 'all';
  String _sexFilter = 'all';

  @override
  Widget build(BuildContext context) {
    final animalsAsync = ref.watch(animalsProvider(widget.species));
    final speciesName = LivestockConstants.displayName(widget.species);
    const color = AppColors.primary;

    return FarmScaffold(
      appBar: FarmAppBar(
        title: speciesName,
        subtitle: 'Manage your herd',
        actions: [
          IconButton(
            icon: Icon(
              _viewMode == _ViewMode.list
                  ? Icons.grid_view_rounded
                  : Icons.view_list_rounded,
            ),
            tooltip: _viewMode == _ViewMode.list
                ? 'Switch to grid'
                : 'Switch to list',
            onPressed: () => setState(() {
              _viewMode = _viewMode == _ViewMode.list
                  ? _ViewMode.grid
                  : _ViewMode.list;
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.addAnimalPath(widget.species)),
        backgroundColor: color,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Animal'),
      ),
      body: Column(
        children: [
          _FilterBar(
            onSearchChanged: (v) => setState(() => _search = v),
            statusFilter: _statusFilter,
            sexFilter: _sexFilter,
            onStatusChanged: (v) => setState(() => _statusFilter = v),
            onSexChanged: (v) => setState(() => _sexFilter = v),
            color: color,
          ),
          Expanded(
            child: animalsAsync.when(
              loading: () => LoadingShimmer.list(count: 8),
              error: (err, _) => ErrorState(
                message: err.toString(),
                onRetry: () =>
                    ref.invalidate(animalsProvider(widget.species)),
              ),
              data: (animals) {
                final filtered = _filter(animals);
                if (filtered.isEmpty) {
                  return EmptyState(
                    title: 'No $speciesName found',
                    subtitle: _search.isEmpty &&
                            _statusFilter == 'all' &&
                            _sexFilter == 'all'
                        ? 'Tap + to add your first animal.'
                        : 'Try a different search term or filter.',
                  );
                }
                return _viewMode == _ViewMode.grid
                    ? _AnimalGrid(
                        animals: filtered, species: widget.species)
                    : _AnimalList(
                        animals: filtered, species: widget.species);
              },
            ),
          ),
        ],
      ),
    );
  }

  List<Animal> _filter(List<Animal> animals) {
    var list = animals;
    if (_statusFilter != 'all') {
      list = list.where((a) => a.status == _statusFilter).toList();
    }
    if (_sexFilter != 'all') {
      list = list
          .where((a) => a.sex.toLowerCase().startsWith(_sexFilter[0]))
          .toList();
    }
    if (_search.isNotEmpty) {
      final q = _search.toLowerCase();
      list = list
          .where((a) =>
              a.name.toLowerCase().contains(q) ||
              a.tagNumber.toLowerCase().contains(q) ||
              a.breed.toLowerCase().contains(q))
          .toList();
    }
    return list;
  }
}

// ── Filter bar ────────────────────────────────────────────────────────────────

class _FilterBar extends StatelessWidget {
  const _FilterBar({
    required this.onSearchChanged,
    required this.statusFilter,
    required this.sexFilter,
    required this.onStatusChanged,
    required this.onSexChanged,
    required this.color,
  });

  final ValueChanged<String> onSearchChanged;
  final String statusFilter;
  final String sexFilter;
  final ValueChanged<String> onStatusChanged;
  final ValueChanged<String> onSexChanged;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pagePaddingHorizontal,
            AppSpacing.md,
            AppSpacing.pagePaddingHorizontal,
            0,
          ),
          child: AnimalSearchBar(
            onSearch: onSearchChanged,
            hint: 'Search by name, tag or breed…',
            showRfidButton: true,
          ),
        ),
        SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.pagePaddingHorizontal,
              0,
              AppSpacing.pagePaddingHorizontal,
              AppSpacing.sm,
            ),
            children: [
              _FilterPill(
                label: 'All',
                selected: statusFilter == 'all',
                color: color,
                onTap: () => onStatusChanged('all'),
              ),
              const SizedBox(width: AppSpacing.xs),
              _FilterPill(
                label: 'Active',
                selected: statusFilter == 'active',
                color: AppColors.success,
                onTap: () => onStatusChanged(
                    statusFilter == 'active' ? 'all' : 'active'),
              ),
              const SizedBox(width: AppSpacing.xs),
              _FilterPill(
                label: 'Sold',
                selected: statusFilter == 'sold',
                color: AppColors.warning,
                onTap: () =>
                    onStatusChanged(statusFilter == 'sold' ? 'all' : 'sold'),
              ),
              const SizedBox(width: AppSpacing.sm),
              const VerticalDivider(width: 1, indent: 4, endIndent: 12),
              const SizedBox(width: AppSpacing.sm),
              _FilterPill(
                label: 'Male',
                selected: sexFilter == 'male',
                color: AppColors.tertiary,
                icon: Icons.male_rounded,
                onTap: () =>
                    onSexChanged(sexFilter == 'male' ? 'all' : 'male'),
              ),
              const SizedBox(width: AppSpacing.xs),
              _FilterPill(
                label: 'Female',
                selected: sexFilter == 'female',
                color: const Color(0xFFAD1457),
                icon: Icons.female_rounded,
                onTap: () =>
                    onSexChanged(sexFilter == 'female' ? 'all' : 'female'),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
      ],
    );
  }
}

class _FilterPill extends StatelessWidget {
  const _FilterPill({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
    this.icon,
  });

  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? color : cs.surface,
          borderRadius: AppRadius.chip,
          border: Border.all(color: selected ? color : cs.outlineVariant),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: selected ? Colors.white : color),
              const SizedBox(width: 4),
            ],
            Text(
              label,
              style: TextStyle(
                color: selected ? Colors.white : cs.onSurface,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── List mode ─────────────────────────────────────────────────────────────────

class _AnimalList extends StatelessWidget {
  const _AnimalList({required this.animals, required this.species});
  final List<Animal> animals;
  final String species;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pagePaddingHorizontal,
        AppSpacing.xs,
        AppSpacing.pagePaddingHorizontal,
        AppSpacing.xxl,
      ),
      itemCount: animals.length,
      itemBuilder: (context, i) {
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
          child: _AnimalListCard(animal: animals[i], species: species),
        );
      },
    );
  }
}

class _AnimalListCard extends StatelessWidget {
  const _AnimalListCard({required this.animal, required this.species});
  final Animal animal;
  final String species;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final color = AppColors.forSpecies(species);
    final imageUrl = LivestockConstants.animalImageUrl(
        species, animal.id,
        width: 180, height: 180);
    final statusColor = _statusColor(animal.status);
    final isFemale = animal.sex.toLowerCase().startsWith('f');

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
      color: cs.surface,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        borderRadius: AppRadius.card,
        onTap: () =>
            context.go(AppRoutes.animalDetailPath(species, animal.id)),
        child: SizedBox(
          height: 94,
          child: Row(
            children: [
              // Photo thumbnail
              SizedBox(
                width: 94,
                height: 94,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(
                    color: color.withAlpha(30),
                    child:
                        Icon(Icons.pets_rounded, color: color, size: 36),
                  ),
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return Container(color: color.withAlpha(15));
                  },
                ),
              ),
              // Content
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              animal.name,
                              style: tt.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w700),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: statusColor.withAlpha(25),
                              borderRadius:
                                  BorderRadius.circular(AppRadius.xs),
                            ),
                            child: Text(
                              animal.status.toUpperCase(),
                              style: TextStyle(
                                color: statusColor,
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${animal.tagNumber} · ${animal.breed}',
                        style: tt.bodySmall
                            ?.copyWith(color: cs.onSurfaceVariant),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            isFemale
                                ? Icons.female_rounded
                                : Icons.male_rounded,
                            size: 13,
                            color: isFemale
                                ? const Color(0xFFAD1457)
                                : AppColors.tertiary,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            animal.displaySex,
                            style: tt.labelSmall?.copyWith(
                              color: isFemale
                                  ? const Color(0xFFAD1457)
                                  : AppColors.tertiary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (animal.currentWeightKg != null) ...[
                            const SizedBox(width: 10),
                            Icon(Icons.monitor_weight_outlined,
                                size: 13, color: cs.onSurfaceVariant),
                            const SizedBox(width: 2),
                            Text(
                              animal.displayWeight,
                              style: tt.labelSmall
                                  ?.copyWith(color: cs.onSurfaceVariant),
                            ),
                          ],
                          if (animal.ageMonths != null) ...[
                            const SizedBox(width: 10),
                            Icon(Icons.access_time_rounded,
                                size: 13, color: cs.onSurfaceVariant),
                            const SizedBox(width: 2),
                            Text(
                              animal.displayAge,
                              style: tt.labelSmall
                                  ?.copyWith(color: cs.onSurfaceVariant),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: Icon(Icons.chevron_right_rounded,
                    color: cs.onSurfaceVariant, size: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _statusColor(String status) => switch (status) {
        'active' => AppColors.success,
        'sold' => AppColors.warning,
        'deceased' => AppColors.error,
        _ => AppColors.outline,
      };
}

// ── Grid mode ─────────────────────────────────────────────────────────────────

class _AnimalGrid extends StatelessWidget {
  const _AnimalGrid({required this.animals, required this.species});
  final List<Animal> animals;
  final String species;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pagePaddingHorizontal,
        AppSpacing.xs,
        AppSpacing.pagePaddingHorizontal,
        AppSpacing.xxl,
      ),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppSpacing.sm,
        mainAxisSpacing: AppSpacing.sm,
        childAspectRatio: 0.72,
      ),
      itemCount: animals.length,
      itemBuilder: (context, i) =>
          _AnimalGridCard(animal: animals[i], species: species),
    );
  }
}

class _AnimalGridCard extends StatelessWidget {
  const _AnimalGridCard({required this.animal, required this.species});
  final Animal animal;
  final String species;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final color = AppColors.forSpecies(species);
    final imageUrl = LivestockConstants.animalImageUrl(
        species, animal.id,
        width: 300, height: 260);
    final isFemale = animal.sex.toLowerCase().startsWith('f');
    final statusColor = _statusColor(animal.status);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () =>
            context.go(AppRoutes.animalDetailPath(species, animal.id)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photo area
            Expanded(
              flex: 5,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      color: color.withAlpha(30),
                      child: Icon(Icons.pets_rounded,
                          color: color, size: 48),
                    ),
                    loadingBuilder: (context, child, progress) {
                      if (progress == null) return child;
                      return Container(color: color.withAlpha(15));
                    },
                  ),
                  // Status badge
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 3),
                      decoration: BoxDecoration(
                        color: statusColor.withAlpha(220),
                        borderRadius:
                            BorderRadius.circular(AppRadius.xs),
                      ),
                      child: Text(
                        animal.status.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                  // Sex icon badge
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.black.withAlpha(120),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isFemale
                            ? Icons.female_rounded
                            : Icons.male_rounded,
                        size: 14,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Info panel
            Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.sm,
                  AppSpacing.sm,
                  AppSpacing.sm,
                  AppSpacing.sm,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      animal.name,
                      style: tt.titleSmall
                          ?.copyWith(fontWeight: FontWeight.w700),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 1),
                    Text(
                      animal.tagNumber,
                      style: tt.labelSmall
                          ?.copyWith(color: cs.onSurfaceVariant),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      animal.breed,
                      style: tt.labelSmall?.copyWith(
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        if (animal.currentWeightKg != null) ...[
                          Icon(Icons.monitor_weight_outlined,
                              size: 12, color: cs.onSurfaceVariant),
                          const SizedBox(width: 3),
                          Text(
                            animal.displayWeight,
                            style: tt.labelSmall
                                ?.copyWith(color: cs.onSurfaceVariant),
                          ),
                        ],
                        const Spacer(),
                        if (animal.ageMonths != null)
                          Text(
                            animal.displayAge,
                            style: tt.labelSmall?.copyWith(
                              color: cs.onSurfaceVariant,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(String status) => switch (status) {
        'active' => AppColors.success,
        'sold' => AppColors.warning,
        'deceased' => AppColors.error,
        _ => AppColors.primary,
      };
}

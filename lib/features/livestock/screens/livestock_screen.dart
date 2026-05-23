import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/livestock_constants.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_typography.dart';
import '../../../shared/widgets/farm_app_bar.dart';
import '../../../shared/widgets/farm_scaffold.dart';
import '../../../shared/widgets/farm_drawer.dart';
import '../../../shared/widgets/loading_shimmer.dart';
import '../../../shared/widgets/section_header.dart';
import '../providers/livestock_providers.dart';
import '../../events/providers/alerts_provider.dart';

// ── Local providers ───────────────────────────────────────────────────────────

class _HerdFilterNotifier extends Notifier<int> {
  @override
  int build() => 0;
  void set(int v) => state = v;
}

final _herdFilterProvider =
    NotifierProvider<_HerdFilterNotifier, int>(_HerdFilterNotifier.new);

class LivestockScreen extends ConsumerWidget {
  const LivestockScreen({super.key});

  // Bees use a separate apiary/hive structure — excluded from animalsProvider.
  static const _species = LivestockConstants.animalSpecies;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countsAsync = [
      for (final sp in _species) ref.watch(animalsProvider(sp)),
    ];

    final allLoaded = countsAsync.every((a) => !a.isLoading);

    int countFor(int i) {
      return countsAsync[i].when(
        data: (list) => list.length,
        loading: () => 0,
        error: (_, _) => 0,
      );
    }

    final totalAnimals = [
      for (int i = 0; i < _species.length; i++) countFor(i),
    ].fold(0, (sum, c) => sum + c);

    final alertCount = ref.watch(alertsProvider).length;

    return FarmScaffold(
      drawer: const FarmDrawer(),
      appBar: FarmAppBar(
        title: 'Herd',
        subtitle: '$totalAnimals animals across ${_species.length} species',
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            tooltip: 'Filter',
            onPressed: () => showModalBottomSheet(
              context: context,
              useSafeArea: true,
              builder: (_) => const _FilterBottomSheet(),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
      body: allLoaded
          ? _HerdContent(
              species: _species,
              countsAsync: countsAsync,
              totalAnimals: totalAnimals,
              alertCount: alertCount,
            )
          : LoadingShimmer.list(count: 8),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          useSafeArea: true,
          builder: (_) => const _AddAnimalSpeciesPicker(),
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Add Animal',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

// ── Category data ─────────────────────────────────────────────────────────────

class _HerdCategory {
  const _HerdCategory({
    required this.label,
    required this.description,
    required this.emoji,
    required this.species,
  });
  final String label;
  final String description;
  final String emoji;
  final List<String> species;
}

const _kCategories = [
  _HerdCategory(
    label: 'Herd Cattle',
    description: 'Grazing & browsing livestock',
    emoji: '🐄',
    species: ['cattle', 'sheep', 'goats'],
  ),
  _HerdCategory(
    label: 'Equine',
    description: 'Horses & working animals',
    emoji: '🐴',
    species: ['horses'],
  ),
  _HerdCategory(
    label: 'Monogastrics',
    description: 'Pigs & small mammals',
    emoji: '🐷',
    species: ['pigs', 'rabbits'],
  ),
  _HerdCategory(
    label: 'Poultry',
    description: 'Broilers, layers & game birds',
    emoji: '🐓',
    species: ['poultry'],
  ),
  _HerdCategory(
    label: 'Aquatics & Apiculture',
    description: 'Fish farming, beekeeping & specialty',
    emoji: '🐟',
    species: ['aquaculture', 'bees'],
  ),
];

// ── Hub content ───────────────────────────────────────────────────────────────

class _HerdContent extends StatelessWidget {
  const _HerdContent({
    required this.species,
    required this.countsAsync,
    required this.totalAnimals,
    required this.alertCount,
  });

  final List<String> species;
  final List<dynamic> countsAsync;
  final int totalAnimals;
  final int alertCount;

  int _count(int i) {
    final a = countsAsync[i] as AsyncValue<List>;
    return a.when(data: (v) => v.length, loading: () => 0, error: (_, _) => 0);
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, int> counts = {
      for (int i = 0; i < species.length; i++) species[i]: _count(i),
    };

    return CustomScrollView(
      slivers: [
        // Alert banner
        if (alertCount > 0)
          SliverToBoxAdapter(
            child: _HerdHealthBanner(alertCount: alertCount),
          ),

        // KPI summary row
        SliverToBoxAdapter(
          child: _KpiRow(
            totalAnimals: totalAnimals,
            speciesCount: species.length,
            alertCount: alertCount,
          ),
        ),

        // Quick actions
        const SliverToBoxAdapter(
          child: SectionHeader(title: 'Quick Actions'),
        ),
        const SliverToBoxAdapter(child: _QuickActionsRow()),
        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.sm)),

        // Livestock categories
        const SliverToBoxAdapter(
          child: SectionHeader(title: 'Livestock Categories'),
        ),
        SliverList.separated(
          itemCount: _kCategories.length,
          separatorBuilder: (context, _) =>
              const SizedBox(height: AppSpacing.sm),
          itemBuilder: (context, i) => _CategoryCard(
            category: _kCategories[i],
            counts: counts,
          ),
        ),
        const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.md)),

        // Groups
        const SliverToBoxAdapter(
          child: SectionHeader(title: 'Farm Groups'),
        ),
        const SliverToBoxAdapter(child: _GroupsCard()),

        const SliverPadding(
            padding: EdgeInsets.only(bottom: AppSpacing.xxl)),
      ],
    );
  }
}

// ── Herd health banner ────────────────────────────────────────────────────────

class _HerdHealthBanner extends StatelessWidget {
  const _HerdHealthBanner({required this.alertCount});
  final int alertCount;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Material(
      color: AppColors.warningContainer,
      child: InkWell(
        onTap: () => context.push(AppRoutes.recordAlerts),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.pagePaddingHorizontal,
            vertical: 10,
          ),
          child: Row(
            children: [
              const Icon(Icons.warning_amber_rounded,
                  color: AppColors.warning, size: 18),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Text(
                  '$alertCount animal${alertCount > 1 ? 's' : ''} need attention',
                  style: tt.bodySmall?.copyWith(
                    color: AppColors.warning,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                'View alerts →',
                style: tt.labelSmall?.copyWith(
                  color: AppColors.warning,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── KPI row ───────────────────────────────────────────────────────────────────

class _KpiRow extends StatelessWidget {
  const _KpiRow({
    required this.totalAnimals,
    required this.speciesCount,
    required this.alertCount,
  });
  final int totalAnimals;
  final int speciesCount;
  final int alertCount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pagePaddingHorizontal,
        AppSpacing.md,
        AppSpacing.pagePaddingHorizontal,
        AppSpacing.sm,
      ),
      child: Row(
        children: [
          Expanded(
            child: _KpiCard(
              value: '$totalAnimals',
              label: 'Total Animals',
              icon: Icons.pets_rounded,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: _KpiCard(
              value: '$speciesCount',
              label: 'Species',
              icon: Icons.category_rounded,
              color: AppColors.tertiary,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: _KpiCard(
              value: '$alertCount',
              label: 'Alerts',
              icon: Icons.warning_amber_rounded,
              color: alertCount > 0 ? AppColors.warning : AppColors.success,
            ),
          ),
        ],
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm, vertical: AppSpacing.sm + 2),
      decoration: BoxDecoration(
        color: color.withAlpha(12),
        borderRadius: AppRadius.card,
        border: Border.all(color: color.withAlpha(50)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 4),
          Text(
            value,
            style: AppTypography.kpiValue.copyWith(
              fontSize: 22,
              color: color,
              height: 1,
            ),
          ),
          Text(
            label,
            style: tt.labelSmall?.copyWith(
              color: cs.onSurfaceVariant,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Quick actions row ─────────────────────────────────────────────────────────

class _QuickActionsRow extends StatelessWidget {
  const _QuickActionsRow();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 82,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.pagePaddingHorizontal),
        children: [
          _QuickActionButton(
            label: 'Add Animal',
            icon: Icons.add_circle_rounded,
            color: AppColors.primary,
            onTap: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              useSafeArea: true,
              builder: (_) => const _AddAnimalSpeciesPicker(),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          _QuickActionButton(
            label: 'Alerts',
            icon: Icons.notifications_rounded,
            color: AppColors.warning,
            onTap: () => context.push(AppRoutes.recordAlerts),
          ),
          const SizedBox(width: AppSpacing.sm),
          _QuickActionButton(
            label: 'Groups',
            icon: Icons.group_work_rounded,
            color: AppColors.tertiary,
            onTap: () => context.push(AppRoutes.groups),
          ),
          const SizedBox(width: AppSpacing.sm),
          _QuickActionButton(
            label: 'LITS Export',
            icon: Icons.upload_file_rounded,
            color: AppColors.success,
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('LITS export coming soon'),
                  duration: Duration(seconds: 2)),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          _QuickActionButton(
            label: 'FMD Zone',
            icon: Icons.health_and_safety_rounded,
            color: AppColors.info,
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('FMD zone map coming soon'),
                  duration: Duration(seconds: 2)),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          _QuickActionButton(
            label: 'Market',
            icon: Icons.storefront_rounded,
            color: AppColors.secondary,
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Market prices coming soon'),
                  duration: Duration(seconds: 2)),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.card,
      child: Container(
        width: 70,
        decoration: BoxDecoration(
          color: color.withAlpha(12),
          borderRadius: AppRadius.card,
          border: Border.all(color: color.withAlpha(50)),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 5),
            Text(
              label,
              style: tt.labelSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
                height: 1.2,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Category card ─────────────────────────────────────────────────────────────

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({required this.category, required this.counts});
  final _HerdCategory category;
  final Map<String, int> counts;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final total =
        category.species.fold(0, (s, sp) => s + (counts[sp] ?? 0));
    const accent = AppColors.primary;
    const containerColor = AppColors.primaryContainer;

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.pagePaddingHorizontal),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context
              .go(AppRoutes.livestockSpeciesPath(category.species.first)),
          borderRadius: AppRadius.card,
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [containerColor, accent.withAlpha(15)],
              ),
              borderRadius: AppRadius.card,
              border: Border.all(color: accent.withAlpha(55), width: 1),
              boxShadow: AppShadows.level1,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header: emoji + name/desc + total badge + chevron
                Row(
                  children: [
                    Text(
                      category.emoji,
                      style: const TextStyle(fontSize: 26, height: 1),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            category.label,
                            style: tt.titleMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: accent,
                              height: 1.1,
                            ),
                          ),
                          Text(
                            category.description,
                            style: tt.bodySmall
                                ?.copyWith(color: cs.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.sm, vertical: 4),
                      decoration: BoxDecoration(
                        color: accent.withAlpha(18),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: accent.withAlpha(60)),
                      ),
                      child: Text(
                        '$total head',
                        style: tt.labelSmall?.copyWith(
                          color: accent,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.xs),
                    Icon(Icons.chevron_right_rounded,
                        color: accent.withAlpha(180), size: 18),
                  ],
                ),
                // Species chips shown when category has multiple species
                if (category.species.length > 1) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Divider(height: 1, color: accent.withAlpha(40)),
                  const SizedBox(height: AppSpacing.sm),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.xs,
                    children: [
                      for (final sp in category.species)
                        _SpeciesChip(species: sp, count: counts[sp] ?? 0),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SpeciesChip extends StatelessWidget {
  const _SpeciesChip({required this.species, required this.count});
  final String species;
  final int count;

  static String _emoji(String sp) => switch (sp) {
        'cattle' => '🐄',
        'sheep' => '🐑',
        'goats' => '🐐',
        'pigs' => '🐷',
        'horses' => '🐴',
        'poultry' => '🐓',
        'rabbits' => '🐇',
        'aquaculture' => '🐟',
        'bees' => '🐝',
        _ => '🐾',
      };

  @override
  Widget build(BuildContext context) {
    const accent = AppColors.primary;
    final tt = Theme.of(context).textTheme;
    return InkWell(
      onTap: () => context.go(AppRoutes.livestockSpeciesPath(species)),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: accent.withAlpha(12),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: accent.withAlpha(50)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_emoji(species),
                style: const TextStyle(fontSize: 13, height: 1)),
            const SizedBox(width: 4),
            Text(
              '${LivestockConstants.displayName(species)} · $count',
              style: tt.labelSmall?.copyWith(
                color: accent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Groups card ───────────────────────────────────────────────────────────────

class _GroupsCard extends StatelessWidget {
  const _GroupsCard();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pagePaddingHorizontal,
        0,
        AppSpacing.pagePaddingHorizontal,
        AppSpacing.md,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push(AppRoutes.groups),
          borderRadius: AppRadius.card,
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: cs.surfaceContainerLow,
              borderRadius: AppRadius.card,
              border: Border.all(color: cs.outlineVariant, width: 1),
              boxShadow: AppShadows.level1,
            ),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.tertiary.withAlpha(20),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: const Icon(Icons.group_work_rounded,
                      color: AppColors.tertiary, size: 24),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Groups & Herds',
                        style: tt.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Manage paddock groups and herd assignments',
                        style: tt.bodySmall
                            ?.copyWith(color: cs.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Icon(Icons.chevron_right_rounded,
                    color: cs.onSurfaceVariant),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Add animal species picker ─────────────────────────────────────────────────

class _AddAnimalSpeciesPicker extends StatelessWidget {
  const _AddAnimalSpeciesPicker();

  static String _emoji(String species) {
    switch (species) {
      case LivestockConstants.cattle:
        return '🐄';
      case LivestockConstants.sheep:
        return '🐑';
      case LivestockConstants.goats:
        return '🐐';
      case LivestockConstants.pigs:
        return '🐷';
      case LivestockConstants.horses:
        return '🐴';
      case LivestockConstants.poultry:
        return '🐓';
      case LivestockConstants.rabbits:
        return '🐇';
      case LivestockConstants.aquaculture:
        return '🐟';
      case LivestockConstants.bees:
        return '🐝';
      default:
        return '🐾';
    }
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: cs.outlineVariant,
                  borderRadius: AppRadius.chip,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text('Add Animal',
                style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text('Select species to add',
                style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                for (final sp in LivestockConstants.allSpecies)
                  InkWell(
                    onTap: () {
                      context.pop();
                      context.push(AppRoutes.addAnimalPath(sp));
                    },
                    borderRadius: AppRadius.card,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppSpacing.md,
                          vertical: AppSpacing.sm + 2),
                      decoration: BoxDecoration(
                        color: AppColors.forSpecies(sp).withAlpha(15),
                        borderRadius: AppRadius.card,
                        border: Border.all(
                            color: AppColors.forSpecies(sp).withAlpha(70)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(_emoji(sp),
                              style: const TextStyle(fontSize: 18)),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            LivestockConstants.displayName(sp),
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.forSpecies(sp),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
          ],
        ),
      ),
    );
  }
}

// ── Filter bottom sheet ───────────────────────────────────────────────────────

class _Filter {
  const _Filter({required this.label, required this.icon});
  final String label;
  final IconData icon;
}

class _FilterBottomSheet extends ConsumerWidget {
  const _FilterBottomSheet();

  static const _filters = [
    _Filter(label: 'All animals', icon: Icons.pets_rounded),
    _Filter(label: 'With alerts', icon: Icons.warning_amber_rounded),
    _Filter(label: 'Active only', icon: Icons.check_circle_rounded),
    _Filter(label: 'Pregnant', icon: Icons.favorite_rounded),
    _Filter(label: 'Overdue check-ups', icon: Icons.schedule_rounded),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(_herdFilterProvider);
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
            AppSpacing.sm, AppSpacing.md, AppSpacing.sm, AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Drag handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: cs.outlineVariant,
                  borderRadius: AppRadius.chip,
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              child: Text('Filter Herd',
                  style: tt.titleLarge
                      ?.copyWith(fontWeight: FontWeight.w800)),
            ),
            const SizedBox(height: AppSpacing.sm),
            for (int i = 0; i < _filters.length; i++)
              ListTile(
                leading: Icon(
                  _filters[i].icon,
                  color: i == selected
                      ? AppColors.primary
                      : cs.onSurfaceVariant,
                ),
                title: Text(
                  _filters[i].label,
                  style: TextStyle(
                    fontWeight: i == selected
                        ? FontWeight.w700
                        : FontWeight.w400,
                    color: i == selected ? AppColors.primary : cs.onSurface,
                  ),
                ),
                trailing: i == selected
                    ? const Icon(Icons.check_rounded,
                        color: AppColors.primary)
                    : null,
                shape:
                    RoundedRectangleBorder(borderRadius: AppRadius.card),
                onTap: () {
                  ref.read(_herdFilterProvider.notifier).set(i);
                  context.pop();
                },
              ),
          ],
        ),
      ),
    );
  }
}

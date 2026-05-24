import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/livestock_constants.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/bcs_indicator.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/farm_app_bar.dart';
import '../../../shared/widgets/farm_scaffold.dart';
import '../../../shared/widgets/fmd_zone_indicator.dart';
import '../../../shared/widgets/loading_shimmer.dart';
import '../../../shared/widgets/status_chip.dart';
import '../../../shared/widgets/tag_cloud.dart';
import '../../../shared/widgets/withdrawal_countdown.dart';
import '../../events/providers/events_providers.dart';
import '../../events/models/breeding_event.dart';
import '../../events/models/health_event.dart';
import '../../events/models/weight_record.dart';
import '../models/animal.dart';
import '../providers/livestock_providers.dart';

// ── Per-animal data providers ─────────────────────────────────────────────────

final _weightRecordsByAnimalProvider =
    FutureProvider.autoDispose.family<List<WeightRecord>, String>(
        (ref, animalId) async {
  final all = await ref.watch(eventsRepositoryProvider).getWeightRecords();
  return all.where((r) => r.animalId == animalId).toList()
    ..sort((a, b) => a.weighDate.compareTo(b.weighDate));
});

final _healthEventsByAnimalProvider =
    FutureProvider.autoDispose.family<List<HealthEvent>, String>(
        (ref, animalId) async {
  final all = await ref.watch(eventsRepositoryProvider).getHealthEvents();
  return all.where((e) => e.animalId == animalId).toList()
    ..sort((a, b) => b.eventDate.compareTo(a.eventDate));
});

final _breedingEventsByAnimalProvider =
    FutureProvider.autoDispose.family<List<BreedingEvent>, String>(
        (ref, animalId) async {
  final all = await ref.watch(eventsRepositoryProvider).getBreedingEvents();
  return all.where((e) => e.animalId == animalId).toList()
    ..sort((a, b) => b.serviceDate.compareTo(a.serviceDate));
});

// ── Screen ────────────────────────────────────────────────────────────────────

class AnimalDetailScreen extends ConsumerWidget {
  const AnimalDetailScreen({
    super.key,
    required this.species,
    required this.animalId,
  });

  final String species;
  final String animalId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final animalAsync =
        ref.watch(animalDetailProvider((species, animalId)));

    return animalAsync.when(
      loading: () => FarmScaffold(
        appBar: const FarmAppBar(title: 'Animal Detail'),
        body: LoadingShimmer.list(count: 6),
      ),
      error: (err, _) => FarmScaffold(
        appBar: const FarmAppBar(title: 'Animal Detail'),
        body: ErrorState(
          message: err.toString(),
          onRetry: () =>
              ref.invalidate(animalDetailProvider((species, animalId))),
        ),
      ),
      data: (animal) {
        if (animal == null) {
          return const FarmScaffold(
            appBar: FarmAppBar(title: 'Animal Detail'),
            body: EmptyState(
              title: 'Animal not found',
              subtitle: 'This record may have been removed.',
            ),
          );
        }
        return _TabbedDetailView(animal: animal);
      },
    );
  }
}

// ── Tab spec types ────────────────────────────────────────────────────────────

class _FabSpec {
  const _FabSpec({
    required this.icon,
    required this.label,
    required this.route,
  });
  final IconData icon;
  final String label;
  final String route;
}

class _TabSpec {
  const _TabSpec({
    required this.tab,
    required this.view,
    required this.fab,
  });
  final Tab tab;
  final Widget view;
  final _FabSpec fab;
}

List<_TabSpec> _buildTabSpecs(Animal animal) {
  final sp = animal.species;
  final prod = animal.productionType.toLowerCase();
  final breed = animal.breed;
  final specs = <_TabSpec>[];

  // 1. Overview — always present
  specs.add(_TabSpec(
    tab: const Tab(
        icon: Icon(Icons.info_outline_rounded, size: 18), text: 'Overview'),
    view: _OverviewTab(animal: animal),
    fab: _FabSpec(
      icon: Icons.edit_rounded,
      label: 'Edit Animal',
      route: AppRoutes.editAnimalPath(sp, animal.id),
    ),
  ));

  // 2. Health — always present
  specs.add(_TabSpec(
    tab: const Tab(
        icon: Icon(Icons.health_and_safety_outlined, size: 18),
        text: 'Health'),
    view: _HealthTab(animal: animal),
    fab: _FabSpec(
      icon: Icons.add_rounded,
      label: 'Health Event',
      route: '${AppRoutes.addRecordHealth}?animalId=${animal.id}',
    ),
  ));

  // 3. Weight — always present
  specs.add(_TabSpec(
    tab: const Tab(
        icon: Icon(Icons.monitor_weight_outlined, size: 18), text: 'Weight'),
    view: _WeightTab(animal: animal),
    fab: _FabSpec(
      icon: Icons.add_rounded,
      label: 'Record Weight',
      route: '${AppRoutes.addRecordWeight}?animalId=${animal.id}',
    ),
  ));

  // 4. Reproduction — skip bees & aquaculture (no individual breeding)
  if (sp != LivestockConstants.bees && sp != LivestockConstants.aquaculture) {
    specs.add(_TabSpec(
      tab: const Tab(
          icon: Icon(Icons.favorite_outline_rounded, size: 18),
          text: 'Reproduction'),
      view: _BreedingTab(animal: animal),
      fab: _FabSpec(
        icon: Icons.add_rounded,
        label: 'Breeding Event',
        route: '${AppRoutes.addRecordBreeding}?animalId=${animal.id}',
      ),
    ));
  }

  // 5. Milk — dairy cattle, goats, or sheep
  const dairySpecies = {
    LivestockConstants.cattle,
    LivestockConstants.goats,
    LivestockConstants.sheep,
  };
  if (dairySpecies.contains(sp) && (prod == 'milk' || prod == 'dairy')) {
    specs.add(_TabSpec(
      tab: const Tab(
          icon: Icon(Icons.water_drop_outlined, size: 18), text: 'Milk'),
      view: _MilkTab(animal: animal),
      fab: _FabSpec(
        icon: Icons.add_rounded,
        label: 'Milk Record',
        route: '${AppRoutes.addRecordMilk}?animalId=${animal.id}',
      ),
    ));
  }

  // 6. Fleece — wool sheep or Angora/Cashmere goats
  const woolBreeds = {
    'Merino',
    'Dohne Merino',
    'SA Merino',
    'Rambouillet',
    'Corriedale',
    'Romney',
    'Awassi',
  };
  final isWoolBreed = woolBreeds.any((b) => breed.contains(b));
  final isFleeceGoat = sp == LivestockConstants.goats &&
      (breed.contains('Angora') || breed.contains('Cashmere'));
  if ((sp == LivestockConstants.sheep &&
          (prod == 'wool' ||
              prod == 'fibre' ||
              prod == 'fiber' ||
              isWoolBreed)) ||
      isFleeceGoat) {
    specs.add(_TabSpec(
      tab: const Tab(
          icon: Icon(Icons.texture_rounded, size: 18), text: 'Fleece'),
      view: _FleeceTab(animal: animal),
      fab: _FabSpec(
        icon: Icons.add_rounded,
        label: 'Shear Record',
        route: '${AppRoutes.addRecordWool}?animalId=${animal.id}',
      ),
    ));
  }

  return specs;
}

// ── Tabbed detail view ────────────────────────────────────────────────────────

class _TabbedDetailView extends StatefulWidget {
  const _TabbedDetailView({required this.animal});
  final Animal animal;

  @override
  State<_TabbedDetailView> createState() => _TabbedDetailViewState();
}

class _TabbedDetailViewState extends State<_TabbedDetailView>
    with SingleTickerProviderStateMixin {
  late final List<_TabSpec> _specs;
  late final TabController _tabController;
  int _tabIndex = 0;

  @override
  void initState() {
    super.initState();
    _specs = _buildTabSpecs(widget.animal);
    _tabController = TabController(length: _specs.length, vsync: this);
    _tabController.addListener(_onTabChanged);
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging) {
      setState(() => _tabIndex = _tabController.index);
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final animal = widget.animal;
    final color = AppColors.forSpecies(animal.species);
    final cs = Theme.of(context).colorScheme;
    final fab = _specs[_tabIndex].fab;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      floatingActionButton: FloatingActionButton.extended(
        key: ValueKey(_tabIndex),
        onPressed: () => context.push(fab.route),
        backgroundColor: color,
        foregroundColor: Colors.white,
        icon: Icon(fab.icon),
        label: Text(fab.label,
            style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: NestedScrollView(
        headerSliverBuilder: (ctx, innerBoxIsScrolled) => [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: color,
            foregroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: Padding(
              padding: const EdgeInsets.all(8),
              child: GestureDetector(
                onTap: () => context.pop(),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(90),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.arrow_back_rounded,
                      color: Colors.white, size: 20),
                ),
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8),
                child: GestureDetector(
                  onTap: () => context.push(
                    AppRoutes.editAnimalPath(animal.species, animal.id),
                  ),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(90),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.edit_rounded,
                        color: Colors.white, size: 18),
                  ),
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              titlePadding:
                  const EdgeInsetsDirectional.fromSTEB(56, 0, 56, 14),
              title: Text(
                animal.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  letterSpacing: -0.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  _HeroBackground(animal: animal, color: color),
                  Positioned(
                    bottom: AppRadius.xl + 12,
                    left: AppSpacing.lg,
                    right: AppSpacing.lg,
                    child: _HeroOverlay(animal: animal, color: color),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: AppRadius.xl,
                      decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: AppRadius.topOnly,
                      ),
                    ),
                  ),
                ],
              ),
              collapseMode: CollapseMode.parallax,
            ),
          ),
          SliverToBoxAdapter(
            child: _AnimalProfileCard(animal: animal, color: color),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: _TabBarDelegate(
              surfaceColor: cs.surface,
              tabBar: TabBar(
                controller: _tabController,
                indicatorColor: color,
                labelColor: color,
                unselectedLabelColor: cs.onSurfaceVariant,
                dividerColor: cs.outlineVariant.withAlpha(60),
                indicatorWeight: 3,
                isScrollable: _specs.length > 4,
                tabAlignment: _specs.length > 4
                    ? TabAlignment.start
                    : TabAlignment.fill,
                labelStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
                unselectedLabelStyle: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                tabs: [for (final s in _specs) s.tab],
              ),
            ),
          ),
        ],
        body: ScrollConfiguration(
          behavior:
              ScrollConfiguration.of(context).copyWith(scrollbars: false),
          child: TabBarView(
            controller: _tabController,
            children: [for (final s in _specs) s.view],
          ),
        ),
      ),
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  const _TabBarDelegate(
      {required this.tabBar, required this.surfaceColor});
  final TabBar tabBar;
  final Color surfaceColor;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: surfaceColor,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).colorScheme.outlineVariant.withAlpha(80),
          ),
        ),
      ),
      child: tabBar,
    );
  }

  @override
  double get maxExtent => tabBar.preferredSize.height;
  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  bool shouldRebuild(_TabBarDelegate old) => tabBar != old.tabBar;
}

// ── Hero background ───────────────────────────────────────────────────────────

class _HeroBackground extends StatelessWidget {
  const _HeroBackground({required this.animal, required this.color});
  final Animal animal;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final imageUrl = LivestockConstants.animalImageUrl(
      animal.species,
      animal.id,
      width: 800,
      height: 500,
    );

    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => Container(
            color: color,
            child: Icon(Icons.pets_rounded,
                size: 80, color: Colors.white.withAlpha(80)),
          ),
          loadingBuilder: (_, child, progress) {
            if (progress == null) return child;
            return Container(
              color: color.withAlpha(200),
              child: Center(
                child: CircularProgressIndicator(
                  color: Colors.white.withAlpha(180),
                  strokeWidth: 2,
                ),
              ),
            );
          },
        ),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xCC000000), Colors.transparent],
              stops: [0.0, 0.40],
            ),
          ),
        ),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.transparent, Color(0xBB000000)],
              stops: [0.40, 1.0],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Hero overlay ──────────────────────────────────────────────────────────────

class _HeroOverlay extends StatelessWidget {
  const _HeroOverlay({required this.animal, required this.color});
  final Animal animal;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          animal.name,
          style: tt.headlineMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            height: 1.1,
            shadows: const [Shadow(blurRadius: 12, color: Colors.black54)],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Tag: ${animal.tagNumber}  ·  ${LivestockConstants.displayName(animal.species)}',
          style: tt.bodyMedium?.copyWith(color: Colors.white.withAlpha(210)),
        ),
        const SizedBox(height: AppSpacing.sm),
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: [
            _HeroBadge(
              label: animal.status.toUpperCase(),
              color: animal.isActive ? AppColors.success : AppColors.outline,
            ),
            _HeroBadge(
              label: animal.displaySex.toUpperCase(),
              color: animal.sex.toLowerCase().startsWith('f')
                  ? const Color(0xFFAD1457)
                  : AppColors.tertiary,
            ),
            if (animal.breed.isNotEmpty)
              _HeroBadge(label: animal.breed, color: color),
          ],
        ),
      ],
    );
  }
}

class _HeroBadge extends StatelessWidget {
  const _HeroBadge({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(200),
        borderRadius: BorderRadius.circular(AppRadius.xs),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}

// ── Animal profile card ───────────────────────────────────────────────────────

class _AnimalProfileCard extends StatelessWidget {
  const _AnimalProfileCard({required this.animal, required this.color});
  final Animal animal;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final vaccColor = switch (animal.vaccinationStatus) {
      'up_to_date' => AppColors.success,
      'overdue' => AppColors.error,
      'partial' => AppColors.warning,
      _ => AppColors.outline,
    };

    final vaccLabel = switch (animal.vaccinationStatus) {
      'up_to_date' => 'Current',
      'overdue' => 'Overdue',
      'partial' => 'Partial',
      _ => '—',
    };

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pagePaddingHorizontal,
        AppSpacing.md,
        AppSpacing.pagePaddingHorizontal,
        AppSpacing.sm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: AppSpacing.md),
              decoration: BoxDecoration(
                color: cs.outlineVariant,
                borderRadius: AppRadius.chip,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: AppRadius.card,
              boxShadow: AppShadows.level1,
              border: Border.all(color: cs.outlineVariant.withAlpha(60)),
            ),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  Expanded(
                    child: _QuickStat(
                      icon: Icons.monitor_weight_outlined,
                      value: animal.displayWeight,
                      label: 'Weight',
                      color: color,
                    ),
                  ),
                  _VertDivider(cs),
                  Expanded(
                    child: _QuickStat(
                      icon: Icons.cake_outlined,
                      value: animal.displayAge,
                      label: 'Age',
                      color: color,
                    ),
                  ),
                  _VertDivider(cs),
                  Expanded(
                    child: _QuickStat(
                      icon: Icons.fitness_center_outlined,
                      value: animal.bodyConditionScore != null
                          ? 'BCS ${animal.bodyConditionScore}'
                          : '—',
                      label: 'Condition',
                      color: color,
                    ),
                  ),
                  if (animal.vaccinationStatus != null) ...[
                    _VertDivider(cs),
                    Expanded(
                      child: _QuickStat(
                        icon: Icons.vaccines_outlined,
                        value: vaccLabel,
                        label: 'Vaccines',
                        color: vaccColor,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          if (animal.productionType.isNotEmpty ||
              animal.locationPaddock != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.xs,
              runSpacing: AppSpacing.xs,
              children: [
                if (animal.productionType.isNotEmpty)
                  _MetaChip(
                      icon: Icons.category_outlined,
                      label: animal.productionType,
                      cs: cs,
                      tt: tt),
                if (animal.locationPaddock != null)
                  _MetaChip(
                      icon: Icons.location_on_outlined,
                      label: animal.locationPaddock!,
                      cs: cs,
                      tt: tt),
              ],
            ),
          ],
          const SizedBox(height: AppSpacing.xs),
        ],
      ),
    );
  }
}

class _QuickStat extends StatelessWidget {
  const _QuickStat({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(height: 5),
          Text(
            value,
            style: tt.labelMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: cs.onSurface,
              height: 1,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: tt.labelSmall?.copyWith(
              color: cs.onSurfaceVariant,
              fontSize: 10,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _VertDivider extends StatelessWidget {
  const _VertDivider(this.cs);
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    return VerticalDivider(
        width: 1,
        thickness: 1,
        color: cs.outlineVariant.withAlpha(80));
  }
}

class _MetaChip extends StatelessWidget {
  const _MetaChip(
      {required this.icon,
      required this.label,
      required this.cs,
      required this.tt});
  final IconData icon;
  final String label;
  final ColorScheme cs;
  final TextTheme tt;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: AppRadius.chip,
        border: Border.all(color: cs.outlineVariant.withAlpha(80)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: cs.onSurfaceVariant),
          const SizedBox(width: 4),
          Text(label,
              style: tt.labelSmall?.copyWith(
                  color: cs.onSurfaceVariant,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// TAB: OVERVIEW
// ═══════════════════════════════════════════════════════════════════════════════

class _OverviewTab extends StatelessWidget {
  const _OverviewTab({required this.animal});
  final Animal animal;

  @override
  Widget build(BuildContext context) {
    final color = AppColors.forSpecies(animal.species);
    final isVaccOverdue = animal.vaccinationStatus == 'overdue';
    final inFmdZone = animal.isInFmdZone;

    return ListView(
      padding: const EdgeInsets.only(
          bottom: AppSpacing.xxl + 32, top: AppSpacing.sm),
      children: [
        // ── Alert banner ─────────────────────────────────────────────────────
        if (isVaccOverdue)
          _AlertBanner(
            icon: Icons.warning_amber_rounded,
            message: 'Vaccination overdue — schedule a health check',
            color: AppColors.error,
          ),
        if (inFmdZone && !isVaccOverdue)
          _AlertBanner(
            icon: Icons.location_off_rounded,
            message:
                '${animal.displayFmdZone} — movement permit (B313) required',
            color: AppColors.warning,
          ),

        // ── Health status card ────────────────────────────────────────────────
        _HealthStatusCard(animal: animal, color: color),

        // ── Identity ─────────────────────────────────────────────────────────
        _SectionCard(
          title: 'Identity',
          icon: Icons.badge_outlined,
          child: _IconIdentityGrid(animal: animal),
        ),

        // ── Body Condition ────────────────────────────────────────────────────
        if (animal.bodyConditionScore != null)
          _SectionCard(
            title: 'Body Condition Score',
            icon: Icons.fitness_center_outlined,
            child: _BcsSection(animal: animal),
          ),

        // ── SA Compliance ─────────────────────────────────────────────────────
        _SAComplianceSection(animal: animal),

        // ── Tags ─────────────────────────────────────────────────────────────
        _TagSection(animal: animal),
      ],
    );
  }
}

// ── Alert banner ──────────────────────────────────────────────────────────────

class _AlertBanner extends StatelessWidget {
  const _AlertBanner(
      {required this.icon, required this.message, required this.color});
  final IconData icon;
  final String message;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Container(
      margin: const EdgeInsets.fromLTRB(
          AppSpacing.pagePaddingHorizontal, AppSpacing.sm,
          AppSpacing.pagePaddingHorizontal, 0),
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: 10),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: AppRadius.card,
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(message,
                style: tt.bodySmall?.copyWith(
                    color: color, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}

// ── Health status card ────────────────────────────────────────────────────────

class _HealthStatusCard extends StatelessWidget {
  const _HealthStatusCard(
      {required this.animal, required this.color});
  final Animal animal;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final vaccColor = switch (animal.vaccinationStatus) {
      'up_to_date' => AppColors.success,
      'overdue' => AppColors.error,
      'partial' => AppColors.warning,
      _ => AppColors.outline,
    };
    final vaccLabel = switch (animal.vaccinationStatus) {
      'up_to_date' => 'Up to Date',
      'overdue' => 'Overdue',
      'partial' => 'Partially Vaccinated',
      _ => 'Unknown',
    };
    final vaccIcon = switch (animal.vaccinationStatus) {
      'up_to_date' => Icons.verified_rounded,
      'overdue' => Icons.warning_amber_rounded,
      'partial' => Icons.pending_rounded,
      _ => Icons.help_outline_rounded,
    };

    return Container(
      margin: const EdgeInsets.fromLTRB(
          AppSpacing.pagePaddingHorizontal, AppSpacing.md,
          AppSpacing.pagePaddingHorizontal, 0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [vaccColor.withAlpha(28), vaccColor.withAlpha(8)],
        ),
        borderRadius: AppRadius.card,
        border: Border.all(color: vaccColor.withAlpha(70)),
      ),
      child: Column(
        children: [
          // Top: vaccination status
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: vaccColor.withAlpha(25),
                    borderRadius: AppRadius.button,
                  ),
                  child: Icon(vaccIcon, color: vaccColor, size: 26),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Vaccination Status',
                          style: tt.labelSmall
                              ?.copyWith(color: cs.onSurfaceVariant)),
                      Text(vaccLabel,
                          style: tt.titleMedium?.copyWith(
                              color: vaccColor,
                              fontWeight: FontWeight.w800)),
                      if (animal.lastHealthCheck != null)
                        Text('Last check: ${animal.lastHealthCheck}',
                            style: tt.bodySmall
                                ?.copyWith(color: cs.onSurfaceVariant)),
                    ],
                  ),
                ),
                StatusChip(
                  label: animal.status.toUpperCase(),
                  color: animal.isActive
                      ? AppColors.success
                      : AppColors.outline,
                ),
              ],
            ),
          ),
          // Bottom stats row
          Divider(height: 1, color: vaccColor.withAlpha(50)),
          IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                    child: _MiniStat(
                  icon: Icons.monitor_weight_outlined,
                  label: 'Weight',
                  value: animal.displayWeight,
                  color: color,
                )),
                VerticalDivider(
                    width: 1, color: vaccColor.withAlpha(40)),
                Expanded(
                    child: _MiniStat(
                  icon: Icons.calendar_today_outlined,
                  label: 'Last Weighed',
                  value: animal.lastWeighedDate ?? '—',
                  color: color,
                )),
                VerticalDivider(
                    width: 1, color: vaccColor.withAlpha(40)),
                Expanded(
                    child: _MiniStat(
                  icon: Icons.fitness_center_outlined,
                  label: 'Condition',
                  value: animal.bodyConditionScore != null
                      ? 'BCS ${animal.bodyConditionScore}'
                      : '—',
                  color: color,
                )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat(
      {required this.icon,
      required this.label,
      required this.value,
      required this.color});
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(height: 3),
          Text(value,
              style: tt.labelSmall?.copyWith(
                  fontWeight: FontWeight.w700, color: cs.onSurface),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis),
          Text(label,
              style: tt.labelSmall
                  ?.copyWith(color: cs.onSurfaceVariant, fontSize: 9),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

// ── Icon identity grid ────────────────────────────────────────────────────────

class _IconIdentityGrid extends StatelessWidget {
  const _IconIdentityGrid({required this.animal});
  final Animal animal;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final items = [
      _IconInfo(Icons.category_outlined, 'Breed', animal.breed),
      _IconInfo(Icons.agriculture_outlined, 'Production',
          animal.productionType.isEmpty ? '—' : animal.productionType),
      _IconInfo(Icons.cake_outlined, 'Date of Birth',
          animal.dateOfBirth ?? '—'),
      _IconInfo(Icons.schedule_outlined, 'Age', animal.displayAge),
      _IconInfo(Icons.location_on_outlined, 'Paddock',
          animal.locationPaddock ?? '—'),
      _IconInfo(Icons.group_outlined, 'Herd', animal.herdId ?? '—'),
    ];

    return Column(
      children: [
        for (int i = 0; i < items.length; i += 2) ...[
          if (i > 0) Divider(height: 1, color: cs.outlineVariant.withAlpha(60)),
          Row(
            children: [
              Expanded(child: _IconInfoCell(item: items[i])),
              Container(
                  width: 1,
                  height: 52,
                  color: cs.outlineVariant.withAlpha(60)),
              Expanded(
                child: i + 1 < items.length
                    ? _IconInfoCell(item: items[i + 1])
                    : const SizedBox(),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _IconInfo {
  const _IconInfo(this.icon, this.label, this.value);
  final IconData icon;
  final String label;
  final String value;
}

class _IconInfoCell extends StatelessWidget {
  const _IconInfoCell({required this.item});
  final _IconInfo item;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: 10),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: cs.surfaceContainerLow,
              borderRadius: AppRadius.button,
            ),
            child: Icon(item.icon, size: 15, color: cs.onSurfaceVariant),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.label,
                    style: tt.labelSmall
                        ?.copyWith(color: cs.onSurfaceVariant, fontSize: 10)),
                Text(item.value,
                    style: tt.bodySmall
                        ?.copyWith(fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// TAB: HEALTH
// ═══════════════════════════════════════════════════════════════════════════════

class _HealthTab extends ConsumerWidget {
  const _HealthTab({required this.animal});
  final Animal animal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = AppColors.forSpecies(animal.species);
    final eventsAsync = ref.watch(_healthEventsByAnimalProvider(animal.id));

    return eventsAsync.when(
      loading: () => ListView(
        padding: const EdgeInsets.all(AppSpacing.pagePaddingHorizontal),
        children: [LoadingShimmer.list(count: 5)],
      ),
      error: (_, _) => const Center(
        child: EmptyState(
          title: 'Could not load events',
          subtitle: 'Pull down to retry.',
          icon: Icon(Icons.sync_problem_rounded),
        ),
      ),
      data: (events) {
        final activeWithdrawals =
            events.where((e) => e.isWithdrawalActive).toList();

        return ListView(
          padding: const EdgeInsets.only(
              bottom: AppSpacing.xxl + 32, top: AppSpacing.sm),
          children: [
            // Active withdrawal banner
            if (activeWithdrawals.isNotEmpty)
              _WithdrawalBanner(events: activeWithdrawals),

            // FAMACHA eye score — sheep & goats only
            if (animal.species == LivestockConstants.sheep ||
                animal.species == LivestockConstants.goats)
              _FamachaCard(animal: animal),

            // Current health summary card
            _CurrentHealthCard(animal: animal, color: color),

            // History section
            if (events.isEmpty)
              const Padding(
                padding: EdgeInsets.only(top: AppSpacing.xl),
                child: EmptyState(
                  title: 'No health events yet',
                  subtitle:
                      'Vaccinations and treatments will appear here once logged.',
                  icon: Icon(Icons.vaccines_outlined),
                ),
              )
            else ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.pagePaddingHorizontal,
                    AppSpacing.md,
                    AppSpacing.pagePaddingHorizontal,
                    AppSpacing.xs),
                child: Row(children: [
                  Text('Health History',
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: color.withAlpha(20),
                      borderRadius: AppRadius.chip,
                    ),
                    child: Text('${events.length}',
                        style: Theme.of(context)
                            .textTheme
                            .labelSmall
                            ?.copyWith(
                                color: color,
                                fontWeight: FontWeight.w700)),
                  ),
                ]),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.pagePaddingHorizontal),
                child: _HealthTimeline(events: events),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _WithdrawalBanner extends StatelessWidget {
  const _WithdrawalBanner({required this.events});
  final List<HealthEvent> events;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Container(
      margin: const EdgeInsets.fromLTRB(
          AppSpacing.pagePaddingHorizontal, AppSpacing.sm,
          AppSpacing.pagePaddingHorizontal, 0),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.warning.withAlpha(20),
        borderRadius: AppRadius.card,
        border: Border.all(color: AppColors.warning.withAlpha(80)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Icon(Icons.timer_outlined,
                color: AppColors.warning, size: 18),
            const SizedBox(width: 6),
            Text('Active Withdrawal Periods',
                style: tt.labelMedium?.copyWith(
                    color: AppColors.warning,
                    fontWeight: FontWeight.w700)),
          ]),
          const SizedBox(height: AppSpacing.sm),
          ...events.map((e) => Padding(
                padding: const EdgeInsets.only(top: 4),
                child: WithdrawalCountdown(
                  productName: e.productName ?? 'Medication',
                  withdrawalEndDate: e.withdrawalEndDate!,
                  daysRemaining: e.withdrawalDaysRemaining,
                  compact: true,
                ),
              )),
        ],
      ),
    );
  }
}

class _CurrentHealthCard extends StatelessWidget {
  const _CurrentHealthCard(
      {required this.animal, required this.color});
  final Animal animal;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.fromLTRB(
          AppSpacing.pagePaddingHorizontal, AppSpacing.md,
          AppSpacing.pagePaddingHorizontal, 0),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: AppRadius.card,
        boxShadow: AppShadows.level1,
        border: Border.all(color: cs.outlineVariant.withAlpha(50)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.sm),
            child: Row(children: [
              Icon(Icons.medical_services_outlined,
                  size: 16, color: AppColors.primary),
              const SizedBox(width: AppSpacing.xs),
              Text('Current Status',
                  style: tt.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700)),
            ]),
          ),
          Divider(height: 1, color: cs.outlineVariant.withAlpha(80)),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                if (animal.vaccinationStatus != null)
                  _HealthChip(
                    icon: Icons.vaccines_outlined,
                    label: 'Vaccines: ${animal.vaccinationStatus!.replaceAll('_', ' ').toUpperCase()}',
                    color: switch (animal.vaccinationStatus) {
                      'up_to_date' => AppColors.success,
                      'overdue' => AppColors.error,
                      _ => AppColors.warning,
                    },
                  ),
                if (animal.lastHealthCheck != null)
                  _HealthChip(
                    icon: Icons.calendar_today_outlined,
                    label: 'Checked: ${animal.lastHealthCheck}',
                    color: color,
                  ),
                if (animal.bodyConditionScore != null)
                  _HealthChip(
                    icon: Icons.fitness_center_outlined,
                    label: 'BCS: ${animal.bodyConditionScore}/5',
                    color: color,
                  ),
                if (animal.currentWeightKg != null)
                  _HealthChip(
                    icon: Icons.monitor_weight_outlined,
                    label: animal.displayWeight,
                    color: color,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _HealthChip extends StatelessWidget {
  const _HealthChip(
      {required this.icon, required this.label, required this.color});
  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withAlpha(18),
        borderRadius: AppRadius.chip,
        border: Border.all(color: color.withAlpha(50)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(label,
              style: tt.labelSmall?.copyWith(
                  color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// ── Health timeline ───────────────────────────────────────────────────────────

class _HealthTimeline extends StatelessWidget {
  const _HealthTimeline({required this.events});
  final List<HealthEvent> events;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (int i = 0; i < events.length; i++)
          _TimelineTile(
            event: events[i],
            isLast: i == events.length - 1,
          ),
      ],
    );
  }
}

class _TimelineTile extends StatelessWidget {
  const _TimelineTile({required this.event, required this.isLast});
  final HealthEvent event;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final typeColor = switch (event.eventType) {
      'vaccination' => AppColors.success,
      'treatment' => AppColors.warning,
      'examination' => AppColors.tertiary,
      'surgery' => AppColors.error,
      'deworming' => AppColors.secondary,
      _ => AppColors.outline,
    };

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Left: dot + connecting line
        SizedBox(
          width: 20,
          child: Column(
            children: [
              const SizedBox(height: 14),
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: typeColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      width: 2),
                  boxShadow: [
                    BoxShadow(
                        color: typeColor.withAlpha(60), blurRadius: 4)
                  ],
                ),
              ),
              if (!isLast)
                Container(
                  width: 2,
                  height: 56,
                  color: cs.outlineVariant,
                ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: _HealthEventCard(event: event, typeColor: typeColor),
          ),
        ),
      ],
    );
  }
}

class _HealthEventCard extends StatelessWidget {
  const _HealthEventCard(
      {required this.event, required this.typeColor});
  final HealthEvent event;
  final Color typeColor;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: AppRadius.card,
        boxShadow: AppShadows.level1,
        border: Border(
          left: BorderSide(color: typeColor, width: 3),
          top: BorderSide(color: cs.outlineVariant.withAlpha(40)),
          right: BorderSide(color: cs.outlineVariant.withAlpha(40)),
          bottom: BorderSide(color: cs.outlineVariant.withAlpha(40)),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.md, AppSpacing.sm, AppSpacing.md, 0),
            child: Row(
              children: [
                StatusChip(
                    label: event.displayType,
                    color: typeColor,
                    small: true),
                const SizedBox(width: AppSpacing.xs),
                Expanded(
                  child: Text(event.eventDate,
                      style: tt.labelSmall
                          ?.copyWith(color: cs.onSurfaceVariant),
                      textAlign: TextAlign.right),
                ),
                if (event.costZar != null) ...[
                  const SizedBox(width: AppSpacing.xs),
                  Text('R${event.costZar!.toStringAsFixed(0)}',
                      style: tt.labelMedium?.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w700)),
                ],
              ],
            ),
          ),
          // Body
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.md, 4, AppSpacing.md, AppSpacing.sm),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (event.description != null)
                  Text(event.description!,
                      style: tt.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w600)),
                if (event.productName != null) ...[
                  const SizedBox(height: 2),
                  Row(children: [
                    Icon(Icons.vaccines_outlined,
                        size: 12, color: cs.onSurfaceVariant),
                    const SizedBox(width: 4),
                    Text(event.productName!,
                        style: tt.bodySmall
                            ?.copyWith(color: cs.onSurfaceVariant)),
                  ]),
                ],
                if (event.isWithdrawalActive &&
                    event.withdrawalEndDate != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  WithdrawalCountdown(
                    productName: event.productName ?? 'Medication',
                    withdrawalEndDate: event.withdrawalEndDate!,
                    daysRemaining: event.withdrawalDaysRemaining,
                    compact: true,
                  ),
                ],
                if (event.isNotifiable) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.error.withAlpha(15),
                      borderRadius: AppRadius.chip,
                      border: Border.all(
                          color: AppColors.error.withAlpha(50)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.report_outlined,
                            size: 11, color: AppColors.error),
                        const SizedBox(width: 4),
                        Text('Notifiable disease — DAFF report required',
                            style: tt.labelSmall?.copyWith(
                                color: AppColors.error,
                                fontWeight: FontWeight.w600,
                                fontSize: 10)),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// TAB: WEIGHT
// ═══════════════════════════════════════════════════════════════════════════════

class _WeightTab extends ConsumerWidget {
  const _WeightTab({required this.animal});
  final Animal animal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final color = AppColors.forSpecies(animal.species);
    final recordsAsync =
        ref.watch(_weightRecordsByAnimalProvider(animal.id));

    return recordsAsync.when(
      loading: () => ListView(
        padding: const EdgeInsets.all(AppSpacing.pagePaddingHorizontal),
        children: [LoadingShimmer.list(count: 4)],
      ),
      error: (_, _) => const Center(
        child: EmptyState(
          title: 'Could not load records',
          subtitle: 'Pull down to retry.',
          icon: Icon(Icons.show_chart_rounded),
        ),
      ),
      data: (records) {
        final trend = records.length >= 2
            ? records.last.weightKg -
                records[records.length - 2].weightKg
            : null;
        final latestAdg = records.isNotEmpty
            ? records.last.adgSinceLastKg
            : null;

        return ListView(
          padding: const EdgeInsets.only(
              bottom: AppSpacing.xxl + 32, top: AppSpacing.sm),
          children: [
            // Weight hero card
            _WeightHeroCard(
              animal: animal,
              color: color,
              trend: trend,
              latestAdg: latestAdg,
              recordCount: records.length,
            ),

            // Weight history chart / empty state
            if (records.length >= 2) ...[
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.pagePaddingHorizontal,
                    AppSpacing.md,
                    AppSpacing.pagePaddingHorizontal,
                    0),
                child: Text('Weight History',
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700)),
              ),
              _WeightChart(records: records, species: animal.species),
            ] else
              const Padding(
                padding: EdgeInsets.only(top: AppSpacing.xl),
                child: EmptyState(
                  title: 'No Weight History',
                  subtitle:
                      'Log 2 or more weigh-ins to view a growth chart.',
                  icon: Icon(Icons.show_chart_rounded),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _WeightHeroCard extends StatelessWidget {
  const _WeightHeroCard({
    required this.animal,
    required this.color,
    required this.trend,
    required this.latestAdg,
    required this.recordCount,
  });
  final Animal animal;
  final Color color;
  final double? trend;
  final double? latestAdg;
  final int recordCount;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final trendUp = trend != null && trend! >= 0;
    final trendColor =
        trend == null ? cs.onSurfaceVariant : (trendUp ? AppColors.success : AppColors.error);
    final trendIcon =
        trendUp ? Icons.trending_up_rounded : Icons.trending_down_rounded;

    return Container(
      margin: const EdgeInsets.fromLTRB(
          AppSpacing.pagePaddingHorizontal, AppSpacing.md,
          AppSpacing.pagePaddingHorizontal, 0),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [color.withAlpha(28), color.withAlpha(8)],
        ),
        borderRadius: AppRadius.card,
        border: Border.all(color: color.withAlpha(60)),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left: big weight number
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Current Weight',
                        style: tt.labelSmall
                            ?.copyWith(color: cs.onSurfaceVariant)),
                    const SizedBox(height: 4),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          animal.currentWeightKg != null
                              ? animal.currentWeightKg!
                                  .toStringAsFixed(0)
                              : '—',
                          style: tt.displaySmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: color,
                            height: 1,
                          ),
                        ),
                        if (animal.currentWeightKg != null)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(' kg',
                                style: tt.titleMedium?.copyWith(
                                    color: cs.onSurfaceVariant)),
                          ),
                      ],
                    ),
                    if (animal.lastWeighedDate != null) ...[
                      const SizedBox(height: 4),
                      Text('Weighed: ${animal.lastWeighedDate}',
                          style: tt.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant)),
                    ],
                  ],
                ),
              ),
              // Right: trend + ADG
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (trend != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: trendColor.withAlpha(20),
                        borderRadius: AppRadius.chip,
                        border: Border.all(
                            color: trendColor.withAlpha(60)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(trendIcon,
                              size: 14, color: trendColor),
                          const SizedBox(width: 4),
                          Text(
                            '${trend! >= 0 ? '+' : ''}${trend!.toStringAsFixed(1)} kg',
                            style: tt.labelSmall?.copyWith(
                                color: trendColor,
                                fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: AppSpacing.xs),
                  Text('$recordCount weigh-ins',
                      style: tt.labelSmall
                          ?.copyWith(color: cs.onSurfaceVariant)),
                ],
              ),
            ],
          ),
          if (latestAdg != null) ...[
            const SizedBox(height: AppSpacing.md),
            Divider(height: 1, color: color.withAlpha(40)),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Icon(Icons.speed_outlined, size: 16, color: color),
                const SizedBox(width: 6),
                Text('Average Daily Gain:',
                    style: tt.bodySmall
                        ?.copyWith(color: cs.onSurfaceVariant)),
                const SizedBox(width: 6),
                Text(
                  '${latestAdg! >= 0 ? '+' : ''}${latestAdg!.toStringAsFixed(2)} kg/day',
                  style: tt.bodySmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: latestAdg! >= 0
                        ? AppColors.success
                        : AppColors.error,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: (latestAdg! >= 0.6
                            ? AppColors.success
                            : AppColors.warning)
                        .withAlpha(20),
                    borderRadius: AppRadius.chip,
                  ),
                  child: Text(
                    latestAdg! >= 0.8
                        ? 'Excellent'
                        : latestAdg! >= 0.5
                            ? 'Good'
                            : 'Below target',
                    style: tt.labelSmall?.copyWith(
                      color: latestAdg! >= 0.8
                          ? AppColors.success
                          : AppColors.warning,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _WeightChart extends StatelessWidget {
  const _WeightChart({required this.records, required this.species});
  final List<WeightRecord> records;
  final String species;

  @override
  Widget build(BuildContext context) {
    final color = AppColors.forSpecies(species);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final spots = records.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.weightKg);
    }).toList();

    final minY = records
        .map((r) => r.weightKg)
        .reduce((a, b) => a < b ? a : b);
    final maxY = records
        .map((r) => r.weightKg)
        .reduce((a, b) => a > b ? a : b);
    final padding = (maxY - minY) < 5 ? 5.0 : (maxY - minY) * 0.15;

    return Container(
      margin: const EdgeInsets.fromLTRB(
          AppSpacing.pagePaddingHorizontal, AppSpacing.sm,
          AppSpacing.pagePaddingHorizontal, 0),
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.sm, AppSpacing.md, AppSpacing.sm, AppSpacing.sm),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: AppRadius.card,
        boxShadow: AppShadows.level1,
        border: Border.all(color: cs.outlineVariant.withAlpha(50)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(
                left: AppSpacing.sm, bottom: AppSpacing.sm),
            child: Row(children: [
              Icon(Icons.show_chart_rounded,
                  size: 16, color: AppColors.primary),
              const SizedBox(width: AppSpacing.xs),
              Text('Growth Trend',
                  style: tt.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700)),
            ]),
          ),
          SizedBox(
            height: 200,
            child: LineChart(
              LineChartData(
                minY: minY - padding,
                maxY: maxY + padding,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: cs.outlineVariant.withAlpha(80),
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 44,
                      getTitlesWidget: (v, _) => Text(
                        '${v.toStringAsFixed(0)}kg',
                        style: tt.labelSmall?.copyWith(
                            color: cs.onSurfaceVariant, fontSize: 9),
                      ),
                    ),
                  ),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (v, _) {
                        final idx = v.toInt();
                        if (idx < 0 || idx >= records.length) {
                          return const SizedBox.shrink();
                        }
                        final date = records[idx].weighDate;
                        final parts = date.split('-');
                        final label = parts.length >= 2
                            ? '${parts[2]}/${parts[1]}'
                            : date;
                        return Text(label,
                            style: tt.labelSmall?.copyWith(
                                color: cs.onSurfaceVariant,
                                fontSize: 9));
                      },
                    ),
                  ),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                ),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots,
                    isCurved: true,
                    color: color,
                    barWidth: 2.5,
                    belowBarData: BarAreaData(
                        show: true, color: color.withAlpha(30)),
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, pct, bar, idx) =>
                          FlDotCirclePainter(
                        radius: 4,
                        color: color,
                        strokeWidth: 2,
                        strokeColor: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════════
// TAB: BREEDING
// ═══════════════════════════════════════════════════════════════════════════════

class _BreedingTab extends ConsumerWidget {
  const _BreedingTab({required this.animal});
  final Animal animal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final eventsAsync =
        ref.watch(_breedingEventsByAnimalProvider(animal.id));

    return eventsAsync.when(
      loading: () => ListView(
        padding: const EdgeInsets.all(AppSpacing.pagePaddingHorizontal),
        children: [LoadingShimmer.list(count: 3)],
      ),
      error: (_, _) => const Center(
        child: EmptyState(
          title: 'Could not load records',
          subtitle: 'Pull down to retry.',
          icon: Icon(Icons.sync_problem_rounded),
        ),
      ),
      data: (events) {
        if (events.isEmpty) {
          return const Center(
            child: EmptyState(
              title: 'No Breeding Records',
              subtitle:
                  'Mating, pregnancy checks, and birth events will appear here.',
              icon: Icon(Icons.favorite_outline_rounded),
            ),
          );
        }

        // Find confirmed pregnancy with future expected birth date
        BreedingEvent? activePregnancy;
        for (final e in events) {
          if (e.pregnancyResult == 'confirmed_pregnant' &&
              e.expectedBirthDate != null) {
            final expected = DateTime.tryParse(e.expectedBirthDate!);
            if (expected != null && expected.isAfter(DateTime.now())) {
              activePregnancy = e;
              break;
            }
          }
        }

        return ListView(
          padding: const EdgeInsets.only(
              bottom: AppSpacing.xxl + 32, top: AppSpacing.sm),
          children: [
            if (activePregnancy != null)
              _PregnancyCard(
                  event: activePregnancy, species: animal.species),

            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pagePaddingHorizontal,
                  AppSpacing.md,
                  AppSpacing.pagePaddingHorizontal,
                  AppSpacing.xs),
              child: Row(children: [
                Text('Breeding History',
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE91E63).withAlpha(20),
                    borderRadius: AppRadius.chip,
                  ),
                  child: Text('${events.length}',
                      style: Theme.of(context)
                          .textTheme
                          .labelSmall
                          ?.copyWith(
                              color: const Color(0xFFE91E63),
                              fontWeight: FontWeight.w700)),
                ),
              ]),
            ),
            ...events.map((e) => Padding(
                  padding: const EdgeInsets.fromLTRB(
                      AppSpacing.pagePaddingHorizontal,
                      0,
                      AppSpacing.pagePaddingHorizontal,
                      AppSpacing.sm),
                  child: _BreedingEventCard(event: e),
                )),
          ],
        );
      },
    );
  }
}

class _PregnancyCard extends StatelessWidget {
  const _PregnancyCard(
      {required this.event, required this.species});
  final BreedingEvent event;
  final String species;

  static const _gestation = {
    'cattle': 283,
    'sheep': 147,
    'goats': 150,
    'pigs': 114,
    'horses': 340,
  };

  String _formatDate(String iso) {
    try {
      final d = DateTime.parse(iso);
      return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
    } catch (_) {
      return iso;
    }
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    const pink = Color(0xFFE91E63);

    final expected = DateTime.parse(event.expectedBirthDate!);
    final daysRemaining =
        expected.difference(DateTime.now()).inDays.clamp(0, 999);

    final serviceDate = DateTime.tryParse(event.serviceDate);
    final gestDays = _gestation[species] ?? 280;
    final daysGestated = serviceDate != null
        ? DateTime.now().difference(serviceDate).inDays
        : null;
    final progress = daysGestated != null
        ? (daysGestated / gestDays).clamp(0.0, 1.0)
        : null;

    return Container(
      margin: const EdgeInsets.fromLTRB(
          AppSpacing.pagePaddingHorizontal, AppSpacing.md,
          AppSpacing.pagePaddingHorizontal, 0),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0x1AE91E63), Color(0x08E91E63)],
        ),
        borderRadius: AppRadius.card,
        border: Border.all(color: pink.withAlpha(70)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: pink.withAlpha(25),
                  borderRadius: AppRadius.button,
                ),
                child: const Icon(Icons.favorite_rounded,
                    color: pink, size: 22),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Confirmed Pregnant',
                        style: tt.titleMedium?.copyWith(
                            color: pink, fontWeight: FontWeight.w800)),
                    Row(children: [
                      Icon(Icons.child_care_outlined,
                          size: 13, color: cs.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Text(
                          'Expected: ${_formatDate(event.expectedBirthDate!)}',
                          style: tt.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant)),
                    ]),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: pink.withAlpha(20),
                  borderRadius: AppRadius.card,
                  border: Border.all(color: pink.withAlpha(60)),
                ),
                child: Column(
                  children: [
                    Text('$daysRemaining',
                        style: tt.titleLarge?.copyWith(
                            color: pink,
                            fontWeight: FontWeight.w800,
                            height: 1)),
                    Text('days',
                        style: tt.labelSmall
                            ?.copyWith(color: pink, fontSize: 10)),
                  ],
                ),
              ),
            ],
          ),
          if (progress != null) ...[
            const SizedBox(height: AppSpacing.md),
            Row(children: [
              Text('${(progress * 100).toInt()}% gestated',
                  style: tt.labelSmall
                      ?.copyWith(color: cs.onSurfaceVariant)),
              const Spacer(),
              Text(
                  '${daysGestated ?? 0} / $gestDays days',
                  style: tt.labelSmall
                      ?.copyWith(color: cs.onSurfaceVariant)),
            ]),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: AppRadius.chip,
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: pink.withAlpha(25),
                valueColor:
                    const AlwaysStoppedAnimation<Color>(pink),
                minHeight: 7,
              ),
            ),
          ],
          if (event.sireName != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Divider(height: 1, color: pink.withAlpha(40)),
            const SizedBox(height: AppSpacing.sm),
            Row(children: [
              Icon(Icons.male_rounded,
                  size: 14, color: cs.onSurfaceVariant),
              const SizedBox(width: 4),
              Text(
                  'Sire: ${event.sireName}${event.sireBreed != null ? ' (${event.sireBreed})' : ''}',
                  style: tt.bodySmall
                      ?.copyWith(color: cs.onSurfaceVariant)),
              if (event.serviceMethod != null) ...[
                const SizedBox(width: AppSpacing.md),
                Icon(Icons.science_outlined,
                    size: 14, color: cs.onSurfaceVariant),
                const SizedBox(width: 4),
                Text(event.serviceMethod!,
                    style: tt.bodySmall
                        ?.copyWith(color: cs.onSurfaceVariant)),
              ],
            ]),
          ],
        ],
      ),
    );
  }
}

class _BreedingEventCard extends StatelessWidget {
  const _BreedingEventCard({required this.event});
  final BreedingEvent event;

  String _formatDate(String iso) {
    try {
      final d = DateTime.parse(iso);
      return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
    } catch (_) {
      return iso;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    const pink = Color(0xFFE91E63);

    final pregnancyColor = switch (event.pregnancyResult) {
      'confirmed_pregnant' => AppColors.success,
      'confirmed' => AppColors.success,
      'negative' => AppColors.error,
      'pending' => AppColors.warning,
      _ => AppColors.outline,
    };

    final eventIcon = switch (event.eventType) {
      'mating' || 'service' => Icons.favorite_rounded,
      'birth' || 'kidding' || 'farrowing' || 'foaling' || 'lambing' =>
        Icons.child_care_rounded,
      'pregnancy_check' => Icons.pregnant_woman_rounded,
      _ => Icons.favorite_border_rounded,
    };

    final eventColor = switch (event.eventType) {
      'birth' || 'kidding' || 'farrowing' || 'foaling' || 'lambing' =>
        AppColors.success,
      'pregnancy_check' => AppColors.tertiary,
      _ => pink,
    };

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: AppRadius.card,
        boxShadow: AppShadows.level1,
        border: Border.all(color: cs.outlineVariant.withAlpha(40)),
      ),
      child: ClipRRect(
        borderRadius: AppRadius.card,
        child: Stack(
          children: [
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              width: 3,
              child: ColoredBox(color: eventColor),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: eventColor.withAlpha(20),
                    borderRadius: AppRadius.button,
                  ),
                  child: Icon(eventIcon, color: eventColor, size: 18),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(event.displayType,
                          style: tt.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w700)),
                      Text(_formatDate(event.serviceDate),
                          style: tt.labelSmall?.copyWith(
                              color: cs.onSurfaceVariant)),
                    ],
                  ),
                ),
                if (event.pregnancyResult != null)
                  StatusChip(
                    label: event.pregnancyResult!
                        .replaceAll('_', ' ')
                        .toUpperCase(),
                    color: pregnancyColor,
                    small: true,
                  ),
              ],
            ),
            if (event.sireName != null ||
                event.serviceMethod != null ||
                event.expectedBirthDate != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Divider(height: 1, color: cs.outlineVariant.withAlpha(60)),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.md,
                runSpacing: 4,
                children: [
                  if (event.sireName != null)
                    _BreedingDetail(
                        icon: Icons.male_rounded,
                        text:
                            '${event.sireName}${event.sireBreed != null ? ' (${event.sireBreed})' : ''}'),
                  if (event.serviceMethod != null)
                    _BreedingDetail(
                        icon: Icons.science_outlined,
                        text: event.serviceMethod!),
                  if (event.expectedBirthDate != null)
                    _BreedingDetail(
                        icon: Icons.child_care_outlined,
                        text:
                            'Expected: ${_formatDate(event.expectedBirthDate!)}'),
                ],
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

class _BreedingDetail extends StatelessWidget {
  const _BreedingDetail({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: cs.onSurfaceVariant),
        const SizedBox(width: 3),
        Text(text,
            style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
      ],
    );
  }
}

// ── Shared layout helpers ─────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });
  final String title;
  final IconData icon;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.pagePaddingHorizontal,
        AppSpacing.md,
        AppSpacing.pagePaddingHorizontal,
        0,
      ),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: AppRadius.card,
        boxShadow: AppShadows.level1,
        border: Border.all(color: cs.outlineVariant.withAlpha(50)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.sm),
            child: Row(
              children: [
                Icon(icon, size: 16, color: AppColors.primary),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  title,
                  style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: cs.outlineVariant.withAlpha(80)),
          Padding(
              padding: const EdgeInsets.all(AppSpacing.md), child: child),
        ],
      ),
    );
  }
}

// ── BCS section ───────────────────────────────────────────────────────────────

class _BcsSection extends StatelessWidget {
  const _BcsSection({required this.animal});
  final Animal animal;

  @override
  Widget build(BuildContext context) {
    final bcs = animal.bodyConditionScore;
    if (bcs == null) {
      return Text('No BCS recorded',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color:
                  Theme.of(context).colorScheme.onSurfaceVariant));
    }
    // Cattle & horses use the 9-point Leanne/BCS scale; all others use 1–5
    final maxScore = (animal.species == LivestockConstants.cattle ||
            animal.species == LivestockConstants.horses)
        ? 9
        : 5;
    return BcsIndicator(
      score: bcs.toDouble(),
      maxScore: maxScore,
      label: 'BCS $bcs / $maxScore',
    );
  }
}

// ── Tag cloud section ─────────────────────────────────────────────────────────

class _TagSection extends StatelessWidget {
  const _TagSection({required this.animal});
  final Animal animal;

  @override
  Widget build(BuildContext context) {
    final tags = [
      TagItem(
          label: animal.species,
          color: AppColors.forSpecies(animal.species)),
      TagItem(label: animal.breed),
      if (animal.productionType.isNotEmpty)
        TagItem(label: animal.productionType),
      TagItem(label: animal.displaySex),
      if (animal.status.isNotEmpty) TagItem(label: animal.status),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pagePaddingHorizontal,
        AppSpacing.md,
        AppSpacing.pagePaddingHorizontal,
        AppSpacing.md,
      ),
      child: TagCloud(tags: tags),
    );
  }
}

// ── SA Compliance section ─────────────────────────────────────────────────────

class _SAComplianceSection extends StatelessWidget {
  const _SAComplianceSection({required this.animal});
  final Animal animal;

  bool get _hasSAData =>
      animal.fmdZone != null ||
      animal.rmisAnimalId != null ||
      animal.brandNumber != null ||
      animal.earmarkDesc != null ||
      animal.studBookNumber != null ||
      animal.brucellaTested ||
      animal.importPermitNo != null;

  @override
  Widget build(BuildContext context) {
    if (!_hasSAData) return const SizedBox.shrink();

    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      margin: const EdgeInsets.fromLTRB(
          AppSpacing.pagePaddingHorizontal, AppSpacing.md,
          AppSpacing.pagePaddingHorizontal, 0),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: AppRadius.card,
        boxShadow: AppShadows.level1,
        border: Border.all(color: cs.outlineVariant.withAlpha(50)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.sm),
            child: Row(
              children: [
                Icon(Icons.verified_user_outlined,
                    size: 16, color: AppColors.primary),
                const SizedBox(width: AppSpacing.xs),
                Text('SA Compliance',
                    style: tt.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700)),
                const Spacer(),
                if (animal.isRmisRegistered)
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: AppColors.success.withAlpha(20),
                      borderRadius: AppRadius.chip,
                      border: Border.all(
                          color: AppColors.success.withAlpha(60)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.verified_rounded,
                            size: 11, color: AppColors.success),
                        const SizedBox(width: 4),
                        Text('RMIS Registered',
                            style: tt.labelSmall?.copyWith(
                                color: AppColors.success,
                                fontWeight: FontWeight.w600,
                                fontSize: 10)),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          Divider(height: 1, color: cs.outlineVariant.withAlpha(80)),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (animal.fmdZone != null) ...[
                  FmdZoneIndicator(zone: animal.fmdZone!),
                  const SizedBox(height: AppSpacing.md),
                ],
                // Compliance fields as icon rows
                Wrap(
                  spacing: AppSpacing.sm,
                  runSpacing: AppSpacing.sm,
                  children: [
                    if (animal.rmisAnimalId != null)
                      _ComplianceTag(
                          icon: Icons.qr_code_2_outlined,
                          label: 'RMIS',
                          value: animal.rmisAnimalId!),
                    if (animal.rfidNumber != null)
                      _ComplianceTag(
                          icon: Icons.nfc_rounded,
                          label: 'RFID',
                          value: animal.rfidNumber!),
                    if (animal.brandNumber != null)
                      _ComplianceTag(
                          icon: Icons.local_fire_department_outlined,
                          label: 'Brand',
                          value: animal.brandNumber!),
                    if (animal.earmarkDesc != null)
                      _ComplianceTag(
                          icon: Icons.label_outline_rounded,
                          label: 'Earmark',
                          value: animal.earmarkDesc!),
                    if (animal.studBookNumber != null)
                      _ComplianceTag(
                          icon: Icons.menu_book_outlined,
                          label: 'Stud Book',
                          value: animal.studBookNumber!),
                    if (animal.brucellaTested)
                      _ComplianceTag(
                          icon: Icons.science_outlined,
                          label: 'Brucella',
                          value: animal.brucellaTestDate ?? 'Tested'),
                    if (animal.importPermitNo != null)
                      _ComplianceTag(
                          icon: Icons.article_outlined,
                          label: 'Import Permit',
                          value: animal.importPermitNo!),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ComplianceTag extends StatelessWidget {
  const _ComplianceTag(
      {required this.icon, required this.label, required this.value});
  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: AppRadius.chip,
        border: Border.all(color: cs.outlineVariant.withAlpha(80)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: cs.onSurfaceVariant),
          const SizedBox(width: 5),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: tt.labelSmall?.copyWith(
                      color: cs.onSurfaceVariant, fontSize: 9)),
              Text(value,
                  style: tt.labelSmall?.copyWith(
                      fontWeight: FontWeight.w700, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}

// ── FAMACHA eye score card ────────────────────────────────────────────────────

class _FamachaCard extends StatelessWidget {
  const _FamachaCard({required this.animal});
  final Animal animal;

  // FAMACHA 1–5 colour swatches (standard chart colours)
  static const _swatchColors = [
    Color(0xFFB71C1C), // 1 – Red (healthy)
    Color(0xFFE57373), // 2 – Red-pink (acceptable)
    Color(0xFFFFCDD2), // 3 – Pink (borderline, monitor)
    Color(0xFFFFEBEE), // 4 – Pale pink (treat)
    Color(0xFFF5F5F5), // 5 – White (critical, treat immediately)
  ];

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final color = AppColors.forSpecies(animal.species);

    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.pagePaddingHorizontal,
        AppSpacing.md,
        AppSpacing.pagePaddingHorizontal,
        0,
      ),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: AppRadius.card,
        boxShadow: AppShadows.level1,
        border: Border.all(color: cs.outlineVariant.withAlpha(50)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.sm),
            child: Row(
              children: [
                Icon(Icons.visibility_outlined, size: 16, color: color),
                const SizedBox(width: AppSpacing.xs),
                Text('FAMACHA Eye Score',
                    style: tt.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700)),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: color.withAlpha(15),
                    borderRadius: AppRadius.chip,
                    border: Border.all(color: color.withAlpha(50)),
                  ),
                  child: Text('Haemonchus screening',
                      style: tt.labelSmall?.copyWith(
                          color: color,
                          fontWeight: FontWeight.w600,
                          fontSize: 10)),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: cs.outlineVariant.withAlpha(80)),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Colour swatch row 1–5
                Row(
                  children: List.generate(5, (i) {
                    return Expanded(
                      child: Container(
                        margin: EdgeInsets.only(right: i < 4 ? 3 : 0),
                        height: 36,
                        decoration: BoxDecoration(
                          color: _swatchColors[i],
                          borderRadius: i == 0
                              ? const BorderRadius.horizontal(
                                  left: Radius.circular(AppRadius.sm))
                              : i == 4
                                  ? const BorderRadius.horizontal(
                                      right: Radius.circular(AppRadius.sm))
                                  : null,
                          border: Border.all(
                              color: cs.outlineVariant.withAlpha(80),
                              width: 0.5),
                        ),
                        child: Center(
                          child: Text(
                            '${i + 1}',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 14,
                              color: i < 2 ? Colors.white : cs.onSurface,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: AppSpacing.sm),
                // Score range labels
                Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Text('1–2: Healthy',
                          style: tt.labelSmall?.copyWith(
                              color: AppColors.success, fontSize: 10)),
                    ),
                    Expanded(
                      child: Text('3: Monitor',
                          textAlign: TextAlign.center,
                          style: tt.labelSmall?.copyWith(
                              color: AppColors.warning, fontSize: 10)),
                    ),
                    Expanded(
                      flex: 2,
                      child: Text('4–5: Treat now',
                          textAlign: TextAlign.right,
                          style: tt.labelSmall?.copyWith(
                              color: AppColors.error, fontSize: 10)),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.info_outline_rounded,
                        size: 13, color: AppColors.outline),
                    const SizedBox(width: 5),
                    Expanded(
                      child: Text(
                        'No scores recorded yet. Score monthly during the warm season to detect Haemonchus anaemia early.',
                        style: tt.bodySmall
                            ?.copyWith(color: cs.onSurfaceVariant),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Align(
                  alignment: Alignment.centerRight,
                  child: OutlinedButton.icon(
                    onPressed: () => context.push(
                        '${AppRoutes.addRecordHealth}?animalId=${animal.id}&type=famacha'),
                    icon: const Icon(Icons.add_rounded, size: 14),
                    label: const Text('Score Now'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: color,
                      side: BorderSide(color: color.withAlpha(120)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 6),
                      textStyle: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Milk production tab ───────────────────────────────────────────────────────

class _MilkTab extends StatelessWidget {
  const _MilkTab({required this.animal});
  final Animal animal;

  @override
  Widget build(BuildContext context) {
    final color = AppColors.forSpecies(animal.species);
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.only(
          bottom: AppSpacing.xxl + 32, top: AppSpacing.sm),
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(
            AppSpacing.pagePaddingHorizontal,
            AppSpacing.md,
            AppSpacing.pagePaddingHorizontal,
            0,
          ),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color.withAlpha(28), color.withAlpha(8)],
            ),
            borderRadius: AppRadius.card,
            border: Border.all(color: color.withAlpha(60)),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withAlpha(25),
                  borderRadius: AppRadius.button,
                ),
                child: Icon(Icons.water_drop_outlined, color: color, size: 24),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Milk Production Tracking',
                        style: tt.titleSmall
                            ?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 2),
                    Text(
                        'Log daily milk yield (AM/PM), somatic cell count, and lactation cycle.',
                        style: tt.bodySmall
                            ?.copyWith(color: cs.onSurfaceVariant)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        const Center(
          child: EmptyState(
            title: 'No Milk Records Yet',
            subtitle:
                'Tap + Milk Record to log your first milking session.',
            icon: Icon(Icons.water_drop_outlined),
          ),
        ),
      ],
    );
  }
}

// ── Fleece / shearing tab ─────────────────────────────────────────────────────

class _FleeceTab extends StatelessWidget {
  const _FleeceTab({required this.animal});
  final Animal animal;

  @override
  Widget build(BuildContext context) {
    final color = AppColors.forSpecies(animal.species);
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.only(
          bottom: AppSpacing.xxl + 32, top: AppSpacing.sm),
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(
            AppSpacing.pagePaddingHorizontal,
            AppSpacing.md,
            AppSpacing.pagePaddingHorizontal,
            0,
          ),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color.withAlpha(28), color.withAlpha(8)],
            ),
            borderRadius: AppRadius.card,
            border: Border.all(color: color.withAlpha(60)),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: color.withAlpha(25),
                  borderRadius: AppRadius.button,
                ),
                child: Icon(Icons.texture_rounded, color: color, size: 24),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Fleece & Shearing Records',
                        style: tt.titleSmall
                            ?.copyWith(fontWeight: FontWeight.w800)),
                    const SizedBox(height: 2),
                    Text(
                        'Track fleece weight, micron count (µ), staple length, and shearing dates.',
                        style: tt.bodySmall
                            ?.copyWith(color: cs.onSurfaceVariant)),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xxl),
        const Center(
          child: EmptyState(
            title: 'No Shearing Records Yet',
            subtitle: 'Tap + Shear Record to log a shearing session.',
            icon: Icon(Icons.texture_rounded),
          ),
        ),
      ],
    );
  }
}


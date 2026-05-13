import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/farm_app_bar.dart';
import '../../../shared/widgets/farm_scaffold.dart';
import '../../../shared/widgets/loading_shimmer.dart';
import '../models/cattle_animal.dart';
import '../models/cattle_records.dart';
import '../providers/cattle_providers.dart';

// ── Filter enum ────────────────────────────────────────────────────────────────

enum _ProductionFilter { all, beef, dairy, breeding }

// ── Main screen ────────────────────────────────────────────────────────────────

class CattleScreen extends ConsumerStatefulWidget {
  const CattleScreen({super.key});

  @override
  ConsumerState<CattleScreen> createState() => _CattleScreenState();
}

class _CattleScreenState extends ConsumerState<CattleScreen> {
  _ProductionFilter _filter = _ProductionFilter.all;

  @override
  Widget build(BuildContext context) {
    final breedMapAsync = ref.watch(cattleByBreedProvider);
    final animalsAsync = ref.watch(cattleProvider);
    final calvingAlert = ref.watch(calvingDueSoonProvider);
    final dippingAlert = ref.watch(cattleDippingDueSoonProvider);
    final vacAlert = ref.watch(cattleVaccinationOverdueProvider);
    final lowBcsAlert = ref.watch(cattleLowBcsAlertsProvider);
    final dryOffAlert = ref.watch(cattleDryOffSoonProvider);

    return FarmScaffold(
      drawer: null,
      appBar: FarmAppBar(
        title: 'Cattle Herd',
        subtitle: animalsAsync.asData?.value != null
            ? '${animalsAsync.asData!.value.where((a) => a.isAlive).length} head active'
            : null,
        actions: [
          IconButton(
            icon: const Icon(Icons.compare_arrows_outlined),
            tooltip: 'Cross-Herd Comparison',
            onPressed: () => context.push(AppRoutes.cattleCrossHerd),
          ),
          IconButton(
            icon: const Icon(Icons.inventory_2_outlined),
            tooltip: 'Inventory',
            onPressed: () => context.push(AppRoutes.cattleInventory),
          ),
        ],
      ),
      floatingActionButton: ref.watch(canManageCattleProvider)
          ? FloatingActionButton.extended(
              onPressed: () => context.push(AppRoutes.addCattle),
              backgroundColor: AppColors.cattleColor,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text('Add Cattle'),
            )
          : null,
      body: animalsAsync.when(
        loading: () => LoadingShimmer.list(count: 6),
        error: (e, _) => _ErrorView(message: e.toString()),
        data: (animals) {
          final alive = animals.where((a) => a.isAlive).toList();
          final cows = alive.where((a) => a.sex == 'cow').length;
          final bulls = alive.where((a) => a.sex == 'bull').length;
          final pregnant = alive.where((a) => a.isPregnant).length;
          final lactating = alive.where((a) => a.isLactating).length;

          return breedMapAsync.when(
            loading: () => LoadingShimmer.list(count: 6),
            error: (e, _) => _ErrorView(message: e.toString()),
            data: (breedMap) {
              final filteredBreeds = _buildFilteredBreeds(breedMap);

              return CustomScrollView(
                slivers: [
                  SliverToBoxAdapter(
                    child: _AnalyticsStrip(
                      total: alive.length,
                      cows: cows,
                      bulls: bulls,
                      pregnant: pregnant,
                      lactating: lactating,
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: _AlertBanners(
                      calvingDue: calvingAlert.asData?.value ?? [],
                      dippingDue: dippingAlert.asData?.value ?? [],
                      vacOverdue: vacAlert.asData?.value ?? [],
                      lowBcs: lowBcsAlert.asData?.value ?? [],
                      dryOffSoon: dryOffAlert.asData?.value ?? [],
                    ),
                  ),
                  const SliverToBoxAdapter(child: _QuickActions()),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.xs,
                      ),
                      child: Row(
                        children: [
                          const Text(
                            'By Breed',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                              color: AppColors.cattleColor,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: _ProductionFilter.values.map((mode) {
                                  return Padding(
                                    padding: const EdgeInsets.only(
                                        right: AppSpacing.xs),
                                    child: ChoiceChip(
                                      label: Text(_filterLabel(mode)),
                                      selected: _filter == mode,
                                      selectedColor:
                                          AppColors.cattleColor.withAlpha(38),
                                      labelStyle: TextStyle(
                                        fontSize: 12,
                                        color: _filter == mode
                                            ? AppColors.cattleColor
                                            : null,
                                        fontWeight: _filter == mode
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                      ),
                                      onSelected: (_) =>
                                          setState(() => _filter = mode),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (filteredBreeds.isEmpty)
                    const SliverFillRemaining(child: _EmptyState())
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.md,
                        AppSpacing.xs,
                        AppSpacing.md,
                        100,
                      ),
                      sliver: SliverList.separated(
                        itemCount: filteredBreeds.length,
                        separatorBuilder: (_, __) =>
                            const SizedBox(height: AppSpacing.sm),
                        itemBuilder: (_, i) {
                          final entry = filteredBreeds[i];
                          return _BreedGroupCard(
                            breed: entry.key,
                            animals: entry.value,
                          );
                        },
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  String _filterLabel(_ProductionFilter mode) => switch (mode) {
        _ProductionFilter.all => 'All',
        _ProductionFilter.beef => 'Beef',
        _ProductionFilter.dairy => 'Dairy',
        _ProductionFilter.breeding => 'Breeding',
      };

  List<MapEntry<String, List<CattleAnimal>>> _buildFilteredBreeds(
      Map<String, List<CattleAnimal>> breedMap) {
    if (_filter == _ProductionFilter.all) return breedMap.entries.toList();
    final typeName = switch (_filter) {
      _ProductionFilter.beef => 'beef',
      _ProductionFilter.dairy => 'dairy',
      _ProductionFilter.breeding => 'breeding',
      _ProductionFilter.all => '',
    };
    final result = <MapEntry<String, List<CattleAnimal>>>[];
    for (final e in breedMap.entries) {
      final filtered =
          e.value.where((a) => a.productionType == typeName).toList();
      if (filtered.isNotEmpty) result.add(MapEntry(e.key, filtered));
    }
    return result;
  }
}

// ── Analytics strip ────────────────────────────────────────────────────────────

class _AnalyticsStrip extends StatelessWidget {
  const _AnalyticsStrip({
    required this.total,
    required this.cows,
    required this.bulls,
    required this.pregnant,
    required this.lactating,
  });

  final int total;
  final int cows;
  final int bulls;
  final int pregnant;
  final int lactating;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
          AppSpacing.md, AppSpacing.sm, AppSpacing.md, 0),
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.cattleColorContainer,
        borderRadius: AppRadius.card,
      ),
      child: Row(
        children: [
          _StatCell(
            label: 'Total',
            value: total >= 1000
                ? '${(total / 1000).toStringAsFixed(1)}k'
                : '$total',
            icon: Icons.pets_outlined,
          ),
          _Divider(),
          _StatCell(label: 'Cows', value: '$cows', icon: Icons.female),
          _Divider(),
          _StatCell(label: 'Bulls', value: '$bulls', icon: Icons.male),
          _Divider(),
          _StatCell(
            label: 'In Calf',
            value: '$pregnant',
            icon: Icons.child_care_outlined,
            alert: pregnant > 0,
          ),
          _Divider(),
          _StatCell(
            label: 'Milking',
            value: '$lactating',
            icon: Icons.opacity_outlined,
          ),
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 28,
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      color: AppColors.cattleColor.withAlpha(64),
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({
    required this.label,
    required this.value,
    required this.icon,
    this.alert = false,
  });

  final String label;
  final String value;
  final IconData icon;
  final bool alert;

  @override
  Widget build(BuildContext context) {
    final valueColor = alert ? AppColors.error : AppColors.cattleColor;
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 14, color: AppColors.cattleColor),
          const SizedBox(height: 2),
          Text(value,
              style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: valueColor)),
          Text(label,
              style: const TextStyle(
                  fontSize: 10, color: AppColors.cattleColor)),
        ],
      ),
    );
  }
}

// ── Alert banners ──────────────────────────────────────────────────────────────

class _AlertBanners extends StatelessWidget {
  const _AlertBanners({
    required this.calvingDue,
    required this.dippingDue,
    required this.vacOverdue,
    required this.lowBcs,
    required this.dryOffSoon,
  });

  final List<CattleAnimal> calvingDue;
  final List<CattleAnimal> dippingDue;
  final List<CattleVaccination> vacOverdue;
  final List<CattleAnimal> lowBcs;
  final List<CattleAnimal> dryOffSoon;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (calvingDue.isNotEmpty)
          _AlertBanner(
            icon: Icons.child_care_outlined,
            color: AppColors.warning,
            message:
                '${calvingDue.length} cow${calvingDue.length == 1 ? '' : 's'} due to calve within 10 days',
            onTap: () => context.push(AppRoutes.cattlePregnancyCheck),
          ),
        if (dippingDue.isNotEmpty)
          _AlertBanner(
            icon: Icons.water_outlined,
            color: AppColors.warning,
            message:
                '${dippingDue.length} animal${dippingDue.length == 1 ? '' : 's'} due for dipping',
            onTap: () => context.push(AppRoutes.cattleDipping),
          ),
        if (vacOverdue.isNotEmpty)
          _AlertBanner(
            icon: Icons.vaccines_outlined,
            color: AppColors.warning,
            message:
                '${vacOverdue.length} overdue vaccination${vacOverdue.length == 1 ? '' : 's'}',
            onTap: () => context.push(AppRoutes.cattleVaccinations),
          ),
        if (lowBcs.isNotEmpty)
          _AlertBanner(
            icon: Icons.monitor_weight_outlined,
            color: AppColors.warning,
            message:
                '${lowBcs.length} animal${lowBcs.length == 1 ? '' : 's'} with low BCS (< 2.0) — review nutrition',
            onTap: () => context.push(AppRoutes.cattleBodyCondition),
          ),
        if (dryOffSoon.isNotEmpty)
          _AlertBanner(
            icon: Icons.water_drop_outlined,
            color: AppColors.warning,
            message:
                '${dryOffSoon.length} dairy animal${dryOffSoon.length == 1 ? '' : 's'} due for dry-off within 7 days',
            onTap: () => context.push(AppRoutes.cattleReports),
          ),
      ],
    );
  }
}

class _AlertBanner extends StatelessWidget {
  const _AlertBanner({
    required this.icon,
    required this.color,
    required this.message,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final String message;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.fromLTRB(
            AppSpacing.md, AppSpacing.xs, AppSpacing.md, 0),
        padding:
            const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 8),
        decoration: BoxDecoration(
          color: color.withAlpha(20),
          borderRadius: AppRadius.card,
          border: Border.all(color: color.withAlpha(80)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child:
                  Text(message, style: TextStyle(fontSize: 12, color: color)),
            ),
            if (onTap != null)
              Icon(Icons.arrow_forward_ios, color: color, size: 12),
          ],
        ),
      ),
    );
  }
}

// ── Quick-action row ───────────────────────────────────────────────────────────

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    final actions = [
      ('Pregnancy\nCheck', Icons.favorite_outlined,
          AppRoutes.cattlePregnancyCheck),
      ('Vaccinations', Icons.vaccines_outlined, AppRoutes.cattleVaccinations),
      ('Dipping', Icons.water_outlined, AppRoutes.cattleDipping),
      ('Body\nCondition', Icons.monitor_weight_outlined,
          AppRoutes.cattleBodyCondition),
      ('Pasture', Icons.grass_outlined, AppRoutes.cattlePasture),
      ('Sales', Icons.account_balance_wallet_outlined, AppRoutes.cattleSales),
      ('Reports', Icons.description_outlined, AppRoutes.cattleReports),
    ];
    return Container(
      height: 84,
      margin: const EdgeInsets.only(top: AppSpacing.sm),
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        itemCount: actions.length,
        separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (_, i) {
          final (label, icon, route) = actions[i];
          return InkWell(
            borderRadius: AppRadius.card,
            onTap: () => context.push(route),
            child: Container(
              width: 70,
              padding: const EdgeInsets.symmetric(
                  vertical: AppSpacing.xs, horizontal: 6),
              decoration: BoxDecoration(
                color: AppColors.cattleColorContainer,
                borderRadius: AppRadius.card,
                border:
                    Border.all(color: AppColors.cattleColor.withAlpha(50)),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: AppColors.cattleColor, size: 22),
                  const SizedBox(height: 4),
                  Text(
                    label,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                      color: AppColors.cattleColor,
                      height: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

// ── Breed group card ───────────────────────────────────────────────────────────

class _BreedGroupCard extends StatelessWidget {
  const _BreedGroupCard({required this.breed, required this.animals});

  final String breed;
  final List<CattleAnimal> animals;

  @override
  Widget build(BuildContext context) {
    final cows = animals.where((a) => a.sex == 'cow').length;
    final bulls = animals.where((a) => a.sex == 'bull').length;
    final pregnant = animals.where((a) => a.isPregnant).length;
    final lactating = animals.where((a) => a.isLactating).length;

    final withWeight =
        animals.where((a) => a.currentWeightKg != null).toList();
    final avgWeight = withWeight.isEmpty
        ? null
        : withWeight
                .map((a) => a.currentWeightKg!)
                .reduce((s, w) => s + w) /
            withWeight.length;

    final typeCount = <String, int>{};
    for (final a in animals) {
      typeCount[a.productionType] = (typeCount[a.productionType] ?? 0) + 1;
    }
    final dominantType =
        typeCount.entries.reduce((a, b) => a.value >= b.value ? a : b).key;

    return InkWell(
      borderRadius: AppRadius.card,
      onTap: () => context.push(AppRoutes.cattleBreedPath(breed)),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppRadius.card,
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(10),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              decoration: BoxDecoration(
                color: AppColors.cattleColorContainer,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(12)),
              ),
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              child: Row(
                children: [
                  _BreedAvatar(breed: breed),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          breed,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 15,
                            color: AppColors.cattleColor,
                          ),
                        ),
                        Row(
                          children: [
                            _TypeBadge(type: dominantType),
                            const SizedBox(width: AppSpacing.xs),
                            Text(
                              '${animals.length} head',
                              style:
                                  TextStyle(fontSize: 12, color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: AppColors.cattleColor),
                ],
              ),
            ),
            // Stats row
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: AppSpacing.sm),
              child: Row(
                children: [
                  _MiniStat(icon: Icons.female, label: 'Cows', value: '$cows'),
                  _MiniStat(icon: Icons.male, label: 'Bulls', value: '$bulls'),
                  _MiniStat(
                      icon: Icons.child_care_outlined,
                      label: 'In Calf',
                      value: '$pregnant'),
                  _MiniStat(
                      icon: Icons.opacity_outlined,
                      label: 'Milking',
                      value: '$lactating'),
                  if (avgWeight != null)
                    _MiniStat(
                        icon: Icons.monitor_weight_outlined,
                        label: 'Avg kg',
                        value: avgWeight.toStringAsFixed(1)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 14, color: Colors.grey[500]),
          const SizedBox(height: 2),
          Text(value,
              style:
                  const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[500])),
        ],
      ),
    );
  }
}

class _TypeBadge extends StatelessWidget {
  const _TypeBadge({required this.type});
  final String type;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (type) {
      'beef' => ('Beef', Colors.orange.shade700),
      'dairy' => ('Dairy', Colors.blue.shade700),
      'breeding' => ('Breeding', Colors.pink.shade700),
      _ => ('Mixed', Colors.grey.shade600),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 10, fontWeight: FontWeight.w600, color: color)),
    );
  }
}

// ── Breed avatar ───────────────────────────────────────────────────────────────

class _BreedAvatar extends StatelessWidget {
  const _BreedAvatar({required this.breed});
  final String breed;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.cattleColor.withAlpha(30),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.pets, color: AppColors.cattleColor, size: 22),
    );
  }
}

// ── Empty / Error states ───────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.pets_outlined,
              size: 64, color: AppColors.cattleColor.withAlpha(100)),
          const SizedBox(height: AppSpacing.md),
          const Text(
            'No cattle recorded yet',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Tap "Add Cattle" to register your first animal.',
            style: TextStyle(color: Colors.grey[600], fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 48, color: AppColors.error),
            const SizedBox(height: AppSpacing.sm),
            Text(message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.error)),
          ],
        ),
      ),
    );
  }
}

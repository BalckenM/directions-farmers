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
import '../models/goat_animal.dart';
import '../providers/goat_providers.dart';

// ── Sort enum ─────────────────────────────────────────────────────────────────

enum _SortMode { tag, age, weight, status }

// ── Screen ────────────────────────────────────────────────────────────────────

class GoatBreedScreen extends ConsumerStatefulWidget {
  const GoatBreedScreen({super.key, required this.breed});

  final String breed;

  @override
  ConsumerState<GoatBreedScreen> createState() => _GoatBreedScreenState();
}

class _GoatBreedScreenState extends ConsumerState<GoatBreedScreen> {
  _SortMode _sort = _SortMode.tag;
  String _search = '';
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final animalsAsync = ref.watch(breedAnimalsProvider(widget.breed));

    return FarmScaffold(
      drawer: null,
      appBar: FarmAppBar(
        title: widget.breed,
        subtitle: 'Breed group',
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add goat',
            onPressed: () => context.push(AppRoutes.addGoat),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.addGoat),
        backgroundColor: AppColors.goatColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Goat'),
      ),
      body: animalsAsync.when(
        loading: () => LoadingShimmer.list(count: 8),
        error: (e, _) => _ErrorView(message: e.toString()),
        data: (animals) {
          // Search filter
          final filtered = _search.isEmpty
              ? animals
              : animals
                  .where((a) =>
                      a.tagNumber
                          .toLowerCase()
                          .contains(_search.toLowerCase()) ||
                      (a.name
                              ?.toLowerCase()
                              .contains(_search.toLowerCase()) ??
                          false))
                  .toList();

          // Sort
          final sorted = _applySorted(filtered);

          // Breed summary stats
          final does = animals.where((a) => a.isFemale).length;
          final bucks = animals.where((a) => a.isMale).length;
          final pregnant = animals.where((a) => a.isPregnant).length;
          final withWeight =
              animals.where((a) => a.currentWeightKg != null).toList();
          final avgWeight = withWeight.isEmpty
              ? null
              : withWeight.map((a) => a.currentWeightKg!).reduce((s, w) => s + w) /
                  withWeight.length;

          return Column(
            children: [
              // ── Stats strip ─────────────────────────────────────────
              _BreedStatsStrip(
                total: animals.length,
                does: does,
                bucks: bucks,
                pregnant: pregnant,
                avgWeight: avgWeight,
              ),

              // ── Search bar ──────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md, AppSpacing.sm, AppSpacing.md, 0),
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(
                    hintText: 'Search by tag or name…',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    suffixIcon: _search.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () {
                              _controller.clear();
                              setState(() => _search = '');
                            },
                          )
                        : null,
                    isDense: true,
                    contentPadding: const EdgeInsets.symmetric(vertical: 10),
                    border: OutlineInputBorder(
                      borderRadius: AppRadius.card,
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: AppRadius.card,
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                  onChanged: (v) => setState(() => _search = v),
                ),
              ),

              // ── Sort chips ──────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                child: Row(
                  children: [
                    Text(
                      '${sorted.length} animal${sorted.length == 1 ? '' : 's'}',
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey[600]),
                    ),
                    const Spacer(),
                    ..._SortMode.values.map((mode) => Padding(
                          padding:
                              const EdgeInsets.only(left: AppSpacing.xs),
                          child: ChoiceChip(
                            label: Text(_sortLabel(mode),
                                style: const TextStyle(fontSize: 11)),
                            selected: _sort == mode,
                            selectedColor:
                                AppColors.goatColor.withAlpha(38),
                            labelStyle: TextStyle(
                              color: _sort == mode
                                  ? AppColors.goatColor
                                  : null,
                              fontWeight: _sort == mode
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                            onSelected: (_) =>
                                setState(() => _sort = mode),
                          ),
                        )),
                  ],
                ),
              ),

              // ── Animal list ─────────────────────────────────────────
              Expanded(
                child: sorted.isEmpty
                    ? const _EmptySearchState()
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.md,
                          AppSpacing.xs,
                          AppSpacing.md,
                          100,
                        ),
                        itemCount: sorted.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: AppSpacing.xs),
                        itemBuilder: (_, i) =>
                            _AnimalCard(animal: sorted[i]),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _sortLabel(_SortMode mode) => switch (mode) {
        _SortMode.tag => 'Tag',
        _SortMode.age => 'Age',
        _SortMode.weight => 'Wt',
        _SortMode.status => 'Status',
      };

  List<GoatAnimal> _applySorted(List<GoatAnimal> animals) {
    final list = List.of(animals);
    switch (_sort) {
      case _SortMode.tag:
        list.sort((a, b) => a.tagNumber.compareTo(b.tagNumber));
      case _SortMode.age:
        list.sort((a, b) => b.ageMonths.compareTo(a.ageMonths));
      case _SortMode.weight:
        list.sort((a, b) {
          final wa = a.currentWeightKg ?? 0;
          final wb = b.currentWeightKg ?? 0;
          return wb.compareTo(wa);
        });
      case _SortMode.status:
        list.sort((a, b) => a.status.compareTo(b.status));
    }
    return list;
  }
}

// ── Breed stats strip ──────────────────────────────────────────────────────────

class _BreedStatsStrip extends StatelessWidget {
  const _BreedStatsStrip({
    required this.total,
    required this.does,
    required this.bucks,
    required this.pregnant,
    required this.avgWeight,
  });

  final int total;
  final int does;
  final int bucks;
  final int pregnant;
  final double? avgWeight;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(
          AppSpacing.md, AppSpacing.sm, AppSpacing.md, 0),
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.goatColorContainer,
        borderRadius: AppRadius.card,
      ),
      child: Row(
        children: [
          _StatCell(label: 'Total', value: '$total'),
          _VDivider(),
          _StatCell(label: 'Does', value: '$does'),
          _VDivider(),
          _StatCell(label: 'Bucks', value: '$bucks'),
          _VDivider(),
          _StatCell(label: 'Pregnant', value: '$pregnant'),
          if (avgWeight != null) ...[
            _VDivider(),
            _StatCell(
                label: 'Avg kg', value: avgWeight!.toStringAsFixed(1)),
          ],
        ],
      ),
    );
  }
}

class _VDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 28,
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      color: AppColors.goatColor.withAlpha(64),
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.goatColor)),
          Text(label,
              style: const TextStyle(
                  fontSize: 10, color: AppColors.goatColor)),
        ],
      ),
    );
  }
}

// ── Animal card ────────────────────────────────────────────────────────────────

class _AnimalCard extends StatelessWidget {
  const _AnimalCard({required this.animal});
  final GoatAnimal animal;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: AppRadius.card,
      onTap: () => context.push(AppRoutes.goatDetailPath(animal.id)),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: AppRadius.card,
          border: Border.all(color: Colors.grey.shade200),
        ),
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        child: Row(
          children: [
            // Sex/status indicator
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _sexColor(animal.sex).withAlpha(25),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _sexIcon(animal.sex),
                color: _sexColor(animal.sex),
                size: 20,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),

            // Main info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          animal.displayName,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 14),
                        ),
                      ),
                      _StatusBadge(status: animal.status),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${animal.sex}  ·  ${animal.ageMonths}mo  ·  ${animal.productionType}',
                    style: TextStyle(fontSize: 11, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  // Alert badges
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: [
                      if (animal.currentWeightKg != null)
                        _Badge(
                          icon: Icons.monitor_weight_outlined,
                          label:
                              '${animal.currentWeightKg!.toStringAsFixed(1)} kg',
                          color: Colors.grey.shade700,
                        ),
                      if (animal.isPregnant)
                        _Badge(
                          icon: Icons.child_care_outlined,
                          label: 'Pregnant',
                          color: Colors.pink.shade600,
                        ),
                      if (animal.isLactating)
                        _Badge(
                          icon: Icons.opacity_outlined,
                          label: animal.currentMilkLitrePd != null
                              ? '${animal.currentMilkLitrePd!.toStringAsFixed(1)} L/d'
                              : 'Lactating',
                          color: Colors.blue.shade600,
                        ),
                      if ((animal.famachaScore ?? 0) >= 4)
                        _Badge(
                          icon: Icons.warning_amber_rounded,
                          label: 'FAMACHA ${animal.famachaScore}',
                          color: AppColors.error,
                          bg: AppColors.errorContainer,
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right,
                color: AppColors.goatColor, size: 18),
          ],
        ),
      ),
    );
  }

  Color _sexColor(String sex) {
    if (sex == 'buck' || sex == 'kid_male') return Colors.blue.shade700;
    if (sex == 'wether') return Colors.grey.shade600;
    return Colors.pink.shade600;
  }

  IconData _sexIcon(String sex) {
    if (sex == 'buck' || sex == 'kid_male') return Icons.male;
    if (sex == 'wether') return Icons.remove_circle_outline;
    return Icons.female;
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final String status;

  @override
  Widget build(BuildContext context) {
    final (label, color) = switch (status) {
      'active' => ('Active', Colors.green.shade700),
      'sold' => ('Sold', Colors.grey.shade600),
      'dry' => ('Dry', Colors.orange.shade700),
      'slaughtered' => ('Slaughtered', AppColors.error),
      'deceased' => ('Deceased', AppColors.error),
      'culled' => ('Culled', Colors.red.shade700),
      _ => (status, Colors.grey.shade600),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(label,
          style: TextStyle(
              fontSize: 10,
              color: color,
              fontWeight: FontWeight.w600)),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({
    required this.icon,
    required this.label,
    required this.color,
    this.bg,
  });

  final IconData icon;
  final String label;
  final Color color;
  final Color? bg;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: bg ?? color.withAlpha(15),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 11, color: color),
          const SizedBox(width: 2),
          Text(label,
              style: TextStyle(
                  fontSize: 10,
                  color: color,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}

// ── Empty / Error states ───────────────────────────────────────────────────────

class _EmptySearchState extends StatelessWidget {
  const _EmptySearchState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'No animals match the search.',
        style: TextStyle(color: Colors.grey[600]),
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

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/user_role.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/farm_app_bar.dart';
import '../../../shared/widgets/farm_scaffold.dart';
import '../../../shared/widgets/loading_shimmer.dart';
import '../models/poultry_flock.dart';
import '../providers/poultry_providers.dart';

// ── Breed image helpers ───────────────────────────────────────────────────────

/// Cache: Wikipedia article title → resolved thumbnail source URL (null = no image).
final _breedImageCache = <String, String?>{};

/// Returns the Wikipedia article title that best represents the given flock's breed.
String _wikiArticle(PoultryFlock flock) {
  final strain = flock.strain.toLowerCase();
  final species = flock.species.toLowerCase();
  final type = flock.productionType.toLowerCase();

  if (species == 'duck' ||
      strain.contains('pekin') ||
      strain.contains('cherry valley') ||
      strain.contains('muscovy') ||
      strain.contains('aylesbury')) {
    return 'American_Pekin';
  }
  if (species == 'turkey' || strain.contains('nicholas') || strain.contains('b.u.t.')) {
    return 'Wild_turkey';
  }
  if (strain.contains('lohmann')) return 'Lohmann_Brown';
  if (strain.contains('hy-line') || strain.contains('hyline')) return 'Hy-Line_Brown';
  if (strain.contains('isa')) return 'ISA_Brown';
  if (strain.contains('bovans')) return 'Lohmann_Brown';
  if (strain.contains('ross')) return 'Ross_308';
  if (strain.contains('cobb')) return 'Cobb_500';
  if (type == 'broiler') return 'Broiler';
  if (type == 'layer') return 'Lohmann_Brown';
  return 'Chicken';
}

/// Fetches the Wikipedia REST API summary for [article] and returns the thumbnail URL.
/// Results are cached in [_breedImageCache].
Future<String?> _fetchBreedImage(String article) async {
  if (_breedImageCache.containsKey(article)) return _breedImageCache[article];
  try {
    final response = await Dio().get<Map<String, dynamic>>(
      'https://en.wikipedia.org/api/rest_v1/page/summary/${Uri.encodeComponent(article)}',
      options: Options(receiveTimeout: const Duration(seconds: 8)),
    );
    final source = response.data?['thumbnail']?['source'] as String?;
    _breedImageCache[article] = source;
    return source;
  } catch (_) {
    _breedImageCache[article] = null;
    return null;
  }
}

/// Stateful widget that loads and shows the breed photo for a flock.
class _BreedImage extends StatefulWidget {
  const _BreedImage({required this.flock});
  final PoultryFlock flock;

  @override
  State<_BreedImage> createState() => _BreedImageState();
}

class _BreedImageState extends State<_BreedImage> {
  String? _url;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    final article = _wikiArticle(widget.flock);
    _fetchBreedImage(article).then((url) {
      if (mounted) setState(() { _url = url; _ready = true; });
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: AppColors.poultryColorContainer,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ),
      );
    }
    if (_url == null) {
      return Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          color: AppColors.poultryColorContainer,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Icon(Icons.egg_alt, color: AppColors.poultryColor, size: 28),
      );
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.network(
        _url!,
        width: 64,
        height: 64,
        fit: BoxFit.cover,
        errorBuilder: (_, e, s) => Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: AppColors.poultryColorContainer,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.egg_alt, color: AppColors.poultryColor, size: 28),
        ),
      ),
    );
  }
}

enum _FilterMode { all, active, historical }

class PoultryScreen extends ConsumerStatefulWidget {
  const PoultryScreen({super.key});

  @override
  ConsumerState<PoultryScreen> createState() => _PoultryScreenState();
}

class _PoultryScreenState extends ConsumerState<PoultryScreen> {
  _FilterMode _filter = _FilterMode.all;

  @override
  Widget build(BuildContext context) {
    final flocksAsync = ref.watch(flocksProvider);
    final role = ref.watch(userRoleProvider);

    return FarmScaffold(
      drawer: null,
      appBar: FarmAppBar(
        title: 'Poultry Flocks',
        subtitle: flocksAsync.whenOrNull(
          data: (f) => '${f.length} flock${f.length == 1 ? '' : 's'}',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.compare_arrows_outlined),
            tooltip: 'Cross-batch Comparison',
            onPressed: () => context.push('/livestock/poultry/cross-batch'),
          ),
          IconButton(
            icon: const Icon(Icons.home_work_outlined),
            tooltip: 'House Allocation',
            onPressed: () => context.push(AppRoutes.poultryHouses),
          ),
          _RoleSwitcherButton(role: role),
        ],
      ),
      floatingActionButton: role.canAddFlock
          ? FloatingActionButton.extended(
              onPressed: () => context.push(AppRoutes.addFlock),
              backgroundColor: AppColors.poultryColor,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add),
              label: const Text('Add Flock'),
            )
          : null,
      body: flocksAsync.when(
        loading: () => LoadingShimmer.list(count: 6),
        error: (e, _) => _ErrorView(message: e.toString()),
        data: (flocks) {
          // ── Analytics summary ──────────────────────────────────────────
          final active = flocks.where((f) => f.isActive).toList();
          final totalBirds = active.fold(0, (s, f) => s + f.currentCount);
          final avgMort = active.isEmpty
              ? 0.0
              : active.map((f) => f.mortalityPct).reduce((a, b) => a + b) /
                  active.length;
          final avgFcr = active.isEmpty
              ? null
              : () {
                  final withFcr =
                      active.where((f) => f.fcrToDate != null).toList();
                  if (withFcr.isEmpty) return null;
                  return withFcr
                          .map((f) => f.fcrToDate!)
                          .reduce((a, b) => a + b) /
                      withFcr.length;
                }();

          // ── Filtered list ──────────────────────────────────────────────
          final filtered = flocks.where((f) {
            return switch (_filter) {
              _FilterMode.all => true,
              _FilterMode.active => f.isActive,
              _FilterMode.historical => !f.isActive,
            };
          }).toList();

          return Column(
            children: [
              // ── Analytics strip ─────────────────────────────────────
              _AnalyticsStrip(
                activeFlocks: active.length,
                totalBirds: totalBirds,
                avgMortPct: avgMort,
                avgFcr: avgFcr,
              ),

              // ── Vaccination due-soon banner ──────────────────────────
              Consumer(
                builder: (ctx, ref, _) {
                  final dueSoonAsync =
                      ref.watch(dueSoonVaccinationsProvider);
                  final dueSoon = dueSoonAsync.value ?? [];
                  if (dueSoon.isEmpty) return const SizedBox.shrink();
                  return Container(
                    margin: const EdgeInsets.fromLTRB(
                        AppSpacing.md, AppSpacing.xs, AppSpacing.md, 0),
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withAlpha(26),
                      borderRadius: AppRadius.card,
                      border: Border.all(
                          color: AppColors.warning.withAlpha(102)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.vaccines_outlined,
                            color: AppColors.warning, size: 20),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Vaccinations Due Soon',
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.warning),
                              ),
                              const SizedBox(height: 2),
                              ...dueSoon.map((v) => Text(
                                    '· ${v.vaccine} — ${v.flockName} '
                                    '(${v.dueDate.month}/${v.dueDate.day})',
                                    style: const TextStyle(fontSize: 12),
                                  )),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              // ── Filter chips ─────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                child: Row(
                  children: _FilterMode.values.map((mode) {
                    final label = switch (mode) {
                      _FilterMode.all => 'All',
                      _FilterMode.active => 'Active',
                      _FilterMode.historical => 'Historical',
                    };
                    return Padding(
                      padding: const EdgeInsets.only(right: AppSpacing.xs),
                      child: ChoiceChip(
                        label: Text(label),
                        selected: _filter == mode,
                        selectedColor:
                            AppColors.poultryColor.withAlpha(38),
                        labelStyle: TextStyle(
                          color: _filter == mode
                              ? AppColors.poultryColor
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

              // ── Flock list ───────────────────────────────────────────
              Expanded(
                child: filtered.isEmpty
                    ? const _EmptyView()
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(
                          AppSpacing.md,
                          AppSpacing.xs,
                          AppSpacing.md,
                          AppSpacing.md,
                        ),
                        itemCount: filtered.length,
                        separatorBuilder: (_, i) =>
                            const SizedBox(height: AppSpacing.sm),
                        itemBuilder: (_, i) =>
                            _FlockCard(flock: filtered[i]),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ── Analytics strip ───────────────────────────────────────────────────────────

class _AnalyticsStrip extends StatelessWidget {
  const _AnalyticsStrip({
    required this.activeFlocks,
    required this.totalBirds,
    required this.avgMortPct,
    required this.avgFcr,
  });

  final int activeFlocks;
  final int totalBirds;
  final double avgMortPct;
  final double? avgFcr;

  @override
  Widget build(BuildContext context) {

    return Container(
      margin: const EdgeInsets.fromLTRB(
          AppSpacing.md, AppSpacing.sm, AppSpacing.md, 0),
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.poultryColorContainer,
        borderRadius: AppRadius.card,
      ),
      child: Row(
        children: [
          _StatCell(
            label: 'Active',
            value: '$activeFlocks',
            icon: Icons.batch_prediction_outlined,
          ),
          _Divider(),
          _StatCell(
            label: 'Total Birds',
            value: totalBirds >= 1000
                ? '${(totalBirds / 1000).toStringAsFixed(1)}k'
                : '$totalBirds',
            icon: Icons.groups_outlined,
          ),
          _Divider(),
          _StatCell(
            label: 'Avg Mort%',
            value: '${avgMortPct.toStringAsFixed(1)}%',
            icon: Icons.trending_down_outlined,
            alert: avgMortPct > 4,
          ),
          _Divider(),
          _StatCell(
            label: 'Avg FCR',
            value: avgFcr != null ? avgFcr!.toStringAsFixed(2) : '—',
            icon: Icons.show_chart,
            alert: avgFcr != null && avgFcr! > 1.9,
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
      height: 32,
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      color: AppColors.poultryColor.withAlpha(64),
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
    final valueColor =
        alert ? AppColors.error : AppColors.poultryColor;
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 16, color: AppColors.poultryColor),
          const SizedBox(height: 2),
          Text(value,
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: valueColor)),
          Text(label,
              style: const TextStyle(
                  fontSize: 10, color: AppColors.poultryColor)),
        ],
      ),
    );
  }
}

// ── Flock Card ────────────────────────────────────────────────────────────────

class _FlockCard extends StatelessWidget {
  const _FlockCard({required this.flock});

  final PoultryFlock flock;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isActive = flock.isActive;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
      elevation: 1,
      child: InkWell(
        borderRadius: AppRadius.card,
        onTap: () => context.push(AppRoutes.flockDetailPath(flock.id)),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header row ────────────────────────────────────────────────
              Row(
                children: [
                  // ── Breed photo ───────────────────────────────────────
                  _BreedImage(flock: flock),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(flock.batchName,
                            style: theme.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600)),
                        Text(flock.strain,
                            style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant)),
                      ],
                    ),
                  ),
                  _StatusChip(status: flock.status, isActive: isActive),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),

              // ── Production type + house ───────────────────────────────────
              Row(
                children: [
                  _Chip(
                    label: flock.productionType,
                    color: AppColors.poultryColor,
                    background: AppColors.poultryColorContainer,
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  _Chip(
                    label: 'House ${flock.houseId}',
                    color: theme.colorScheme.onSurfaceVariant,
                    background: theme.colorScheme.surfaceContainerHighest,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),

              // ── KPI grid ─────────────────────────────────────────────────
              Row(
                children: [
                  _Kpi(
                    icon: Icons.calendar_today_outlined,
                    label: 'Day',
                    value: '${flock.dayOfAge}',
                  ),
                  _Kpi(
                    icon: Icons.groups_outlined,
                    label: 'Birds',
                    value: '${flock.currentCount}',
                  ),
                  _Kpi(
                    icon: Icons.show_chart,
                    label: 'FCR',
                    value: flock.fcrToDate != null
                        ? flock.fcrToDate!.toStringAsFixed(2)
                        : '—',
                    alert: flock.fcrToDate != null && flock.fcrToDate! > 1.9,
                  ),
                  _Kpi(
                    icon: Icons.trending_down_outlined,
                    label: 'Mort%',
                    value: '${flock.mortalityPct.toStringAsFixed(1)}%',
                    alert: flock.mortalityPct > 4,
                  ),
                ],
              ),

              // ── Quick action buttons ──────────────────────────────────────
              const Divider(height: AppSpacing.md, thickness: 0.5),
              Row(
                children: [
                  Expanded(
                    child: TextButton.icon(
                      onPressed: () => context.push(
                          AppRoutes.addPoultryDailyRecord(flock.id)),
                      icon: const Icon(Icons.add_chart_outlined, size: 16),
                      label: const Text('Add Record'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.poultryColor,
                        visualDensity: VisualDensity.compact,
                        textStyle: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                  Container(
                      width: 1,
                      height: 24,
                      color: AppColors.poultryColor.withAlpha(51)),
                  Expanded(
                    child: TextButton.icon(
                      onPressed: () =>
                          context.push(AppRoutes.feedPhases(flock.id)),
                      icon: const Icon(Icons.restaurant_menu_outlined,
                          size: 16),
                      label: const Text('Feed Plan'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.poultryColor,
                        visualDensity: VisualDensity.compact,
                        textStyle: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                  Container(
                      width: 1,
                      height: 24,
                      color: AppColors.poultryColor.withAlpha(51)),
                  Expanded(
                    child: TextButton.icon(
                      onPressed: () =>
                          context.push(AppRoutes.flockDetailPath(flock.id)),
                      icon: const Icon(Icons.open_in_new, size: 16),
                      label: const Text('Details'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.poultryColor,
                        visualDensity: VisualDensity.compact,
                        textStyle: const TextStyle(fontSize: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Shared small widgets ───────────────────────────────────────────────────────

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.color,
    required this.background,
  });

  final String label;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm, vertical: 3),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status, required this.isActive});

  final String status;
  final bool isActive;

  @override
  Widget build(BuildContext context) {
    final color = isActive ? Colors.green : Colors.grey;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withAlpha(31),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withAlpha(102)),
      ),
      child: Text(status,
          style: TextStyle(
              color: color, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}

class _Kpi extends StatelessWidget {
  const _Kpi({
    required this.icon,
    required this.label,
    required this.value,
    this.alert = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool alert;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final valueColor = alert ? AppColors.error : theme.colorScheme.onSurface;
    return Expanded(
      child: Column(
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(height: 2),
          Text(value,
              style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700, color: valueColor)),
          Text(label,
              style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant, fontSize: 10)),
        ],
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.egg_alt_outlined, size: 56, color: AppColors.poultryColor),
          SizedBox(height: AppSpacing.md),
          Text('No flocks found',
              style: TextStyle(fontSize: 16, color: Colors.grey)),
          SizedBox(height: AppSpacing.sm),
          Text('Tap + to add your first flock',
              style: TextStyle(fontSize: 13, color: Colors.grey)),
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
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Text('Failed to load flocks:\n$message',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.error)),
      ),
    );
  }
}

// ── Role switcher (demo helper) ───────────────────────────────────────────────

class _RoleSwitcherButton extends ConsumerWidget {
  const _RoleSwitcherButton({required this.role});

  final UserRole role;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<UserRole>(
      tooltip: 'Switch role (demo)',
      icon: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.manage_accounts_outlined),
          const SizedBox(width: 4),
          Text(role.displayName,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
      itemBuilder: (_) => UserRole.values
          .map(
            (r) => PopupMenuItem<UserRole>(
              value: r,
              child: Row(
                children: [
                  if (r == role)
                    const Icon(Icons.check, size: 16,
                        color: AppColors.poultryColor)
                  else
                    const SizedBox(width: 16),
                  const SizedBox(width: 8),
                  Text(r.displayName),
                ],
              ),
            ),
          )
          .toList(),
      onSelected: (r) =>
          ref.read(userRoleProvider.notifier).setRole(r),
    );
  }
}

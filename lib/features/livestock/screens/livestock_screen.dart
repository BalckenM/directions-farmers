import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mobile_app/core/constants/livestock_constants.dart';
import 'package:mobile_app/core/router/app_routes.dart';
import 'package:mobile_app/core/theme/app_colors.dart';
import 'package:mobile_app/core/theme/app_spacing.dart';
import 'package:mobile_app/shared/widgets/farm_app_bar.dart';
import 'package:mobile_app/shared/widgets/farm_drawer.dart';
import 'package:mobile_app/shared/widgets/farm_scaffold.dart';
import 'package:mobile_app/shared/widgets/loading_shimmer.dart';
import 'package:mobile_app/features/livestock/providers/livestock_providers.dart';
import 'package:mobile_app/features/events/providers/alerts_provider.dart';

// ── Local filter state ────────────────────────────────────────────────────────

class _HerdFilterNotifier extends Notifier<int> {
  @override
  int build() => 0;
  void set(int v) => state = v;
}

final _herdFilterProvider =
    NotifierProvider<_HerdFilterNotifier, int>(_HerdFilterNotifier.new);

// ── Screen ────────────────────────────────────────────────────────────────────

class LivestockScreen extends ConsumerWidget {
  const LivestockScreen({super.key});

  static const _species = LivestockConstants.animalSpecies;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final countsAsync = [
      for (final sp in _species) ref.watch(animalsProvider(sp)),
    ];

    final allLoaded = countsAsync.every((a) => !a.isLoading);

    int countFor(int i) => (countsAsync[i] as AsyncValue<List>).when(
          data: (l) => l.length,
          loading: () => 0,
          error: (_, _) => 0,
        );

    final counts = {
      for (int i = 0; i < _species.length; i++) _species[i]: countFor(i),
    };

    final totalAnimals = counts.values.fold(0, (s, c) => s + c);
    final alertCount = ref.watch(alertsProvider).length;
    final healthPct = totalAnimals > 0
        ? ((totalAnimals - alertCount) / totalAnimals * 100).round()
        : 100;

    return FarmScaffold(
      drawer: const FarmDrawer(),
      appBar: FarmAppBar(
        title: 'Herd',
        subtitle: allLoaded
            ? '$totalAnimals animals · $healthPct% healthy'
            : 'Loading…',
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
          ? _HerdBody(
              counts: counts,
              totalAnimals: totalAnimals,
              alertCount: alertCount,
              healthPct: healthPct,
            )
          : LoadingShimmer.list(count: 8),
      floatingActionButton: FloatingActionButton.extended(heroTag: null, 
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

// ── Body ──────────────────────────────────────────────────────────────────────

class _HerdBody extends StatelessWidget {
  const _HerdBody({
    required this.counts,
    required this.totalAnimals,
    required this.alertCount,
    required this.healthPct,
  });

  final Map<String, int> counts;
  final int totalAnimals;
  final int alertCount;
  final int healthPct;

  @override
  Widget build(BuildContext context) {
    final activeSpeciesCount = LivestockConstants.animalSpecies
        .where((s) => (counts[s] ?? 0) > 0)
        .length;

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        const SizedBox(height: 12),

        // ── 1. Summary stats card ──────────────────────────────────────────
        _HerdSummaryCard(
          totalAnimals: totalAnimals,
          activeSpecies: activeSpeciesCount,
          alertCount: alertCount,
          healthPct: healthPct,
        ),

        // ── 2. Alert strip (only when alerts present) ──────────────────────
        if (alertCount > 0) ...[
          const SizedBox(height: 10),
          _AlertStrip(alertCount: alertCount),
        ],

        // ── 3. Quick actions ───────────────────────────────────────────────
        const SizedBox(height: 20),
        const Padding(
          padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.pagePaddingHorizontal),
          child: _SectionLabel('Quick Actions'),
        ),
        const SizedBox(height: 10),
        const _QuickActionsChips(),

        // ── 4. Your Livestock ──────────────────────────────────────────────
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.pagePaddingHorizontal),
          child: _SectionLabel(
            'Your Livestock',
            trailing:
                Text('${LivestockConstants.animalSpecies.length} species'),
          ),
        ),
        const SizedBox(height: 10),
        _SpeciesListSection(counts: counts),

        // ── 5. Management ──────────────────────────────────────────────────
        const SizedBox(height: 24),
        const Padding(
          padding: EdgeInsets.symmetric(
              horizontal: AppSpacing.pagePaddingHorizontal),
          child: _SectionLabel('Management'),
        ),
        const SizedBox(height: 10),
        const _ManagementSection(),

        // Bottom FAB clearance
        const SizedBox(height: AppSpacing.xxl + 48),
      ],
    );
  }
}

// ── Herd summary card ─────────────────────────────────────────────────────────

class _HerdSummaryCard extends StatelessWidget {
  const _HerdSummaryCard({
    required this.totalAnimals,
    required this.activeSpecies,
    required this.alertCount,
    required this.healthPct,
  });

  final int totalAnimals;
  final int activeSpecies;
  final int alertCount;
  final int healthPct;

  Color _healthColor() {
    if (healthPct >= 90) return AppColors.success;
    if (healthPct >= 70) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.pagePaddingHorizontal),
      child: Container(
        decoration: BoxDecoration(
          color: cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: cs.outlineVariant.withValues(alpha: 0.50),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Health indicator bar
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: _healthColor().withValues(alpha: 0.08),
                borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(17)),
                border: Border(
                  bottom: BorderSide(
                    color: cs.outlineVariant.withValues(alpha: 0.40),
                  ),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _healthColor(),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Herd Health',
                    style: tt.labelMedium?.copyWith(
                      color: cs.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '$healthPct% healthy',
                    style: tt.labelMedium?.copyWith(
                      color: _healthColor(),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),

            // 3-stat row
            IntrinsicHeight(
              child: Row(
                children: [
                  _StatPillar(
                    value: '$totalAnimals',
                    label: 'Animals',
                    icon: Icons.pets_rounded,
                    color: AppColors.primary,
                  ),
                  VerticalDivider(
                    width: 1,
                    thickness: 1,
                    color: cs.outlineVariant.withValues(alpha: 0.50),
                  ),
                  _StatPillar(
                    value: '$activeSpecies',
                    label: 'Species',
                    icon: Icons.category_rounded,
                    color: AppColors.tertiary,
                  ),
                  VerticalDivider(
                    width: 1,
                    thickness: 1,
                    color: cs.outlineVariant.withValues(alpha: 0.50),
                  ),
                  _StatPillar(
                    value: '$alertCount',
                    label: 'Alerts',
                    icon: Icons.warning_amber_rounded,
                    color: alertCount > 0 ? AppColors.warning : AppColors.success,
                    muted: alertCount == 0,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatPillar extends StatelessWidget {
  const _StatPillar({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
    this.muted = false,
  });

  final String value;
  final String label;
  final IconData icon;
  final Color color;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final effectiveColor = muted ? cs.onSurfaceVariant : color;

    return Expanded(
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(icon,
                    size: 14,
                    color: effectiveColor.withValues(alpha: 0.70)),
                const SizedBox(width: 5),
                Text(
                  value,
                  style: tt.titleLarge?.copyWith(
                    color: effectiveColor,
                    fontWeight: FontWeight.w800,
                    height: 1.0,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: tt.labelSmall?.copyWith(
                color: cs.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Alert strip ───────────────────────────────────────────────────────────────

class _AlertStrip extends StatelessWidget {
  const _AlertStrip({required this.alertCount});
  final int alertCount;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.pagePaddingHorizontal),
      child: Material(
        color: AppColors.warningContainer,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => context.push(AppRoutes.recordAlerts),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.warning_amber_rounded,
                      color: AppColors.warning, size: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    '$alertCount animal${alertCount > 1 ? 's need' : ' needs'} attention',
                    style: tt.bodySmall?.copyWith(
                      color: AppColors.onWarningContainer,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  'View all →',
                  style: tt.labelSmall?.copyWith(
                    color: AppColors.warning,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Section label ─────────────────────────────────────────────────────────────

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.title, {this.trailing});
  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Row(
      children: [
        Text(
          title.toUpperCase(),
          style: tt.labelSmall?.copyWith(
            color: cs.onSurfaceVariant,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
          ),
        ),
        if (trailing != null) ...[
          const Spacer(),
          DefaultTextStyle(
            style: tt.labelSmall!.copyWith(
              color: cs.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
            child: trailing!,
          ),
        ],
      ],
    );
  }
}

// ── Quick action chips ────────────────────────────────────────────────────────

class _QuickActionsChips extends StatelessWidget {
  const _QuickActionsChips();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.pagePaddingHorizontal),
        children: [
          _ActionChip(
            label: 'Add Animal',
            icon: Icons.add_circle_outline_rounded,
            color: AppColors.primary,
            onTap: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              useSafeArea: true,
              builder: (_) => const _AddAnimalSpeciesPicker(),
            ),
          ),
          const SizedBox(width: 8),
          _ActionChip(
            label: 'Alerts',
            icon: Icons.notifications_rounded,
            color: AppColors.warning,
            onTap: () => context.push(AppRoutes.recordAlerts),
          ),
          const SizedBox(width: 8),
          _ActionChip(
            label: 'Groups',
            icon: Icons.group_work_outlined,
            color: AppColors.tertiary,
            onTap: () => context.push(AppRoutes.groups),
          ),
          const SizedBox(width: 8),
          _ActionChip(
            label: 'Health',
            icon: Icons.monitor_heart_outlined,
            color: AppColors.error,
            onTap: () => context.push(AppRoutes.recordHealth),
          ),
          const SizedBox(width: 8),
          _ActionChip(
            label: 'Movements',
            icon: Icons.swap_horiz_rounded,
            color: AppColors.secondary,
            onTap: () => context.push(AppRoutes.movementRecords),
          ),
          const SizedBox(width: 8),
          _ActionChip(
            label: 'LITS Export',
            icon: Icons.upload_file_outlined,
            color: AppColors.success,
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('LITS export coming soon'),
                duration: Duration(seconds: 2),
              ),
            ),
          ),
          const SizedBox(width: 8),
          _ActionChip(
            label: 'FMD Zone',
            icon: Icons.health_and_safety_outlined,
            color: AppColors.info,
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('FMD zone map coming soon'),
                duration: Duration(seconds: 2),
              ),
            ),
          ),
          const SizedBox(width: 8),
          _ActionChip(
            label: 'Market',
            icon: Icons.storefront_outlined,
            color: AppColors.secondary,
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Market prices coming soon'),
                duration: Duration(seconds: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({
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
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(100),
      child: InkWell(
        borderRadius: BorderRadius.circular(100),
        onTap: onTap,
        child: Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(100),
            border: Border.all(
              color: color.withValues(alpha: 0.28),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 17, color: color),
              const SizedBox(width: 6),
              Text(
                label,
                style: tt.labelMedium?.copyWith(
                  color: cs.onSurface,
                  fontWeight: FontWeight.w600,
                  height: 1.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Species list section ──────────────────────────────────────────────────────

class _SpeciesListSection extends StatelessWidget {
  const _SpeciesListSection({required this.counts});
  final Map<String, int> counts;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final species = LivestockConstants.animalSpecies;

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.pagePaddingHorizontal),
      child: Container(
        decoration: BoxDecoration(
          color: cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: cs.outlineVariant.withValues(alpha: 0.50),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(17),
          child: Column(
            children: [
              for (int i = 0; i < species.length; i++) ...[
                _SpeciesTile(
                  species: species[i],
                  count: counts[species[i]] ?? 0,
                ),
                if (i < species.length - 1)
                  Divider(
                    height: 1,
                    thickness: 1,
                    indent: 68,
                    endIndent: 0,
                    color: cs.outlineVariant.withValues(alpha: 0.40),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SpeciesTile extends StatelessWidget {
  const _SpeciesTile({required this.species, required this.count});
  final String species;
  final int count;

  static String _emoji(String sp) => switch (sp) {
        'cattle' => '🐄',
        'sheep' => '🐑',
        'goats' => '🐐',
        'pigs' => '🐷',
        'poultry' => '🐓',
        'rabbits' => '🐇',
        'bees' => '🐝',
        _ => '🐾',
      };

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final accent = AppColors.forSpecies(species);
    final hasAnimals = count > 0;

    return InkWell(
      onTap: () => context.go(AppRoutes.livestockSpeciesPath(species)),
      child: Padding(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            // Emoji badge
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: hasAnimals ? 0.12 : 0.06),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  _emoji(species),
                  style: TextStyle(
                    fontSize: 22,
                    height: 1.0,
                    color: hasAnimals ? null : const Color(0x80000000),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Name + sub
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    LivestockConstants.displayName(species),
                    style: tt.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: hasAnimals
                          ? cs.onSurface
                          : cs.onSurfaceVariant,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    hasAnimals ? '$count head registered' : 'None registered',
                    style: tt.bodySmall?.copyWith(
                      color: cs.onSurfaceVariant,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),

            // Count badge
            if (hasAnimals) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                    color: accent.withValues(alpha: 0.28),
                  ),
                ),
                child: Text(
                  '$count',
                  style: TextStyle(
                    color: accent,
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    height: 1.0,
                  ),
                ),
              ),
            ],

            const SizedBox(width: 8),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: cs.onSurfaceVariant.withValues(alpha: 0.50),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Management section ────────────────────────────────────────────────────────

class _ManagementSection extends StatelessWidget {
  const _ManagementSection();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final items = [
      (
        label: 'Groups & Herds',
        sub: 'Paddock assignments',
        icon: Icons.group_work_rounded,
        color: AppColors.tertiary,
        route: AppRoutes.groups,
      ),
      (
        label: 'Health Records',
        sub: 'Events & treatments',
        icon: Icons.monitor_heart_rounded,
        color: AppColors.error,
        route: AppRoutes.recordHealth,
      ),
      (
        label: 'Movements',
        sub: 'Transfers & sales',
        icon: Icons.moving_rounded,
        color: AppColors.secondary,
        route: AppRoutes.movementRecords,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.pagePaddingHorizontal),
      child: Container(
        decoration: BoxDecoration(
          color: cs.surfaceContainerLow,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: cs.outlineVariant.withValues(alpha: 0.50),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(17),
          child: Column(
            children: [
              for (int i = 0; i < items.length; i++) ...[
                InkWell(
                  onTap: () => context.push(items[i].route),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 14),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: items[i]
                                .color
                                .withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(11),
                          ),
                          child: Icon(items[i].icon,
                              color: items[i].color, size: 20),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                items[i].label,
                                style: tt.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 1),
                              Text(
                                items[i].sub,
                                style: tt.bodySmall?.copyWith(
                                  color: cs.onSurfaceVariant,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          size: 20,
                          color: cs.onSurfaceVariant
                              .withValues(alpha: 0.50),
                        ),
                      ],
                    ),
                  ),
                ),
                if (i < items.length - 1)
                  Divider(
                    height: 1,
                    thickness: 1,
                    indent: 66,
                    endIndent: 0,
                    color: cs.outlineVariant.withValues(alpha: 0.40),
                  ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ── Add animal species picker ─────────────────────────────────────────────────

class _AddAnimalSpeciesPicker extends StatelessWidget {
  const _AddAnimalSpeciesPicker();

  static String _emoji(String sp) => switch (sp) {
        'cattle' => '🐄',
        'sheep' => '🐑',
        'goats' => '🐐',
        'pigs' => '🐷',
        'poultry' => '🐓',
        'rabbits' => '🐇',
        'bees' => '🐝',
        _ => '🐾',
      };

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: cs.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Add Animal',
                style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text('Select species to register',
                style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant)),
            const SizedBox(height: 16),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 10,
                crossAxisSpacing: 10,
                childAspectRatio: 1.0,
              ),
              itemCount: LivestockConstants.allSpecies.length,
              itemBuilder: (_, i) {
                final sp = LivestockConstants.allSpecies[i];
                final color = AppColors.forSpecies(sp);
                return Material(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () {
                      context.pop();
                      context.push(AppRoutes.addAnimalPath(sp));
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.10),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                            color: color.withValues(alpha: 0.28)),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(_emoji(sp),
                              style: const TextStyle(
                                  fontSize: 26, height: 1)),
                          const SizedBox(height: 6),
                          Text(
                            LivestockConstants.displayName(sp),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: color,
                              height: 1.2,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ── Filter bottom sheet ───────────────────────────────────────────────────────

class _Filter {
  const _Filter({required this.label, required this.icon, required this.color});
  final String label;
  final IconData icon;
  final Color color;
}

class _FilterBottomSheet extends ConsumerWidget {
  const _FilterBottomSheet();

  static const _filters = [
    _Filter(
        label: 'All animals',
        icon: Icons.pets_rounded,
        color: AppColors.primary),
    _Filter(
        label: 'With alerts',
        icon: Icons.warning_amber_rounded,
        color: AppColors.warning),
    _Filter(
        label: 'Active only',
        icon: Icons.check_circle_rounded,
        color: AppColors.success),
    _Filter(
        label: 'Pregnant',
        icon: Icons.favorite_rounded,
        color: AppColors.breedingPink),
    _Filter(
        label: 'Overdue check-ups',
        icon: Icons.schedule_rounded,
        color: AppColors.error),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(_herdFilterProvider);
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: cs.outlineVariant,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text('Filter Herd',
                style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            for (int i = 0; i < _filters.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Material(
                  color: i == selected
                      ? _filters[i].color.withValues(alpha: 0.08)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () {
                      ref.read(_herdFilterProvider.notifier).set(i);
                      context.pop();
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 11),
                      child: Row(
                        children: [
                          Container(
                            width: 34,
                            height: 34,
                            decoration: BoxDecoration(
                              color: _filters[i]
                                  .color
                                  .withValues(alpha: i == selected ? 0.18 : 0.10),
                              borderRadius: BorderRadius.circular(9),
                            ),
                            child: Icon(
                              _filters[i].icon,
                              color: _filters[i].color,
                              size: 17,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _filters[i].label,
                              style: tt.bodyMedium?.copyWith(
                                fontWeight: i == selected
                                    ? FontWeight.w700
                                    : FontWeight.w500,
                                color: i == selected
                                    ? _filters[i].color
                                    : cs.onSurface,
                              ),
                            ),
                          ),
                          if (i == selected)
                            Container(
                              width: 20,
                              height: 20,
                              decoration: BoxDecoration(
                                color: _filters[i].color,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.check_rounded,
                                  color: Colors.white, size: 13),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

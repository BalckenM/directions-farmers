import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/farm_app_bar.dart';
import '../../../shared/widgets/farm_drawer.dart';
import '../../../shared/widgets/farm_scaffold.dart';
import '../../../shared/widgets/loading_shimmer.dart';
import '../models/aquaculture_unit.dart';
import '../providers/aquaculture_providers.dart';

class AquacultureScreen extends ConsumerWidget {
  const AquacultureScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unitsAsync = ref.watch(aquacultureUnitsProvider);

    final emergencyCount = unitsAsync.whenOrNull(
          data: (u) => u.where((x) => x.hasEmergency).length,
        ) ??
        0;

    return FarmScaffold(
      drawer: const FarmDrawer(),
      appBar: FarmAppBar(
        title: 'Aquaculture Units',
        subtitle: unitsAsync.whenOrNull(
          data: (u) => '${u.length} unit${u.length == 1 ? '' : 's'}',
        ),
        actions: emergencyCount > 0
            ? [
                Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: _AlertBadge(
                    count: emergencyCount,
                    color: AppColors.error,
                    label: 'CRIT',
                  ),
                )
              ]
            : null,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: AppColors.aquacultureColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Unit'),
      ),
      body: unitsAsync.when(
        loading: () => LoadingShimmer.list(count: 6),
        error: (e, _) => _ErrorView(message: e.toString()),
        data: (units) => units.isEmpty
            ? const _EmptyView()
            : ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.md),
                itemCount: units.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppSpacing.sm),
                itemBuilder: (_, i) => _UnitCard(unit: units[i]),
              ),
      ),
    );
  }
}

// ── Unit Card ─────────────────────────────────────────────────────────────────

class _UnitCard extends StatelessWidget {
  const _UnitCard({required this.unit});

  final AquacultureUnit unit;

  Color _doColor(AquacultureUnit u) {
    if (u.isDoEmergency) return AppColors.error;
    if (u.isDoWarning) return Colors.orange;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activeBatch = unit.currentBatch;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
      elevation: 1,
      child: InkWell(
        borderRadius: AppRadius.card,
        onTap: () => context.push(AppRoutes.aquaUnitDetailPath(unit.id)),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ────────────────────────────────────────────────────
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.aquacultureColorContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.water,
                        color: AppColors.aquacultureColor, size: 22),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(unit.unitName,
                            style: theme.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600)),
                        Text(
                            '${unit.unitTypeLabel} · ${activeBatch?.species ?? unit.species}',    
                            style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant)),
                      ],
                    ),
                  ),
                  if (unit.hasEmergency)
                    const _AlertBadge(
                        count: 1, color: AppColors.error, label: 'CRIT')
                  else if (unit.hasAlerts)
                    _AlertBadge(
                        count: 1, color: Colors.orange, label: 'WARN'),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),

              // ── Water quality row ─────────────────────────────────────────
              if (unit.currentDoMgL != null || unit.currentPh != null) ...[
                Row(
                  children: [
                    _WqKpi(
                      label: 'DO',
                      value: unit.currentDoMgL != null
                          ? '${unit.currentDoMgL!.toStringAsFixed(1)} mg/L'
                          : '—',
                      color: _doColor(unit),
                      icon: Icons.opacity,
                    ),
                    _WqKpi(
                      label: 'pH',
                      value: unit.currentPh != null
                          ? unit.currentPh!.toStringAsFixed(1)
                          : '—',
                      color: unit.phAlert ? Colors.orange : Colors.green,
                      icon: Icons.science_outlined,
                    ),
                    _WqKpi(
                      label: 'NH₃',
                      value: unit.currentAmmoniaMgL != null
                          ? '${unit.currentAmmoniaMgL!.toStringAsFixed(2)} mg/L'
                          : '—',
                      color:
                          unit.ammoniaAlert ? Colors.orange : Colors.green,
                      icon: Icons.warning_amber_outlined,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
              ],

              // ── Stock row ─────────────────────────────────────────────────
              if (activeBatch != null)
                Row(
                  children: [
                    _KpiTile(
                      label: 'Stocked',
                      value: '${activeBatch.initialCount}',
                    ),
                    _KpiTile(
                      label: 'Biomass',
                      value: '${activeBatch.biomassKg.toStringAsFixed(0)} kg',
                    ),
                    _KpiTile(
                      label: 'Survival',
                      value: activeBatch.survivalRatePct != null
                          ? '${activeBatch.survivalRatePct!.toStringAsFixed(1)}%'
                          : '—',
                    ),
                    _KpiTile(
                      label: 'DOC',
                      value: '${activeBatch.daysInCulture}d',
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

class _WqKpi extends StatelessWidget {
  const _WqKpi({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  final String label;
  final String value;
  final Color color;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Row(
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 3),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(fontSize: 10, color: Colors.grey)),
                Text(value,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: color)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _KpiTile extends StatelessWidget {
  const _KpiTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: theme.textTheme.labelMedium
                  ?.copyWith(fontWeight: FontWeight.w700)),
          Text(label,
              style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant, fontSize: 10)),
        ],
      ),
    );
  }
}

class _AlertBadge extends StatelessWidget {
  const _AlertBadge({
    required this.count,
    required this.color,
    required this.label,
  });

  final int count;
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text(count > 1 ? '$count $label' : label,
          style: TextStyle(
              color: color, fontSize: 11, fontWeight: FontWeight.w700)),
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
          Icon(Icons.water_outlined, size: 56, color: AppColors.aquacultureColor),
          SizedBox(height: AppSpacing.md),
          Text('No aquaculture units', style: TextStyle(color: Colors.grey)),
          SizedBox(height: AppSpacing.sm),
          Text('Tap + to add your first pond or tank',
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
        child: Text('Failed to load units:\n$message',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.error)),
      ),
    );
  }
}

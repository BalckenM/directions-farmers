import 'dart:convert';

import 'package:csv/csv.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/auth/user_role.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/web_download.dart';
import '../../../shared/widgets/farm_app_bar.dart';
import '../../../shared/widgets/farm_scaffold.dart';
import '../models/flock.dart';
import '../models/poultry_flock.dart';
import '../providers/poultry_providers.dart';

class FlockDetailScreen extends ConsumerStatefulWidget {
  const FlockDetailScreen({super.key, required this.flockId});

  final String flockId;

  @override
  ConsumerState<FlockDetailScreen> createState() => _FlockDetailScreenState();
}

class _FlockDetailScreenState extends ConsumerState<FlockDetailScreen> {
  @override
  Widget build(BuildContext context) {
    final flockAsync = ref.watch(flockDetailProvider(widget.flockId));

    return flockAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
      data: (flock) {
        if (flock == null) {
          return const Scaffold(body: Center(child: Text('Flock not found')));
        }
        return DefaultTabController(
          length: 5,
          child: _FlockDetailView(flockId: widget.flockId, flock: flock),
        );
      },
    );
  }
}

class _FlockDetailView extends ConsumerWidget {
  const _FlockDetailView({required this.flockId, required this.flock});

  final String flockId;
  final PoultryFlock flock;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordsAsync = ref.watch(flockDailyRecordsProvider(flockId));
    final vaccAsync = ref.watch(flockVaccinationProvider(flockId));
    final healthAsync = ref.watch(flockDiseaseEventsProvider(flockId));
    final medicationAsync = ref.watch(flockMedicationLogsProvider(flockId));
    final envAsync = ref.watch(flockEnvironmentReadingsProvider(flockId));

    return FarmScaffold(
      drawer: null,
      appBar: FarmAppBar(
        title: flock.batchName,
        subtitle: '${flock.productionType} · Day ${flock.dayOfAge}',
        actions: [
          IconButton(
            icon: const Icon(Icons.add_chart_outlined),
            tooltip: 'Add Daily Record',
            onPressed: () =>
                context.push(AppRoutes.addPoultryDailyRecord(flockId)),
          ),
          _ExportButton(flockId: flockId),
          _FlockActionMenu(flockId: flockId, flock: flock),
        ],
        bottom: TabBar(
          indicatorColor: AppColors.poultryColor,
          labelColor: AppColors.poultryColor,
          unselectedLabelColor: Theme.of(context).colorScheme.onSurfaceVariant,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Daily Records'),
            Tab(text: 'Vaccination'),
            Tab(text: 'Health'),
            Tab(text: 'Environment'),
          ],
        ),
      ),
      body: Column(
        children: [
          // ── Mortality spike alert ─────────────────────────────────────
          Consumer(
            builder: (ctx, ref, _) {
              final isSpiking = ref.watch(mortalitySpikeProvider(flockId));
              if (!isSpiking) return const SizedBox.shrink();
              return Container(
                margin: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.error.withAlpha(26),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.error.withAlpha(102)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.warning_amber_rounded, color: AppColors.error),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Mortality Spike: Today\'s mortality exceeds 3× '
                        'the rolling average. Investigate immediately.',
                        style: TextStyle(color: AppColors.error),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          Expanded(
            child: TabBarView(
              children: [
                _OverviewTab(flock: flock),
                _DailyRecordsTab(flockId: flockId, recordsAsync: recordsAsync),
                _VaccinationTab(flockId: flockId, vaccAsync: vaccAsync),
                _HealthTab(
                  flockId: flockId,
                  diseaseAsync: healthAsync,
                  medicationAsync: medicationAsync,
                ),
                _EnvironmentTab(flockId: flockId, envAsync: envAsync),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// â”€â”€ Overview Tab â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _OverviewTab extends ConsumerWidget {
  const _OverviewTab({required this.flock});

  final PoultryFlock flock;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final harvestAsync = ref.watch(flockHarvestRecordsProvider(flock.id));
    final canFinancials = ref.watch(userRoleProvider).canEditFinancials;
    final dailyAsync = ref.watch(flockDailyRecordsProvider(flock.id));
    final ndOverdue =
        ref.watch(newcastleOverdueProvider(flock.id)).value ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _TabActionBar(
          actions: [
            _TabAction(
              icon: Icons.restaurant_menu_outlined,
              label: 'Feed Plan',
              onTap: () => context.push(AppRoutes.feedPhases(flock.id)),
            ),
            _TabAction(
              icon: Icons.attach_money_outlined,
              label: 'Financials',
              onTap: canFinancials
                  ? () => context.push(AppRoutes.financialScreen(flock.id))
                  : null,
            ),
          ],
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Newcastle disease recurring-vaccination alert ──────────
                if (ndOverdue) ...[
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withAlpha(31),
                      borderRadius: BorderRadius.circular(AppRadius.sm),
                      border: Border.all(color: AppColors.warning),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.vaccines_outlined,
                          color: AppColors.warning,
                          size: 20,
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            'Newcastle Disease vaccination overdue (>28 days). '
                            'Schedule a booster on the Vaccination tab.',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppColors.warning),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
                // â”€â”€ Performance KPIs â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                _SectionTitle('Performance'),
                const SizedBox(height: AppSpacing.sm),
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: AppSpacing.sm,
                  crossAxisSpacing: AppSpacing.sm,
                  childAspectRatio: 2.2,
                  children: [
                    _KpiCard(
                      label: 'FCR to Date',
                      value: flock.fcrToDate?.toStringAsFixed(2) ?? 'â€”',
                      icon: Icons.show_chart,
                      alert: flock.fcrToDate != null && flock.fcrToDate! > 1.9,
                    ),
                    _KpiCard(
                      label: 'Livability',
                      value: flock.livabilityPct != null
                          ? '${flock.livabilityPct!.toStringAsFixed(1)}%'
                          : 'â€”',
                      icon: Icons.favorite_border,
                      alert:
                          flock.livabilityPct != null &&
                          flock.livabilityPct! < 95,
                    ),
                    _KpiCard(
                      label: 'Mortality %',
                      value: '${flock.mortalityPct.toStringAsFixed(1)}%',
                      icon: Icons.trending_down,
                      alert: flock.mortalityPct > 4,
                    ),
                    _KpiCard(
                      label: 'Avg Weight',
                      value: flock.currentAvgWeightG != null
                          ? '${flock.currentAvgWeightG!.toStringAsFixed(0)}g'
                          : 'â€”',
                      icon: Icons.monitor_weight_outlined,
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),

                // â”€â”€ Flock info â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                _SectionTitle('Flock Info'),
                const SizedBox(height: AppSpacing.sm),
                _InfoRow(label: 'Strain', value: flock.strain),
                _InfoRow(label: 'Placement date', value: flock.placementDate),
                _InfoRow(
                  label: 'Placement count',
                  value: '${flock.placementCount}',
                ),
                _InfoRow(
                  label: 'Current count',
                  value: '${flock.currentCount}',
                ),
                _InfoRow(
                  label: 'Total mortality',
                  value: '${flock.mortalityTotal}',
                ),
                _InfoRow(label: 'House', value: flock.houseId),

                // â”€â”€ Layer-specific â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                if (flock.isLayer && flock.layerSpecific != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  _SectionTitle('Layer Performance'),
                  const SizedBox(height: AppSpacing.sm),
                  _InfoRow(
                    label: 'HDP %',
                    value: flock.layerSpecific!.currentHdpPct != null
                        ? '${flock.layerSpecific!.currentHdpPct!.toStringAsFixed(1)}%'
                        : 'â€”',
                  ),
                  _InfoRow(
                    label: 'Peak HDP',
                    value: flock.layerSpecific!.peakHdpPct != null
                        ? '${flock.layerSpecific!.peakHdpPct!.toStringAsFixed(1)}%'
                        : 'â€”',
                  ),
                  _InfoRow(
                    label: 'Total eggs',
                    value: '${flock.layerSpecific!.totalEggsProduced ?? 0}',
                  ),
                  // â”€â”€ HDP Trend chart â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                  dailyAsync.whenOrNull(
                        data: (records) {
                          if (records.length < 2) return null;
                          final last30 = records.length > 30
                              ? records.sublist(records.length - 30)
                              : records;
                          final hdpSpots = <FlSpot>[];
                          for (var i = 0; i < last30.length; i++) {
                            final v = last30[i].hdpPct;
                            if (v != null)
                              hdpSpots.add(FlSpot(i.toDouble(), v));
                          }
                          if (hdpSpots.isEmpty) return null;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: AppSpacing.md),
                              _SectionTitle('HDP Trend (last 30 days)'),
                              const SizedBox(height: AppSpacing.sm),
                              _MiniLineChart(
                                spots: hdpSpots,
                                yLabel: '%',
                                lineColor: AppColors.poultryColor,
                              ),
                            ],
                          );
                        },
                      ) ??
                      const SizedBox.shrink(),
                ],

                // â”€â”€ Broiler-specific â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                if (flock.isBroiler && flock.broilerSpecific != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  _SectionTitle('Broiler Performance'),
                  const SizedBox(height: AppSpacing.sm),
                  _InfoRow(
                    label: 'EPEF',
                    value: flock.broilerSpecific!.epefCurrent != null
                        ? flock.broilerSpecific!.epefCurrent!.toStringAsFixed(1)
                        : 'â€”',
                  ),
                  _InfoRow(
                    label: 'Target FCR 42d',
                    value: flock.broilerSpecific!.targetFcr42d != null
                        ? flock.broilerSpecific!.targetFcr42d!.toStringAsFixed(
                            2,
                          )
                        : 'â€”',
                  ),
                  // â”€â”€ Weight benchmark chart â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                  dailyAsync.whenOrNull(
                        data: (records) {
                          if (records.length < 2) return null;
                          final actualSpots = <FlSpot>[];
                          for (final r in records) {
                            if (r.dayOfAge != null &&
                                r.avgBodyWeightG != null) {
                              actualSpots.add(
                                FlSpot(
                                  r.dayOfAge!.toDouble(),
                                  r.avgBodyWeightG!.toDouble(),
                                ),
                              );
                            }
                          }
                          if (actualSpots.isEmpty) return null;
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: AppSpacing.md),
                              _SectionTitle('Weight vs Ross 308 Benchmark'),
                              const SizedBox(height: AppSpacing.sm),
                              _WeightBenchmarkChart(
                                actualSpots: actualSpots,
                                strain: flock.strain,
                              ),
                            ],
                          );
                        },
                      ) ??
                      const SizedBox.shrink(),
                ],

                // â”€â”€ Harvest / Depletion Record â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                if (flock.status == 'harvested' ||
                    flock.status == 'depleted') ...[
                  const SizedBox(height: AppSpacing.md),
                  _SectionTitle('Harvest Record'),
                  const SizedBox(height: AppSpacing.sm),
                  harvestAsync.when(
                    loading: () => const SizedBox(
                      height: 80,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (e, _) => Text('Error loading harvest data: $e'),
                    data: (records) {
                      if (records.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: AppSpacing.sm,
                          ),
                          child: Text('No harvest record on file.'),
                        );
                      }
                      final hr = records.first;
                      return Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.card,
                          side: BorderSide(
                            color: AppColors.poultryColor.withAlpha(80),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: Column(
                            children: [
                              _InfoRow(
                                label: 'Harvest Date',
                                value: hr.harvestDate,
                              ),
                              _InfoRow(
                                label: 'Birds Harvested',
                                value: '${hr.birdsHarvested}',
                              ),
                              _InfoRow(
                                label: 'Total Live Weight',
                                value:
                                    '${hr.totalLiveWeightKg.toStringAsFixed(1)} kg',
                              ),
                              _InfoRow(
                                label: 'Avg Harvest Weight',
                                value:
                                    '${hr.avgHarvestWeightKg.toStringAsFixed(3)} kg',
                              ),
                              if (hr.processorName != null)
                                _InfoRow(
                                  label: 'Processor',
                                  value: hr.processorName!,
                                ),
                              if (hr.carcassGradeAPct != null)
                                _InfoRow(
                                  label: 'Grade A %',
                                  value:
                                      '${hr.carcassGradeAPct!.toStringAsFixed(1)}%',
                                ),
                              if (hr.condemnationRatePct != null)
                                _InfoRow(
                                  label: 'Condemnation %',
                                  value:
                                      '${hr.condemnationRatePct!.toStringAsFixed(1)}%',
                                ),
                              if (hr.pricePerKgZar != null && canFinancials)
                                _InfoRow(
                                  label: 'Price / kg',
                                  value:
                                      'ZAR ${hr.pricePerKgZar!.toStringAsFixed(2)}',
                                ),
                              if (hr.pricePerKgZar != null && canFinancials)
                                _InfoRow(
                                  label: 'Total Revenue',
                                  value:
                                      'ZAR ${hr.totalRevenueZar.toStringAsFixed(2)}',
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],

                const SizedBox(height: AppSpacing.xl),

                // ── More features ───────────────────────────────────────────
                _SectionTitle('More'),
                const SizedBox(height: AppSpacing.sm),
                Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: AppRadius.card,
                    side: BorderSide(
                      color: Theme.of(context).colorScheme.outlineVariant,
                    ),
                  ),
                  child: Column(
                    children: [
                      ListTile(
                        leading: const Icon(Icons.health_and_safety_outlined),
                        title: const Text('Biosecurity Log'),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.push(
                          '/livestock/poultry/${flock.id}/biosecurity',
                        ),
                      ),
                      if (flock.isBroiler ||
                          flock.productionType == 'turkey') ...[
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.layers_outlined),
                          title: const Text('Litter Management'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => context.push(
                            '/livestock/poultry/${flock.id}/litter',
                          ),
                        ),
                      ],
                      if (flock.isLayer) ...[
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.loop_outlined),
                          title: const Text('Molt Management'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => context.push(
                            '/livestock/poultry/${flock.id}/molt',
                          ),
                        ),
                      ],
                      if (flock.productionType == 'breeder') ...[
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.egg_outlined),
                          title: const Text('Breeder Records'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => context.push(
                            '/livestock/poultry/${flock.id}/breeder-records',
                          ),
                        ),
                      ],
                      if (flock.isLayer ||
                          flock.productionType == 'breeder') ...[
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(Icons.sell_outlined),
                          title: const Text('Record Egg Sale'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () => context.push(
                            '/livestock/poultry/${flock.id}/egg-sales/new',
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // ── Close Batch ─────────────────────────────────────────────
                if (flock.isActive) ...[
                  const SizedBox(height: AppSpacing.md),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Theme.of(context).colorScheme.error,
                      side: BorderSide(
                        color: Theme.of(
                          context,
                        ).colorScheme.error.withAlpha(128),
                      ),
                      minimumSize: const Size.fromHeight(48),
                    ),
                    icon: const Icon(Icons.lock_outline),
                    label: const Text('Close Batch'),
                    onPressed: () async {
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Close Batch'),
                          content: Text(
                            'Mark "${flock.batchName}" as depleted? '
                            'This action records the end of this production cycle.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancel'),
                            ),
                            FilledButton(
                              style: FilledButton.styleFrom(
                                backgroundColor: Theme.of(
                                  context,
                                ).colorScheme.error,
                              ),
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Close Batch'),
                            ),
                          ],
                        ),
                      );
                      if (confirmed == true && context.mounted) {
                        ref
                            .read(flockStatusOverrideProvider.notifier)
                            .setStatus(flock.id, 'depleted');
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '${flock.batchName} closed successfully',
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ],

                const SizedBox(height: AppSpacing.xl),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// â”€â”€ Daily Records Tab â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _DailyRecordsTab extends ConsumerWidget {
  const _DailyRecordsTab({required this.flockId, required this.recordsAsync});

  final String flockId;
  final AsyncValue<List<DailyRecord>> recordsAsync;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // â”€â”€ Quick action bar â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
        _TabActionBar(
          actions: [
            _TabAction(
              icon: Icons.add_chart_outlined,
              label: 'Add Record',
              onTap: () =>
                  context.push(AppRoutes.addPoultryDailyRecord(flockId)),
            ),
            _TabAction(
              icon: Icons.inventory_2_outlined,
              label: 'Record Harvest',
              onTap: () => context.push(AppRoutes.harvestRecord(flockId)),
            ),
          ],
        ),
        // â”€â”€ Record list â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
        Expanded(
          child: recordsAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (records) => records.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.xl),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.add_chart_outlined,
                            size: 56,
                            color: AppColors.poultryColor.withAlpha(102),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          const Text(
                            'No daily records yet',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          const Text(
                            'Tap "Add Daily Record" above\nto log your first entry.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  )
                : Builder(
                    builder: (context) {
                      // â”€â”€ Mortality spike detection â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
                      final totalMort = records.fold<int>(
                        0,
                        (s, r) => s + (r.mortalityCount ?? 0),
                      );
                      final batchAvg = records.isEmpty
                          ? 0.0
                          : totalMort / records.length;
                      final last2 = records.length >= 2
                          ? records.sublist(records.length - 2)
                          : records;
                      final spikeDetected =
                          last2.length == 2 &&
                          batchAvg > 0 &&
                          last2.every(
                            (r) => (r.mortalityCount ?? 0) > batchAvg * 3,
                          );

                      return Column(
                        children: [
                          if (spikeDetected)
                            Container(
                              color: AppColors.error.withAlpha(26),
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.md,
                                vertical: 8,
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.warning_amber_rounded,
                                    color: AppColors.error,
                                    size: 18,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      'âš  Mortality spike â€” 2 consecutive days above 3Ã— batch average',
                                      style: const TextStyle(
                                        color: AppColors.error,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                  TextButton(
                                    onPressed: () => context.push(
                                      AppRoutes.addDiseaseEvent(flockId),
                                    ),
                                    child: const Text(
                                      'Log Event',
                                      style: TextStyle(color: AppColors.error),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          Expanded(
                            child: ListView.separated(
                              padding: const EdgeInsets.all(AppSpacing.md),
                              itemCount: records.length,
                              separatorBuilder: (_, i) =>
                                  const SizedBox(height: AppSpacing.xs),
                              itemBuilder: (_, i) {
                                final rec = records[i];
                                return Dismissible(
                                  key: ValueKey(rec.id),
                                  direction: DismissDirection.endToStart,
                                  background: Container(
                                    alignment: Alignment.centerRight,
                                    padding: const EdgeInsets.only(right: 20),
                                    decoration: BoxDecoration(
                                      color: AppColors.error.withAlpha(204),
                                      borderRadius: AppRadius.card,
                                    ),
                                    child: const Icon(
                                      Icons.delete_outline,
                                      color: Colors.white,
                                    ),
                                  ),
                                  confirmDismiss: (_) => showDialog<bool>(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: const Text('Delete Record'),
                                      content: Text(
                                        'Remove the Day ${rec.dayOfAge} record dated ${rec.date}?',
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(ctx, false),
                                          child: const Text('Cancel'),
                                        ),
                                        FilledButton(
                                          style: FilledButton.styleFrom(
                                            backgroundColor: AppColors.error,
                                          ),
                                          onPressed: () =>
                                              Navigator.pop(ctx, true),
                                          child: const Text('Delete'),
                                        ),
                                      ],
                                    ),
                                  ),
                                  onDismissed: (_) {
                                    ref
                                        .read(
                                          dailyRecordDeleteProvider.notifier,
                                        )
                                        .delete(rec.id);
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Day ${rec.dayOfAge} record deleted',
                                        ),
                                        behavior: SnackBarBehavior.floating,
                                      ),
                                    );
                                  },
                                  child: _DailyRecordTile(record: rec),
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ),
      ],
    );
  }
}

class _DailyRecordTile extends StatelessWidget {
  const _DailyRecordTile({required this.record});

  final DailyRecord record;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final waterFeedAlert =
        record.waterConsumedLitres != null &&
        record.feedConsumedKg != null &&
        record.feedConsumedKg! > 0 &&
        record.waterConsumedLitres! / record.feedConsumedKg! > 2.4;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLowest,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Day ${record.dayOfAge}',
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      record.date,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                if (waterFeedAlert)
                  const Tooltip(
                    message:
                        'Water-to-feed ratio exceeds 2.4 â€” check drinkers or respiratory health',
                    child: Icon(
                      Icons.water_drop_outlined,
                      color: AppColors.warning,
                      size: 18,
                    ),
                  ),
                const SizedBox(width: AppSpacing.xs),
                _RecordStat(
                  label: 'Mort',
                  value: '${record.mortalityCount ?? 0}',
                ),
                _RecordStat(
                  label: 'Feed',
                  value: record.feedConsumedKg != null
                      ? '${record.feedConsumedKg!.toStringAsFixed(1)}kg'
                      : 'â€”',
                ),
                if (record.isLayerRecord) ...[
                  _RecordStat(label: 'Eggs', value: '${record.totalEggs}'),
                  _RecordStat(
                    label: 'HDP',
                    value: record.hdpPct != null
                        ? '${record.hdpPct!.toStringAsFixed(1)}%'
                        : 'â€”',
                  ),
                ] else ...[
                  _RecordStat(
                    label: 'Wt',
                    value: record.avgBodyWeightG != null
                        ? '${record.avgBodyWeightG!.toStringAsFixed(0)}g'
                        : 'â€”',
                  ),
                ],
              ],
            ),
            // â”€â”€ Egg grading breakdown â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            if (record.hasGrading)
              Padding(
                padding: const EdgeInsets.only(top: AppSpacing.xs),
                child: Wrap(
                  spacing: 4,
                  children: [
                    if ((record.eggsJumbo ?? 0) > 0)
                      _GradeBadge(label: 'J', count: record.eggsJumbo!),
                    if ((record.eggsExtraLarge ?? 0) > 0)
                      _GradeBadge(label: 'XL', count: record.eggsExtraLarge!),
                    if ((record.eggsLarge ?? 0) > 0)
                      _GradeBadge(label: 'L', count: record.eggsLarge!),
                    if ((record.eggsMedium ?? 0) > 0)
                      _GradeBadge(label: 'M', count: record.eggsMedium!),
                    if ((record.eggsSmall ?? 0) > 0)
                      _GradeBadge(label: 'S', count: record.eggsSmall!),
                    if ((record.eggsPeewee ?? 0) > 0)
                      _GradeBadge(label: 'P', count: record.eggsPeewee!),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _RecordStat extends StatelessWidget {
  const _RecordStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: AppSpacing.md),
      child: Column(
        children: [
          Text(
            value,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class _GradeBadge extends StatelessWidget {
  const _GradeBadge({required this.label, required this.count});

  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.poultryColorContainer,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '$label $count',
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: AppColors.poultryColor,
        ),
      ),
    );
  }
}

// â”€â”€ Vaccination Tab â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _VaccinationTab extends ConsumerWidget {
  const _VaccinationTab({required this.flockId, required this.vaccAsync});

  final String flockId;
  final AsyncValue<VaccinationSchedule?> vaccAsync;

  Future<void> _showMarkGivenSheet(
    BuildContext context,
    WidgetRef ref,
    VaccineItem item,
  ) async {
    final batchCtrl = TextEditingController();
    final productCtrl = TextEditingController(text: item.product ?? '');
    final adminCtrl = TextEditingController();
    DateTime selectedDate = DateTime.now();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.vaccines, color: AppColors.poultryColor),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Mark Vaccine Given',
                          style: Theme.of(ctx).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  const Divider(height: 1),
                  const SizedBox(height: 12),
                  Text(
                    '${item.vaccine}  ·  Day ${item.targetDay}  ·  ${item.method}',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Date
                  InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: ctx,
                        initialDate: selectedDate,
                        firstDate: DateTime(2024),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) setState(() => selectedDate = picked);
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Date Administered',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.calendar_today_outlined),
                        isDense: true,
                      ),
                      child: Text(
                        '${selectedDate.year}-'
                        '${selectedDate.month.toString().padLeft(2, '0')}-'
                        '${selectedDate.day.toString().padLeft(2, '0')}',
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: productCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Product / Brand',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: batchCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Batch / Lot Number',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: adminCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Administered By',
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      style: FilledButton.styleFrom(
                        backgroundColor: AppColors.poultryColor,
                      ),
                      icon: const Icon(Icons.check_circle_outline),
                      label: const Text('Confirm — Mark as Given'),
                      onPressed: () {
                        ref
                            .read(vaccinationAdministrationProvider.notifier)
                            .markGiven(
                              flockId: flockId,
                              targetDay: item.targetDay,
                              vaccine: item.vaccine,
                              method: item.method,
                              product: productCtrl.text.trim().isEmpty
                                  ? null
                                  : productCtrl.text.trim(),
                              batchNo: batchCtrl.text.trim().isEmpty
                                  ? null
                                  : batchCtrl.text.trim(),
                              administeredBy: adminCtrl.text.trim().isEmpty
                                  ? null
                                  : adminCtrl.text.trim(),
                            );
                        Navigator.pop(ctx);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${item.vaccine} marked as given'),
                              backgroundColor: AppColors.success,
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
    batchCtrl.dispose();
    productCtrl.dispose();
    adminCtrl.dispose();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return vaccAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (schedule) {
        if (schedule == null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.vaccines_outlined,
                    size: 56,
                    color: AppColors.poultryColor.withAlpha(102),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const Text(
                    'No vaccination schedule',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  const Text(
                    'A schedule will appear once one is\nassigned to this flock.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _TabActionBar(
                    actions: [
                      _TabAction(
                        icon: Icons.vaccines_outlined,
                        label: 'Log Given',
                        onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Assign a vaccination schedule to this flock to log vaccines.',
                            ),
                            behavior: SnackBarBehavior.floating,
                          ),
                        ),
                      ),
                      _TabAction(
                        icon: Icons.schedule_outlined,
                        label: 'Add Schedule',
                        onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Vaccination scheduling coming soon.',
                            ),
                            behavior: SnackBarBehavior.floating,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // â”€â”€ Quick action bar â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            _TabActionBar(
              actions: [
                _TabAction(
                  icon: Icons.check_circle_outlined,
                  label: 'Mark Given',
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Tap the âœ“ next to a pending vaccine to mark it as given.',
                      ),
                      behavior: SnackBarBehavior.floating,
                    ),
                  ),
                ),
                _TabAction(
                  icon: Icons.schedule_outlined,
                  label: 'Schedule Settings',
                  onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Vaccination scheduling settings coming soon.',
                      ),
                      behavior: SnackBarBehavior.floating,
                    ),
                  ),
                ),
              ],
            ),
            // â”€â”€ Due-date alert banner â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            Builder(
              builder: (ctx) {
                final now = DateTime.now();
                final upcoming = schedule.schedule.where((v) {
                  if (!v.isPending || v.dueDate == null) return false;
                  final due = DateTime.tryParse(v.dueDate!);
                  if (due == null) return false;
                  return due.isAfter(now) && due.difference(now).inDays <= 3;
                }).toList();
                if (upcoming.isEmpty) return const SizedBox.shrink();
                return Container(
                  margin: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.xs,
                    AppSpacing.md,
                    0,
                  ),
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withAlpha(31),
                    borderRadius: AppRadius.card,
                    border: Border.all(color: AppColors.warning),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.alarm_outlined,
                        color: AppColors.warning,
                        size: 16,
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          '${upcoming.length} vaccination${upcoming.length == 1 ? '' : 's'} due within 3 days',
                          style: const TextStyle(
                            color: AppColors.warning,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
            // â”€â”€ Summary bar â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            _VaccinationSummary(schedule: schedule),
            // â”€â”€ Schedule list â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            Expanded(
              child: ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.md),
                itemCount: schedule.schedule.length,
                separatorBuilder: (_, i) =>
                    const SizedBox(height: AppSpacing.xs),
                itemBuilder: (_, i) => _VaccineItemTile(
                  item: schedule.schedule[i],
                  onMarkGiven: (!schedule.schedule[i].isCompleted)
                      ? () => _showMarkGivenSheet(
                          context,
                          ref,
                          schedule.schedule[i],
                        )
                      : null,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _VaccinationSummary extends StatelessWidget {
  const _VaccinationSummary({required this.schedule});

  final VaccinationSchedule schedule;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      color: AppColors.poultryColorContainer,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: [
          _SummaryChip(
            label: 'Done',
            count: schedule.completedCount,
            color: Colors.green,
          ),
          const SizedBox(width: AppSpacing.md),
          _SummaryChip(
            label: 'Pending',
            count: schedule.pendingCount,
            color: Colors.blue,
          ),
          const SizedBox(width: AppSpacing.md),
          _SummaryChip(
            label: 'Overdue',
            count: schedule.overdueCount,
            color: Colors.red,
          ),
          const Spacer(),
          Text(
            schedule.productionType,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({
    required this.label,
    required this.count,
    required this.color,
  });

  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          '$count',
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w800,
            fontSize: 16,
          ),
        ),
        const SizedBox(width: 3),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _VaccineItemTile extends StatelessWidget {
  const _VaccineItemTile({required this.item, this.onMarkGiven});

  final VaccineItem item;
  final VoidCallback? onMarkGiven;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    Color statusColor;
    IconData statusIcon;

    if (item.isCompleted) {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle_outline;
    } else if (item.isOverdue) {
      statusColor = Colors.red;
      statusIcon = Icons.error_outline;
    } else {
      statusColor = Colors.blue;
      statusIcon = Icons.schedule;
    }

    return Card(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
      elevation: 0,
      color: theme.colorScheme.surfaceContainerLowest,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Row(
          children: [
            Icon(statusIcon, color: statusColor, size: 20),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.vaccine,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Day ${item.targetDay} · ${item.method}${item.product != null ? ' · ${item.product}' : ''}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: statusColor.withAlpha(31),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                item.status,
                style: TextStyle(
                  color: statusColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (onMarkGiven != null) ...[
              const SizedBox(width: AppSpacing.xs),
              IconButton(
                visualDensity: VisualDensity.compact,
                onPressed: onMarkGiven,
                icon: const Icon(Icons.check_circle_outline, size: 20),
                color: Colors.green,
                tooltip: 'Mark as given',
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// â”€â”€ Shared helpers â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.w700,
        color: AppColors.poultryColor,
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({
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
    final theme = Theme.of(context);
    final color = alert ? AppColors.error : AppColors.poultryColor;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: alert
            ? AppColors.error.withAlpha(20)
            : AppColors.poultryColorContainer,
        borderRadius: AppRadius.card,
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: AppSpacing.xs),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: color,
                  ),
                ),
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontSize: 10,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// â”€â”€ Health Tab â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _HealthTab extends ConsumerWidget {
  const _HealthTab({
    required this.flockId,
    required this.diseaseAsync,
    required this.medicationAsync,
  });

  final String flockId;
  final AsyncValue<List<DiseaseEvent>> diseaseAsync;
  final AsyncValue<List<MedicationLog>> medicationAsync;

  Color _severityColor(String severity) => switch (severity) {
    'emergency' => AppColors.error,
    'high' => Colors.deepOrange,
    'medium' => Colors.orange,
    _ => AppColors.success,
  };

  void _showReportDiseaseDialog(BuildContext context) {
    context.push(AppRoutes.addDiseaseEvent(flockId));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final role = ref.watch(userRoleProvider);
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // â”€â”€ Quick action bar â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
        _TabActionBar(
          actions: [
            _TabAction(
              icon: Icons.medication_outlined,
              label: 'Log Medication',
              onTap: role.canAdministerMedication
                  ? () => context.push(AppRoutes.addMedication(flockId))
                  : null,
            ),
            _TabAction(
              icon: Icons.coronavirus_outlined,
              label: 'Report Disease',
              onTap: () => _showReportDiseaseDialog(context),
            ),
          ],
        ),
        // â”€â”€ Scrollable data â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.pagePaddingHorizontal,
              vertical: AppSpacing.pagePaddingVertical,
            ),
            children: [
              Text('Disease Events', style: tt.titleSmall),
              const SizedBox(height: AppSpacing.sm),
              diseaseAsync.when(
                loading: () => const LinearProgressIndicator(),
                error: (e, _) => Text('Error: $e'),
                data: (events) {
                  if (events.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.md,
                      ),
                      child: Text(
                        'No disease events recorded.',
                        style: tt.bodySmall,
                      ),
                    );
                  }
                  return Column(
                    children: events.map((e) {
                      final color = _severityColor(e.severity);
                      return Card(
                        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                        shape: RoundedRectangleBorder(
                          borderRadius: AppRadius.card,
                          side: BorderSide(color: color.withAlpha(102)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: color.withAlpha(38),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      e.severity.toUpperCase(),
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.bold,
                                        color: color,
                                      ),
                                    ),
                                  ),
                                  if (e.isHpai) ...[
                                    const SizedBox(width: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 2,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppColors.error,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: const Text(
                                        'NOTIFIABLE',
                                        style: TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                        ),
                                      ),
                                    ),
                                  ],
                                  const Spacer(),
                                  Text(e.date, style: tt.labelSmall),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                e.disease,
                                style: tt.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              if (e.symptoms != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  'Symptoms: ${e.symptoms!}',
                                  style: tt.bodySmall,
                                ),
                              ],
                              if (e.outcome != null) ...[
                                const SizedBox(height: 4),
                                Text(
                                  'Outcome: ${e.outcome!}',
                                  style: tt.bodySmall?.copyWith(
                                    color: AppColors.success,
                                  ),
                                ),
                              ],
                              Text(
                                '${e.affectedCount} birds affected',
                                style: tt.labelSmall,
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
              const SizedBox(height: AppSpacing.xl),

              // â”€â”€ Medication Logs â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
              Text('Medication Log', style: tt.titleSmall),
              const SizedBox(height: AppSpacing.sm),
              medicationAsync.when(
                loading: () => const LinearProgressIndicator(),
                error: (e, _) => Text('Error: $e'),
                data: (logs) {
                  if (logs.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.md,
                      ),
                      child: Text(
                        'No medications recorded.',
                        style: tt.bodySmall,
                      ),
                    );
                  }
                  return Column(
                    children: logs.map((log) {
                      return Dismissible(
                        key: ValueKey(log.id),
                        direction: DismissDirection.endToStart,
                        background: Container(
                          alignment: Alignment.centerRight,
                          padding: const EdgeInsets.only(right: 20),
                          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                          decoration: BoxDecoration(
                            color: AppColors.error.withAlpha(204),
                            borderRadius: AppRadius.card,
                          ),
                          child: const Icon(
                            Icons.delete_outline,
                            color: Colors.white,
                          ),
                        ),
                        confirmDismiss: (_) => showDialog<bool>(
                          context: context,
                          builder: (ctx) => AlertDialog(
                            title: const Text('Delete Medication Log'),
                            content: Text(
                              'Remove "${log.drugName}" entry dated ${log.date}?',
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(ctx, false),
                                child: const Text('Cancel'),
                              ),
                              FilledButton(
                                style: FilledButton.styleFrom(
                                  backgroundColor: AppColors.error,
                                ),
                                onPressed: () => Navigator.pop(ctx, true),
                                child: const Text('Delete'),
                              ),
                            ],
                          ),
                        ),
                        onDismissed: (_) {
                          ref
                              .read(medicationDeleteProvider.notifier)
                              .delete(log.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                '${log.drugName} medication log deleted',
                              ),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                        child: Card(
                          margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        log.drugName,
                                        style: tt.bodyMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                    Text(log.date, style: tt.labelSmall),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Dose: ${log.dosage}',
                                  style: tt.bodySmall,
                                ),
                                Text(
                                  'Route: ${log.route.replaceAll('_', ' ')}',
                                  style: tt.bodySmall,
                                ),
                                if (log.withdrawalDays > 0)
                                  Container(
                                    margin: const EdgeInsets.only(top: 6),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.amber.shade50,
                                      borderRadius: BorderRadius.circular(4),
                                      border: Border.all(color: Colors.amber),
                                    ),
                                    child: Text(
                                      'Withdrawal: ${log.withdrawalDays} days · Clearance: ${log.clearanceDate}',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: Colors.brown,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// â”€â”€ Environment Tab â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _EnvironmentTab extends ConsumerWidget {
  const _EnvironmentTab({required this.flockId, required this.envAsync});

  final String flockId;
  final AsyncValue<List<EnvironmentReading>> envAsync;

  void _showManualReadingDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add Manual Reading'),
        content: const Text(
          'Manual environment data entry is coming in the next update.\n\n'
          'Connect IoT sensors for automatic readings, or ask your '
          'farm technician to record house conditions.',
        ),
        actions: [
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.poultryColor,
            ),
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tt = Theme.of(context).textTheme;
    final liveAsync = ref.watch(iotEnvironmentStreamProvider(flockId));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // â”€â”€ Live IoT gauge strip â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
        liveAsync.whenOrNull(
              data: (reading) => Container(
                color: AppColors.poultryColor.withAlpha(15),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.xs,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.sensors,
                      size: 14,
                      color: AppColors.poultryColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Live · ${reading.sensorZone.toUpperCase()}',
                      style: tt.labelSmall?.copyWith(
                        color: AppColors.poultryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    if (reading.tempC != null)
                      _IoTChip(
                        '${reading.tempC!.toStringAsFixed(1)}Â°C',
                        reading.tempAlert,
                      ),
                    if (reading.humidityPct != null)
                      _IoTChip(
                        '${reading.humidityPct!.toStringAsFixed(0)}%RH',
                        reading.humidityAlert,
                      ),
                    if (reading.ammoniaPpm != null)
                      _IoTChip(
                        '${reading.ammoniaPpm!.toStringAsFixed(0)}ppm',
                        reading.ammoniaAlert,
                      ),
                  ],
                ),
              ),
            ) ??
            const SizedBox.shrink(),
        // â”€â”€ Environmental breach alert banner â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
        liveAsync.whenOrNull(
              data: (reading) {
                final breaches = [
                  if (reading.tempAlert) 'Temperature',
                  if (reading.humidityAlert) 'Humidity',
                  if (reading.ammoniaAlert) 'Ammonia >20 ppm',
                ];
                if (breaches.isEmpty) return null;
                return Container(
                  color: AppColors.error.withAlpha(26),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: 6,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.crisis_alert,
                        color: AppColors.error,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          'âš  Breach: ${breaches.join(' Â· ')}',
                          style: const TextStyle(
                            color: AppColors.error,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ) ??
            const SizedBox.shrink(),
        // â”€â”€ Quick action bar â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
        _TabActionBar(
          actions: [
            _TabAction(
              icon: Icons.edit_note_outlined,
              label: 'Manual Entry',
              onTap: () => _showManualReadingDialog(context),
            ),
            _TabAction(
              icon: Icons.notifications_outlined,
              label: 'Alert Settings',
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Environmental alert configuration coming soon.',
                  ),
                  behavior: SnackBarBehavior.floating,
                ),
              ),
            ),
          ],
        ),
        // â”€â”€ Sensor readings â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
        Expanded(
          child: envAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
            data: (readings) {
              if (readings.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.sensors_off_outlined,
                          size: 56,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Text('No sensor data available', style: tt.titleMedium),
                        const SizedBox(height: AppSpacing.xs),
                        Text(
                          'IoT environment readings will appear here\nwhen sensors are connected.',
                          style: tt.bodySmall,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        OutlinedButton.icon(
                          onPressed: () => _showManualReadingDialog(context),
                          icon: const Icon(Icons.edit_note_outlined, size: 18),
                          label: const Text('Add Manual Reading'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.poultryColor,
                            side: const BorderSide(
                              color: AppColors.poultryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              // Group by zone
              final zones = readings.map((r) => r.sensorZone).toSet().toList()
                ..sort();
              final latest = <String, EnvironmentReading>{};
              for (final z in zones) {
                final zoneReadings = readings.where((r) => r.sensorZone == z);
                if (zoneReadings.isNotEmpty) {
                  latest[z] = zoneReadings.first;
                }
              }

              return ListView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.pagePaddingHorizontal,
                  vertical: AppSpacing.pagePaddingVertical,
                ),
                children: [
                  Text('Latest Readings by Zone', style: tt.titleSmall),
                  const SizedBox(height: AppSpacing.sm),
                  ...latest.entries.map((entry) {
                    final zone = entry.key;
                    final r = entry.value;
                    return Card(
                      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.sensors, size: 16),
                                const SizedBox(width: 6),
                                Text(
                                  'Zone: ${zone.toUpperCase()}',
                                  style: tt.labelMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Spacer(),
                                Text(
                                  r.timestamp.length > 10
                                      ? r.timestamp.substring(0, 10)
                                      : r.timestamp,
                                  style: tt.labelSmall,
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            _EnvRow(
                              label: 'Temperature',
                              value: r.tempC != null
                                  ? '${r.tempC!.toStringAsFixed(1)}Â°C'
                                  : 'â€”',
                              alert: r.tempAlert,
                              alertLabel: r.tempAlert
                                  ? 'âš  Out of range'
                                  : null,
                            ),
                            _EnvRow(
                              label: 'Humidity',
                              value: r.humidityPct != null
                                  ? '${r.humidityPct!.toStringAsFixed(0)}%'
                                  : 'â€”',
                              alert: r.humidityAlert,
                              alertLabel: r.humidityAlert
                                  ? 'âš  High/low'
                                  : null,
                            ),
                            _EnvRow(
                              label: 'Ammonia',
                              value: r.ammoniaPpm != null
                                  ? '${r.ammoniaPpm!.toStringAsFixed(1)} ppm'
                                  : 'â€”',
                              alert: r.ammoniaAlert,
                              alertLabel: r.ammoniaAlert ? 'âš  >20 ppm' : null,
                            ),
                            if (r.co2Ppm != null)
                              _EnvRow(
                                label: 'COâ‚‚',
                                value: '${r.co2Ppm!.toStringAsFixed(0)} ppm',
                              ),
                          ],
                        ),
                      ),
                    );
                  }),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class _EnvRow extends StatelessWidget {
  const _EnvRow({
    required this.label,
    required this.value,
    this.alert = false,
    this.alertLabel,
  });

  final String label;
  final String value;
  final bool alert;
  final String? alertLabel;

  @override
  Widget build(BuildContext context) {
    final valueColor = alert ? AppColors.error : null;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13)),
          Row(
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: valueColor,
                ),
              ),
              if (alertLabel != null) ...[
                const SizedBox(width: 4),
                Text(
                  alertLabel!,
                  style: TextStyle(fontSize: 10, color: AppColors.error),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}

// â”€â”€ IoT Chip â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _IoTChip extends StatelessWidget {
  const _IoTChip(this.label, this.alert);

  final String label;
  final bool alert;

  @override
  Widget build(BuildContext context) {
    final color = alert ? AppColors.error : AppColors.poultryColor;
    return Container(
      margin: const EdgeInsets.only(left: AppSpacing.xs),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: color.withAlpha(31),
        borderRadius: BorderRadius.circular(AppSpacing.sm),
        border: Border.all(color: color.withAlpha(102)),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }
}

// â”€â”€ Flock Action Menu â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

// â”€â”€ Reusable horizontal tab action bar â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _TabAction {
  const _TabAction({required this.icon, required this.label, this.onTap});

  final IconData icon;
  final String label;
  final VoidCallback? onTap;
}

class _TabActionBar extends StatelessWidget {
  const _TabActionBar({required this.actions});

  final List<_TabAction> actions;

  @override
  Widget build(BuildContext context) {
    final items = <Widget>[];
    for (var i = 0; i < actions.length; i++) {
      final a = actions[i];
      items.add(
        Expanded(
          child: TextButton.icon(
            onPressed: a.onTap,
            icon: Icon(a.icon, size: 16),
            label: Text(a.label, style: const TextStyle(fontSize: 12)),
            style: TextButton.styleFrom(
              foregroundColor: a.onTap != null
                  ? AppColors.poultryColor
                  : Colors.grey,
              padding: const EdgeInsets.symmetric(vertical: 10),
            ),
          ),
        ),
      );
      if (i < actions.length - 1) {
        items.add(
          const VerticalDivider(
            width: 1,
            thickness: 0.5,
            indent: 10,
            endIndent: 10,
          ),
        );
      }
    }
    return Container(
      height: 48,
      decoration: BoxDecoration(
        color: AppColors.poultryColorContainer,
        border: Border(
          bottom: BorderSide(color: Colors.orange.shade200, width: 0.5),
        ),
      ),
      child: Row(children: items),
    );
  }
}

// â”€â”€ Export button â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _ExportButton extends ConsumerWidget {
  const _ExportButton({required this.flockId});

  final String flockId;

  void _exportCsv(BuildContext context, WidgetRef ref) {
    final flock = ref.read(flockDetailProvider(flockId)).value;
    final records = ref.read(flockDailyRecordsProvider(flockId)).value ?? [];

    if (flock == null) return;

    // Build CSV rows
    final rows = <List<dynamic>>[
      // Header
      [
        'Date',
        'Day of Age',
        'Mortality Count',
        'Culls',
        'Feed Consumed (kg)',
        'Water Consumed (L)',
        'Avg House Temp (Â°C)',
        'Avg Body Weight (g)',
        'Notes',
      ],
      // Data rows
      for (final r in records)
        [
          r.date,
          r.dayOfAge ?? '',
          r.mortalityCount ?? '',
          r.culls ?? '',
          r.feedConsumedKg ?? '',
          r.waterConsumedLitres ?? '',
          r.avgHouseTempC ?? '',
          r.avgBodyWeightG ?? '',
          r.notes ?? '',
        ],
    ];

    final csvString = CsvEncoder().convert(rows);
    final fileName =
        '${flock.batchName.replaceAll(' ', '_')}_daily_records.csv';

    if (kIsWeb) {
      final encoded = base64Encode(utf8.encode(csvString));
      final uri = 'data:text/csv;base64,$encoded';
      triggerWebDownload(uri, fileName);
      // ignore: unused_local_variable
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Exported ${records.length} records to $fileName'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: const Icon(Icons.download_outlined),
      tooltip: 'Export Daily Records (CSV)',
      onPressed: () => _exportCsv(context, ref),
    );
  }
}

// â”€â”€ Flock action menu (3-dots) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _FlockActionMenu extends ConsumerWidget {
  const _FlockActionMenu({required this.flockId, required this.flock});

  final String flockId;
  final PoultryFlock flock;

  Future<void> _confirmStatusChange(
    BuildContext context,
    WidgetRef ref,
    String label,
    String statusKey, {
    bool requireDate = false,
  }) async {
    DateTime? effectiveDate;

    if (requireDate) {
      final picked = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime.now().subtract(const Duration(days: 365)),
        lastDate: DateTime.now().add(const Duration(days: 30)),
        helpText: 'Select $label date',
      );
      if (picked == null) return; // user cancelled
      effectiveDate = picked;
    }

    if (!context.mounted) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Mark as $label?'),
        content: Text(
          effectiveDate != null
              ? 'Mark "${flock.batchName}" as $label on '
                    '${effectiveDate.year}-${effectiveDate.month.toString().padLeft(2, '0')}-${effectiveDate.day.toString().padLeft(2, '0')}?'
              : 'This will update the status of "${flock.batchName}" to $label. '
                    'You can change it again from this menu.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.poultryColor,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('Mark $label'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      ref
          .read(flockStatusOverrideProvider.notifier)
          .setStatus(flockId, statusKey);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Flock marked as $label'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert),
      tooltip: 'Flock actions',
      itemBuilder: (_) => [
        const PopupMenuItem<String>(
          value: 'editFlock',
          child: ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.edit_outlined),
            title: Text('Edit Flock Details'),
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem<String>(
          value: 'addRecord',
          child: ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.add_chart_outlined),
            title: Text('Add Daily Record'),
          ),
        ),
        const PopupMenuItem<String>(
          value: 'feedPhases',
          child: ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.restaurant_menu_outlined),
            title: Text('Ration Schedule'),
          ),
        ),
        const PopupMenuItem<String>(
          value: 'invoice',
          child: ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.receipt_long_outlined),
            title: Text('Generate Invoice'),
          ),
        ),
        if (flock.isActive) ...[
          const PopupMenuDivider(),
          const PopupMenuItem<String>(
            value: 'harvested',
            child: ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.done_all, color: Colors.green),
              title: Text('Mark as Harvested'),
            ),
          ),
          const PopupMenuItem<String>(
            value: 'depleted',
            child: ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.remove_circle_outline, color: Colors.orange),
              title: Text('Mark as Depleted'),
            ),
          ),
          const PopupMenuItem<String>(
            value: 'sold',
            child: ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.sell_outlined, color: Colors.blue),
              title: Text('Mark as Sold'),
            ),
          ),
        ],
      ],
      onSelected: (v) {
        switch (v) {
          case 'editFlock':
            context.push('/livestock/poultry/$flockId/edit');
          case 'addRecord':
            context.push(AppRoutes.addPoultryDailyRecord(flockId));
          case 'feedPhases':
            context.push(AppRoutes.feedPhases(flockId));
          case 'invoice':
            context.push(AppRoutes.invoiceForFlock(flockId));
          case 'harvested':
            context.push(AppRoutes.harvestRecord(flockId));
          case 'depleted':
            _confirmStatusChange(
              context,
              ref,
              'Depleted',
              'depleted',
              requireDate: true,
            );
          case 'sold':
            _confirmStatusChange(
              context,
              ref,
              'Sold',
              'sold',
              requireDate: true,
            );
        }
      },
    );
  }
}

// â”€â”€ Weight Benchmark Chart (Ross 308 overlay) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

/// Reference body-weight standards (grams) by day of age for Ross 308 broilers.
const Map<int, double> _ross308Benchmark = {
  0: 42,
  7: 180,
  14: 440,
  21: 830,
  28: 1290,
  35: 1780,
  42: 2240,
};

class _WeightBenchmarkChart extends StatelessWidget {
  const _WeightBenchmarkChart({required this.actualSpots, this.strain = ''});

  final List<FlSpot> actualSpots;
  final String strain;

  /// Build benchmark FlSpots limited to the range of actual data.
  List<FlSpot> _benchmarkSpots() {
    final maxDay = actualSpots.map((s) => s.x).reduce((a, b) => a > b ? a : b);
    return _ross308Benchmark.entries
        .where((e) => e.key.toDouble() <= maxDay + 1)
        .map((e) => FlSpot(e.key.toDouble(), e.value))
        .toList()
      ..sort((a, b) => a.x.compareTo(b.x));
  }

  bool get _isBelowBenchmark {
    final sorted = List<FlSpot>.from(actualSpots)
      ..sort((a, b) => b.x.compareTo(a.x));
    if (sorted.isEmpty) return false;
    final latest = sorted.first;
    // Find the benchmark at the nearest reference day â‰¤ latest day
    final refDay = _ross308Benchmark.keys
        .where((d) => d <= latest.x)
        .fold<int>(0, (prev, d) => d > prev ? d : prev);
    final refWeight = _ross308Benchmark[refDay];
    if (refWeight == null) return false;
    return latest.y < refWeight * 0.9;
  }

  @override
  Widget build(BuildContext context) {
    final benchSpots = _benchmarkSpots();
    final belowBenchmark = _isBelowBenchmark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Legend row
        Row(
          children: [
            _LegendDot(color: AppColors.poultryColor, label: 'Actual'),
            const SizedBox(width: AppSpacing.md),
            _LegendDot(
              color: Colors.grey.shade400,
              label: 'Ross 308 Std',
              dashed: true,
            ),
            if (belowBenchmark) ...[
              const SizedBox(width: AppSpacing.sm),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: AppColors.warning.withAlpha(38),
                  borderRadius: BorderRadius.circular(AppSpacing.xs),
                  border: Border.all(color: AppColors.warning.withAlpha(128)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.trending_down,
                      size: 12,
                      color: AppColors.warning,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '>10% below target',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppColors.warning,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        SizedBox(
          height: 160,
          child: LineChart(
            LineChartData(
              lineTouchData: LineTouchData(
                touchTooltipData: LineTouchTooltipData(
                  getTooltipItems: (spots) => spots.map((s) {
                    final label = s.barIndex == 0 ? 'Actual' : 'Benchmark';
                    return LineTooltipItem(
                      '$label\n${s.y.toStringAsFixed(0)} g',
                      Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  }).toList(),
                ),
              ),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 500,
                getDrawingHorizontalLine: (v) =>
                    FlLine(color: Colors.grey.withAlpha(38), strokeWidth: 1),
              ),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  axisNameWidget: const Text(
                    'g',
                    style: TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 44,
                    getTitlesWidget: (v, _) => Text(
                      v >= 1000
                          ? '${(v / 1000).toStringAsFixed(1)}k'
                          : v.toInt().toString(),
                      style: const TextStyle(fontSize: 9, color: Colors.grey),
                    ),
                  ),
                ),
                bottomTitles: AxisTitles(
                  axisNameWidget: const Text(
                    'Day',
                    style: TextStyle(fontSize: 10, color: Colors.grey),
                  ),
                  sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 22,
                    getTitlesWidget: (v, _) => Text(
                      'D${v.toInt()}',
                      style: const TextStyle(fontSize: 9, color: Colors.grey),
                    ),
                  ),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              lineBarsData: [
                // Actual weight line
                LineChartBarData(
                  spots: actualSpots,
                  isCurved: true,
                  color: AppColors.poultryColor,
                  barWidth: 2.5,
                  dotData: FlDotData(
                    show: true,
                    getDotPainter: (spot, percent, barData, index) =>
                        FlDotCirclePainter(
                          radius: 3,
                          color: AppColors.poultryColor,
                          strokeWidth: 1,
                          strokeColor: Colors.white,
                        ),
                  ),
                  belowBarData: BarAreaData(
                    show: true,
                    color: AppColors.poultryColor.withAlpha(20),
                  ),
                ),
                // Ross 308 benchmark line (dashed)
                LineChartBarData(
                  spots: benchSpots,
                  isCurved: false,
                  color: Colors.grey.shade400,
                  barWidth: 1.5,
                  dashArray: [5, 4],
                  dotData: const FlDotData(show: false),
                  belowBarData: BarAreaData(show: false),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  const _LegendDot({
    required this.color,
    required this.label,
    this.dashed = false,
  });
  final Color color;
  final String label;
  final bool dashed;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 20,
          height: 3,
          decoration: BoxDecoration(
            color: dashed ? Colors.transparent : color,
            border: dashed
                ? Border(
                    bottom: BorderSide(
                      color: color,
                      width: 2,
                      style: BorderStyle.none,
                    ),
                  )
                : null,
          ),
          child: dashed
              ? CustomPaint(painter: _DashPainter(color: color))
              : null,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.labelSmall?.copyWith(color: Colors.grey.shade600),
        ),
      ],
    );
  }
}

class _DashPainter extends CustomPainter {
  const _DashPainter({required this.color});
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2;
    double x = 0;
    while (x < size.width) {
      canvas.drawLine(
        Offset(x, size.height / 2),
        Offset((x + 4).clamp(0, size.width), size.height / 2),
        paint,
      );
      x += 8;
    }
  }

  @override
  bool shouldRepaint(_DashPainter old) => old.color != color;
}

// â”€â”€ Mini Line Chart â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _MiniLineChart extends StatelessWidget {
  const _MiniLineChart({
    required this.spots,
    required this.lineColor,
    this.yLabel = '',
  });

  final List<FlSpot> spots;
  final Color lineColor;
  final String yLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: 150,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) => FlLine(
              color: theme.colorScheme.outlineVariant.withAlpha(102),
              strokeWidth: 1,
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (v, _) => Text(
                  '${v.toInt()}$yLabel',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 20,
                getTitlesWidget: (v, _) => Text(
                  'D${v.toInt()}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: lineColor,
              barWidth: 2.5,
              dotData: const FlDotData(show: false),
              belowBarData: BarAreaData(
                show: true,
                color: lineColor.withAlpha(20),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

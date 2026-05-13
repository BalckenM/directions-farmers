import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/farm_scaffold.dart';
import '../../../shared/widgets/farm_app_bar.dart';
import '../models/flock.dart';
import '../models/poultry_flock.dart';
import '../providers/poultry_providers.dart';

class PoultryReportsScreen extends ConsumerStatefulWidget {
  const PoultryReportsScreen({super.key, required this.flockId});

  final String flockId;

  @override
  ConsumerState<PoultryReportsScreen> createState() =>
      _PoultryReportsScreenState();
}

class _PoultryReportsScreenState extends ConsumerState<PoultryReportsScreen> {
  String? _selectedFlockId;

  String get _effectiveFlockId => _selectedFlockId ?? widget.flockId;

  @override
  Widget build(BuildContext context) {
    if (_effectiveFlockId.isEmpty) {
      return _buildFlockPicker(context);
    }
    return _buildReport(context);
  }

  Widget _buildFlockPicker(BuildContext context) {
    final flocksAsync = ref.watch(flocksProvider);
    final tt = Theme.of(context).textTheme;
    return FarmScaffold(
      drawer: null,
      appBar: const FarmAppBar(title: 'Batch Report'),
      body: flocksAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (flocks) {
          if (flocks.isEmpty) {
            return const Center(child: Text('No flocks found.'));
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                child: Text('Select a flock',
                    style: tt.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: flocks.length,
                  itemBuilder: (_, i) {
                    final f = flocks[i];
                    return ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: AppColors.poultryColorContainer,
                        child: Icon(Icons.description_outlined,
                            color: AppColors.poultryColor),
                      ),
                      title: Text(f.batchName),
                      subtitle: Text(
                        '${f.productionType.toUpperCase()} · ${f.currentCount} birds · Day ${f.dayOfAge}',
                        style: tt.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.outline),
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () =>
                          setState(() => _selectedFlockId = f.id),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildReport(BuildContext context) {
    final flockAsync = ref.watch(flockDetailProvider(_effectiveFlockId));
    final dailyAsync = ref.watch(flockDailyRecordsProvider(_effectiveFlockId));
    final vaccAsync = ref.watch(flockVaccinationProvider(_effectiveFlockId));
    final diseaseAsync =
        ref.watch(flockDiseaseEventsProvider(_effectiveFlockId));
    final medAsync = ref.watch(flockMedicationLogsProvider(_effectiveFlockId));
    final harvestAsync =
        ref.watch(flockHarvestRecordsProvider(_effectiveFlockId));

    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return FarmScaffold(
      drawer: null,
      appBar: FarmAppBar(
        title: 'Batch Report',
        leading: widget.flockId.isEmpty
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() => _selectedFlockId = null),
              )
            : null,
      ),
      body: flockAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (flock) {
          if (flock == null) {
            return const Center(child: Text('Flock not found.'));
          }
          return ListView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.pagePaddingHorizontal,
              vertical: AppSpacing.pagePaddingVertical,
            ),
            children: [
              _buildFlockHeader(context, flock),
              const SizedBox(height: AppSpacing.md),
              _buildKpiSection(context, flock),
              const SizedBox(height: AppSpacing.md),
              _buildDailySection(context, tt, cs, dailyAsync),
              const SizedBox(height: AppSpacing.md),
              _buildVaccSection(context, tt, cs, vaccAsync),
              const SizedBox(height: AppSpacing.md),
              _buildDiseaseSection(context, tt, cs, diseaseAsync),
              const SizedBox(height: AppSpacing.md),
              _buildMedSection(context, tt, cs, medAsync),
              harvestAsync.whenData((h) => h.isNotEmpty).value == true
                  ? Column(children: [
                      const SizedBox(height: AppSpacing.md),
                      _buildHarvestSection(context, tt, cs, harvestAsync),
                    ])
                  : const SizedBox.shrink(),
              const SizedBox(height: AppSpacing.xl),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFlockHeader(BuildContext context, PoultryFlock f) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.poultryColor.withValues(alpha: 0.12),
              child: const Icon(Icons.description_outlined,
                  color: AppColors.poultryColor, size: 22),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(f.batchName,
                      style: tt.titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  Text(
                    '${f.productionType.toUpperCase()} · ${f.species.toUpperCase()} · ${f.houseId}',
                    style: tt.bodySmall?.copyWith(color: cs.outline),
                  ),
                  Text(
                    'Day ${f.dayOfAge} · Placed ${f.placementDate}',
                    style: tt.bodySmall?.copyWith(color: cs.outline),
                  ),
                ],
              ),
            ),
            _StatusChip(status: f.status),
          ],
        ),
      ),
    );
  }

  Widget _buildKpiSection(BuildContext context, PoultryFlock f) {
    final items = [
      _KpiData(
          label: 'Mortality',
          value: '${f.mortalityPct.toStringAsFixed(1)}%',
          icon: Icons.trending_down_rounded,
          color: f.mortalityPct > 5 ? Colors.red : Colors.green),
      _KpiData(
          label: 'Livability',
          value: '${f.livabilityPct?.toStringAsFixed(1) ?? '—'}%',
          icon: Icons.favorite_border_rounded,
          color: AppColors.poultryColor),
      _KpiData(
          label: 'FCR',
          value: f.fcrToDate?.toStringAsFixed(2) ?? '—',
          icon: Icons.show_chart_rounded,
          color: AppColors.poultryColor),
      _KpiData(
          label: 'Avg Weight',
          value: f.currentAvgWeightG != null
              ? '${(f.currentAvgWeightG! / 1000).toStringAsFixed(2)} kg'
              : '—',
          icon: Icons.monitor_weight_outlined,
          color: AppColors.poultryColor),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: 'Performance KPIs'),
        const SizedBox(height: AppSpacing.sm),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          mainAxisSpacing: AppSpacing.sm,
          crossAxisSpacing: AppSpacing.sm,
          childAspectRatio: 2.4,
          children: items.map((kpi) => _KpiCard(kpi: kpi)).toList(),
        ),
      ],
    );
  }

  Widget _buildDailySection(
    BuildContext context,
    TextTheme tt,
    ColorScheme cs,
    AsyncValue<List<DailyRecord>> async,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: 'Recent Daily Records'),
        const SizedBox(height: AppSpacing.sm),
        async.when(
          loading: () => const LinearProgressIndicator(),
          error: (e, _) => Text('Error: $e'),
          data: (records) {
            if (records.isEmpty) {
              return _EmptyNote(message: 'No daily records yet.');
            }
            final recent = records.take(7).toList();
            return Card(
              child: Column(
                children: recent.asMap().entries.map((e) {
                  final r = e.value;
                  final isLast = e.key == recent.length - 1;
                  return Column(
                    children: [
                      ListTile(
                        dense: true,
                        title: Text(r.date, style: tt.bodySmall),
                        subtitle: Text(
                          [
                            if (r.mortalityCount != null)
                              '${r.mortalityCount} deaths',
                            if (r.feedConsumedKg != null)
                              '${r.feedConsumedKg!.toStringAsFixed(1)} kg feed',
                            if (r.avgBodyWeightG != null)
                              '${r.avgBodyWeightG} g avg wt',
                          ].join(' · '),
                          style: tt.bodySmall?.copyWith(color: cs.outline),
                        ),
                      ),
                      if (!isLast) const Divider(height: 1),
                    ],
                  );
                }).toList(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildVaccSection(
    BuildContext context,
    TextTheme tt,
    ColorScheme cs,
    AsyncValue<VaccinationSchedule?> async,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: 'Vaccination Status'),
        const SizedBox(height: AppSpacing.sm),
        async.when(
          loading: () => const LinearProgressIndicator(),
          error: (e, _) => Text('Error: $e'),
          data: (schedule) {
            if (schedule == null) {
              return _EmptyNote(message: 'No vaccination schedule.');
            }
            return Card(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '${schedule.completedCount}/${schedule.schedule.length} vaccines given',
                          style: tt.bodyMedium
                              ?.copyWith(fontWeight: FontWeight.w600),
                        ),
                        const Spacer(),
                        if (schedule.pendingCount > 0)
                          _SmallChip(
                              label:
                                  '${schedule.pendingCount} pending',
                              color: Colors.orange),
                        if (schedule.overdueCount > 0) ...[
                          const SizedBox(width: 4),
                          _SmallChip(
                              label:
                                  '${schedule.overdueCount} overdue',
                              color: Colors.red),
                        ],
                      ],
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    ...schedule.schedule.map((v) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            children: [
                              Icon(
                                v.isCompleted
                                    ? Icons.check_circle_outline
                                    : Icons.radio_button_unchecked,
                                size: 16,
                                color: v.isCompleted
                                    ? Colors.green
                                    : Colors.orange,
                              ),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  'Day ${v.targetDay}: ${v.vaccine}',
                                  style: tt.bodySmall,
                                ),
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildDiseaseSection(
    BuildContext context,
    TextTheme tt,
    ColorScheme cs,
    AsyncValue<List<DiseaseEvent>> async,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: 'Disease Events'),
        const SizedBox(height: AppSpacing.sm),
        async.when(
          loading: () => const LinearProgressIndicator(),
          error: (e, _) => Text('Error: $e'),
          data: (events) {
            if (events.isEmpty) {
              return _EmptyNote(message: 'No disease events recorded.');
            }
            return Card(
              child: Column(
                children: events.asMap().entries.map((e) {
                  final ev = e.value;
                  final isLast = e.key == events.length - 1;
                  final color = switch (ev.severity) {
                    'emergency' || 'high' => Colors.red,
                    'medium' => Colors.orange,
                    _ => Colors.green,
                  };
                  return Column(
                    children: [
                      ListTile(
                        dense: true,
                        leading: Icon(Icons.warning_amber_rounded,
                            color: color, size: 18),
                        title: Text(ev.disease, style: tt.bodySmall),
                        subtitle: Text(
                          '${ev.date} · ${ev.affectedCount} birds · ${ev.severity}',
                          style: tt.bodySmall?.copyWith(color: cs.outline),
                        ),
                      ),
                      if (!isLast) const Divider(height: 1),
                    ],
                  );
                }).toList(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildMedSection(
    BuildContext context,
    TextTheme tt,
    ColorScheme cs,
    AsyncValue<List<MedicationLog>> async,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: 'Medication Log'),
        const SizedBox(height: AppSpacing.sm),
        async.when(
          loading: () => const LinearProgressIndicator(),
          error: (e, _) => Text('Error: $e'),
          data: (logs) {
            if (logs.isEmpty) {
              return _EmptyNote(message: 'No medications recorded.');
            }
            return Card(
              child: Column(
                children: logs.asMap().entries.map((e) {
                  final m = e.value;
                  final isLast = e.key == logs.length - 1;
                  return Column(
                    children: [
                      ListTile(
                        dense: true,
                        title: Text(m.drugName, style: tt.bodySmall),
                        subtitle: Text(
                          '${m.date} · ${m.dosage} · ${m.route.replaceAll('_', ' ')} · W/D: ${m.withdrawalDays}d',
                          style: tt.bodySmall?.copyWith(color: cs.outline),
                        ),
                      ),
                      if (!isLast) const Divider(height: 1),
                    ],
                  );
                }).toList(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildHarvestSection(
    BuildContext context,
    TextTheme tt,
    ColorScheme cs,
    AsyncValue<List<HarvestRecord>> async,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: 'Harvest Summary'),
        const SizedBox(height: AppSpacing.sm),
        async.when(
          loading: () => const LinearProgressIndicator(),
          error: (e, _) => Text('Error: $e'),
          data: (records) {
            if (records.isEmpty) return const SizedBox.shrink();
            return Card(
              child: Column(
                children: records.asMap().entries.map((e) {
                  final h = e.value;
                  final isLast = e.key == records.length - 1;
                  return Column(
                    children: [
                      ListTile(
                        dense: true,
                        leading: const Icon(Icons.storefront_outlined,
                            color: AppColors.poultryColor, size: 18),
                        title: Text(
                          '${h.harvestDate} · ${h.birdsHarvested} birds · ${h.totalLiveWeightKg.toStringAsFixed(1)} kg',
                          style: tt.bodySmall,
                        ),
                        subtitle: h.pricePerKgZar != null
                            ? Text(
                                'R${h.pricePerKgZar!.toStringAsFixed(2)}/kg → R${h.totalRevenueZar.toStringAsFixed(0)} total',
                                style: tt.bodySmall
                                    ?.copyWith(color: Colors.green.shade700),
                              )
                            : null,
                      ),
                      if (!isLast) const Divider(height: 1),
                    ],
                  );
                }).toList(),
              ),
            );
          },
        ),
      ],
    );
  }
}

// ── Supporting widgets ────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) => Text(
        title,
        style: Theme.of(context)
            .textTheme
            .titleSmall
            ?.copyWith(fontWeight: FontWeight.bold),
      );
}

class _EmptyNote extends StatelessWidget {
  const _EmptyNote({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Text(
            message,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Theme.of(context).colorScheme.outline),
          ),
        ),
      );
}

class _KpiData {
  const _KpiData(
      {required this.label,
      required this.value,
      required this.icon,
      required this.color});
  final String label;
  final String value;
  final IconData icon;
  final Color color;
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({required this.kpi});
  final _KpiData kpi;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm, vertical: AppSpacing.sm),
        child: Row(
          children: [
            Icon(kpi.icon, color: kpi.color, size: 20),
            const SizedBox(width: 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(kpi.value,
                      style: tt.titleSmall
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  Text(kpi.label,
                      style: tt.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                          fontSize: 10)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});
  final String status;

  Color get _color => switch (status.toLowerCase()) {
        'active' => Colors.green,
        'harvested' || 'sold' => AppColors.poultryColor,
        'depleted' => Colors.grey,
        _ => Colors.blue,
      };

  @override
  Widget build(BuildContext context) {
    final color = _color;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
            fontSize: 10, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }
}

class _SmallChip extends StatelessWidget {
  const _SmallChip({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
              fontSize: 10, fontWeight: FontWeight.w600, color: color),
        ),
      );
}

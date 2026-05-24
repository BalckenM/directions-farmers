import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../shared/widgets/farm_app_bar.dart';
import '../../../shared/widgets/farm_scaffold.dart';
import '../../../shared/widgets/fmd_zone_indicator.dart';
import '../../../shared/widgets/loading_shimmer.dart';
import '../../../shared/widgets/withdrawal_countdown.dart';
import '../../livestock/models/animal.dart' show FmdZone;
import '../models/cattle_animal.dart';
import '../models/cattle_records.dart';
import '../providers/cattle_providers.dart';

class CattleDetailScreen extends ConsumerWidget {
  const CattleDetailScreen({super.key, required this.cattleId});
  final String cattleId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final animalAsync = ref.watch(cattleDetailProvider(cattleId));

    return animalAsync.when(
      loading: () => FarmScaffold(
        appBar: const FarmAppBar(title: 'Cattle Detail'),
        body: const LoadingShimmer(),
      ),
      error: (e, _) => FarmScaffold(
        appBar: const FarmAppBar(title: 'Error'),
        body: Center(child: Text('Error: $e')),
      ),
      data: (animal) {
        if (animal == null) {
          return FarmScaffold(
            appBar: const FarmAppBar(title: 'Not Found'),
            body: const Center(child: Text('Animal not found')),
          );
        }
        return _AnimalDetailView(animal: animal);
      },
    );
  }
}

class _AnimalDetailView extends StatefulWidget {
  const _AnimalDetailView({required this.animal});
  final CattleAnimal animal;

  @override
  State<_AnimalDetailView> createState() => _AnimalDetailViewState();
}

class _AnimalDetailViewState extends State<_AnimalDetailView>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 5, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final a = widget.animal;
    return FarmScaffold(
      appBar: FarmAppBar(
        title: a.displayName,
        subtitle: '${a.tagNumber} · ${a.breed}',
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit',
            onPressed: () => context.go(AppRoutes.editCattlePath(a.id)),
          ),
        ],
        bottom: TabBar(
          controller: _tabs,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Health'),
            Tab(text: 'Breeding'),
            Tab(text: 'Production'),
            Tab(text: 'Records'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _OverviewTab(animal: a),
          _HealthTab(animal: a),
          _BreedingTab(animal: a),
          _ProductionTab(animal: a),
          _RecordsTab(animal: a),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showQuickAdd(context, a),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Record'),
      ),
    );
  }

  void _showQuickAdd(BuildContext context, CattleAnimal a) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.monitor_weight_outlined),
              title: const Text('Add Weight'),
              onTap: () {
                Navigator.pop(context);
                context.go(AppRoutes.cattleWeightsPath(a.id));
              },
            ),
            if (a.productionType == 'dairy')
              ListTile(
                leading: const Icon(Icons.water_drop_outlined),
                title: const Text('Add Milk Record'),
                onTap: () {
                  Navigator.pop(context);
                  context.go(AppRoutes.cattleMilkPath(a.id));
                },
              ),
            if (a.isFemale)
              ListTile(
                leading: const Icon(Icons.child_care_rounded),
                title: const Text('Record Calving'),
                onTap: () {
                  Navigator.pop(context);
                  context.go(AppRoutes.cattleCalvingPath(a.id));
                },
              ),
            ListTile(
              leading: const Icon(Icons.medical_services_outlined),
              title: const Text('Add Medication'),
              onTap: () {
                Navigator.pop(context);
                context.go(AppRoutes.addCattleMedicationPath(a.id));
              },
            ),
          ],
        ),
      ),
    );
  }
}

// ── Overview Tab ──────────────────────────────────────────────────────────────

class _OverviewTab extends StatelessWidget {
  const _OverviewTab({required this.animal});
  final CattleAnimal animal;

  @override
  Widget build(BuildContext context) {
    final a = animal;
    final tt = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _InfoCard(title: 'Identity', children: [
          _InfoRow(label: 'Tag', value: a.tagNumber),
          _InfoRow(label: 'Name', value: a.name ?? '—'),
          _InfoRow(label: 'Breed', value: a.breed),
          _InfoRow(label: 'Sex', value: a.sex),
          _InfoRow(label: 'Production', value: a.productionType),
          _InfoRow(label: 'Date of Birth', value: a.dateOfBirth),
          _InfoRow(label: 'Age', value: '${a.ageMonths} months'),
          _InfoRow(label: 'Herd', value: a.herdId),
          if (a.registrationNumber != null)
            _InfoRow(label: 'Reg No.', value: a.registrationNumber!),
          if (a.niisEidNumber != null)
            _InfoRow(label: 'NIIS EID', value: a.niisEidNumber!),
        ]),
        const SizedBox(height: 12),
        _InfoCard(title: 'Condition', children: [
          if (a.currentWeightKg != null)
            _InfoRow(
                label: 'Current Weight',
                value: '${a.currentWeightKg!.toStringAsFixed(1)} kg'),
          if (a.targetWeightKg != null)
            _InfoRow(
                label: 'Target Weight',
                value: '${a.targetWeightKg!.toStringAsFixed(1)} kg'),
          if (a.bodyConditionScore != null)
            _InfoRow(label: 'BCS', value: '${a.bodyConditionScore} / 5'),
          if (a.lastDewormingDate != null)
            _InfoRow(label: 'Last Dewormed', value: a.lastDewormingDate!),
          if (a.lastDippingDate != null)
            _InfoRow(label: 'Last Dipped', value: a.lastDippingDate!),
        ]),
        if (a.isPregnant || a.isLactating) ...[
          const SizedBox(height: 12),
          _InfoCard(title: 'Reproductive Status', children: [
            _InfoRow(label: 'In Calf', value: a.isPregnant ? 'Yes' : 'No'),
            if (a.isPregnant && a.expectedCalvingDate != null)
              _InfoRow(
                  label: 'Expected Calving', value: a.expectedCalvingDate!),
            _InfoRow(
                label: 'Lactating', value: a.isLactating ? 'Yes' : 'No'),
            if (a.isLactating && a.currentMilkLitrePd != null)
              _InfoRow(
                  label: 'Milk Yield',
                  value:
                      '${a.currentMilkLitrePd!.toStringAsFixed(1)} L/day'),
            if (a.lastCalvingDate != null)
              _InfoRow(
                  label: 'Last Calving', value: a.lastCalvingDate!),
            if (a.totalCalvesRaised != null)
              _InfoRow(
                  label: 'Calves Raised', value: '${a.totalCalvesRaised}'),
            if (a.lactationNumber != null)
              _InfoRow(
                  label: 'Lactation No.',
                  value: '${a.lactationNumber}'),
            if (a.dryOffDate != null)
              _InfoRow(label: 'Dry-off Date', value: a.dryOffDate!),
          ]),
        ],
        if (a.notes != null && a.notes!.isNotEmpty) ...[
          const SizedBox(height: 12),
          _InfoCard(title: 'Notes', children: [
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(a.notes!, style: tt.bodyMedium),
            ),
          ]),
        ],
        // ── Low BCS warning ──────────────────────────────────────────────────
        if (a.isAlive &&
            a.bodyConditionScore != null &&
            a.bodyConditionScore! < 2.0) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withAlpha(30),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.orange.withAlpha(100)),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded,
                    color: Colors.orange, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Low BCS Alert: BCS ${a.bodyConditionScore} is below 2.0. Review nutrition immediately.',
                    style: const TextStyle(
                        fontSize: 13, color: Colors.orange),
                  ),
                ),
              ],
            ),
          ),
        ],
        // ── SA Compliance ────────────────────────────────────────────────────
        if (a.brandNumber != null ||
            a.brandPosition != null ||
            a.earmarkDesc != null ||
            a.brucellaTested ||
            a.brucellaTestDate != null ||
            a.fmdZone != null ||
            a.niisEidNumber != null) ...[
          const SizedBox(height: 12),
          _InfoCard(title: 'SA Compliance', children: [
            if (a.brandNumber != null)
              _InfoRow(label: 'Brand No.', value: a.brandNumber!),
            if (a.brandPosition != null)
              _InfoRow(label: 'Brand Position', value: a.brandPosition!),
            if (a.earmarkDesc != null)
              _InfoRow(label: 'Earmark', value: a.earmarkDesc!),
            _InfoRow(
                label: 'Brucella Tested',
                value: a.brucellaTested ? 'Yes' : 'No'),
            if (a.brucellaTestDate != null)
              _InfoRow(
                  label: 'Brucella Test Date', value: a.brucellaTestDate!),
            if (a.fmdZone != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(children: [
                  SizedBox(
                    width: 140,
                    child: Text('FMD Zone',
                        style:
                            Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                                )),
                  ),
                  FmdZoneIndicator(zone: _parseFmdZone(a.fmdZone!)),
                ]),
              ),
            ],
            if (a.niisEidNumber != null)
              _InfoRow(label: 'NIIS EID', value: a.niisEidNumber!),
          ]),
        ],
      ],
    );
  }
}

// ── Health Tab ────────────────────────────────────────────────────────────────

class _HealthTab extends ConsumerWidget {
  const _HealthTab({required this.animal});
  final CattleAnimal animal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final healthAsync = ref.watch(cattleHealthEventsProvider(animal.id));
    final vacAsync = ref.watch(cattleVaccinationsProvider(animal.id));
    final medAsync = ref.watch(cattleMedicationLogsProvider(animal.id));

    final healthEvents = healthAsync.asData?.value ?? [];
    final vaccinations = vacAsync.asData?.value ?? [];
    final medications = medAsync.asData?.value ?? [];

    // Active withdrawal: medications with non-null withdrawal that are still active
    final activeMeds = medications.where((m) {
      final meat = m.withdrawalExpiryDateMeat;
      final milk = m.withdrawalExpiryDateMilk;
      bool meatActive = false;
      bool milkActive = false;
      if (meat != null) {
        try {
          meatActive = DateTime.parse(meat).isAfter(DateTime.now());
        } catch (_) {}
      }
      if (milk != null) {
        try {
          milkActive = DateTime.parse(milk).isAfter(DateTime.now());
        } catch (_) {}
      }
      return meatActive || milkActive;
    }).toList();

    // Upcoming/overdue vaccinations (not yet given)
    final pendingVacs = vaccinations.where((v) => !v.isGiven).toList();
    final recentHealth = healthEvents.take(5).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Notifiable disease prompt
        _NotifiableDiseaseBanner(events: healthEvents),

        // Withdrawal countdowns
        if (activeMeds.isNotEmpty) ...[
          Text('Active Withdrawals',
              style: Theme.of(context).textTheme.titleSmall),
          const SizedBox(height: 8),
          ...activeMeds.expand((m) {
            final meatExpiry = m.withdrawalExpiryDateMeat;
            final milkExpiry = m.withdrawalExpiryDateMilk;
            return [
              if (meatExpiry != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: WithdrawalCountdown(
                    productName: '${m.medicationName} — Meat',
                    withdrawalEndDate: _isoToDisplay(meatExpiry),
                    daysRemaining: _daysUntil(meatExpiry),
                  ),
                ),
              if (milkExpiry != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: WithdrawalCountdown(
                    productName: '${m.medicationName} — Milk',
                    withdrawalEndDate: _isoToDisplay(milkExpiry),
                    daysRemaining: _daysUntil(milkExpiry),
                  ),
                ),
            ];
          }),
          const SizedBox(height: 16),
        ],

        // Recent health events
        Text('Recent Health Events',
            style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        if (recentHealth.isEmpty)
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text('No health events recorded.',
                style: TextStyle(color: Colors.grey)),
          )
        else
          ...recentHealth.map((e) => Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                child: ListTile(
                  dense: true,
                  leading: CircleAvatar(
                    backgroundColor: _severityColor(e.severity).withAlpha(40),
                    child: Icon(
                      Icons.monitor_heart_outlined,
                      color: _severityColor(e.severity),
                      size: 18,
                    ),
                  ),
                  title: Text(e.diagnosis),
                  subtitle: Text('${e.date} · ${e.eventType}'),
                  trailing: Chip(
                    label: Text(e.severity,
                        style: const TextStyle(
                            fontSize: 10, color: Colors.white)),
                    backgroundColor: _severityColor(e.severity),
                    visualDensity: VisualDensity.compact,
                    padding: EdgeInsets.zero,
                  ),
                ),
              )),
        const SizedBox(height: 16),

        // Pending vaccinations
        Text('Pending Vaccinations',
            style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        if (pendingVacs.isEmpty)
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text('All vaccinations up to date.',
                style: TextStyle(color: Colors.grey)),
          )
        else
          ...pendingVacs.map((v) => Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                child: ListTile(
                  dense: true,
                  leading: Icon(
                    Icons.vaccines_outlined,
                    color: v.isOverdue
                        ? Theme.of(context).colorScheme.error
                        : Colors.orange,
                    size: 20,
                  ),
                  title: Text(v.vaccineName),
                  subtitle: Text('Due: ${v.dueDate}'),
                  trailing: v.isOverdue
                      ? Chip(
                          label: const Text('OVERDUE',
                              style: TextStyle(
                                  fontSize: 10, color: Colors.white)),
                          backgroundColor:
                              Theme.of(context).colorScheme.error,
                          visualDensity: VisualDensity.compact,
                          padding: EdgeInsets.zero,
                        )
                      : null,
                ),
              )),
        const Divider(height: 24),

        // Navigation buttons
        OutlinedButton.icon(
          onPressed: () =>
              context.go(AppRoutes.cattleHealthPath(animal.id)),
          icon: const Icon(Icons.favorite_border_rounded),
          label: const Text('All Health Events'),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () => context.go(AppRoutes.cattleVaccinations),
          icon: const Icon(Icons.vaccines_outlined),
          label: const Text('All Vaccinations'),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () =>
              context.go(AppRoutes.addCattleMedicationPath(animal.id)),
          icon: const Icon(Icons.medical_services_outlined),
          label: const Text('Medication Log'),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () => context.go(AppRoutes.cattleBodyCondition),
          icon: const Icon(Icons.assignment_outlined),
          label: const Text('Body Condition (BCS)'),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () => context.go(AppRoutes.cattleDipping),
          icon: const Icon(Icons.water_outlined),
          label: const Text('Dipping Records'),
        ),
      ],
    );
  }

  static String _isoToDisplay(String iso) {
    try {
      final d = DateTime.parse(iso);
      return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
    } catch (_) {
      return iso;
    }
  }

  static int _daysUntil(String iso) {
    try {
      return DateTime.parse(iso).difference(DateTime.now()).inDays.clamp(0, 9999);
    } catch (_) {
      return 0;
    }
  }

  Color _severityColor(String severity) {
    switch (severity.toLowerCase()) {
      case 'critical':
        return Colors.red.shade700;
      case 'high':
        return Colors.orange.shade700;
      case 'medium':
        return Colors.amber.shade700;
      default:
        return Colors.blue.shade600;
    }
  }
}

// ── Breeding Tab ──────────────────────────────────────────────────────────────

class _BreedingTab extends ConsumerWidget {
  const _BreedingTab({required this.animal});
  final CattleAnimal animal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (animal.isFemale) ...[
          OutlinedButton.icon(
            onPressed: () =>
                context.go(AppRoutes.cattleBreedingPath(animal.id)),
            icon: const Icon(Icons.favorite_outlined),
            label: const Text('Mating Records'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () =>
                context.go(AppRoutes.cattleCalvingPath(animal.id)),
            icon: const Icon(Icons.child_care_rounded),
            label: const Text('Calving Events'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => context.go(AppRoutes.cattlePregnancyCheck),
            icon: const Icon(Icons.pregnant_woman_rounded),
            label: const Text('Pregnancy Checks'),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () =>
                context.go(AppRoutes.addCalfPath(animal.id)),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Register New Calf'),
          ),
        ] else ...[
          OutlinedButton.icon(
            onPressed: () =>
                context.go(AppRoutes.cattleBreedingPath(animal.id)),
            icon: const Icon(Icons.favorite_outlined),
            label: const Text('Services Performed'),
          ),
        ],
      ],
    );
  }
}

// ── Production Tab ────────────────────────────────────────────────────────────

class _ProductionTab extends ConsumerWidget {
  const _ProductionTab({required this.animal});
  final CattleAnimal animal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        OutlinedButton.icon(
          onPressed: () =>
              context.go(AppRoutes.cattleWeightsPath(animal.id)),
          icon: const Icon(Icons.monitor_weight_outlined),
          label: const Text('Weight History'),
        ),
        if (animal.productionType == 'dairy') ...[
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () =>
                context.go(AppRoutes.cattleMilkPath(animal.id)),
            icon: const Icon(Icons.water_drop_outlined),
            label: const Text('Milk Records'),
          ),
          if (animal.dairySpecific != null) ...[
            const SizedBox(height: 16),
            _InfoCard(title: 'Dairy Stats', children: [
              _InfoRow(
                  label: 'Peak Yield',
                  value:
                      '${animal.dairySpecific!.peakMilkLitrePd?.toStringAsFixed(1) ?? '?'} L/d'),
              _InfoRow(
                  label: 'This Lactation',
                  value:
                      '${animal.dairySpecific!.totalMilkThisLactation?.toStringAsFixed(0) ?? '?'} L'),
              if (animal.dairySpecific!.butterfatPct != null)
                _InfoRow(
                    label: 'Fat %',
                    value:
                        '${animal.dairySpecific!.butterfatPct!.toStringAsFixed(1)}%'),
              if (animal.dairySpecific!.proteinPct != null)
                _InfoRow(
                    label: 'Protein %',
                    value:
                        '${animal.dairySpecific!.proteinPct!.toStringAsFixed(1)}%'),
              if (animal.dairySpecific!.milkingSchedule != null)
                _InfoRow(
                    label: 'Milking Schedule',
                    value: animal.dairySpecific!.milkingSchedule!),
              if (animal.dairySpecific!.somaticCellCount != null)
                _InfoRow(
                    label: 'SCC',
                    value:
                        '${animal.dairySpecific!.somaticCellCount} cells/mL'),
            ]),
          ],
        ],
        if (animal.productionType == 'beef' &&
            animal.beefSpecific != null) ...[
          const SizedBox(height: 16),
          _InfoCard(title: 'Beef Stats', children: [
            if (animal.beefSpecific!.averageDailyGainKg != null)
              _InfoRow(
                  label: 'ADG',
                  value:
                      '${animal.beefSpecific!.averageDailyGainKg!.toStringAsFixed(3)} kg/day'),
            if (animal.beefSpecific!.feedConversionRatio != null)
              _InfoRow(
                  label: 'FCR',
                  value:
                      '${animal.beefSpecific!.feedConversionRatio!.toStringAsFixed(2)}'),
            if (animal.beefSpecific!.slaughterWeightKg != null)
              _InfoRow(
                  label: 'Slaughter Weight',
                  value:
                      '${animal.beefSpecific!.slaughterWeightKg!.toStringAsFixed(1)} kg'),
            if (animal.beefSpecific!.dressingPercent != null)
              _InfoRow(
                  label: 'Dressing %',
                  value:
                      '${animal.beefSpecific!.dressingPercent!.toStringAsFixed(1)}%'),
            if (animal.beefSpecific!.feedlotPenId != null)
              _InfoRow(
                  label: 'Feedlot Pen',
                  value: animal.beefSpecific!.feedlotPenId!),
          ]),
        ],
      ],
    );
  }
}

// ── Records Tab ───────────────────────────────────────────────────────────────

class _RecordsTab extends ConsumerWidget {
  const _RecordsTab({required this.animal});
  final CattleAnimal animal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calvingAsync = ref.watch(cattleCalvingEventsProvider(animal.id));
    final bcsAsync = ref.watch(cattleBcsRecordsProvider(animal.id));
    final salesAsync = ref.watch(cattleSaleRecordsProvider(animal.id));

    final calvings = calvingAsync.asData?.value ?? [];
    final bcsRecords = bcsAsync.asData?.value ?? [];
    final sales = salesAsync.asData?.value ?? [];

    final recentCalvings = calvings.take(3).toList();
    final recentBcs = bcsRecords.take(3).toList();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Calving events
        Text('Recent Calving Events',
            style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        if (recentCalvings.isEmpty)
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text('No calving events recorded.',
                style: TextStyle(color: Colors.grey)),
          )
        else
          ...recentCalvings.map((c) => Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                child: ListTile(
                  dense: true,
                  leading: Icon(
                    Icons.child_care_rounded,
                    color: c.calfAlive ? Colors.green : Colors.red,
                    size: 22,
                  ),
                  title: Text(c.calvingDate),
                  subtitle: Text(
                      '${c.calvingEase} · ${c.calfSex ?? 'unknown sex'}'),
                  trailing: Text(c.calfAlive ? '✓ Alive' : '✗ Died',
                      style: TextStyle(
                          color: c.calfAlive
                              ? Colors.green.shade700
                              : Colors.red.shade700,
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                ),
              )),
        const SizedBox(height: 16),

        // BCS records
        Text('Body Condition Scores',
            style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        if (recentBcs.isEmpty)
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text('No BCS records.',
                style: TextStyle(color: Colors.grey)),
          )
        else
          ...recentBcs.map((b) => Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                child: ListTile(
                  dense: true,
                  leading: const Icon(Icons.assignment_outlined, size: 20),
                  title: Text('BCS ${b.score.toStringAsFixed(1)} / 5.0'),
                  subtitle: Text(b.date),
                  trailing: b.assessedBy != null
                      ? Text(b.assessedBy!,
                          style: TextStyle(
                              fontSize: 11, color: Colors.grey[600]))
                      : null,
                ),
              )),
        const SizedBox(height: 16),

        // Sale records
        Text('Sale Records',
            style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        if (sales.isEmpty)
          const Padding(
            padding: EdgeInsets.only(bottom: 12),
            child: Text('No sale records.',
                style: TextStyle(color: Colors.grey)),
          )
        else
          ...sales.map((s) => Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                child: ListTile(
                  dense: true,
                  leading: const Icon(Icons.receipt_long_outlined, size: 20),
                  title: Text(s.buyerName),
                  subtitle: Text(s.saleDate),
                  trailing: s.totalAmount != null
                      ? Text(
                          'R${s.totalAmount!.toStringAsFixed(0)}',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color:
                                  Theme.of(context).colorScheme.primary),
                        )
                      : null,
                ),
              )),

        if (animal.purchasePrice != null ||
            animal.purchaseDate != null) ...[          
          const SizedBox(height: 16),
          _InfoCard(title: 'Acquisition', children: [
            if (animal.purchaseDate != null)
              _InfoRow(label: 'Purchase Date', value: animal.purchaseDate!),
            if (animal.purchasePrice != null)
              _InfoRow(
                  label: 'Purchase Price',
                  value:
                      'R${animal.purchasePrice!.toStringAsFixed(0)}'),
          ]),
        ],
        const Divider(height: 24),

        // Navigation
        OutlinedButton.icon(
          onPressed: () =>
              context.go(AppRoutes.cattleFinancialsPath(animal.id)),
          icon: const Icon(Icons.account_balance_wallet_outlined),
          label: const Text('Full Financial Summary'),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () => context.go(AppRoutes.cattleSales),
          icon: const Icon(Icons.sell_outlined),
          label: const Text('All Sale Records'),
        ),
      ],
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

/// Maps the cattle model's free-form fmdZone string to the shared [FmdZone] enum.
FmdZone _parseFmdZone(String raw) {
  final s = raw.toLowerCase();
  if (s.contains('surveillance')) return FmdZone.surveillanceZone;
  if (s.contains('protection') || s.contains('infected')) {
    return FmdZone.protectionZone;
  }
  return FmdZone.freeZone;
}

// ── Shared widgets ────────────────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: Theme.of(context).colorScheme.primary)),
            const Divider(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(
      {required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurfaceVariant,
                    )),
          ),
          Expanded(
            child: Text(value,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                    )),
          ),
        ],
      ),
    );
  }
}

// ── Notifiable disease banner ─────────────────────────────────────────────────

/// Inline warning banner shown at the top of the Health tab when one or more
/// recorded health events are classified as notifiable diseases.
///
/// This is a passive display widget. For the interactive reporting modal,
/// use [NotifiableDiseasePrompt.show] from shared/widgets.
class _NotifiableDiseaseBanner extends StatelessWidget {
  const _NotifiableDiseaseBanner({required this.events});

  final List<CattleHealthEvent> events;

  @override
  Widget build(BuildContext context) {
    final notifiable = events.where((e) => e.isNotifiable).toList();
    if (notifiable.isEmpty) return const SizedBox.shrink();

    final diagnoses = notifiable.map((e) => e.diagnosis).toSet().join(', ');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.red.shade400, width: 1.5),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.crisis_alert_rounded, color: Colors.red.shade700, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'NOTIFIABLE DISEASE DETECTED',
                  style: TextStyle(
                    color: Colors.red.shade700,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  diagnoses,
                  style: TextStyle(
                      color: Colors.red.shade700,
                      fontSize: 12,
                      fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 4),
                Text(
                  'Report to State Vet immediately as required by law.',
                  style: TextStyle(color: Colors.red.shade600, fontSize: 11),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

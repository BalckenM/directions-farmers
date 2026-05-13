import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../shared/widgets/farm_app_bar.dart';
import '../../../shared/widgets/farm_scaffold.dart';
import '../../../shared/widgets/loading_shimmer.dart';
import '../models/goat_animal.dart';
import '../providers/goat_providers.dart';

class GoatDetailScreen extends ConsumerWidget {
  const GoatDetailScreen({super.key, required this.goatId});
  final String goatId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final animalAsync = ref.watch(animalDetailProvider(goatId));

    return animalAsync.when(
      loading: () => FarmScaffold(
        appBar: const FarmAppBar(title: 'Goat Detail'),
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
            body: const Center(child: Text('Goat not found')),
          );
        }
        return _AnimalDetailView(animal: animal);
      },
    );
  }
}

class _AnimalDetailView extends StatefulWidget {
  const _AnimalDetailView({required this.animal});
  final GoatAnimal animal;

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
            onPressed: () => context.go(AppRoutes.editGoatPath(a.id)),
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
            Tab(text: 'Finance'),
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
          _FinanceTab(animal: a),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showQuickAdd(context, a),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Record'),
      ),
    );
  }

  void _showQuickAdd(BuildContext context, GoatAnimal a) {
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
                context.go(AppRoutes.goatWeightsPath(a.id));
              },
            ),
            if (a.productionType == 'dairy')
              ListTile(
                leading: const Icon(Icons.water_drop_outlined),
                title: const Text('Add Milk Record'),
                onTap: () {
                  Navigator.pop(context);
                  context.go(AppRoutes.goatMilkPath(a.id));
                },
              ),
            if (a.isFemale)
              ListTile(
                leading: const Icon(Icons.child_care_rounded),
                title: const Text('Record Kidding'),
                onTap: () {
                  Navigator.pop(context);
                  context.go(AppRoutes.goatKiddingPath(a.id));
                },
              ),
            ListTile(
              leading: const Icon(Icons.medical_services_outlined),
              title: const Text('Add Medication'),
              onTap: () {
                Navigator.pop(context);
                context.go(AppRoutes.addGoatMedicationPath(a.id));
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
  final GoatAnimal animal;

  @override
  Widget build(BuildContext context) {
    final a = animal;
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

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
            _InfoRow(
                label: 'BCS',
                value: '${a.bodyConditionScore} / 5'),
          if (a.famachaScore != null)
            _InfoRow(
              label: 'FAMACHA',
              value: '${a.famachaScore}',
              valueColor:
                  a.famachaScore! >= 4 ? cs.error : null,
            ),
          if (a.lastDewormingDate != null)
            _InfoRow(label: 'Last Dewormed', value: a.lastDewormingDate!),
        ]),
        if (a.isPregnant || a.isLactating) ...[
          const SizedBox(height: 12),
          _InfoCard(title: 'Reproductive Status', children: [
            _InfoRow(label: 'Pregnant', value: a.isPregnant ? 'Yes' : 'No'),
            if (a.isPregnant && a.expectedKiddingDate != null)
              _InfoRow(label: 'Expected Kidding', value: a.expectedKiddingDate!),
            _InfoRow(label: 'Lactating', value: a.isLactating ? 'Yes' : 'No'),
            if (a.isLactating && a.currentMilkLitrePd != null)
              _InfoRow(
                  label: 'Milk Yield',
                  value: '${a.currentMilkLitrePd!.toStringAsFixed(1)} L/day'),
            if (a.lastKiddingDate != null)
              _InfoRow(label: 'Last Kidding', value: a.lastKiddingDate!),
            if (a.totalKidsRaised != null)
              _InfoRow(label: 'Kids Raised', value: '${a.totalKidsRaised}'),
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
      ],
    );
  }
}

// ── Health Tab ────────────────────────────────────────────────────────────────

class _HealthTab extends ConsumerWidget {
  const _HealthTab({required this.animal});
  final GoatAnimal animal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        OutlinedButton.icon(
          onPressed: () => context.go(AppRoutes.goatHealthPath(animal.id)),
          icon: const Icon(Icons.favorite_border_rounded),
          label: const Text('Health Events'),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () =>
              context.go(AppRoutes.goatVaccinations),
          icon: const Icon(Icons.vaccines_outlined),
          label: const Text('Vaccinations'),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () =>
              context.go(AppRoutes.addGoatMedicationPath(animal.id)),
          icon: const Icon(Icons.medical_services_outlined),
          label: const Text('Medication Log'),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () =>
              context.go(AppRoutes.goatBodyCondition),
          icon: const Icon(Icons.assignment_outlined),
          label: const Text('Body Condition (BCS)'),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () => context.go(AppRoutes.goatFamacha),
          icon: const Icon(Icons.visibility_rounded),
          label: const Text('FAMACHA Scoring'),
        ),
      ],
    );
  }
}

// ── Breeding Tab ──────────────────────────────────────────────────────────────

class _BreedingTab extends ConsumerWidget {
  const _BreedingTab({required this.animal});
  final GoatAnimal animal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (animal.isFemale) ...[
          OutlinedButton.icon(
            onPressed: () =>
                context.go(AppRoutes.goatBreedingPath(animal.id)),
            icon: const Icon(Icons.favorite_outlined),
            label: const Text('Mating Records'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () =>
                context.go(AppRoutes.goatKiddingPath(animal.id)),
            icon: const Icon(Icons.child_care_rounded),
            label: const Text('Kidding Events'),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () =>
                context.go(AppRoutes.goatPregnancyCheck),
            icon: const Icon(Icons.pregnant_woman_rounded),
            label: const Text('Pregnancy Checks'),
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: () =>
                context.go(AppRoutes.addKidPath(animal.id)),
            icon: const Icon(Icons.add_rounded),
            label: const Text('Register New Kid'),
          ),
        ] else ...[
          OutlinedButton.icon(
            onPressed: () =>
                context.go(AppRoutes.goatBreedingPath(animal.id)),
            icon: const Icon(Icons.favorite_outlined),
            label: const Text('Services Performed'),
          ),
          if (animal.breederSpecific != null) ...[
            const SizedBox(height: 16),
            _InfoCard(title: 'Stud Record', children: [
              _InfoRow(
                  label: 'Does Served',
                  value: '${animal.breederSpecific!.doesServedCount ?? 0}'),
              if (animal.breederSpecific!.kidRatio != null)
                _InfoRow(
                    label: 'Kid Ratio',
                    value:
                        animal.breederSpecific!.kidRatio!.toStringAsFixed(2)),
              if (animal.breederSpecific!.breedingFee != null)
                _InfoRow(
                    label: 'Stud Fee',
                    value:
                        'R${animal.breederSpecific!.breedingFee!.toStringAsFixed(0)}'),
              if (animal.breederSpecific!.studBookNumber != null)
                _InfoRow(
                    label: 'Stud Book',
                    value: animal.breederSpecific!.studBookNumber!),
            ]),
          ],
        ],
      ],
    );
  }
}

// ── Production Tab ────────────────────────────────────────────────────────────

class _ProductionTab extends ConsumerWidget {
  const _ProductionTab({required this.animal});
  final GoatAnimal animal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        OutlinedButton.icon(
          onPressed: () => context.go(AppRoutes.goatWeightsPath(animal.id)),
          icon: const Icon(Icons.monitor_weight_outlined),
          label: const Text('Weight History'),
        ),
        if (animal.productionType == 'dairy') ...[
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => context.go(AppRoutes.goatMilkPath(animal.id)),
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
              if (animal.dairySpecific!.milkFatPct != null)
                _InfoRow(
                    label: 'Fat %',
                    value:
                        '${animal.dairySpecific!.milkFatPct!.toStringAsFixed(1)}%'),
              if (animal.dairySpecific!.milkProteinPct != null)
                _InfoRow(
                    label: 'Protein %',
                    value:
                        '${animal.dairySpecific!.milkProteinPct!.toStringAsFixed(1)}%'),
              if (animal.dairySpecific!.projectedDryOffDate != null)
                _InfoRow(
                    label: 'Projected Dry Off',
                    value: animal.dairySpecific!.projectedDryOffDate!),
            ]),
          ],
        ],
        if (animal.productionType == 'fiber') ...[
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => context.go(AppRoutes.goatShearingPath(animal.id)),
            icon: const Icon(Icons.cut_rounded),
            label: const Text('Shearing Records'),
          ),
          if (animal.fiberSpecific != null) ...[
            const SizedBox(height: 16),
            _InfoCard(title: 'Fiber Stats', children: [
              _InfoRow(
                  label: 'Avg Fleece',
                  value:
                      '${animal.fiberSpecific!.avgFleeceMassKg?.toStringAsFixed(1) ?? '?'} kg'),
              if (animal.fiberSpecific!.micronRating != null)
                _InfoRow(
                    label: 'Micron',
                    value:
                        '${animal.fiberSpecific!.micronRating!.toStringAsFixed(1)} µm'),
              if (animal.fiberSpecific!.colorGrade != null)
                _InfoRow(
                    label: 'Colour Grade',
                    value: animal.fiberSpecific!.colorGrade!),
              if (animal.fiberSpecific!.lastMohairPricePerKg != null)
                _InfoRow(
                    label: 'Last Price',
                    value:
                        'R${animal.fiberSpecific!.lastMohairPricePerKg!.toStringAsFixed(0)}/kg'),
            ]),
          ],
        ],
        if (animal.productionType == 'meat' && animal.meatSpecific != null) ...[
          const SizedBox(height: 16),
          _InfoCard(title: 'Meat Stats', children: [
            if (animal.meatSpecific!.adgGPerDay != null)
              _InfoRow(
                  label: 'ADG',
                  value:
                      '${animal.meatSpecific!.adgGPerDay!.toStringAsFixed(0)} g/day'),
            if (animal.meatSpecific!.dressingPct != null)
              _InfoRow(
                  label: 'Dressing %',
                  value:
                      '${animal.meatSpecific!.dressingPct!.toStringAsFixed(1)}%'),
            if (animal.meatSpecific!.targetSlaughterAgeMonths != null)
              _InfoRow(
                  label: 'Target Slaughter',
                  value:
                      '${animal.meatSpecific!.targetSlaughterAgeMonths} months'),
          ]),
        ],
      ],
    );
  }
}

// ── Finance Tab ───────────────────────────────────────────────────────────────

class _FinanceTab extends ConsumerWidget {
  const _FinanceTab({required this.animal});
  final GoatAnimal animal;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        OutlinedButton.icon(
          onPressed: () =>
              context.go(AppRoutes.goatFinancialsPath(animal.id)),
          icon: const Icon(Icons.account_balance_wallet_outlined),
          label: const Text('Financial Summary'),
        ),
        const SizedBox(height: 8),
        OutlinedButton.icon(
          onPressed: () => context.go(AppRoutes.goatSales),
          icon: const Icon(Icons.sell_outlined),
          label: const Text('Sale Records'),
        ),
      ],
    );
  }
}

// ── Shared widgets ────────────────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: Theme.of(context)
                    .textTheme
                    .labelMedium
                    ?.copyWith(color: Theme.of(context).colorScheme.primary)),
            const Divider(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value, this.valueColor});
  final String label;
  final String value;
  final Color? valueColor;

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
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    )),
          ),
          Expanded(
            child: Text(value,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: valueColor,
                    )),
          ),
        ],
      ),
    );
  }
}

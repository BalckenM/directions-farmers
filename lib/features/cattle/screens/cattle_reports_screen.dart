import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/farm_app_bar.dart';
import '../../../shared/widgets/farm_scaffold.dart';
import '../../../shared/widgets/loading_shimmer.dart';
import '../providers/cattle_providers.dart';

class CattleReportsScreen extends ConsumerStatefulWidget {
  const CattleReportsScreen({super.key});

  @override
  ConsumerState<CattleReportsScreen> createState() =>
      _CattleReportsScreenState();
}

class _CattleReportsScreenState
    extends ConsumerState<CattleReportsScreen> {
  DateTime? _from;
  DateTime? _to;

  Future<void> _pickDate({required bool isFrom}) async {
    final initial = isFrom
        ? (_from ?? DateTime.now().subtract(const Duration(days: 365)))
        : (_to ?? DateTime.now());
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        if (isFrom) {
          _from = picked;
        } else {
          _to = picked;
        }
      });
    }
  }

  bool _inRange(String dateStr) {
    if (_from == null && _to == null) return true;
    try {
      final d = DateTime.parse(dateStr);
      if (_from != null && d.isBefore(_from!)) return false;
      if (_to != null &&
          d.isAfter(_to!.add(const Duration(days: 1)))) return false;
      return true;
    } catch (_) {
      return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final allAsync = ref.watch(cattleProvider);
    final calvingAsync = ref.watch(allCalvingEventsProvider);
    final milkAsync = ref.watch(allCattleMilkRecordsProvider);

    final isLoading = allAsync is AsyncLoading ||
        calvingAsync is AsyncLoading ||
        milkAsync is AsyncLoading;

    if (isLoading) {
      return const FarmScaffold(
        appBar: FarmAppBar(
            title: 'Cattle Reports', subtitle: 'Herd overview'),
        body: LoadingShimmer(),
      );
    }

    final animals = allAsync.asData?.value ?? [];
    final allCalvings = calvingAsync.asData?.value ?? [];
    final allMilk = milkAsync.asData?.value ?? [];

    // Filter calvings by date range
    final calvings = allCalvings
        .where((c) => _inRange(c.calvingDate))
        .toList();

    // ── Counts using correct sex values ──────────────────────────────────────
    final total = animals.length;
    final bulls = animals
        .where((a) => a.sex == 'bull' || a.sex == 'steer')
        .length;
    final cows = animals
        .where((a) => a.sex == 'cow' || a.sex == 'heifer')
        .length;
    final calves = animals
        .where((a) =>
            a.sex == 'calf_male' ||
            a.sex == 'calf_female' ||
            a.ageMonths < 12)
        .length;
    final deceased =
        animals.where((a) => a.status == 'deceased').length;

    // ── Mortality rate ────────────────────────────────────────────────────────
    final mortalityRate = total > 0 ? (deceased / total * 100) : 0.0;

    // ── Calving rate ──────────────────────────────────────────────────────────
    final calvingRate =
        cows > 0 ? (calvings.length / cows * 100) : 0.0;

    // ── Average ADG (beef) ────────────────────────────────────────────────────
    final beefWithAdg = animals
        .where((a) =>
            a.productionType == 'beef' &&
            a.beefSpecific?.averageDailyGainKg != null)
        .toList();
    final avgAdg = beefWithAdg.isEmpty
        ? null
        : beefWithAdg.fold<double>(
                0, (s, a) => s + a.beefSpecific!.averageDailyGainKg!) /
            beefWithAdg.length;

    // ── Average milk yield (dairy, lactating) ─────────────────────────────────
    final dairyAnimals = animals.where((a) =>
        a.productionType == 'dairy' && a.currentMilkLitrePd != null);
    final avgMilk = dairyAnimals.isEmpty
        ? null
        : dairyAnimals.fold<double>(
                0, (s, a) => s + a.currentMilkLitrePd!) /
            dairyAnimals.length;

    // ── Milk records yield average ────────────────────────────────────────────
    final filteredMilk =
        allMilk.where((r) => _inRange(r.date)).toList();
    final avgMilkRecord = filteredMilk.isEmpty
        ? null
        : filteredMilk.fold<double>(
                0, (s, r) => s + r.totalLitres) /
            filteredMilk.length;

    // ── Breed breakdown ───────────────────────────────────────────────────────
    final byBreed = <String, int>{};
    for (final a in animals) {
      byBreed[a.breed] = (byBreed[a.breed] ?? 0) + 1;
    }
    final sortedBreeds = byBreed.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return FarmScaffold(
      appBar: const FarmAppBar(
          title: 'Cattle Reports', subtitle: 'Herd overview'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Date range filter ─────────────────────────────────────────────
            Row(children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pickDate(isFrom: true),
                  icon: const Icon(Icons.date_range_rounded, size: 18),
                  label: Text(_from != null
                      ? 'From: ${_from!.toIso8601String().substring(0, 10)}'
                      : 'From: All time'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _pickDate(isFrom: false),
                  icon: const Icon(Icons.date_range_rounded, size: 18),
                  label: Text(_to != null
                      ? 'To: ${_to!.toIso8601String().substring(0, 10)}'
                      : 'To: Today'),
                ),
              ),
              if (_from != null || _to != null) ...[
                const SizedBox(width: 4),
                IconButton(
                  icon: const Icon(Icons.clear_rounded),
                  tooltip: 'Clear date filter',
                  onPressed: () =>
                      setState(() => _from = _to = null),
                ),
              ],
            ]),
            const SizedBox(height: 16),

            // ── Herd summary ──────────────────────────────────────────────────
            Text('Herd Summary',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            _StatCard(label: 'Total Animals', value: '$total'),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(
                  child: _StatCard(label: 'Bulls/Steers', value: '$bulls')),
              const SizedBox(width: 8),
              Expanded(
                  child: _StatCard(label: 'Cows/Heifers', value: '$cows')),
              const SizedBox(width: 8),
              Expanded(
                  child: _StatCard(label: 'Calves', value: '$calves')),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(
                child: _StatCard(
                  label: 'Mortality Rate',
                  value: '${mortalityRate.toStringAsFixed(1)}%',
                  valueColor: deceased > 0
                      ? Theme.of(context).colorScheme.error
                      : null,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StatCard(
                  label: 'Calving Rate',
                  value: '${calvingRate.toStringAsFixed(1)}%',
                ),
              ),
            ]),
            const SizedBox(height: 24),

            // ── Production metrics ────────────────────────────────────────────
            Text('Production Metrics',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Row(children: [
              Expanded(
                child: _StatCard(
                  label: 'Avg ADG (beef)',
                  value: avgAdg != null
                      ? '${avgAdg.toStringAsFixed(3)} kg/d'
                      : '—',
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _StatCard(
                  label: 'Avg Milk Yield',
                  value: avgMilk != null
                      ? '${avgMilk.toStringAsFixed(1)} L/d'
                      : avgMilkRecord != null
                          ? '${avgMilkRecord.toStringAsFixed(1)} L'
                          : '—',
                ),
              ),
            ]),
            const SizedBox(height: 24),

            // ── Calving events ────────────────────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Calving Events',
                    style: Theme.of(context).textTheme.titleSmall),
                Text('${calvings.length} total',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.grey[600])),
              ],
            ),
            const SizedBox(height: 8),
            if (calvings.isEmpty)
              const Text('No calving events in range.',
                  style: TextStyle(color: Colors.grey))
            else
              ...calvings.take(5).map((c) => Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    child: ListTile(
                      dense: true,
                      leading: Icon(
                        Icons.child_care_rounded,
                        color: c.calfAlive
                            ? Colors.green
                            : Theme.of(context).colorScheme.error,
                        size: 22,
                      ),
                      title: Text(c.calvingDate),
                      subtitle: Text(
                          '${c.calvingEase} · ${c.calfSex ?? 'unknown sex'}'),
                      trailing: c.calfAlive
                          ? const Chip(
                              label: Text('Alive',
                                  style: TextStyle(fontSize: 11)),
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                            )
                          : Chip(
                              label: const Text('Died',
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.white)),
                              backgroundColor:
                                  Theme.of(context).colorScheme.error,
                              visualDensity: VisualDensity.compact,
                              padding: EdgeInsets.zero,
                            ),
                    ),
                  )),
            const SizedBox(height: 24),

            // ── Breed breakdown ───────────────────────────────────────────────
            Text('By Breed',
                style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            ...sortedBreeds.map(
              (e) => Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                child: ListTile(
                  title: Text(e.key),
                  trailing: Text(
                    '${e.value}',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // ── Export placeholder ────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () => ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                      content: Text(
                          'Export coming soon — PDF/CSV export not yet implemented')),
                ),
                icon: const Icon(Icons.download_rounded),
                label: const Text('Export Report'),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.label, required this.value, this.valueColor});
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text(value,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: valueColor)),
            const SizedBox(height: 4),
            Text(label,
                style: Theme.of(context).textTheme.labelMedium,
                textAlign: TextAlign.center),
          ],
        ),
      ),
    );
  }
}

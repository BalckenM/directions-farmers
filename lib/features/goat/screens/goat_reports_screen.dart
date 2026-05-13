import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../shared/widgets/farm_app_bar.dart';
import '../../../shared/widgets/farm_scaffold.dart';
import '../../../shared/widgets/loading_shimmer.dart';
import '../providers/goat_providers.dart';

class GoatReportsScreen extends ConsumerWidget {
  const GoatReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final animalsAsync = ref.watch(animalsProvider);
    final salesAsync = ref.watch(allGoatSaleRecordsProvider);
    final feedAsync = ref.watch(allGoatFeedRecordsProvider);
    final kiddingAsync = ref.watch(allGoatKiddingEventsProvider);
    final famachaAsync = ref.watch(allGoatFamachaRecordsProvider);
    final vaccinationsAsync = ref.watch(allGoatVaccinationsProvider);

    final isLoading = animalsAsync is AsyncLoading ||
        salesAsync is AsyncLoading ||
        feedAsync is AsyncLoading ||
        kiddingAsync is AsyncLoading ||
        famachaAsync is AsyncLoading ||
        vaccinationsAsync is AsyncLoading;

    if (isLoading) {
      return FarmScaffold(
        appBar: const FarmAppBar(title: 'Reports', subtitle: 'Goats'),
        body: const LoadingShimmer(),
      );
    }

    final animals = animalsAsync.asData?.value ?? [];
    final sales = salesAsync.asData?.value ?? [];
    final feed = feedAsync.asData?.value ?? [];
    final kiddingEvents = kiddingAsync.asData?.value ?? [];
    final famachaRecords = famachaAsync.asData?.value ?? [];
    final vaccinations = vaccinationsAsync.asData?.value ?? [];

    // ── Herd breakdown ────────────────────────────────────────────────
    final counts = <String, int>{};
    for (final a in animals) {
      counts[a.productionType] = (counts[a.productionType] ?? 0) + 1;
    }

    // ── Financials ────────────────────────────────────────────────────
    final totalFeedCost =
        feed.fold<double>(0, (s, r) => s + (r.totalCost ?? 0));
    final totalRevenue =
        sales.fold<double>(0, (s, r) => s + (r.totalRevenue ?? 0));

    // ── Kidding KPIs ──────────────────────────────────────────────────
    final doesWithKidding =
        kiddingEvents.map((e) => e.damId).toSet().length;
    final totalKidsAlive =
        kiddingEvents.fold<int>(0, (s, e) => s + e.kidsAliveBorn);
    final totalKidsStillborn =
        kiddingEvents.fold<int>(0, (s, e) => s + e.kidsStillborn);
    final totalKidsBorn = totalKidsAlive + totalKidsStillborn;

    // Kidding % = does that kidded / total does (does = female)
    final totalDoes = animals.where((a) => a.sex == 'female').length;
    final kiddingPct = totalDoes > 0
        ? (doesWithKidding / totalDoes * 100).toStringAsFixed(1)
        : '—';
    final mortalityPct = totalKidsBorn > 0
        ? (totalKidsStillborn / totalKidsBorn * 100).toStringAsFixed(1)
        : '—';

    // Average birth weight
    final allBirthWeights = kiddingEvents
        .expand((e) => e.birthWeights)
        .whereType<double>()
        .toList();
    final avgBirthWeight = allBirthWeights.isNotEmpty
        ? (allBirthWeights.reduce((a, b) => a + b) / allBirthWeights.length)
            .toStringAsFixed(2)
        : '—';

    // ── FAMACHA distribution ──────────────────────────────────────────
    // Latest per animal
    final Map<String, int> latestScoreByAnimal = {};
    for (final r in famachaRecords) {
      final prev = latestScoreByAnimal[r.animalId];
      if (prev == null) {
        latestScoreByAnimal[r.animalId] = r.score;
      } else {
        // keep by date — scan separately
      }
    }
    // Properly get latest per animal
    final Map<String, String> latestDateByAnimal = {};
    final Map<String, int> latestFamachaScore = {};
    for (final r in famachaRecords) {
      final prev = latestDateByAnimal[r.animalId];
      if (prev == null || r.date.compareTo(prev) > 0) {
        latestDateByAnimal[r.animalId] = r.date;
        latestFamachaScore[r.animalId] = r.score;
      }
    }
    final famachaDist = <int, int>{1: 0, 2: 0, 3: 0, 4: 0, 5: 0};
    for (final s in latestFamachaScore.values) {
      famachaDist[s] = (famachaDist[s] ?? 0) + 1;
    }

    // ── Vaccination coverage ──────────────────────────────────────────
    final totalVacs = vaccinations.length;
    final givenVacs = vaccinations.where((v) => v.givenDate != null).length;
    final vacCoverage = totalVacs > 0
        ? (givenVacs / totalVacs * 100).toStringAsFixed(1)
        : '—';

    return FarmScaffold(
      appBar: const FarmAppBar(title: 'Reports', subtitle: 'Goats'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Herd Overview ──────────────────────────────────────────
            Text('Herd Overview',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            _StatCard(
              icon: Icons.pets_rounded,
              title: 'Total Animals',
              value: animals.length.toString(),
              color: Colors.blue.shade50,
            ),
            const SizedBox(height: 8),
            ...counts.entries.map(
              (e) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _StatCard(
                  icon: Icons.category_outlined,
                  title:
                      '${e.key.substring(0, 1).toUpperCase()}${e.key.substring(1)} type',
                  value: e.value.toString(),
                  color: Colors.grey.shade100,
                ),
              ),
            ),

            const Divider(height: 32),

            // ── Kidding KPIs ──────────────────────────────────────────
            Text('Reproduction',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            _StatCard(
              icon: Icons.child_friendly_rounded,
              title: 'Kidding %',
              value: kiddingPct == '—' ? '—' : '$kiddingPct%',
              color: Colors.green.shade50,
            ),
            const SizedBox(height: 8),
            _StatCard(
              icon: Icons.warning_amber_rounded,
              title: 'Kid Mortality %',
              value: mortalityPct == '—' ? '—' : '$mortalityPct%',
              color: totalKidsStillborn > 0
                  ? Colors.red.shade50
                  : Colors.green.shade50,
            ),
            const SizedBox(height: 8),
            _StatCard(
              icon: Icons.monitor_weight_rounded,
              title: 'Avg Birth Weight',
              value: avgBirthWeight == '—' ? '—' : '${avgBirthWeight}kg',
              color: Colors.teal.shade50,
            ),

            const Divider(height: 32),

            // ── FAMACHA Distribution ───────────────────────────────────
            Text('FAMACHA Scores',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            if (famachaRecords.isEmpty)
              Text('No FAMACHA scores recorded yet.',
                  style: Theme.of(context)
                      .textTheme
                      .bodySmall
                      ?.copyWith(color: Colors.grey))
            else ...[
              Text(
                '${latestFamachaScore.length} of ${animals.length} animals scored',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.grey[600]),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [1, 2, 3, 4, 5].map((s) {
                  final color = _famachaColor(s);
                  final count = famachaDist[s] ?? 0;
                  return Column(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                          border: Border.all(color: color, width: 1.5),
                        ),
                        child: Center(
                          child: Text(
                            '$count',
                            style: TextStyle(
                              color: color,
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text('Score $s',
                          style:
                              TextStyle(color: color, fontSize: 11)),
                    ],
                  );
                }).toList(),
              ),
            ],

            const Divider(height: 32),

            // ── Health ────────────────────────────────────────────────
            Text('Health', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            _StatCard(
              icon: Icons.vaccines_rounded,
              title: 'Vaccination Coverage',
              value: vacCoverage == '—' ? '—' : '$vacCoverage%',
              color: vacCoverage != '—' && double.parse(vacCoverage) >= 80
                  ? Colors.green.shade50
                  : Colors.orange.shade50,
            ),
            const SizedBox(height: 8),
            _StatCard(
              icon: Icons.check_circle_outline,
              title: 'Vaccinations Given / Total',
              value: '$givenVacs / $totalVacs',
              color: Colors.blue.shade50,
            ),

            const Divider(height: 32),

            // ── Financials ────────────────────────────────────────────
            Text('Financials',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            _StatCard(
              icon: Icons.shopping_bag_outlined,
              title: 'Total Feed Cost',
              value: 'R${totalFeedCost.toStringAsFixed(0)}',
              color: Colors.orange.shade50,
            ),
            const SizedBox(height: 8),
            _StatCard(
              icon: Icons.sell_rounded,
              title: 'Total Sale Revenue',
              value: 'R${totalRevenue.toStringAsFixed(0)}',
              color: Colors.green.shade50,
            ),
            const SizedBox(height: 8),
            _StatCard(
              icon: Icons.trending_up_rounded,
              title: 'Net (Revenue - Feed)',
              value: 'R${(totalRevenue - totalFeedCost).toStringAsFixed(0)}',
              color: totalRevenue >= totalFeedCost
                  ? Colors.green.shade100
                  : Colors.red.shade100,
            ),
          ],
        ),
      ),
    );
  }

  Color _famachaColor(int score) {
    switch (score) {
      case 1:
        return const Color(0xFF388E3C);
      case 2:
        return const Color(0xFF8BC34A);
      case 3:
        return const Color(0xFFFBC02D);
      case 4:
        return const Color(0xFFE64A19);
      case 5:
        return const Color(0xFFC62828);
      default:
        return Colors.grey;
    }
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.icon,
    required this.title,
    required this.value,
    required this.color,
  });
  final IconData icon;
  final String title;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: color,
      shape:
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: Text(value,
            style: Theme.of(context)
                .textTheme
                .titleSmall
                ?.copyWith(fontWeight: FontWeight.bold)),
      ),
    );
  }
}


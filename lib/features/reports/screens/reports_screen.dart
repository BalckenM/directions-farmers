import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/livestock_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/farm_app_bar.dart';
import '../../../shared/widgets/farm_scaffold.dart';
import '../../../shared/widgets/loading_shimmer.dart';
import '../../dashboard/providers/dashboard_providers.dart';
import '../../events/providers/events_providers.dart';
import '../../events/models/breeding_event.dart';
import '../../events/models/health_event.dart';
import '../../events/models/weight_record.dart';
import '../../production/providers/production_providers.dart';
import '../../production/models/egg_record.dart';
import '../../production/models/milk_record.dart';
import '../../production/models/wool_record.dart';

// ── Data model ────────────────────────────────────────────────────────────────

class _ReportData {
  const _ReportData({
    required this.totalHealthEvents,
    required this.vaccinationCount,
    required this.treatmentCount,
    required this.activeWithdrawals,
    required this.totalHealthCostZar,
    required this.totalWeighings,
    required this.avgWeightKg,
    required this.avgAdgKgPerDay,
    required this.totalMilkLitres,
    required this.avgDailyYieldLitres,
    required this.avgFatPct,
    required this.goodMilkSessions,
    required this.totalMilkSessions,
    required this.totalEggsCollected,
    required this.totalEggsBroken,
    required this.avgBreakageRate,
    required this.eggDaysRecorded,
    required this.totalBreedingEvents,
    required this.confirmedPregnancies,
    required this.birthEvents,
    required this.totalWoolKg,
    required this.woolRevenue,
    required this.woolRecordCount,
    required this.mohairCount,
  });

  final int totalHealthEvents;
  final int vaccinationCount;
  final int treatmentCount;
  final int activeWithdrawals;
  final double totalHealthCostZar;

  final int totalWeighings;
  final double avgWeightKg;
  final double avgAdgKgPerDay;

  final double totalMilkLitres;
  final double avgDailyYieldLitres;
  final double avgFatPct;
  final int goodMilkSessions;
  final int totalMilkSessions;

  final int totalEggsCollected;
  final int totalEggsBroken;
  final double avgBreakageRate;
  final int eggDaysRecorded;

  final int totalBreedingEvents;
  final int confirmedPregnancies;
  final int birthEvents;

  final double totalWoolKg;
  final double woolRevenue;
  final int woolRecordCount;
  final int mohairCount;
}

// ── Provider ──────────────────────────────────────────────────────────────────

final _reportDataProvider =
    FutureProvider.autoDispose.family<_ReportData, String>((ref, species) async {
  final eventsRepo = ref.watch(eventsRepositoryProvider);
  final productionRepo = ref.watch(productionRepositoryProvider);
  final results = await Future.wait([
    eventsRepo.getHealthEvents(),
    eventsRepo.getWeightRecords(),
    productionRepo.getMilkRecords(),
    productionRepo.getEggRecords(),
    eventsRepo.getBreedingEvents(),
    productionRepo.getWoolRecords(),
  ]);

    // ── Health ──────────────────────────────────────────────────────────────
    final allHealthEvents = results[0] as List<HealthEvent>;
    final healthEvents = species.isEmpty
        ? allHealthEvents
        : allHealthEvents.where((e) => e.animalType == species).toList();
    final vaccinationCount =
        healthEvents.where((e) => e.eventType == 'vaccination').length;
    final treatmentCount =
        healthEvents.where((e) => e.eventType == 'treatment').length;
    final activeWithdrawals =
        healthEvents.where((e) => e.isWithdrawalActive).length;
    final totalHealthCostZar =
        healthEvents.fold<double>(0, (s, e) => s + (e.costZar ?? 0));

    // ── Growth ──────────────────────────────────────────────────────────────
    final allWeightRecords = results[1] as List<WeightRecord>;
    final weightRecords = species.isEmpty
        ? allWeightRecords
        : allWeightRecords.where((w) => w.animalType == species).toList();
    final totalWeighings = weightRecords.length;
    final avgWeightKg = totalWeighings > 0
        ? weightRecords.fold<double>(0, (s, w) => s + w.weightKg) /
            totalWeighings
        : 0.0;
    final validAdg =
        weightRecords.where((w) => w.adgSinceLastKg != null).toList();
    final avgAdgKgPerDay = validAdg.isNotEmpty
        ? validAdg.fold<double>(0, (s, w) => s + w.adgSinceLastKg!) /
            validAdg.length
        : 0.0;

    // ── Milk ────────────────────────────────────────────────────────────────
    final allMilkRecords = results[2] as List<MilkRecord>;
    final milkRecords = species.isEmpty
        ? allMilkRecords
        : allMilkRecords.where((m) => m.animalType == species).toList();
    final totalMilkLitres =
        milkRecords.fold<double>(0, (s, m) => s + m.yieldLitres);
    final dailyMilk = <String, double>{};
    for (final m in milkRecords) {
      dailyMilk[m.sessionDate] = (dailyMilk[m.sessionDate] ?? 0) + m.yieldLitres;
    }
    final avgDailyYieldLitres = dailyMilk.isNotEmpty
        ? dailyMilk.values.fold<double>(0, (s, v) => s + v) / dailyMilk.length
        : 0.0;
    final validFat = milkRecords.where((m) => m.fatPct != null).toList();
    final avgFatPct = validFat.isNotEmpty
        ? validFat.fold<double>(0, (s, m) => s + m.fatPct!) / validFat.length
        : 0.0;
    final goodMilkSessions =
        milkRecords.where((m) => (m.sccCellsPerMl ?? 999999) < 200000).length;

    // ── Eggs ────────────────────────────────────────────────────────────────
    final eggRecords = results[3] as List<EggRecord>;
    final totalEggsCollected =
        eggRecords.fold<int>(0, (s, e) => s + e.eggsCollected);
    final totalEggsBroken =
        eggRecords.fold<int>(0, (s, e) => s + (e.eggsBroken ?? 0));
    final avgBreakageRate = totalEggsCollected > 0
        ? totalEggsBroken / totalEggsCollected * 100
        : 0.0;
    final eggDaysRecorded =
        eggRecords.map((e) => e.collectionDate).toSet().length;

    // ── Breeding ────────────────────────────────────────────────────────────
    final allBreedingEvents = results[4] as List<BreedingEvent>;
    final breedingEvents = species.isEmpty
        ? allBreedingEvents
        : allBreedingEvents.where((e) => e.animalType == species).toList();
    final totalBreedingEvents = breedingEvents.length;
    final confirmedPregnancies = breedingEvents
        .where((e) => e.pregnancyResult == 'confirmed_pregnant')
        .length;
    const birthTypes = {
      'birth', 'kidding', 'farrowing', 'foaling', 'lambing'
    };
    final birthEvents =
        breedingEvents.where((e) => birthTypes.contains(e.eventType)).length;

    // ── Wool ────────────────────────────────────────────────────────────────
    final allWoolRecords = results[5] as List<WoolRecord>;
    final woolRecords = species.isEmpty
        ? allWoolRecords
        : allWoolRecords
            .where((w) => w.animalType == species)
            .toList();
    final totalWoolKg =
        woolRecords.fold<double>(0, (s, w) => s + w.greasyFleeceWeightKg);
    final woolRevenue =
        woolRecords.fold<double>(0, (s, w) => s + (w.estimatedValueZar ?? 0));
    final mohairCount = woolRecords.where((w) => w.isMohair).length;

    return _ReportData(
      totalHealthEvents: healthEvents.length,
      vaccinationCount: vaccinationCount,
      treatmentCount: treatmentCount,
      activeWithdrawals: activeWithdrawals,
      totalHealthCostZar: totalHealthCostZar,
      totalWeighings: totalWeighings,
      avgWeightKg: avgWeightKg,
      avgAdgKgPerDay: avgAdgKgPerDay,
      totalMilkLitres: totalMilkLitres,
      avgDailyYieldLitres: avgDailyYieldLitres,
      avgFatPct: avgFatPct,
      goodMilkSessions: goodMilkSessions,
      totalMilkSessions: milkRecords.length,
      totalEggsCollected: totalEggsCollected,
      totalEggsBroken: totalEggsBroken,
      avgBreakageRate: avgBreakageRate,
      eggDaysRecorded: eggDaysRecorded,
      totalBreedingEvents: totalBreedingEvents,
      confirmedPregnancies: confirmedPregnancies,
      birthEvents: birthEvents,
      totalWoolKg: totalWoolKg,
      woolRevenue: woolRevenue,
      woolRecordCount: woolRecords.length,
      mohairCount: mohairCount,
    );
});

// ── Screen ────────────────────────────────────────────────────────────────────

class ReportsScreen extends ConsumerWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final species =
        GoRouterState.of(context).uri.queryParameters['species'] ?? '';
    final reportAsync = ref.watch(_reportDataProvider(species));
    final summaryAsync = ref.watch(dashboardSummaryProvider);
    final speciesLabel =
        species.isNotEmpty ? LivestockConstants.displayName(species) : null;

    return FarmScaffold(
      appBar: FarmAppBar(
        title: 'Reports',
        subtitle: speciesLabel != null
            ? '$speciesLabel — Performance insights'
            : 'Farm performance insights',
      ),
      body: reportAsync.when(
        loading: () => LoadingShimmer.list(count: 6),
        error: (err, _) => ErrorState(
          message: err.toString(),
          onRetry: () => ref.invalidate(_reportDataProvider(species)),
        ),
        data: (report) => ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pagePaddingHorizontal,
            AppSpacing.md,
            AppSpacing.pagePaddingHorizontal,
            AppSpacing.xxl + 32,
          ),
          children: [
            _ReportCard(
              icon: Icons.health_and_safety_rounded,
              color: AppColors.error,
              title: 'Health Summary',
              subtitle: 'Vaccination coverage · treatment outcomes · withdrawal periods',
              tag: 'Livestock',
              stats: [
                _Stat('${report.totalHealthEvents}', 'Events'),
                _Stat('${report.vaccinationCount}', 'Vaccinations'),
                _Stat(
                  '${report.activeWithdrawals}',
                  'Withdrawals active',
                  color: report.activeWithdrawals > 0
                      ? AppColors.warning
                      : AppColors.success,
                ),
              ],
              footerLabel:
                  'Total vet cost: R${report.totalHealthCostZar.toStringAsFixed(0)}',
            ),
            const SizedBox(height: AppSpacing.md),
            _ReportCard(
              icon: Icons.monitor_weight_outlined,
              color: AppColors.secondary,
              title: 'Growth Performance',
              subtitle: 'Average daily gain · BCS distribution · weight trends',
              tag: 'Livestock',
              stats: [
                _Stat('${report.totalWeighings}', 'Weigh-ins'),
                _Stat('${report.avgWeightKg.toStringAsFixed(1)} kg', 'Avg weight'),
                _Stat(
                  '${report.avgAdgKgPerDay.toStringAsFixed(2)} kg',
                  'Avg ADG/day',
                  color: report.avgAdgKgPerDay >= 0.8
                      ? AppColors.success
                      : AppColors.warning,
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            if (species.isEmpty ||
                const {'cattle', 'goats', 'sheep'}.contains(species)) ...[
              _ReportCard(
                icon: Icons.water_drop_rounded,
                color: AppColors.info,
                title: 'Milk Production',
                subtitle: 'Daily yield · SCC quality score · lactation performance',
                tag: 'Production',
                stats: [
                  _Stat(
                    '${report.totalMilkLitres.toStringAsFixed(1)} L',
                    'Total yield',
                  ),
                  _Stat(
                    '${report.avgDailyYieldLitres.toStringAsFixed(1)} L',
                    'Avg daily',
                  ),
                  _Stat(
                    '${report.goodMilkSessions}/${report.totalMilkSessions}',
                    'Good quality',
                    color: AppColors.success,
                  ),
                ],
                footerLabel:
                    'Avg butterfat: ${report.avgFatPct.toStringAsFixed(1)}%',
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            if (species.isEmpty || species == 'poultry') ...[
              _ReportCard(
                icon: Icons.egg_rounded,
                color: AppColors.warning,
                title: 'Egg Production',
                subtitle: 'Collection totals · breakage rates · HDP performance',
                tag: 'Production',
                stats: [
                  _Stat('${report.totalEggsCollected}', 'Eggs collected'),
                  _Stat('${report.eggDaysRecorded}', 'Days recorded'),
                  _Stat(
                    '${report.avgBreakageRate.toStringAsFixed(1)}%',
                    'Breakage rate',
                    color: report.avgBreakageRate < 1.5
                        ? AppColors.success
                        : AppColors.warning,
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            _ReportCard(
              icon: Icons.favorite_rounded,
              color: AppColors.primary,
              title: 'Breeding Report',
              subtitle: 'Conception rates · gestation tracking · births recorded',
              tag: 'Breeding',
              stats: [
                _Stat('${report.totalBreedingEvents}', 'Total events'),
                _Stat(
                  '${report.confirmedPregnancies}',
                  'Confirmed pregnant',
                  color: AppColors.success,
                ),
                _Stat('${report.birthEvents}', 'Births recorded'),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            if (species.isEmpty ||
                const {'sheep', 'goats'}.contains(species)) ...[
              _ReportCard(
                icon: Icons.content_cut_rounded,
                color: const Color(0xFF5C6BC0),
                title: 'Fleece & Fibre',
                subtitle: 'Wool & mohair yield · micron · TEAM cert · auction revenue',
                tag: 'Production',
                stats: [
                  _Stat(
                    '${report.totalWoolKg.toStringAsFixed(1)} kg',
                    'Total GFW',
                  ),
                  _Stat('${report.woolRecordCount}', 'Shearing runs'),
                  _Stat(
                    'R${(report.woolRevenue / 1000).toStringAsFixed(1)}k',
                    'Est. revenue',
                    color: AppColors.success,
                  ),
                ],
                footerLabel: 'Mohair records: ${report.mohairCount}',
              ),
              const SizedBox(height: AppSpacing.md),
            ],
            summaryAsync.when(
              loading: () => LoadingShimmer.list(count: 1),
              error: (_, _) => const SizedBox.shrink(),
              data: (summary) => _ReportCard(
                icon: Icons.inventory_2_outlined,
                color: AppColors.tertiary,
                title: 'Inventory Summary',
                subtitle: 'Animal count by species · age class · health status',
                tag: 'Overview',
                stats: [
                  _Stat('${summary.totalAnimals}', 'Total animals'),
                  _Stat('${summary.speciesCount}', 'Species'),
                  _Stat(
                    '${summary.recentHealthAlerts}',
                    'Alerts',
                    color: summary.recentHealthAlerts > 0
                        ? AppColors.warning
                        : AppColors.success,
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

// ── Private widgets ───────────────────────────────────────────────────────────

class _Stat {
  const _Stat(this.value, this.label, {this.color});
  final String value;
  final String label;
  final Color? color;
}

class _ReportCard extends StatelessWidget {
  const _ReportCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.tag,
    required this.stats,
    this.footerLabel,
  });

  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final String tag;
  final List<_Stat> stats;
  final String? footerLabel;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: AppRadius.card,
        boxShadow: AppShadows.level1,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.md, AppSpacing.md, AppSpacing.md, 0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: color.withAlpha(20),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Icon(icon, color: color, size: 22),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: tt.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 7, vertical: 2),
                            decoration: BoxDecoration(
                              color: color.withAlpha(15),
                              borderRadius:
                                  BorderRadius.circular(AppRadius.sm),
                              border: Border.all(
                                  color: color.withAlpha(40), width: 1),
                            ),
                            child: Text(
                              tag,
                              style: tt.labelSmall?.copyWith(
                                color: color,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        subtitle,
                        style: tt.bodySmall?.copyWith(
                          color: cs.onSurfaceVariant,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Stats strip
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  for (int i = 0; i < stats.length; i++) ...[
                    if (i > 0)
                      Container(
                        width: 1,
                        color: cs.outlineVariant,
                        margin: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm),
                      ),
                    Expanded(child: _StatCell(stat: stats[i])),
                  ],
                ],
              ),
            ),
          ),
          // Optional footer
          if (footerLabel != null) ...[
            Divider(height: 1, color: cs.outlineVariant),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: 8),
              child: Text(
                footerLabel!,
                style:
                    tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({required this.stat});
  final _Stat stat;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final valueColor = stat.color ?? cs.onSurface;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          stat.value,
          style: tt.titleMedium?.copyWith(
            fontWeight: FontWeight.w800,
            color: valueColor,
            height: 1,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 3),
        Text(
          stat.label,
          style: tt.labelSmall?.copyWith(
            color: cs.onSurfaceVariant,
            fontSize: 10,
            height: 1.3,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
        ),
      ],
    );
  }
}



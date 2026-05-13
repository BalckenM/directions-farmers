import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/livestock_constants.dart';
import '../../../shared/widgets/chart_card.dart';
import '../../../shared/widgets/farm_app_bar.dart';
import '../../../shared/widgets/farm_scaffold.dart';
import '../../../shared/widgets/loading_shimmer.dart';
import '../../../shared/widgets/section_header.dart';
import '../../../shared/widgets/stat_card.dart';
import '../../dashboard/models/dashboard_summary.dart';
import '../../dashboard/providers/dashboard_providers.dart';

class InsightsScreen extends ConsumerStatefulWidget {
  const InsightsScreen({super.key});

  @override
  ConsumerState<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends ConsumerState<InsightsScreen> {
  int _selectedPeriodIndex = 1; // Default: Month
  static const _periods = ['Week', 'Month', 'Quarter', 'Year'];

  @override
  Widget build(BuildContext context) {
    final summaryAsync = ref.watch(dashboardSummaryProvider);

    return FarmScaffold(
      appBar: FarmAppBar(
        title: 'Insights',
        subtitle: 'Farm analytics & performance',
        actions: [
          IconButton(
            icon: const Icon(Icons.assessment_outlined),
            tooltip: 'Reports',
            onPressed: () => context.push(AppRoutes.reports),
          ),
          IconButton(
            icon: const Icon(Icons.file_download_outlined),
            tooltip: 'Export report',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Export coming soon'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor:
                      Theme.of(context).colorScheme.inverseSurface,
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
      body: summaryAsync.when(
        loading: () => LoadingShimmer.list(count: 5),
        error: (err, _) => Center(
          child: Text('Failed to load insights: $err'),
        ),
        data: (summary) => _InsightsContent(
          summary: summary,
          selectedPeriodIndex: _selectedPeriodIndex,
          periods: _periods,
          onPeriodSelected: (i) => setState(() => _selectedPeriodIndex = i),
        ),
      ),
    );
  }
}

class _InsightsContent extends StatelessWidget {
  const _InsightsContent({
    required this.summary,
    required this.selectedPeriodIndex,
    required this.periods,
    required this.onPeriodSelected,
  });

  final DashboardSummary summary;
  final int selectedPeriodIndex;
  final List<String> periods;
  final ValueChanged<int> onPeriodSelected;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.pagePaddingHorizontal),
      children: [
        const SizedBox(height: AppSpacing.md),
        _PeriodSelector(
          periods: periods,
          selectedIndex: selectedPeriodIndex,
          onSelected: onPeriodSelected,
        ),
        const SizedBox(height: AppSpacing.md),
        _FarmHealthScoreCard(summary: summary),
        const SizedBox(height: AppSpacing.md),
        SectionHeader(title: 'Financial Overview'),
        const SizedBox(height: AppSpacing.sm),
        _FinancialKpiRow(),
        const SizedBox(height: AppSpacing.md),
        SectionHeader(title: 'Production Trend'),
        const SizedBox(height: AppSpacing.sm),
        _MilkYieldChart(),
        const SizedBox(height: AppSpacing.md),
        SectionHeader(title: 'Herd Health'),
        const SizedBox(height: AppSpacing.sm),
        _HealthBreakdownCard(
          healthy: summary.totalAnimals -
              summary.recentHealthAlerts -
              (summary.recentHealthAlerts > 0 ? 2 : 0),
          alerts: summary.recentHealthAlerts,
          treated: summary.recentHealthAlerts > 0 ? 2 : 0,
          total: summary.totalAnimals,
        ),
        const SizedBox(height: AppSpacing.md),
        SectionHeader(title: 'Species Performance'),
        const SizedBox(height: AppSpacing.sm),
        _SpeciesPerformanceTable(summaries: summary.speciesSummaries),
        const SizedBox(height: AppSpacing.md),
        SectionHeader(title: 'Upcoming Events'),
        const SizedBox(height: AppSpacing.sm),
        const _UpcomingEventsCard(),
        const SizedBox(height: AppSpacing.md),
        _MarketPricesBanner(),
        const SizedBox(height: AppSpacing.xxl),
      ],
    );
  }
}

// ── Period selector ───────────────────────────────────────────────────────────

class _PeriodSelector extends StatelessWidget {
  const _PeriodSelector({
    required this.periods,
    required this.selectedIndex,
    required this.onSelected,
  });
  final List<String> periods;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: cs.surfaceContainerLow,
        borderRadius: AppRadius.button,
        border: Border.all(color: cs.outlineVariant, width: 1),
      ),
      child: Row(
        children: [
          for (int i = 0; i < periods.length; i++)
            Expanded(
              child: GestureDetector(
                onTap: () => onSelected(i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: i == selectedIndex ? cs.surface : Colors.transparent,
                    borderRadius: AppRadius.button,
                    boxShadow: i == selectedIndex ? AppShadows.level1 : null,
                  ),
                  child: Text(
                    periods[i],
                    textAlign: TextAlign.center,
                    style: tt.labelMedium?.copyWith(
                      fontWeight: i == selectedIndex
                          ? FontWeight.w700
                          : FontWeight.w400,
                      color: i == selectedIndex
                          ? AppColors.primary
                          : cs.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Farm health score ─────────────────────────────────────────────────────────

class _FarmHealthScoreCard extends StatelessWidget {
  const _FarmHealthScoreCard({required this.summary});
  final DashboardSummary summary;

  double get _score {
    if (summary.totalAnimals == 0) return 1.0;
    final alertRatio = summary.recentHealthAlerts / summary.totalAnimals;
    return (1.0 - alertRatio).clamp(0.0, 1.0);
  }

  String get _rating {
    final s = _score;
    if (s >= 0.95) return 'Excellent';
    if (s >= 0.85) return 'Good';
    if (s >= 0.70) return 'Fair';
    return 'Needs Attention';
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final score = _score;
    final scoreInt = (score * 100).round();

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF2E7D32), Color(0xFF1A5E20)],
        ),
        borderRadius: AppRadius.card,
        boxShadow: AppShadows.level2,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(30),
                  borderRadius: AppRadius.button,
                ),
                child: const Icon(Icons.verified_rounded,
                    color: Colors.white, size: 18),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Farm Health Score',
                      style: tt.labelMedium?.copyWith(
                        color: Colors.white.withAlpha(200),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '$scoreInt / 100',
                      style: AppTypography.kpiValue.copyWith(
                        color: Colors.white,
                        fontSize: 28,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(30),
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  _rating,
                  style: tt.labelSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.xs),
            child: LinearProgressIndicator(
              value: score,
              minHeight: 8,
              backgroundColor: Colors.white.withAlpha(40),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF69F0AE),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Icon(Icons.info_outline_rounded,
                  color: Colors.white.withAlpha(160), size: 12),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  summary.recentHealthAlerts == 0
                      ? 'All animals healthy — great job!'
                      : '${summary.recentHealthAlerts} alert${summary.recentHealthAlerts > 1 ? 's' : ''} affecting your score',
                  style: tt.labelSmall?.copyWith(
                    color: Colors.white.withAlpha(180),
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Financial KPI row ─────────────────────────────────────────────────────────
// Values are mock ZAR figures. When a financial aggregation provider is wired,
// replace _kRevenue/_kCost with real watched values (e.g. from a
// farmFinancialSummaryProvider that sums across species P&L models).

class _FinancialKpiRow extends StatelessWidget {
  const _FinancialKpiRow();

  // Mock ZAR annual farm-level figures (realistic SA mid-scale farm)
  static const double _kRevenue = 4200000;
  static const double _kCost = 2800000;

  static String _fmt(double v) {
    if (v >= 1000000) return 'R ${(v / 1000000).toStringAsFixed(1)}M';
    if (v >= 1000) return 'R ${(v / 1000).toStringAsFixed(0)}k';
    return 'R ${v.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    final gross = _kRevenue - _kCost;
    final marginPct = (_kRevenue > 0 ? (gross / _kRevenue) * 100 : 0).round();

    return Row(
      children: [
        Expanded(
          child: StatCard(
            label: 'Revenue',
            value: _fmt(_kRevenue),
            trend: '+8% vs last period',
            trendPositive: true,
            icon: Icons.trending_up_rounded,
            accentColor: AppColors.success,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: StatCard(
            label: 'Costs',
            value: _fmt(_kCost),
            trend: '+3% vs last period',
            trendPositive: false,
            icon: Icons.trending_down_rounded,
            accentColor: AppColors.tertiary,
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: StatCard(
            label: 'Margin',
            value: '$marginPct%',
            trend: '+5pts',
            trendPositive: true,
            icon: Icons.percent_rounded,
            accentColor: AppColors.secondary,
          ),
        ),
      ],
    );
  }
}

// ── Milk yield chart ──────────────────────────────────────────────────────────

class _MilkYieldChart extends StatelessWidget {
  const _MilkYieldChart();

  static const _yieldData = [38.0, 41.5, 39.0, 44.2, 42.8, 43.6, 42.3];
  static const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  double get _avg =>
      _yieldData.reduce((a, b) => a + b) / _yieldData.length;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final avg = _avg;

    return ChartCard(
      title: 'Milk Yield Trend',
      subtitle: 'This week (litres/day) · Avg ${avg.toStringAsFixed(1)}L',
      chartHeight: 160,
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.primary.withAlpha(15),
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Text(
          '7 days',
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
              ),
        ),
      ),
      chart: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            getDrawingHorizontalLine: (_) => FlLine(
              color: cs.outlineVariant.withAlpha(80),
              strokeWidth: 1,
              dashArray: [4, 4],
            ),
          ),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 22,
                getTitlesWidget: (value, meta) {
                  final i = value.toInt();
                  if (i < 0 || i >= _days.length) return const SizedBox();
                  return Text(
                    _days[i],
                    style: TextStyle(
                      fontSize: 9,
                      color: cs.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          extraLinesData: ExtraLinesData(
            horizontalLines: [
              HorizontalLine(
                y: avg,
                color: AppColors.secondary.withAlpha(140),
                strokeWidth: 1.5,
                dashArray: [6, 4],
                label: HorizontalLineLabel(
                  show: true,
                  alignment: Alignment.topRight,
                  style: const TextStyle(
                    fontSize: 9,
                    color: AppColors.secondary,
                    fontWeight: FontWeight.w600,
                  ),
                  labelResolver: (_) => 'Avg',
                ),
              ),
            ],
          ),
          lineBarsData: [
            LineChartBarData(
              spots: [
                for (int i = 0; i < _yieldData.length; i++)
                  FlSpot(i.toDouble(), _yieldData[i]),
              ],
              isCurved: true,
              curveSmoothness: 0.35,
              color: AppColors.primary,
              barWidth: 2.5,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, pct, bar, idx) => FlDotCirclePainter(
                  radius: 3,
                  color: AppColors.primary,
                  strokeWidth: 1.5,
                  strokeColor: Colors.white,
                ),
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppColors.primary.withAlpha(40),
                    AppColors.primary.withAlpha(0),
                  ],
                ),
              ),
            ),
          ],
          minX: 0,
          maxX: 6,
          minY: 35,
          maxY: 48,
        ),
      ),
    );
  }
}

// ── Health breakdown ──────────────────────────────────────────────────────────

class _HealthBreakdownCard extends StatelessWidget {
  const _HealthBreakdownCard({
    required this.healthy,
    required this.alerts,
    required this.treated,
    required this.total,
  });
  final int healthy;
  final int alerts;
  final int treated;
  final int total;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final safeTotal = total == 0 ? 1 : total;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: AppRadius.card,
        border: Border.all(color: cs.outlineVariant, width: 1),
        boxShadow: AppShadows.level1,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _BreakdownRow(
            label: 'Healthy',
            count: healthy,
            total: safeTotal,
            color: AppColors.success,
            tt: tt,
            cs: cs,
          ),
          const SizedBox(height: AppSpacing.sm),
          _BreakdownRow(
            label: 'Alerts',
            count: alerts,
            total: safeTotal,
            color: AppColors.error,
            tt: tt,
            cs: cs,
          ),
          const SizedBox(height: AppSpacing.sm),
          _BreakdownRow(
            label: 'Under Treatment',
            count: treated,
            total: safeTotal,
            color: AppColors.warning,
            tt: tt,
            cs: cs,
          ),
        ],
      ),
    );
  }
}

class _BreakdownRow extends StatelessWidget {
  const _BreakdownRow({
    required this.label,
    required this.count,
    required this.total,
    required this.color,
    required this.tt,
    required this.cs,
  });
  final String label;
  final int count;
  final int total;
  final Color color;
  final TextTheme tt;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    final pct = count / total;
    final pctLabel = '${(pct * 100).round()}%';

    return Row(
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: tt.bodySmall?.copyWith(color: cs.onSurface),
          ),
        ),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.xs),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 8,
              backgroundColor: cs.surfaceContainerLow,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        SizedBox(
          width: 36,
          child: Text(
            pctLabel,
            style: tt.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: color,
            ),
            textAlign: TextAlign.right,
          ),
        ),
        const SizedBox(width: 4),
        SizedBox(
          width: 24,
          child: Text(
            '$count',
            style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
            textAlign: TextAlign.right,
          ),
        ),
      ],
    );
  }
}

// ── Species performance table ─────────────────────────────────────────────────

class _SpeciesPerformanceTable extends StatelessWidget {
  const _SpeciesPerformanceTable({required this.summaries});
  final List<SpeciesSummary> summaries;

  static String _emojiFor(String species) {
    switch (species.toLowerCase()) {
      case 'cattle':
        return '🐄';
      case 'sheep':
        return '🐑';
      case 'goats':
        return '🐐';
      case 'pigs':
        return '🐷';
      case 'horses':
        return '🐴';
      case 'poultry':
        return '🐓';
      case 'rabbits':
        return '🐇';
      case 'aquaculture':
        return '🐟';
      case 'bees':
        return '🐝';
      default:
        return '🐾';
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: AppRadius.card,
        border: Border.all(color: cs.outlineVariant, width: 1),
        boxShadow: AppShadows.level1,
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: 10,
            ),
            decoration: BoxDecoration(
              color: cs.surfaceContainerLow,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppRadius.lg),
                topRight: Radius.circular(AppRadius.lg),
              ),
            ),
            child: Row(
              children: [
                const Expanded(flex: 3, child: SizedBox()),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Head',
                    style: tt.labelSmall?.copyWith(
                      color: cs.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Active',
                    style: tt.labelSmall?.copyWith(
                      color: cs.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Alerts',
                    style: tt.labelSmall?.copyWith(
                      color: cs.onSurfaceVariant,
                      fontWeight: FontWeight.w700,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          for (int i = 0; i < summaries.length; i++) ...[
            Container(
              color: i.isOdd ? cs.surfaceContainerLowest : null,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: 10,
              ),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: Row(
                      children: [
                        Text(
                          _emojiFor(summaries[i].species),
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            LivestockConstants.displayName(summaries[i].species),
                            style: tt.bodySmall
                                ?.copyWith(fontWeight: FontWeight.w600),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      '${summaries[i].headCount}',
                      style: tt.bodySmall?.copyWith(fontWeight: FontWeight.w600),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      '${summaries[i].activeCount}',
                      style: tt.bodySmall
                          ?.copyWith(color: AppColors.success),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text(
                      summaries[i].alertCount > 0
                          ? '${summaries[i].alertCount}'
                          : '—',
                      style: tt.bodySmall?.copyWith(
                        color: summaries[i].alertCount > 0
                            ? AppColors.error
                            : cs.onSurfaceVariant,
                        fontWeight: summaries[i].alertCount > 0
                            ? FontWeight.w700
                            : FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ],
          // Bottom border radius spacer
          const SizedBox(height: 0),
        ],
      ),
    );
  }
}

// ── Upcoming events ───────────────────────────────────────────────────────────

class _UpcomingEventsCard extends StatelessWidget {
  const _UpcomingEventsCard();

  static const _events = [
    _UpcomingEvent(
      icon: Icons.vaccines_rounded,
      iconColor: AppColors.error,
      iconBg: AppColors.errorContainer,
      title: 'Vaccination due',
      subtitle: '15 cattle — FMD booster',
      dayLabel: 'Mon',
    ),
    _UpcomingEvent(
      icon: Icons.monitor_weight_rounded,
      iconColor: AppColors.tertiary,
      iconBg: AppColors.tertiaryContainer,
      title: 'Weight check',
      subtitle: 'Group A (Goats) — 18 animals',
      dayLabel: 'Wed',
    ),
    _UpcomingEvent(
      icon: Icons.medical_services_rounded,
      iconColor: AppColors.warning,
      iconBg: AppColors.warningContainer,
      title: 'Vet visit',
      subtitle: 'Pig #P-003 — respiratory follow-up',
      dayLabel: 'Fri',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: AppRadius.card,
        border: Border.all(color: cs.outlineVariant, width: 1),
        boxShadow: AppShadows.level1,
      ),
      child: Column(
        children: [
          for (int i = 0; i < _events.length; i++) ...[
            _UpcomingEventTile(event: _events[i]),
            if (i < _events.length - 1)
              Divider(
                height: 1,
                indent: 56 + AppSpacing.md,
                color: cs.outlineVariant,
              ),
          ],
        ],
      ),
    );
  }
}

class _UpcomingEvent {
  const _UpcomingEvent({
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.title,
    required this.subtitle,
    required this.dayLabel,
  });
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final String title;
  final String subtitle;
  final String dayLabel;
}

class _UpcomingEventTile extends StatelessWidget {
  const _UpcomingEventTile({required this.event});
  final _UpcomingEvent event;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 10,
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: event.iconBg,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(event.icon, color: event.iconColor, size: 18),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title,
                  style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                ),
                Text(
                  event.subtitle,
                  style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: cs.surfaceContainerLow,
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(color: cs.outlineVariant),
            ),
            child: Text(
              event.dayLabel,
              style: tt.labelSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: cs.onSurface,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Market prices banner ──────────────────────────────────────────────────────

class _MarketPricesBanner extends StatelessWidget {
  const _MarketPricesBanner();

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return GestureDetector(
      onTap: () => context.push(AppRoutes.marketPrices),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF1A5E20), Color(0xFF2E7D32)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: AppRadius.card,
          boxShadow: AppShadows.level2,
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(30),
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: const Icon(
                Icons.trending_up_rounded,
                color: Colors.white,
                size: 24,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Live Market Prices',
                    style: tt.titleSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'SwiftVEE · SAMEX · RSA commodity data',
                    style: tt.bodySmall?.copyWith(
                      color: Colors.white.withAlpha(200),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: Colors.white.withAlpha(200),
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

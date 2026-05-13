import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/farm_scaffold.dart';
import '../../../../shared/widgets/loading_shimmer.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../models/calendar_event.dart';
import '../../models/crop_field.dart';
import '../../models/planting_plan.dart';
import '../../providers/crop_providers.dart';
import '../../widgets/crop_illustration.dart';

class PlantingCalendarScreen extends ConsumerStatefulWidget {
  const PlantingCalendarScreen({super.key});

  @override
  ConsumerState<PlantingCalendarScreen> createState() =>
      _PlantingCalendarScreenState();
}

class _PlantingCalendarScreenState
    extends ConsumerState<PlantingCalendarScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(calendarEventsProvider(null));
    final fieldsAsync = ref.watch(cropFieldsProvider(null));
    final Map<String, String> fieldNames = {
      for (final f in fieldsAsync.value ?? []) f.id: f.name,
    };

    return FarmScaffold(
      appBar: AppBar(
        title: const Text('Planting Calendar'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.calendar_view_month_rounded, size: 18), text: 'Seasons'),
            Tab(icon: Icon(Icons.upcoming_rounded, size: 18), text: 'Upcoming'),
            Tab(icon: Icon(Icons.list_alt_rounded, size: 18), text: 'Activities'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          useSafeArea: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          builder: (_) => const _AddEventSheet(),
        ),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Activity'),
      ),
      body: eventsAsync.when(
        loading: () => Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: LoadingShimmer.list(count: 6),
        ),
        error: (err, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline,
                  size: AppSpacing.iconXl, color: AppColors.error),
              const SizedBox(height: AppSpacing.sm),
              Text('Failed to load calendar events',
                  style: Theme.of(context).textTheme.bodyLarge),
            ],
          ),
        ),
        data: (events) {
          return TabBarView(
            controller: _tabController,
            children: [
              const _SeasonalGanttTab(),
              _UpcomingTab(events: events, fieldNames: fieldNames),
              _AllActivitiesTab(events: events, fieldNames: fieldNames),
            ],
          );
        },
      ),
    );
  }
}

// ── Seasonal Gantt Tab ────────────────────────────────────────────────────────

/// South-African planting calendar — rows are driven by the crop catalog API.
/// Season bands are app constants (SA seasons don't come from the crop API).
class _SeasonalGanttTab extends ConsumerWidget {
  const _SeasonalGanttTab();

  // SA Season bands (month 1=Jan) — these are fixed SA calendar constants.
  static final List<_Season> _seasons = [
    _Season('Summer',  [12, 1, 2],   const Color(0xFFFF7043)),
    _Season('Autumn',  [3, 4, 5],    const Color(0xFFFFA726)),
    _Season('Winter',  [6, 7, 8],    const Color(0xFF42A5F5)),
    _Season('Spring',  [9, 10, 11],  const Color(0xFF66BB6A)),
  ];

  static const _months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];

  // ── Derive start/end month from a list of individual months ──────────────
  // Finds the longest consecutive run (handling year-wrap) and returns
  // (firstMonth, lastMonth) of that run.
  static (int, int) _monthRange(List<int> months) {
    if (months.isEmpty) return (1, 12);
    if (months.length == 1) return (months.first, months.first);
    final sorted = [...months]..sort();
    int maxGap = 0;
    int splitIdx = 0;
    for (int i = 0; i < sorted.length; i++) {
      final curr = sorted[i];
      final next = sorted[(i + 1) % sorted.length];
      final gap = (next - curr + 12) % 12;
      if (gap > maxGap) {
        maxGap = gap;
        splitIdx = i;
      }
    }
    return (sorted[(splitIdx + 1) % sorted.length], sorted[splitIdx]);
  }

  // ── Material icon lookup by crop name ────────────────────────────────────
  static const Map<String, IconData> _iconMap = {
    'maize':       Icons.grain,
    'corn':        Icons.grain,
    'wheat':       Icons.grain,
    'grain':       Icons.grain,
    'barley':      Icons.grain,
    'sorghum':     Icons.grain,
    'rice':        Icons.grain,
    'tomato':      Icons.eco,
    'tomatoes':    Icons.eco,
    'pepper':      Icons.eco,
    'chilli':      Icons.eco,
    'cucumber':    Icons.eco,
    'squash':      Icons.eco,
    'pumpkin':     Icons.eco,
    'potato':      Icons.spa,
    'potatoes':    Icons.spa,
    'sweet potato':Icons.spa,
    'carrot':      Icons.spa,
    'carrots':     Icons.spa,
    'onion':       Icons.spa,
    'onions':      Icons.spa,
    'beetroot':    Icons.spa,
    'cabbage':     Icons.local_florist,
    'kale':        Icons.local_florist,
    'spinach':     Icons.local_florist,
    'lettuce':     Icons.local_florist,
    'leafy':       Icons.local_florist,
    'sunflower':   Icons.filter_vintage,
    'soybean':     Icons.filter_vintage,
    'soybeans':    Icons.filter_vintage,
    'bean':        Icons.filter_vintage,
    'beans':       Icons.filter_vintage,
    'sugar cane':  Icons.grass,
    'sugarcane':   Icons.grass,
    'mango':       Icons.park,
    'avocado':     Icons.park,
    'citrus':      Icons.park,
    'orange':      Icons.park,
    'lemon':       Icons.park,
    'banana':      Icons.park,
    'grape':       Icons.park,
    'apple':       Icons.park,
    'watermelon':  Icons.eco_outlined,
    'melon':       Icons.eco_outlined,
  };

  static IconData _iconFor(String cropName) {
    final lower = cropName.toLowerCase();
    for (final entry in _iconMap.entries) {
      if (lower.contains(entry.key)) return entry.value;
    }
    return Icons.grass;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final now = DateTime.now();
    final currentMonth = now.month; // 1-12

    final cropsAsync = ref.watch(cropsProvider(null));

    return cropsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(
        child: Text('Failed to load crop data', style: tt.bodyLarge),
      ),
      data: (crops) {
        // Build Gantt rows from API crops
        final rows = crops.map((crop) {
          final (ps, pe) = _monthRange(crop.plantingMonths);
          final (hs, he) = _monthRange(crop.harvestMonths);
          return _CropCalRow(crop.name, _iconFor(crop.name), ps, pe, hs, he);
        }).toList();

        return SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: AppSpacing.xxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Legend ────────────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                color: cs.surfaceContainerLow,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('SA Planting Calendar', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: AppSpacing.sm),
                    Wrap(
                      spacing: AppSpacing.md,
                      runSpacing: AppSpacing.xs,
                      children: [
                        _LegendDot(color: const Color(0xFF2196F3), label: 'Planting window'),
                        _LegendDot(color: const Color(0xFFFF9800), label: 'Harvest window'),
                        ..._seasons.map((s) => _LegendDot(color: s.color.withAlpha(160), label: s.name)),
                      ],
                    ),
                  ],
                ),
              ),

              // ── Gantt chart ───────────────────────────────────────────────
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: _GanttChart(
                    rows: rows,
                    seasons: _seasons,
                    months: _months,
                    currentMonth: currentMonth,
                    cs: cs,
                  ),
                ),
              ),

              // ── Crop illustration strip ───────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Text('Crops in Season Now', style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
              ),
              const SizedBox(height: AppSpacing.sm),
              SizedBox(
                height: 140,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  itemCount: rows.length,
                  separatorBuilder: (_, i) => const SizedBox(width: AppSpacing.sm),
                  itemBuilder: (context, i) {
                    final row = rows[i];
                    final inPlanting = _GanttChart._monthInRange(currentMonth, row.plantStart, row.plantEnd);
                    final inHarvest  = _GanttChart._monthInRange(currentMonth, row.harvestStart, row.harvestEnd);
                    final active = inPlanting || inHarvest;
                    return _CropSeasonCard(
                      row: row,
                      inPlanting: inPlanting,
                      inHarvest: inHarvest,
                      active: active,
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
            ],
          ),
        );
      },
    );
  }
}

// ── Gantt chart widget ────────────────────────────────────────────────────────

class _GanttChart extends StatelessWidget {
  const _GanttChart({
    required this.rows,
    required this.seasons,
    required this.months,
    required this.currentMonth,
    required this.cs,
  });

  final List<_CropCalRow> rows;
  final List<_Season> seasons;
  final List<String> months;
  final int currentMonth;
  final ColorScheme cs;

  static const double _labelW  = 120.0;
  static const double _monthW  = 46.0;
  static const double _rowH    = 44.0;
  static const double _headerH = 52.0;

  double get _totalW => _labelW + _monthW * 12;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: _totalW,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Month + season header
          _buildHeader(context),
          // Crop rows
          ...rows.asMap().entries.map((e) => _buildRow(context, e.value, e.key.isOdd)),
          // Current month indicator line
          _buildCurrentMonthLine(),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SizedBox(
      height: _headerH,
      child: Row(
        children: [
          // Label column placeholder
          SizedBox(width: _labelW),
          // Month columns
          ...List.generate(12, (i) {
            final month = i + 1;
            final season = seasons.firstWhere(
              (s) => s.months.contains(month),
              orElse: () => seasons.first,
            );
            final isCurrent = month == currentMonth;
            return Container(
              width: _monthW,
              height: _headerH,
              decoration: BoxDecoration(
                color: season.color.withAlpha(isCurrent ? 80 : 40),
                border: Border(
                  bottom: BorderSide(color: season.color.withAlpha(120), width: 2),
                  right: BorderSide(color: cs.outlineVariant.withAlpha(60)),
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (isCurrent)
                    Container(
                      width: 6,
                      height: 6,
                      margin: const EdgeInsets.only(bottom: 2),
                      decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                    ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(
                      months[i],
                      style: TextStyle(
                        fontSize: 10.5,
                        fontWeight: isCurrent ? FontWeight.w800 : FontWeight.w500,
                        color: isCurrent ? Colors.red : season.color.withAlpha(220),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildRow(BuildContext context, _CropCalRow row, bool shaded) {
    return Container(
      height: _rowH,
      color: shaded ? cs.surfaceContainerLow.withAlpha(120) : Colors.transparent,
      child: Row(
        children: [
          // Crop label
          SizedBox(
            width: _labelW,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Row(
                children: [
                  Icon(row.icon, size: 16, color: AppColors.cropGreen),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      row.name.split(' /').first,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Month cells
          ...List.generate(12, (i) {
            final month = i + 1;
            final inPlant   = _monthInRange(month, row.plantStart,  row.plantEnd);
            final inHarvest = _monthInRange(month, row.harvestStart, row.harvestEnd);
            final isCurrent = month == currentMonth;

            Color? fill;
            if (inHarvest && inPlant) {
              fill = const Color(0xFF9C27B0).withAlpha(180);
            } else if (inHarvest) {
              fill = const Color(0xFFFF9800).withAlpha(200);
            } else if (inPlant) {
              fill = const Color(0xFF2196F3).withAlpha(200);
            }

            return Container(
              width: _monthW,
              height: _rowH,
              decoration: BoxDecoration(
                color: fill,
                border: Border(
                  left: fill != null ? BorderSide(color: Colors.white.withAlpha(40), width: 1) : BorderSide.none,
                  right: isCurrent ? const BorderSide(color: Colors.red, width: 1.5) : BorderSide(color: cs.outlineVariant.withAlpha(40)),
                ),
              ),
              child: fill != null
                  ? Center(
                      child: Icon(
                        inHarvest && inPlant
                            ? Icons.agriculture_rounded
                            : (inHarvest ? Icons.agriculture_rounded : Icons.spa_outlined),
                        size: 13,
                        color: Colors.white.withAlpha(220),
                      ),
                    )
                  : null,
            );
          }),
        ],
      ),
    );
  }

  Widget _buildCurrentMonthLine() {
    // Red "today" line overlay
    final lineX = _labelW + (currentMonth - 0.5) * _monthW;
    return SizedBox(
      height: 0,
      child: OverflowBox(
        maxHeight: double.infinity,
        alignment: Alignment.topLeft,
        child: Transform.translate(
          offset: Offset(lineX - 0.75, -(_rowH * rows.length + _headerH)),
          child: Container(
            width: 1.5,
            height: _rowH * rows.length + _headerH,
            color: Colors.red.withAlpha(80),
          ),
        ),
      ),
    );
  }

  static bool _monthInRange(int m, int start, int end) {
    if (start <= end) return m >= start && m <= end;
    return m >= start || m <= end;
  }
}

// ── Crop season card ──────────────────────────────────────────────────────────

class _CropSeasonCard extends StatelessWidget {
  const _CropSeasonCard({
    required this.row,
    required this.inPlanting,
    required this.inHarvest,
    required this.active,
  });

  final _CropCalRow row;
  final bool inPlanting;
  final bool inHarvest;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    Color borderColor = cs.outlineVariant;
    Color bgColor = cs.surfaceContainerLow;
    if (inHarvest) { borderColor = const Color(0xFFFF9800); bgColor = const Color(0xFFFF9800).withAlpha(20); }
    if (inPlanting) { borderColor = const Color(0xFF2196F3); bgColor = const Color(0xFF2196F3).withAlpha(20); }

    return Container(
      width: 100,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: AppRadius.card,
        border: Border.all(color: borderColor, width: active ? 2 : 1),
        boxShadow: active ? [BoxShadow(color: borderColor.withAlpha(60), blurRadius: 6, offset: const Offset(0, 2))] : null,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CropIllustration(
            cropName: row.name.split(' /').first,
            growthProgress: inHarvest ? 0.95 : (inPlanting ? 0.35 : 0.7),
            size: 64,
            showSoil: true,
          ),
          const SizedBox(height: 4),
          Icon(row.icon, size: 16, color: AppColors.cropGreen),
          if (active) ...[
            const SizedBox(height: 2),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: borderColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                inHarvest ? 'Harvest' : 'Planting',
                style: const TextStyle(color: Colors.white, fontSize: 8, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Legend dot ────────────────────────────────────────────────────────────────

class _LegendDot extends StatelessWidget {
  const _LegendDot({required this.color, required this.label});
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(3))),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 11)),
      ],
    );
  }
}

// ── Data classes ──────────────────────────────────────────────────────────────

class _CropCalRow {
  _CropCalRow(this.name, this.icon, this.plantStart, this.plantEnd, this.harvestStart, this.harvestEnd);

  final String name;
  final IconData icon;
  final int plantStart;
  final int plantEnd;
  final int harvestStart;
  final int harvestEnd;
}

class _Season {
  const _Season(this.name, this.months, this.color);
  final String name;
  final List<int> months;
  final Color color;
}

// ── Upcoming Tab ──────────────────────────────────────────────────────────────

class _UpcomingTab extends StatelessWidget {
  const _UpcomingTab({required this.events, required this.fieldNames});

  final List<CalendarEvent> events;
  final Map<String, String> fieldNames;

  @override
  Widget build(BuildContext context) {
    final upcoming = events
        .where((e) => e.isPending || e.isOverdue)
        .toList()
      ..sort((a, b) => a.scheduledDate.compareTo(b.scheduledDate));

    if (upcoming.isEmpty) {
      return _EmptyState(
        icon: Icons.event_available_outlined,
        message: 'No upcoming activities',
      );
    }

    // Group by month
    final grouped = <String, List<CalendarEvent>>{};
    for (final event in upcoming) {
      final key = DateFormat('MMMM yyyy').format(event.scheduledDate);
      grouped.putIfAbsent(key, () => []).add(event);
    }

    return ListView(
      padding: const EdgeInsets.only(
          bottom: AppSpacing.xl, top: AppSpacing.sm),
      children: [
        for (final entry in grouped.entries) ...[
          SectionHeader(title: entry.key),
          ...entry.value.map(
            (e) => Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: AppSpacing.xs),
              child: _EventCard(event: e, fieldNames: fieldNames),
            ),
          ),
        ],
      ],
    );
  }
}

// ── All Activities Tab ────────────────────────────────────────────────────────

class _AllActivitiesTab extends StatelessWidget {
  const _AllActivitiesTab({required this.events, required this.fieldNames});

  final List<CalendarEvent> events;
  final Map<String, String> fieldNames;

  @override
  Widget build(BuildContext context) {
    if (events.isEmpty) {
      return _EmptyState(
        icon: Icons.calendar_month_outlined,
        message: 'No activities recorded',
      );
    }

    final overdue = events.where((e) => e.isOverdue).toList();
    final pending = events.where((e) => e.isPending).toList();
    final completed = events.where((e) => e.isCompleted).toList();

    return ListView(
      padding: const EdgeInsets.only(
          bottom: AppSpacing.xl, top: AppSpacing.sm),
      children: [
        if (overdue.isNotEmpty) ...[
          SectionHeader(title: 'Overdue'),
          ...overdue.map(
            (e) => Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: AppSpacing.xs),
              child: _EventCard(event: e, fieldNames: fieldNames),
            ),
          ),
        ],
        if (pending.isNotEmpty) ...[
          SectionHeader(title: 'Pending'),
          ...pending.map(
            (e) => Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: AppSpacing.xs),
              child: _EventCard(event: e, fieldNames: fieldNames),
            ),
          ),
        ],
        if (completed.isNotEmpty) ...[
          SectionHeader(title: 'Completed'),
          ...completed.map(
            (e) => Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md, vertical: AppSpacing.xs),
              child: _EventCard(event: e, fieldNames: fieldNames),
            ),
          ),
        ],
      ],
    );
  }
}

// ── Event Card ────────────────────────────────────────────────────────────────

class _EventCard extends StatelessWidget {
  const _EventCard({required this.event, required this.fieldNames});

  final CalendarEvent event;
  final Map<String, String> fieldNames;

  IconData _iconForType(CalendarActivityType type) => switch (type) {
        CalendarActivityType.planting => Icons.spa_outlined,
        CalendarActivityType.scouting => Icons.search_outlined,
        CalendarActivityType.harvest => Icons.agriculture_outlined,
        CalendarActivityType.spraying => Icons.opacity_outlined,
        CalendarActivityType.fertilizerApplication => Icons.science_outlined,
        CalendarActivityType.landPrep => Icons.construction_outlined,
        CalendarActivityType.weeding => Icons.grass_outlined,
        CalendarActivityType.irrigation => Icons.water_drop_outlined,
        CalendarActivityType.germinationCheck => Icons.eco_outlined,
        CalendarActivityType.inputPurchase => Icons.shopping_cart_outlined,
        CalendarActivityType.postHarvest => Icons.inventory_2_outlined,
      };

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final fmt = DateFormat('dd MMM yyyy');

    final (statusLabel, statusBg, statusFg) = switch (event.status) {
      'completed' => (
          'Completed',
          AppColors.successContainer,
          AppColors.onSuccessContainer
        ),
      'overdue' => (
          'Overdue',
          AppColors.errorContainer,
          AppColors.onErrorContainer
        ),
      _ => (
          'Pending',
          AppColors.tertiaryContainer,
          AppColors.onTertiaryContainer
        ),
    };

    return Card(
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.card),
      child: Padding(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        child: Row(
          children: [
            // Activity icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primaryContainer,
                borderRadius: AppRadius.chip,
              ),
              child: Icon(
                _iconForType(event.activityType),
                size: AppSpacing.iconMd,
                color: AppColors.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: AppSpacing.md),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(event.title,
                      style: tt.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w600)),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      const Icon(Icons.calendar_today_outlined,
                          size: AppSpacing.iconSm,
                          color: AppColors.onSurfaceVariant),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        fmt.format(event.scheduledDate),
                        style: tt.bodySmall
                            ?.copyWith(color: AppColors.onSurfaceVariant),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.xs, vertical: 2),
                        decoration: BoxDecoration(
                          color: statusBg,
                          borderRadius: AppRadius.chip,
                        ),
                        child: Text(
                          statusLabel,
                          style: tt.labelSmall?.copyWith(
                              color: statusFg, fontWeight: FontWeight.w600),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    children: [
                      const Icon(Icons.grid_view_outlined,
                          size: AppSpacing.iconSm,
                          color: AppColors.onSurfaceVariant),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        fieldNames[event.fieldId] ?? event.fieldId,
                        style: tt.bodySmall
                            ?.copyWith(color: AppColors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Mark Done button for pending events
            if (event.isPending) ...[
              const SizedBox(width: AppSpacing.sm),
              _MarkDoneButton(event: event),
            ],
          ],
        ),
      ),
    );
  }
}

class _MarkDoneButton extends ConsumerStatefulWidget {
  const _MarkDoneButton({required this.event});

  final CalendarEvent event;

  @override
  ConsumerState<_MarkDoneButton> createState() => _MarkDoneButtonState();
}

class _MarkDoneButtonState extends ConsumerState<_MarkDoneButton> {
  bool _busy = false;

  Future<void> _markDone() async {
    setState(() => _busy = true);
    final now = DateTime.now();
    final completed = CalendarEvent(
      id: widget.event.id,
      planId: widget.event.planId,
      fieldId: widget.event.fieldId,
      activityType: widget.event.activityType,
      title: widget.event.title,
      scheduledDate: widget.event.scheduledDate,
      completedDate: now,
      status: 'completed',
      notes: widget.event.notes,
      reminderDaysBefore: widget.event.reminderDaysBefore,
    );
    try {
      await ref.read(cropRepositoryProvider).updateCalendarEvent(completed);
      ref.invalidate(calendarEventsProvider);
      ref.invalidate(upcomingCalendarEventsProvider);
    } catch (_) {}
    if (!mounted) return;
    setState(() => _busy = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Activity marked as complete')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: _busy ? null : _markDone,
      style: TextButton.styleFrom(
        foregroundColor: AppColors.success,
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: _busy
          ? const SizedBox(
              width: AppSpacing.iconMd,
              height: AppSpacing.iconMd,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: AppColors.success),
            )
          : const Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.check_circle_outline, size: AppSpacing.iconMd),
                SizedBox(height: 2),
                Text('Done', style: TextStyle(fontSize: 11)),
              ],
            ),
    );
  }
}

// ── Add Event Sheet ───────────────────────────────────────────────────────────

class _AddEventSheet extends ConsumerStatefulWidget {
  const _AddEventSheet();

  @override
  ConsumerState<_AddEventSheet> createState() => _AddEventSheetState();
}

class _AddEventSheetState extends ConsumerState<_AddEventSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();

  CropField? _selectedField;
  PlantingPlan? _selectedPlan;
  CalendarActivityType _activityType = CalendarActivityType.scouting;
  DateTime _scheduledDate = DateTime.now().add(const Duration(days: 1));
  int _reminderDays = 1;
  bool _saving = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _scheduledDate,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (picked != null) setState(() => _scheduledDate = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedField == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a field')),
      );
      return;
    }

    setState(() => _saving = true);
    final event = CalendarEvent(
      id: 'evt-${DateTime.now().millisecondsSinceEpoch}',
      planId: _selectedPlan?.id ?? '',
      fieldId: _selectedField!.id,
      activityType: _activityType,
      title: _titleCtrl.text.trim(),
      scheduledDate: _scheduledDate,
      status: 'pending',
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      reminderDaysBefore: _reminderDays,
    );

    try {
      await ref.read(cropRepositoryProvider).addCalendarEvent(event);
      ref.invalidate(calendarEventsProvider);
      ref.invalidate(upcomingCalendarEventsProvider);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final fieldsAsync = ref.watch(cropFieldsProvider(null));
    final plansAsync = ref.watch(plantingPlansProvider(null));
    final cropsAsync = ref.watch(cropsProvider(null));
    final cropNames = <String, String>{
      for (final c in cropsAsync.value ?? []) c.id: c.name,
    };

    final fields = fieldsAsync.value ?? [];
    final allPlans = plansAsync.value ?? [];
    final fieldPlans = _selectedField == null
        ? <PlantingPlan>[]
        : allPlans.where((p) => p.fieldId == _selectedField!.id).toList();

    final dateFmt = DateFormat('dd MMM yyyy');

    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.md,
        right: AppSpacing.md,
        top: AppSpacing.md,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
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
            const SizedBox(height: AppSpacing.md),

            Text(
              'Add Calendar Activity',
              style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: AppSpacing.md),

            // Field picker
            DropdownButtonFormField<CropField>(
              decoration: const InputDecoration(
                labelText: 'Field *',
                prefixIcon: Icon(Icons.grid_view_outlined),
                border: OutlineInputBorder(),
              ),
              value: _selectedField,
              items: fields
                  .map((f) => DropdownMenuItem(value: f, child: Text(f.name)))
                  .toList(),
              onChanged: (f) => setState(() {
                _selectedField = f;
                _selectedPlan = null; // reset plan when field changes
              }),
              validator: (v) => v == null ? 'Required' : null,
            ),
            const SizedBox(height: AppSpacing.sm),

            // Plan picker (optional)
            DropdownButtonFormField<PlantingPlan?>(
              decoration: const InputDecoration(
                labelText: 'Planting Plan (optional)',
                prefixIcon: Icon(Icons.spa_outlined),
                border: OutlineInputBorder(),
              ),
              value: _selectedPlan,
              items: [
                const DropdownMenuItem<PlantingPlan?>(
                    value: null, child: Text('None')),
                ...fieldPlans.map(
                  (p) => DropdownMenuItem<PlantingPlan?>(
                    value: p,
                    child: Text(cropNames[p.cropId] ?? p.cropId),
                  ),
                ),
              ],
              onChanged: (p) => setState(() => _selectedPlan = p),
            ),
            const SizedBox(height: AppSpacing.sm),

            // Activity type
            DropdownButtonFormField<CalendarActivityType>(
              decoration: const InputDecoration(
                labelText: 'Activity Type *',
                prefixIcon: Icon(Icons.category_outlined),
                border: OutlineInputBorder(),
              ),
              value: _activityType,
              items: CalendarActivityType.values
                  .map((t) => DropdownMenuItem(value: t, child: Text(t.label)))
                  .toList(),
              onChanged: (t) {
                if (t != null) setState(() => _activityType = t);
              },
            ),
            const SizedBox(height: AppSpacing.sm),

            // Title
            TextFormField(
              controller: _titleCtrl,
              decoration: const InputDecoration(
                labelText: 'Title *',
                prefixIcon: Icon(Icons.title_outlined),
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.sentences,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: AppSpacing.sm),

            // Scheduled date
            InkWell(
              onTap: _pickDate,
              borderRadius: AppRadius.card,
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Scheduled Date *',
                  prefixIcon: Icon(Icons.calendar_today_outlined),
                  border: OutlineInputBorder(),
                ),
                child: Text(dateFmt.format(_scheduledDate)),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),

            // Notes (optional)
            TextFormField(
              controller: _notesCtrl,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                prefixIcon: Icon(Icons.notes_outlined),
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: AppSpacing.sm),

            // Reminder days
            Row(
              children: [
                const Icon(Icons.notifications_outlined,
                    size: AppSpacing.iconMd, color: AppColors.onSurfaceVariant),
                const SizedBox(width: AppSpacing.sm),
                Text('Remind me', style: tt.bodyMedium),
                const Spacer(),
                DropdownButton<int>(
                  value: _reminderDays,
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(value: 0, child: Text('Same day')),
                    DropdownMenuItem(value: 1, child: Text('1 day before')),
                    DropdownMenuItem(value: 3, child: Text('3 days before')),
                    DropdownMenuItem(value: 7, child: Text('1 week before')),
                  ],
                  onChanged: (v) {
                    if (v != null) setState(() => _reminderDays = v);
                  },
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // Save button
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _saving ? null : _save,
                icon: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.check_rounded),
                label: Text(_saving ? 'Saving…' : 'Save Activity'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Empty State ───────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: AppSpacing.iconXl, color: AppColors.onSurfaceVariant),
          const SizedBox(height: AppSpacing.md),
          Text(
            message,
            style: Theme.of(context)
                .textTheme
                .bodyLarge
                ?.copyWith(color: AppColors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/farm_app_bar.dart';
import '../../../shared/widgets/farm_scaffold.dart';
import '../models/aquaculture_unit.dart';
import '../models/water_quality_log.dart';
import '../providers/aquaculture_providers.dart';

class AquacultureUnitDetailScreen extends ConsumerStatefulWidget {
  const AquacultureUnitDetailScreen({super.key, required this.unitId});

  final String unitId;

  @override
  ConsumerState<AquacultureUnitDetailScreen> createState() =>
      _AquacultureUnitDetailScreenState();
}

class _AquacultureUnitDetailScreenState
    extends ConsumerState<AquacultureUnitDetailScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final unitAsync = ref.watch(aquacultureUnitDetailProvider(widget.unitId));

    return unitAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
      data: (unit) {
        if (unit == null) {
          return const Scaffold(body: Center(child: Text('Unit not found')));
        }
        return _UnitDetailView(
            unitId: widget.unitId, unit: unit, tabs: _tabs);
      },
    );
  }
}

class _UnitDetailView extends ConsumerWidget {
  const _UnitDetailView({
    required this.unitId,
    required this.unit,
    required this.tabs,
  });

  final String unitId;
  final AquacultureUnit unit;
  final TabController tabs;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logsAsync = ref.watch(unitWaterQualityProvider(unitId));

    return FarmScaffold(
      appBar: FarmAppBar(
        title: unit.unitName,
        subtitle: '${unit.unitTypeLabel} · ${unit.species}',
        bottom: TabBar(
          controller: tabs,
          indicatorColor: AppColors.aquacultureColor,
          labelColor: AppColors.aquacultureColor,
          unselectedLabelColor:
              Theme.of(context).colorScheme.onSurfaceVariant,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Water Quality Log'),
          ],
        ),
      ),
      body: TabBarView(
        controller: tabs,
        children: [
          _OverviewTab(unit: unit),
          _WaterQualityLogTab(logsAsync: logsAsync),
        ],
      ),
    );
  }
}

// ── Overview Tab ──────────────────────────────────────────────────────────────

class _OverviewTab extends StatelessWidget {
  const _OverviewTab({required this.unit});

  final AquacultureUnit unit;

  @override
  Widget build(BuildContext context) {
    final batch = unit.currentBatch;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Water quality snapshot ────────────────────────────────────────
          _SectionTitle('Water Quality', color: AppColors.aquacultureColor),
          const SizedBox(height: AppSpacing.sm),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: AppSpacing.sm,
            crossAxisSpacing: AppSpacing.sm,
            childAspectRatio: 2.2,
            children: [
              _WqKpiCard(
                label: 'Dissolved O₂',
                value: unit.currentDoMgL != null
                    ? '${unit.currentDoMgL!.toStringAsFixed(1)} mg/L'
                    : '—',
                icon: Icons.opacity,
                alert: unit.isDoEmergency,
                warn: unit.isDoWarning,
                color: AppColors.aquacultureColor,
              ),
              _WqKpiCard(
                label: 'pH',
                value: unit.currentPh?.toStringAsFixed(1) ?? '—',
                icon: Icons.science_outlined,
                alert: false,
                warn: unit.phAlert,
                color: AppColors.aquacultureColor,
              ),
              _WqKpiCard(
                label: 'Ammonia',
                value: unit.currentAmmoniaMgL != null
                    ? '${unit.currentAmmoniaMgL!.toStringAsFixed(2)} mg/L'
                    : '—',
                icon: Icons.warning_amber_outlined,
                alert: false,
                warn: unit.ammoniaAlert,
                color: AppColors.aquacultureColor,
              ),
              _WqKpiCard(
                label: 'Temperature',
                value: unit.currentTempC != null
                    ? '${unit.currentTempC!.toStringAsFixed(1)} °C'
                    : '—',
                icon: Icons.thermostat_outlined,
                color: AppColors.aquacultureColor,
              ),
            ],
          ),

          // ── Active batch ──────────────────────────────────────────────────
          if (batch != null) ...[
            const SizedBox(height: AppSpacing.md),
            _SectionTitle('Active Batch', color: AppColors.aquacultureColor),
            const SizedBox(height: AppSpacing.sm),
            _InfoRow(label: 'Species', value: batch.species),
            _InfoRow(
                label: 'Stocking count',
                value: '${batch.initialCount}'),
            _InfoRow(
                label: 'Stocking date',
                value: batch.stockingDate.toLocal().toString().split(' ')[0]),
            _InfoRow(
                label: 'Days of culture',
                value: '${batch.daysInCulture}d'),
            _InfoRow(
                label: 'Avg weight',
                value: '${batch.avgWeightG.toStringAsFixed(0)} g'),
            _InfoRow(
                label: 'Biomass',
                value: '${batch.biomassKg.toStringAsFixed(1)} kg'),
            _InfoRow(
                label: 'Survival rate',
                value: batch.survivalRatePct != null
                    ? '${batch.survivalRatePct!.toStringAsFixed(1)}%'
                    : '—'),
            _InfoRow(
                label: 'Feed consumed',
                value: batch.feedConsumedTotalKg != null
                    ? '${batch.feedConsumedTotalKg!.toStringAsFixed(1)} kg'
                    : '—'),
            _InfoRow(
                label: 'FCR',
                value: batch.fcrToDate.toStringAsFixed(2)),
          ],

          // ── Unit info ─────────────────────────────────────────────────────
          const SizedBox(height: AppSpacing.md),
          _SectionTitle('Unit Info', color: AppColors.aquacultureColor),
          const SizedBox(height: AppSpacing.sm),
          _InfoRow(label: 'Type', value: unit.unitTypeLabel),
          if (unit.capacityM3 != null)
            _InfoRow(
                label: 'Capacity',
                value: '${unit.capacityM3!.toStringAsFixed(0)} m³'),
          if (unit.areaM2 != null)
            _InfoRow(
                label: 'Area',
                value: '${unit.areaM2!.toStringAsFixed(0)} m²'),

          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}

// ── Water Quality Log Tab ─────────────────────────────────────────────────────

class _WaterQualityLogTab extends StatelessWidget {
  const _WaterQualityLogTab({required this.logsAsync});

  final AsyncValue<List<WaterQualityLog>> logsAsync;

  @override
  Widget build(BuildContext context) {
    return logsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (logs) => logs.isEmpty
          ? const Center(child: Text('No water quality records'))
          : ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: logs.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(height: AppSpacing.xs),
              itemBuilder: (_, i) => _WaterQualityTile(log: logs[i]),
            ),
    );
  }
}

class _WaterQualityTile extends StatelessWidget {
  const _WaterQualityTile({required this.log});

  final WaterQualityLog log;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasCritical = log.isCritical;
    final hasAlert = log.hasAlert;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
      elevation: 0,
      color: hasCritical
          ? AppColors.error.withValues(alpha: 0.06)
          : hasAlert
              ? AppColors.warning.withValues(alpha: 0.06)
              : theme.colorScheme.surfaceContainerLowest,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Text(log.recordedAt.substring(0, 10),
                    style: theme.textTheme.labelLarge
                        ?.copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(width: AppSpacing.xs),
                Text(log.session,
                    style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant)),
                const Spacer(),
                if (hasCritical)
                  const _SmallBadge(label: 'CRIT', color: AppColors.error)
                else if (hasAlert)
                  const _SmallBadge(label: 'WARN', color: AppColors.warning),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            // Values
            Wrap(
              spacing: AppSpacing.md,
              children: [
                _WqValue(
                    label: 'DO',
                    value: log.dissolvedOxygenMgL != null
                        ? log.dissolvedOxygenMgL!.toStringAsFixed(1)
                        : '—',
                    unit: 'mg/L',
                    alert: log.isDoEmergency,
                    warn: log.isDoWarning),
                _WqValue(
                    label: 'pH',
                    value: log.ph?.toStringAsFixed(1) ?? '—',
                    unit: '',
                    warn: log.isPhWarning),
                _WqValue(
                    label: 'NH₃',
                    value: log.ammoniaMgL != null
                        ? log.ammoniaMgL!.toStringAsFixed(2)
                        : '—',
                    unit: 'mg/L',
                    warn: log.isAmmoniaAlert),
                _WqValue(
                    label: 'Temp',
                    value: log.temperatureC?.toStringAsFixed(1) ?? '—',
                    unit: '°C'),
              ],
            ),
            if (log.correctiveAction != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text('Action: ${log.correctiveAction}',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: AppColors.warning)),
            ],
          ],
        ),
      ),
    );
  }
}

class _WqValue extends StatelessWidget {
  const _WqValue({
    required this.label,
    required this.value,
    required this.unit,
    this.alert = false,
    this.warn = false,
  });

  final String label;
  final String value;
  final String unit;
  final bool alert;
  final bool warn;

  @override
  Widget build(BuildContext context) {
    final color = alert
        ? AppColors.error
        : warn
            ? AppColors.warning
            : Theme.of(context).colorScheme.onSurface;
    return Text('$label: $value$unit',
        style: TextStyle(
            fontSize: 12, fontWeight: FontWeight.w600, color: color));
  }
}

class _SmallBadge extends StatelessWidget {
  const _SmallBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 10, fontWeight: FontWeight.w800)),
    );
  }
}

// ── Shared helpers ────────────────────────────────────────────────────────────

class _WqKpiCard extends StatelessWidget {
  const _WqKpiCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.alert = false,
    this.warn = false,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool alert;
  final bool warn;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final valueColor = alert
        ? AppColors.error
        : warn
            ? AppColors.warning
            : color;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: alert
            ? AppColors.error.withValues(alpha: 0.08)
            : warn
                ? AppColors.warning.withValues(alpha: 0.08)
                : AppColors.aquacultureColorContainer,
        borderRadius: AppRadius.card,
      ),
      child: Row(
        children: [
          Icon(icon, color: valueColor, size: 20),
          const SizedBox(width: AppSpacing.xs),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(value,
                    style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800, color: valueColor)),
                Text(label,
                    style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 10),
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text, {required this.color});

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700, color: color));
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
          Text(label,
              style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant)),
          const Spacer(),
          Text(value,
              style: theme.textTheme.bodySmall
                  ?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

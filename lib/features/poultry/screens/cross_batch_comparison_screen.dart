import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/farm_app_bar.dart';
import '../../../shared/widgets/farm_scaffold.dart';
import '../models/poultry_flock.dart';
import '../providers/poultry_providers.dart';

// ── Models ────────────────────────────────────────────────────────────────────

/// Aggregated metrics for one batch used in comparison.
class _BatchMetrics {
  const _BatchMetrics({
    required this.flock,
    required this.mortalityPct,
    required this.livabilityPct,
    this.fcrToDate,
    this.currentAvgWeightG,
    this.dayOfAge,
  });

  final PoultryFlock flock;
  final double mortalityPct;
  final double livabilityPct;
  final double? fcrToDate;
  final double? currentAvgWeightG;
  final int? dayOfAge;

  String get name => flock.batchName;
  String get type => flock.productionType;
  String get status => flock.status;
  bool get isActive => flock.isActive;
}

_BatchMetrics _toMetrics(PoultryFlock f) => _BatchMetrics(
      flock: f,
      mortalityPct: f.mortalityPct,
      livabilityPct: f.livabilityPct ?? (100 - f.mortalityPct),
      fcrToDate: f.fcrToDate,
      currentAvgWeightG: f.currentAvgWeightG,
      dayOfAge: f.dayOfAge,
    );

// ── Screen ────────────────────────────────────────────────────────────────────

enum _SortField { name, mortality, fcr, weight, age }

class CrossBatchComparisonScreen extends ConsumerStatefulWidget {
  const CrossBatchComparisonScreen({super.key});

  @override
  ConsumerState<CrossBatchComparisonScreen> createState() =>
      _CrossBatchComparisonScreenState();
}

class _CrossBatchComparisonScreenState
    extends ConsumerState<CrossBatchComparisonScreen> {
  _SortField _sortBy = _SortField.mortality;
  bool _ascending = true;
  bool _activeOnly = true;

  List<_BatchMetrics> _sorted(List<_BatchMetrics> items) {
    final copy = List<_BatchMetrics>.from(items);
    copy.sort((a, b) {
      int cmp;
      switch (_sortBy) {
        case _SortField.name:
          cmp = a.name.compareTo(b.name);
        case _SortField.mortality:
          cmp = a.mortalityPct.compareTo(b.mortalityPct);
        case _SortField.fcr:
          final fa = a.fcrToDate ?? double.infinity;
          final fb = b.fcrToDate ?? double.infinity;
          cmp = fa.compareTo(fb);
        case _SortField.weight:
          final wa = a.currentAvgWeightG ?? -1;
          final wb = b.currentAvgWeightG ?? -1;
          cmp = wa.compareTo(wb);
        case _SortField.age:
          cmp = (a.dayOfAge ?? 0).compareTo(b.dayOfAge ?? 0);
      }
      return _ascending ? cmp : -cmp;
    });
    return copy;
  }

  void _toggleSort(_SortField field) {
    setState(() {
      if (_sortBy == field) {
        _ascending = !_ascending;
      } else {
        _sortBy = field;
        _ascending = true;
      }
    });
  }

  Color _mortalityColor(double pct) {
    if (pct <= 2.0) return AppColors.success;
    if (pct <= 4.0) return AppColors.warning;
    return AppColors.error;
  }

  Color _fcrColor(double? fcr) {
    if (fcr == null) return Colors.grey;
    if (fcr <= 1.7) return AppColors.success;
    if (fcr <= 2.0) return AppColors.warning;
    return AppColors.error;
  }

  Color _weightColor(double? wt) {
    if (wt == null) return Colors.grey;
    if (wt >= 2000) return AppColors.success;
    if (wt >= 1500) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    final flocksAsync = ref.watch(flocksProvider);

    return FarmScaffold(
      drawer: null,
      appBar: FarmAppBar(
        title: 'Batch Comparison',
        subtitle: 'Cross-flock performance analytics',
      ),
      body: flocksAsync.when(
        loading: () =>
            const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (flocks) {
          var metrics = flocks.map(_toMetrics).toList();
          if (_activeOnly) {
            metrics = metrics.where((m) => m.isActive).toList();
          }
          final sorted = _sorted(metrics);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Summary cards ──────────────────────────────────────────
              _SummaryRow(metrics: metrics),

              // ── Controls ──────────────────────────────────────────────
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSpacing.pagePaddingHorizontal,
                  vertical: 8,
                ),
                child: Row(
                  children: [
                    FilterChip(
                      label: Text(_activeOnly ? 'Active only' : 'All batches'),
                      selected: _activeOnly,
                      selectedColor: AppColors.poultryColorContainer,
                      checkmarkColor: AppColors.poultryColor,
                      onSelected: (v) => setState(() => _activeOnly = v),
                    ),
                    const Spacer(),
                    Text(
                      '${sorted.length} batch${sorted.length == 1 ? '' : 'es'}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),

              // ── Table header ───────────────────────────────────────────
              _TableHeader(
                sortBy: _sortBy,
                ascending: _ascending,
                onSort: _toggleSort,
              ),

              // ── Rows ───────────────────────────────────────────────────
              if (sorted.isEmpty)
                const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(
                    child: Text(
                      'No batches to compare.\nToggle "All batches" to see historical data.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.separated(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppSpacing.pagePaddingHorizontal,
                      vertical: 8,
                    ),
                    itemCount: sorted.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 8),
                    itemBuilder: (ctx, i) {
                      final m = sorted[i];
                      return _BatchRow(
                        metrics: m,
                        rank: i + 1,
                        mortalityColor: _mortalityColor(m.mortalityPct),
                        fcrColor: _fcrColor(m.fcrToDate),
                        weightColor: _weightColor(m.currentAvgWeightG),
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
}

// ── Summary Row ───────────────────────────────────────────────────────────────

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.metrics});
  final List<_BatchMetrics> metrics;

  @override
  Widget build(BuildContext context) {
    if (metrics.isEmpty) return const SizedBox.shrink();

    final avgMort = metrics.map((m) => m.mortalityPct).reduce((a, b) => a + b) /
        metrics.length;

    final withFcr = metrics.where((m) => m.fcrToDate != null).toList();
    final avgFcr = withFcr.isEmpty
        ? null
        : withFcr.map((m) => m.fcrToDate!).reduce((a, b) => a + b) /
            withFcr.length;

    final withWt = metrics.where((m) => m.currentAvgWeightG != null).toList();
    final avgWt = withWt.isEmpty
        ? null
        : withWt.map((m) => m.currentAvgWeightG!).reduce((a, b) => a + b) /
            withWt.length;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.pagePaddingHorizontal,
        12,
        AppSpacing.pagePaddingHorizontal,
        4,
      ),
      child: Row(
        children: [
          _SummaryCard(
            label: 'Avg Mortality',
            value: '${avgMort.toStringAsFixed(1)}%',
            icon: Icons.trending_down,
            color: _mortColor(avgMort),
            flex: 1,
          ),
          const SizedBox(width: 8),
          _SummaryCard(
            label: 'Avg FCR',
            value: avgFcr != null ? avgFcr.toStringAsFixed(2) : '—',
            icon: Icons.show_chart,
            color: _fcrColorFor(avgFcr),
            flex: 1,
          ),
          const SizedBox(width: 8),
          _SummaryCard(
            label: 'Avg Weight',
            value: avgWt != null
                ? '${(avgWt / 1000).toStringAsFixed(2)} kg'
                : '—',
            icon: Icons.monitor_weight_outlined,
            color: AppColors.info,
            flex: 1,
          ),
        ],
      ),
    );
  }

  static Color _mortColor(double pct) {
    if (pct <= 2.0) return AppColors.success;
    if (pct <= 4.0) return AppColors.warning;
    return AppColors.error;
  }

  static Color _fcrColorFor(double? fcr) {
    if (fcr == null) return Colors.grey;
    if (fcr <= 1.7) return AppColors.success;
    if (fcr <= 2.0) return AppColors.warning;
    return AppColors.error;
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.flex,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final int flex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      flex: flex,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: color.withAlpha(26),
          borderRadius: AppRadius.card,
          border: Border.all(color: color.withAlpha(77)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 14, color: color),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    label,
                    style: theme.textTheme.labelSmall?.copyWith(color: color),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Table Header ──────────────────────────────────────────────────────────────

class _TableHeader extends StatelessWidget {
  const _TableHeader({
    required this.sortBy,
    required this.ascending,
    required this.onSort,
  });

  final _SortField sortBy;
  final bool ascending;
  final void Function(_SortField) onSort;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final style = theme.textTheme.labelSmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
      fontWeight: FontWeight.w600,
      letterSpacing: 0.4,
    );

    Widget col(String label, _SortField field, {int flex = 1}) {
      final active = sortBy == field;
      return Expanded(
        flex: flex,
        child: GestureDetector(
          onTap: () => onSort(field),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label, style: style),
              if (active) ...[
                const SizedBox(width: 2),
                Icon(
                  ascending ? Icons.arrow_upward : Icons.arrow_downward,
                  size: 10,
                  color: AppColors.poultryColor,
                ),
              ],
            ],
          ),
        ),
      );
    }

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: AppSpacing.pagePaddingHorizontal,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius:
            BorderRadius.vertical(top: AppRadius.card.topLeft),
        border: Border.all(color: theme.colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 24,
            child: Text('#', style: style),
          ),
          const SizedBox(width: 8),
          col('BATCH', _SortField.name, flex: 3),
          col('MORT%', _SortField.mortality),
          col('FCR', _SortField.fcr),
          col('WT (g)', _SortField.weight),
          col('DAY', _SortField.age),
        ],
      ),
    );
  }
}

// ── Batch Row ─────────────────────────────────────────────────────────────────

class _BatchRow extends StatelessWidget {
  const _BatchRow({
    required this.metrics,
    required this.rank,
    required this.mortalityColor,
    required this.fcrColor,
    required this.weightColor,
  });

  final _BatchMetrics metrics;
  final int rank;
  final Color mortalityColor;
  final Color fcrColor;
  final Color weightColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final m = metrics;

    final statusColor = m.isActive ? AppColors.success : Colors.grey;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLow,
        borderRadius: AppRadius.card,
        border: Border.all(
          color: m.isActive
              ? AppColors.poultryColor.withAlpha(51)
              : theme.colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Name + status row
          Row(
            children: [
              // Rank badge
              Container(
                width: 24,
                height: 24,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.poultryColor.withAlpha(26),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '$rank',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: AppColors.poultryColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      m.name,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      m.type,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              // Status badge
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withAlpha(26),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  m.status.toUpperCase(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 10,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Metrics row
          Row(
            children: [
              const SizedBox(width: 32),
              _MetricChip(
                label: 'Mort',
                value: '${m.mortalityPct.toStringAsFixed(1)}%',
                color: mortalityColor,
              ),
              const SizedBox(width: 6),
              _MetricChip(
                label: 'FCR',
                value: m.fcrToDate != null
                    ? m.fcrToDate!.toStringAsFixed(2)
                    : '—',
                color: fcrColor,
              ),
              const SizedBox(width: 6),
              _MetricChip(
                label: 'Wt',
                value: m.currentAvgWeightG != null
                    ? '${m.currentAvgWeightG!.toStringAsFixed(0)} g'
                    : '—',
                color: weightColor,
              ),
              const SizedBox(width: 6),
              _MetricChip(
                label: 'Day',
                value:
                    m.dayOfAge != null ? '${m.dayOfAge}' : '—',
                color: AppColors.info,
              ),
            ],
          ),
          // Livability bar
          const SizedBox(height: 8),
          Row(
            children: [
              const SizedBox(width: 32),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Livability',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          '${m.livabilityPct.toStringAsFixed(1)}%',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: _livabilityColor(m.livabilityPct),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 3),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: (m.livabilityPct / 100).clamp(0.0, 1.0),
                        backgroundColor:
                            theme.colorScheme.outlineVariant.withAlpha(77),
                        valueColor: AlwaysStoppedAnimation(
                            _livabilityColor(m.livabilityPct)),
                        minHeight: 6,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static Color _livabilityColor(double pct) {
    if (pct >= 97) return AppColors.success;
    if (pct >= 95) return AppColors.warning;
    return AppColors.error;
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({
    required this.label,
    required this.value,
    required this.color,
  });

  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withAlpha(77)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$label: ',
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: 10,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

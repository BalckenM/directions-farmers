import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/farm_app_bar.dart';
import '../../../shared/widgets/farm_drawer.dart';
import '../../../shared/widgets/farm_scaffold.dart';
import '../../../shared/widgets/loading_shimmer.dart';
import '../models/sow.dart';
import '../providers/pigs_providers.dart';

class PigsScreen extends ConsumerWidget {
  const PigsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sowsAsync = ref.watch(sowsProvider);

    // Summary stats
    final totalSows =
        sowsAsync.whenOrNull(data: (s) => s.length) ?? 0;
    final dueSoon = sowsAsync.whenOrNull(
          data: (s) => s
              .where((x) =>
                  x.daysToFarrowing != null &&
                  x.daysToFarrowing! >= 0 &&
                  x.daysToFarrowing! <= 7)
              .length,
        ) ??
        0;
    final psyAlerts = sowsAsync.whenOrNull(
          data: (s) => s
              .where((x) =>
                  x.pigSpecific?.isPsyAlert == true)
              .length,
        ) ??
        0;

    // Group by stage
    final stageGroups = <String, List<Sow>>{};
    sowsAsync.whenOrNull(data: (sows) {
      for (final sow in sows) {
        final stage = sow.currentStage;
        stageGroups.putIfAbsent(stage, () => []).add(sow);
      }
    });

    const stageOrder = [
      'Farrowing',
      'Lactating',
      'Gestation',
      'Service',
      'Weaned',
      'Empty',
    ];
    final orderedStages = [
      ...stageOrder.where(stageGroups.containsKey),
      ...stageGroups.keys.where((k) => !stageOrder.contains(k)),
    ];

    return FarmScaffold(
      drawer: const FarmDrawer(),
      appBar: FarmAppBar(
        title: 'Sow Board',
        subtitle: totalSows > 0 ? '$totalSows sows' : null,
        actions: [
          if (dueSoon > 0)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.xs),
              child: _AlertBadge(
                  count: dueSoon, color: Colors.blue, label: 'Due'),
            ),
          if (psyAlerts > 0)
            Padding(
              padding: const EdgeInsets.only(right: AppSpacing.sm),
              child: _AlertBadge(
                  count: psyAlerts, color: AppColors.warning, label: 'PSY'),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: AppColors.pigColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Add Sow'),
      ),
      body: sowsAsync.when(
        loading: () => LoadingShimmer.list(count: 6),
        error: (e, _) => _ErrorView(message: e.toString()),
        data: (_) => stageGroups.isEmpty
            ? const _EmptyView()
            : ListView.builder(
                padding: const EdgeInsets.all(AppSpacing.md),
                itemCount: orderedStages.fold<int>(
                    0, (acc, s) => acc + 1 + (stageGroups[s]?.length ?? 0)),
                itemBuilder: (_, globalIndex) {
                  // Flatten the grouped list with section headers
                  int idx = globalIndex;
                  for (final stage in orderedStages) {
                    final sows = stageGroups[stage]!;
                    if (idx == 0) {
                      // Section header
                      return _StageHeader(
                          stage: stage, count: sows.length);
                    }
                    idx--;
                    if (idx < sows.length) {
                      return Padding(
                        padding:
                            const EdgeInsets.only(bottom: AppSpacing.sm),
                        child: _SowCard(sow: sows[idx]),
                      );
                    }
                    idx -= sows.length;
                  }
                  return const SizedBox.shrink();
                },
              ),
      ),
    );
  }
}

// ── Stage header ──────────────────────────────────────────────────────────────

class _StageHeader extends StatelessWidget {
  const _StageHeader({required this.stage, required this.count});

  final String stage;
  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.sm, bottom: 6),
      child: Row(
        children: [
          Text(stage,
              style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: AppColors.pigColor)),
          const SizedBox(width: AppSpacing.xs),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
            decoration: BoxDecoration(
              color: AppColors.pigColorContainer,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text('$count',
                style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.pigColor)),
          ),
          const Expanded(child: Divider(indent: 8)),
        ],
      ),
    );
  }
}

// ── Sow Card ──────────────────────────────────────────────────────────────────

class _SowCard extends StatelessWidget {
  const _SowCard({required this.sow});

  final Sow sow;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ps = sow.pigSpecific;
    final daysToFarrow = sow.daysToFarrowing;

    return Card(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
      elevation: 1,
      child: InkWell(
        borderRadius: AppRadius.card,
        onTap: () => context.push(AppRoutes.sowDetailPath(sow.id)),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ────────────────────────────────────────────────────
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.pigColorContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.pets,
                        color: AppColors.pigColor, size: 20),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(sow.displayName,
                            style: theme.textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.w600)),
                        Text(
                            '${sow.breed} · P${ps?.parity ?? 0}',
                            style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant)),
                      ],
                    ),
                  ),
                  // Alerts column
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (ps?.isPsyAlert == true)
                        const _InlineAlert(label: 'Low PSY', color: AppColors.warning),
                      if (ps?.isPreWeanAlert == true)
                        const _InlineAlert(label: 'Mortality', color: AppColors.error),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),

              // ── KPI row ───────────────────────────────────────────────────
              Row(
                children: [
                  if (daysToFarrow != null && daysToFarrow >= 0) ...[
                    _KpiChip(
                      icon: Icons.calendar_month_outlined,
                      label: daysToFarrow == 0
                          ? 'Due today'
                          : 'Due in ${daysToFarrow}d',
                      color: daysToFarrow <= 3 ? Colors.red : Colors.blue,
                    ),
                    const SizedBox(width: AppSpacing.xs),
                  ],
                  if (ps?.psyCurrentYear != null)
                    _KpiChip(
                      icon: Icons.child_friendly_outlined,
                      label: 'PSY ${ps!.psyCurrentYear!.toStringAsFixed(1)}',
                      color: ps.isPsyAlert ? AppColors.warning : Colors.green,
                    ),
                  const Spacer(),
                  if (sow.bodyConditionScore != null)
                    Text(
                        'BCS ${sow.bodyConditionScore!.toStringAsFixed(1)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _KpiChip extends StatelessWidget {
  const _KpiChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 3),
        Text(label,
            style: TextStyle(
                fontSize: 12, color: color, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _InlineAlert extends StatelessWidget {
  const _InlineAlert({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 10, fontWeight: FontWeight.w700)),
    );
  }
}

class _AlertBadge extends StatelessWidget {
  const _AlertBadge({
    required this.count,
    required this.color,
    required this.label,
  });

  final int count;
  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Text('$count $label',
          style: TextStyle(
              color: color, fontSize: 11, fontWeight: FontWeight.w700)),
    );
  }
}

class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.pets_outlined, size: 56, color: AppColors.pigColor),
          SizedBox(height: AppSpacing.md),
          Text('No sows registered', style: TextStyle(color: Colors.grey)),
          SizedBox(height: AppSpacing.sm),
          Text('Tap + to add your first sow',
              style: TextStyle(fontSize: 13, color: Colors.grey)),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Text('Failed to load sows:\n$message',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.error)),
      ),
    );
  }
}

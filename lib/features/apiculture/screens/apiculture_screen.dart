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
import '../models/apiculture.dart';
import '../providers/apiculture_providers.dart';

class ApicultureScreen extends ConsumerWidget {
  const ApicultureScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hivesAsync = ref.watch(hivesProvider);
    final apiariesAsync = ref.watch(apiariesProvider);

    final varroaAlerts = hivesAsync.whenOrNull(
          data: (h) => h.where((x) => x.isVarroaAlert).length,
        ) ??
        0;

    final totalApiaries = apiariesAsync.whenOrNull(data: (a) => a.length) ?? 0;
    final totalHives =
        hivesAsync.whenOrNull(data: (h) => h.length) ?? 0;

    return FarmScaffold(
      drawer: const FarmDrawer(),
      appBar: FarmAppBar(
        title: 'Apiary Management',
        subtitle: totalHives > 0
            ? '$totalApiaries apiaries · $totalHives hives'
            : null,
        actions: varroaAlerts > 0
            ? [
                Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: _AlertBadge(
                      count: varroaAlerts,
                      color: Colors.red,
                      label: 'Varroa'),
                )
              ]
            : null,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {},
        backgroundColor: AppColors.beesColor,
        foregroundColor: Colors.black87,
        icon: const Icon(Icons.add),
        label: const Text('Add Hive'),
      ),
      body: hivesAsync.when(
        loading: () => LoadingShimmer.list(count: 6),
        error: (e, _) => _ErrorView(message: e.toString()),
        data: (hives) => hives.isEmpty
            ? const _EmptyView()
            : ListView.separated(
                padding: const EdgeInsets.all(AppSpacing.md),
                itemCount: hives.length,
                separatorBuilder: (_, _) =>
                    const SizedBox(height: AppSpacing.sm),
                itemBuilder: (_, i) => _HiveCard(hive: hives[i]),
              ),
      ),
    );
  }
}

// ── Hive Card ─────────────────────────────────────────────────────────────────

class _HiveCard extends StatelessWidget {
  const _HiveCard({required this.hive});

  final Hive hive;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
      elevation: 1,
      child: InkWell(
        borderRadius: AppRadius.card,
        onTap: () => context.push(AppRoutes.hiveDetailPath(hive.id)),
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
                      color: AppColors.beesColorContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.hive_outlined,
                        color: AppColors.beesColor, size: 22),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Hive ${hive.hiveNumber}',
                            style: theme.textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w600)),
                        Text(
                            '${hive.hiveType} · ${hive.beeSubspecies}',
                            style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant)),
                      ],
                    ),
                  ),
                  _QueenStatusChip(status: hive.queenStatus ?? 'unknown'),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),

              // ── Colony strength bar ───────────────────────────────────────
              _ColonyStrengthBar(score: hive.colonyStrengthScore ?? 0),
              const SizedBox(height: AppSpacing.sm),

              // ── Varroa / overdue row ──────────────────────────────────────
              Row(
                children: [
                  if (hive.varroaInfestationRatePct != null) ...[
                    Icon(
                      Icons.pest_control_outlined,
                      size: 14,
                      color: hive.isVarroaAlert ? Colors.red : Colors.green,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      'Varroa ${hive.varroaInfestationRatePct!.toStringAsFixed(1)}%',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color:
                              hive.isVarroaAlert ? Colors.red : Colors.green),
                    ),
                    const SizedBox(width: AppSpacing.md),
                  ],
                  if (hive.inspectionOverdue == true)
                    const Row(
                      children: [
                        Icon(Icons.schedule, size: 14, color: Colors.orange),
                        SizedBox(width: 3),
                        Text('Inspection overdue',
                            style: TextStyle(
                                fontSize: 12,
                                color: Colors.orange,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  const Spacer(),
                  Text('${hive.honeyStoresFrames ?? 0} honey frames',
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

class _ColonyStrengthBar extends StatelessWidget {
  const _ColonyStrengthBar({required this.score});

  final int score; // 1–10

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pct = (score.clamp(0, 10) / 10).toDouble();
    final color = pct >= 0.7
        ? Colors.green
        : pct >= 0.4
            ? Colors.orange
            : Colors.red;

    return Row(
      children: [
        Text('Strength $score/10',
            style: theme.textTheme.labelSmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 6,
              backgroundColor: theme.colorScheme.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
      ],
    );
  }
}

class _QueenStatusChip extends StatelessWidget {
  const _QueenStatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final isAlert = status.toLowerCase().contains('miss') ||
        status.toLowerCase().contains('dead') ||
        status.toLowerCase().contains('poor');
    final color = isAlert ? Colors.red : Colors.green;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.circle, size: 8, color: color),
          const SizedBox(width: 3),
          Text(status,
              style: TextStyle(
                  color: color, fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
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
          Icon(Icons.hive_outlined, size: 56, color: AppColors.beesColor),
          SizedBox(height: AppSpacing.md),
          Text('No hives registered', style: TextStyle(color: Colors.grey)),
          SizedBox(height: AppSpacing.sm),
          Text('Tap + to add your first hive',
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
        child: Text('Failed to load hives:\n$message',
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.error)),
      ),
    );
  }
}

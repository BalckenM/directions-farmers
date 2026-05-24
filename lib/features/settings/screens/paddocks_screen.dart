import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../providers/settings_providers.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/farm_app_bar.dart';
import '../../../shared/widgets/farm_scaffold.dart';
import '../../../shared/widgets/loading_shimmer.dart';
import '../models/paddock.dart';

// ── Provider ──────────────────────────────────────────────────────────────────

final paddocksProvider =
    FutureProvider.autoDispose<List<Paddock>>((ref) =>
        ref.watch(settingsRepositoryProvider).getPaddocks());

// ── Screen ────────────────────────────────────────────────────────────────────

class PaddocksScreen extends ConsumerWidget {
  const PaddocksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncValue = ref.watch(paddocksProvider);

    return FarmScaffold(
      appBar: const FarmAppBar(
        title: 'Paddocks & Camps',
        subtitle: 'Grazing management',
      ),
      body: asyncValue.when(
        loading: () => LoadingShimmer.list(count: 5),
        error: (e, _) => ErrorState(
          message: e.toString(),
          onRetry: () => ref.invalidate(paddocksProvider),
        ),
        data: (paddocks) {
          if (paddocks.isEmpty) {
            return const EmptyState(
              title: 'No paddocks configured',
              subtitle: 'Add paddock information in your farm setup.',
              icon: Icon(Icons.map_outlined),
            );
          }
          return _PaddockList(paddocks: paddocks);
        },
      ),
    );
  }
}

// ── Summary bar ───────────────────────────────────────────────────────────────

class _SummaryBar extends StatelessWidget {
  const _SummaryBar({required this.paddocks});
  final List<Paddock> paddocks;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final occupied = paddocks.where((p) => p.isOccupied).length;
    final resting = paddocks.where((p) => p.isResting).length;
    final totalHa = paddocks.fold(0.0, (s, p) => s + p.areaHa);
    final totalAnimals =
        paddocks.fold(0, (s, p) => s + p.currentAnimalCount);

    return Container(
      margin: const EdgeInsets.all(AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: AppRadius.card,
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(children: [
        _StatPill(label: 'Total area', value: '${totalHa.toStringAsFixed(0)} ha'),
        const _Div(),
        _StatPill(label: 'Animals', value: '$totalAnimals head'),
        const _Div(),
        _StatPill(label: 'Occupied', value: '$occupied'),
        const _Div(),
        _StatPill(label: 'Resting', value: '$resting'),
      ]),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({required this.label, required this.value});
  final String label, value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(value,
              style: Theme.of(context)
                  .textTheme
                  .titleSmall!
                  .copyWith(fontWeight: FontWeight.bold)),
          Text(label, style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }
}

class _Div extends StatelessWidget {
  const _Div();
  @override
  Widget build(BuildContext context) => SizedBox(
      height: 32,
      child: VerticalDivider(
          color: Theme.of(context).colorScheme.outlineVariant));
}

// ── Paddock list ──────────────────────────────────────────────────────────────

class _PaddockList extends StatelessWidget {
  const _PaddockList({required this.paddocks});
  final List<Paddock> paddocks;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        _SummaryBar(paddocks: paddocks),
        for (final p in paddocks) _PaddockCard(paddock: p),
      ],
    );
  }
}

class _PaddockCard extends StatelessWidget {
  const _PaddockCard({required this.paddock});
  final Paddock paddock;

  Color get _statusColor => switch (paddock.status) {
        'occupied' => const Color(0xFF2E7D32),
        'resting' => const Color(0xFFE65100),
        _ => const Color(0xFF607D8B),
      };

  String get _statusLabel => switch (paddock.status) {
        'occupied' => 'Occupied',
        'resting' => 'Resting',
        _ => 'Empty',
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.card,
        side: BorderSide(
            color: paddock.isOccupied
                ? _statusColor.withAlpha(102)
                : cs.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(paddock.name,
                          style: theme.textTheme.titleSmall!
                              .copyWith(fontWeight: FontWeight.bold)),
                      Text('Camp ${paddock.campNumber} • ${paddock.areaHa.toStringAsFixed(1)} ha',
                          style: theme.textTheme.bodySmall),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm, vertical: 4),
                  decoration: BoxDecoration(
                    color: _statusColor.withAlpha(31),
                    borderRadius: AppRadius.chip,
                  ),
                  child: Text(_statusLabel,
                      style: theme.textTheme.labelSmall!
                          .copyWith(color: _statusColor, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            if (paddock.currentGroupName != null) ...[
              const SizedBox(height: AppSpacing.sm),
              Row(children: [
                const Icon(Icons.groups_rounded, size: 16),
                const SizedBox(width: 4),
                Text(paddock.currentGroupName!,
                    style: theme.textTheme.bodySmall),
                Text('  ·  ${paddock.currentAnimalCount} head',
                    style: theme.textTheme.bodySmall),
              ]),
            ],
            const SizedBox(height: AppSpacing.xs),
            Row(children: [
              const Icon(Icons.water_drop_outlined, size: 14),
              const SizedBox(width: 4),
              Expanded(
                  child: Text(paddock.waterSource,
                      style: theme.textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis)),
            ]),
            const SizedBox(height: AppSpacing.xs),
            Row(children: [
              const Icon(Icons.grass_outlined, size: 14),
              const SizedBox(width: 4),
              Expanded(
                  child: Text(paddock.forageType,
                      style: theme.textTheme.bodySmall,
                      overflow: TextOverflow.ellipsis)),
            ]),
            if (paddock.isResting && paddock.restPeriodDays > 0) ...[
              const SizedBox(height: AppSpacing.xs),
              Row(children: [
                Icon(Icons.timer_outlined, size: 14, color: _statusColor),
                const SizedBox(width: 4),
                Text('${paddock.restPeriodDays} days resting',
                    style: theme.textTheme.bodySmall!
                        .copyWith(color: _statusColor)),
              ]),
            ],
            if (paddock.gpsLat != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Row(children: [
                Icon(Icons.location_on_outlined,
                    size: 14, color: cs.onSurfaceVariant),
                const SizedBox(width: 4),
                Text(
                    '${paddock.gpsLat!.toStringAsFixed(4)}, ${paddock.gpsLng!.toStringAsFixed(4)}',
                    style: theme.textTheme.bodySmall!
                        .copyWith(color: cs.onSurfaceVariant)),
              ]),
            ],
          ],
        ),
      ),
    );
  }
}

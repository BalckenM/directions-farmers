import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../providers/record_providers.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/farm_app_bar.dart';
import '../../../shared/widgets/farm_scaffold.dart';
import '../../../shared/widgets/loading_shimmer.dart';
import '../models/feed_log.dart';

// ── Provider ──────────────────────────────────────────────────────────────────

final feedLogsProvider =
    FutureProvider.autoDispose<List<FeedLog>>((ref) async {
  final logs = await ref.watch(recordRepositoryProvider).getFeedLogs();
  return logs..sort((a, b) => b.date.compareTo(a.date));
});

// ── Screen ────────────────────────────────────────────────────────────────────

class FeedLogScreen extends ConsumerWidget {
  const FeedLogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncValue = ref.watch(feedLogsProvider);

    return FarmScaffold(
      appBar: const FarmAppBar(
        title: 'Feed Log',
        subtitle: 'Daily feed records',
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.addRecordFeed),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Log Feed'),
      ),
      body: asyncValue.when(
        loading: () => LoadingShimmer.list(count: 5),
        error: (e, _) => ErrorState(
          message: e.toString(),
          onRetry: () => ref.invalidate(feedLogsProvider),
        ),
        data: (logs) {
          if (logs.isEmpty) {
            return const EmptyState(
              title: 'No feed logs yet',
              subtitle: 'Tap + to record your first daily feed entry.',
              icon: Icon(Icons.grass_outlined),
            );
          }
          return _FeedLogList(logs: logs);
        },
      ),
    );
  }
}

// ── List ──────────────────────────────────────────────────────────────────────

class _FeedLogList extends StatelessWidget {
  const _FeedLogList({required this.logs});

  final List<FeedLog> logs;

  Map<String, List<FeedLog>> get _grouped {
    final map = <String, List<FeedLog>>{};
    for (final log in logs) {
      final parsed = DateTime.tryParse(log.date);
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final yesterday = today.subtract(const Duration(days: 1));
      final String key;
      if (parsed != null) {
        final d = DateTime(parsed.year, parsed.month, parsed.day);
        if (d == today) {
          key = 'Today';
        } else if (d == yesterday) {
          key = 'Yesterday';
        } else {
          key = DateFormat('EEEE, d MMMM yyyy').format(parsed);
        }
      } else {
        key = log.date;
      }
      map.putIfAbsent(key, () => []).add(log);
    }
    return map;
  }

  @override
  Widget build(BuildContext context) {
    final groups = _grouped;
    return ListView(
      padding: const EdgeInsets.only(bottom: 100),
      children: [
        for (final entry in groups.entries) ...[
          _DateHeader(label: entry.key),
          for (final log in entry.value) _FeedLogTile(log: log),
        ],
      ],
    );
  }
}

class _DateHeader extends StatelessWidget {
  const _DateHeader({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.xs),
      child: Text(label,
          style: Theme.of(context)
              .textTheme
              .titleSmall!
              .copyWith(fontWeight: FontWeight.bold)),
    );
  }
}

class _FeedLogTile extends StatelessWidget {
  const _FeedLogTile({required this.log});

  final FeedLog log;

  Color _speciesColor() {
    return switch (log.species) {
      'cattle' => const Color(0xFF795548),
      'sheep' => const Color(0xFF607D8B),
      'goats' => const Color(0xFF8D6E63),
      'poultry' => const Color(0xFFFF8F00),
      'pigs' => const Color(0xFFE91E63),
      _ => const Color(0xFF2E7D32),
    };
  }

  String _speciesLabel() {
    return switch (log.species) {
      'cattle' => '🐄',
      'sheep' => '🐑',
      'goats' => '🐐',
      'poultry' => '🐔',
      'pigs' => '🐷',
      _ => '🌿',
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final fmt =
        NumberFormat.currency(locale: 'en_ZA', symbol: 'R', decimalDigits: 0);
    final color = _speciesColor();

    return Card(
      margin: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.card,
        side: BorderSide(color: cs.outlineVariant),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md, vertical: AppSpacing.xs),
        leading: CircleAvatar(
          backgroundColor: color.withAlpha(31),
          child: Text(_speciesLabel(), style: const TextStyle(fontSize: 20)),
        ),
        title: Text(log.feedType,
            style: theme.textTheme.bodyMedium!
                .copyWith(fontWeight: FontWeight.w600),
            maxLines: 1,
            overflow: TextOverflow.ellipsis),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${log.groupName} • ${log.animalCount} animals',
                style: theme.textTheme.bodySmall),
            Row(children: [
              Text('${log.quantityKg.toStringAsFixed(0)} kg',
                  style: theme.textTheme.bodySmall),
              if (log.costZar > 0) ...[
                const Text('  ·  '),
                Text(fmt.format(log.costZar),
                    style: theme.textTheme.bodySmall),
              ],
            ]),
          ],
        ),
        trailing: log.costZar > 0
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(fmt.format(log.costPerAnimalZar),
                      style: theme.textTheme.labelSmall),
                  Text('/animal',
                      style: theme.textTheme.labelSmall!
                          .copyWith(color: cs.onSurfaceVariant)),
                ],
              )
            : null,
        isThreeLine: true,
      ),
    );
  }
}


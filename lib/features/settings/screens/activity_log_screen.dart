import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/farm_app_bar.dart';
import '../../../shared/widgets/farm_scaffold.dart';
import '../../../shared/widgets/loading_shimmer.dart';
import '../models/activity_entry.dart';
import '../providers/settings_providers.dart';

// ── Provider ──────────────────────────────────────────────────────────────────

final activityLogProvider =
    FutureProvider.autoDispose<List<ActivityEntry>>((ref) =>
        ref.watch(settingsRepositoryProvider).getActivityLog());

// ── Screen ────────────────────────────────────────────────────────────────────

class ActivityLogScreen extends ConsumerWidget {
  const ActivityLogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncValue = ref.watch(activityLogProvider);

    return FarmScaffold(
      appBar: const FarmAppBar(
        title: 'Activity Log',
        subtitle: 'Farm-wide audit trail',
      ),
      body: asyncValue.when(
        loading: () => const LoadingShimmer(),
        error: (e, _) => ErrorState(
          message: 'Failed to load activity log',
          onRetry: () => ref.invalidate(activityLogProvider),
        ),
        data: (entries) {
          if (entries.isEmpty) {
            return const EmptyState(
              icon: Icon(Icons.history_rounded, size: 48, color: AppColors.primary),
              title: 'No activity yet',
              subtitle: 'Actions performed on your farm will appear here.',
            );
          }

          // Group by date label
          final Map<String, List<ActivityEntry>> grouped = {};
          for (final entry in entries) {
            final label = _formatDate(entry.createdAt);
            grouped.putIfAbsent(label, () => []).add(entry);
          }

          return ListView(
            padding: const EdgeInsets.all(AppSpacing.md),
            children: [
              for (final dateLabel in grouped.keys) ...[
                Padding(
                  padding: const EdgeInsets.only(
                    bottom: AppSpacing.sm,
                    top: AppSpacing.xs,
                  ),
                  child: Text(
                    dateLabel,
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                        ),
                  ),
                ),
                ...grouped[dateLabel]!.map((e) => _ActivityTile(entry: e)),
                const SizedBox(height: AppSpacing.sm),
              ],
            ],
          );
        },
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────────────────────────

IconData _resourceIcon(String resource) {
  if (resource.contains('animal') || resource.contains('cattle') || resource.contains('goat')) {
    return Icons.pets_rounded;
  }
  if (resource.contains('payroll') || resource.contains('staff')) {
    return Icons.payments_rounded;
  }
  if (resource.contains('crop') || resource.contains('field')) {
    return Icons.grass_rounded;
  }
  if (resource.contains('paddock') || resource.contains('setting')) {
    return Icons.settings_rounded;
  }
  if (resource.contains('poultry') || resource.contains('flock')) {
    return Icons.egg_rounded;
  }
  return Icons.history_rounded;
}

Color _resourceColor(String resource) {
  if (resource.contains('animal') || resource.contains('cattle') || resource.contains('goat')) {
    return AppColors.primary;
  }
  if (resource.contains('payroll') || resource.contains('staff')) {
    return AppColors.secondary;
  }
  if (resource.contains('crop') || resource.contains('field')) {
    return const Color(0xFF33691E);
  }
  if (resource.contains('poultry') || resource.contains('flock')) {
    return AppColors.warning;
  }
  return AppColors.info;
}

String _formatDate(DateTime dt) {
  final now = DateTime.now();
  final diff = now.difference(dt);
  if (diff.inDays == 0) return 'Today';
  if (diff.inDays == 1) return 'Yesterday';
  return '${dt.day} ${_monthName(dt.month)} ${dt.year}';
}

String _formatTime(DateTime dt) {
  final h = dt.hour.toString().padLeft(2, '0');
  final m = dt.minute.toString().padLeft(2, '0');
  return '$h:$m';
}

String _monthName(int month) => const [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ][month];

// ── Activity tile ─────────────────────────────────────────────────────────────

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({required this.entry});
  final ActivityEntry entry;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final color = _resourceColor(entry.resource);

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: AppRadius.card,
        boxShadow: AppShadows.level1,
        border: Border.all(color: cs.outlineVariant),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: color.withAlpha(18),
            borderRadius: AppRadius.button,
          ),
          child: Icon(_resourceIcon(entry.resource), color: color, size: 20),
        ),
        title: Text(
          entry.action,
          style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(entry.resource, style: tt.bodySmall),
            const SizedBox(height: 2),
            Text(
              _formatTime(entry.createdAt),
              style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
            ),
          ],
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          decoration: BoxDecoration(
            color: color.withAlpha(18),
            borderRadius: AppRadius.chip,
          ),
          child: Text(
            entry.resource.split('/').first,
            style: tt.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 9,
            ),
          ),
        ),
        isThreeLine: true,
      ),
    );
  }
}

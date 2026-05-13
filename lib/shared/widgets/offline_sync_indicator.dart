import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/utils/connectivity_service.dart';

// ── Mock sync queue providers ─────────────────────────────────────────────────
// Replace with a real Drift-backed provider once offline architecture is built.

/// Number of records pending sync to RMIS / Supabase.
class PendingSyncCountNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void set(int count) => state = count;
  void increment() => state++;
  void decrement() => state = (state - 1).clamp(0, 9999);
}

final pendingSyncCountProvider =
    NotifierProvider<PendingSyncCountNotifier, int>(
        PendingSyncCountNotifier.new);

/// Last successful sync timestamp. Null means never synced.
class LastSyncedAtNotifier extends Notifier<DateTime?> {
  @override
  DateTime? build() => null;

  void setNow() => state = DateTime.now();
  void reset() => state = null;
}

final lastSyncedAtProvider =
    NotifierProvider<LastSyncedAtNotifier, DateTime?>(
        LastSyncedAtNotifier.new);

// ── Widget ────────────────────────────────────────────────────────────────────

/// A compact app-bar chip that shows pending sync count and last sync time.
/// Tapping it opens a bottom sheet with a breakdown of pending records.
///
/// Per design_system.md §12: "When RMIS or API sync is pending, show a
/// persistent subtle chip: [⟳ 3 pending syncs]"
class OfflineSyncIndicator extends ConsumerWidget {
  const OfflineSyncIndicator({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pending = ref.watch(pendingSyncCountProvider);
    final isOnline = ref.watch(isOnlineProvider);
    final lastSynced = ref.watch(lastSyncedAtProvider);

    if (pending == 0 && isOnline) {
      // Nothing to show when fully synced and online
      return const SizedBox.shrink();
    }

    final color = pending > 0
        ? (isOnline ? AppColors.warning : AppColors.error)
        : AppColors.success;

    return GestureDetector(
      onTap: () => _showSyncSheet(context, ref, pending, isOnline, lastSynced),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          color: color.withAlpha(24),
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(color: color.withAlpha(80), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _SyncIcon(isOnline: isOnline, pending: pending, color: color),
            const SizedBox(width: 4),
            Text(
              pending > 0 ? '$pending pending' : 'Synced',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: color,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSyncSheet(
    BuildContext context,
    WidgetRef ref,
    int pending,
    bool isOnline,
    DateTime? lastSynced,
  ) {
    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => _SyncQueueSheet(
        pending: pending,
        isOnline: isOnline,
        lastSynced: lastSynced,
      ),
    );
  }
}

// ── Animated sync icon ────────────────────────────────────────────────────────

class _SyncIcon extends StatefulWidget {
  const _SyncIcon({
    required this.isOnline,
    required this.pending,
    required this.color,
  });

  final bool isOnline;
  final int pending;
  final Color color;

  @override
  State<_SyncIcon> createState() => _SyncIconState();
}

class _SyncIconState extends State<_SyncIcon>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    if (widget.pending > 0 && widget.isOnline) {
      _ctrl.repeat();
    }
  }

  @override
  void didUpdateWidget(_SyncIcon old) {
    super.didUpdateWidget(old);
    if (widget.pending > 0 && widget.isOnline) {
      if (!_ctrl.isAnimating) _ctrl.repeat();
    } else {
      _ctrl.stop();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RotationTransition(
      turns: _ctrl,
      child: Icon(Icons.sync_rounded, size: 13, color: widget.color),
    );
  }
}

// ── Bottom sheet ──────────────────────────────────────────────────────────────

class _SyncQueueSheet extends StatelessWidget {
  const _SyncQueueSheet({
    required this.pending,
    required this.isOnline,
    required this.lastSynced,
  });

  final int pending;
  final bool isOnline;
  final DateTime? lastSynced;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    // Mock breakdown — replace with real queue counts from Drift
    final breakdown = <_QueueItem>[
      _QueueItem(
          icon: Icons.pets_rounded,
          label: 'Animal movements',
          count: (pending * 0.5).ceil(),
          color: const Color(0xFF795548)),
      _QueueItem(
          icon: Icons.health_and_safety_rounded,
          label: 'Health events',
          count: (pending * 0.3).ceil(),
          color: AppColors.error),
      _QueueItem(
          icon: Icons.monitor_weight_rounded,
          label: 'Weight records',
          count: (pending * 0.2).ceil(),
          color: AppColors.tertiary),
    ];

    String lastSyncLabel;
    if (lastSynced == null) {
      lastSyncLabel = 'Never synced';
    } else {
      final diff = DateTime.now().difference(lastSynced!);
      if (diff.inMinutes < 1) {
        lastSyncLabel = 'Last synced: just now';
      } else if (diff.inHours < 1) {
        lastSyncLabel = 'Last synced: ${diff.inMinutes}m ago';
      } else if (diff.inDays < 1) {
        lastSyncLabel = 'Last synced: ${diff.inHours}h ago';
      } else {
        lastSyncLabel = 'Last synced: ${diff.inDays}d ago';
      }
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.md, AppSpacing.sm, AppSpacing.md, AppSpacing.xl),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: AppSpacing.md),
              decoration: BoxDecoration(
                color: cs.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          // Title row
          Row(
            children: [
              Icon(Icons.cloud_sync_rounded,
                  size: 22, color: AppColors.primary),
              const SizedBox(width: AppSpacing.sm),
              Text('Sync Queue',
                  style: tt.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w700)),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm, vertical: 3),
                decoration: BoxDecoration(
                  color: isOnline
                      ? AppColors.successContainer
                      : AppColors.errorContainer,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  isOnline ? 'Online' : 'Offline',
                  style: tt.labelSmall?.copyWith(
                    color: isOnline ? AppColors.success : AppColors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(lastSyncLabel,
              style: tt.bodySmall
                  ?.copyWith(color: cs.onSurfaceVariant)),
          const SizedBox(height: AppSpacing.md),
          const Divider(),
          const SizedBox(height: AppSpacing.sm),
          if (pending == 0)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.cloud_done_rounded,
                        size: 40, color: AppColors.success),
                    const SizedBox(height: AppSpacing.sm),
                    Text('All records synced',
                        style: tt.bodyMedium?.copyWith(
                            color: cs.onSurfaceVariant)),
                  ],
                ),
              ),
            )
          else
            ...breakdown
                .where((item) => item.count > 0)
                .map((item) => _QueueRow(item: item)),
          if (pending > 0) ...[
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.all(AppSpacing.sm),
              decoration: BoxDecoration(
                color: cs.surfaceContainerLow,
                borderRadius: AppRadius.card,
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline_rounded,
                      size: 16, color: cs.onSurfaceVariant),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      isOnline
                          ? 'Records will sync automatically in the background.'
                          : 'Records are queued and will sync when connectivity is restored.',
                      style: tt.bodySmall
                          ?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _QueueItem {
  const _QueueItem({
    required this.icon,
    required this.label,
    required this.count,
    required this.color,
  });
  final IconData icon;
  final String label;
  final int count;
  final Color color;
}

class _QueueRow extends StatelessWidget {
  const _QueueRow({required this.item});
  final _QueueItem item;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: item.color.withAlpha(20),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Icon(item.icon, size: 16, color: item.color),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(item.label, style: tt.bodyMedium),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm, vertical: 3),
            decoration: BoxDecoration(
              color: item.color.withAlpha(20),
              borderRadius: BorderRadius.circular(AppRadius.full),
            ),
            child: Text(
              '${item.count}',
              style: tt.labelSmall?.copyWith(
                color: item.color,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

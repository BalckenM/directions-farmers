import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/farm_app_bar.dart';
import '../../../shared/widgets/farm_scaffold.dart';
import '../../../shared/widgets/primary_button.dart';

// ── Mock data ─────────────────────────────────────────────────────────────────

class _BackupEntry {
  final String label;
  final String size;
  final DateTime timestamp;
  final bool successful;

  const _BackupEntry({
    required this.label,
    required this.size,
    required this.timestamp,
    required this.successful,
  });
}

final _now = DateTime.now();

final _backupHistory = [
  _BackupEntry(
    label: 'Auto backup',
    size: '2.3 MB',
    timestamp: _now.subtract(const Duration(hours: 6)),
    successful: true,
  ),
  _BackupEntry(
    label: 'Manual backup',
    size: '2.1 MB',
    timestamp: _now.subtract(const Duration(days: 1)),
    successful: true,
  ),
  _BackupEntry(
    label: 'Auto backup',
    size: '2.0 MB',
    timestamp: _now.subtract(const Duration(days: 2)),
    successful: true,
  ),
  _BackupEntry(
    label: 'Auto backup',
    size: '—',
    timestamp: _now.subtract(const Duration(days: 3, hours: 2)),
    successful: false,
  ),
];

String _formatDateTime(DateTime dt) {
  final h = dt.hour.toString().padLeft(2, '0');
  final m = dt.minute.toString().padLeft(2, '0');
  final d = dt.day.toString().padLeft(2, '0');
  final mo = dt.month.toString().padLeft(2, '0');
  return '$d/$mo/${dt.year} $h:$m';
}

// ── State ─────────────────────────────────────────────────────────────────────

class _SyncState {
  final bool isSyncing;
  final bool autoBackup;
  final bool wifiOnly;
  final DateTime? lastSync;

  const _SyncState({
    this.isSyncing = false,
    this.autoBackup = true,
    this.wifiOnly = true,
    this.lastSync,
  });

  _SyncState copyWith({
    bool? isSyncing,
    bool? autoBackup,
    bool? wifiOnly,
    DateTime? lastSync,
  }) =>
      _SyncState(
        isSyncing: isSyncing ?? this.isSyncing,
        autoBackup: autoBackup ?? this.autoBackup,
        wifiOnly: wifiOnly ?? this.wifiOnly,
        lastSync: lastSync ?? this.lastSync,
      );
}

class _SyncNotifier extends Notifier<_SyncState> {
  @override
  _SyncState build() =>
      _SyncState(lastSync: _now.subtract(const Duration(hours: 6)));

  Future<void> syncNow() async {
    state = state.copyWith(isSyncing: true);
    await Future.delayed(const Duration(seconds: 2));
    state = state.copyWith(isSyncing: false, lastSync: DateTime.now());
  }

  void toggleAutoBackup() =>
      state = state.copyWith(autoBackup: !state.autoBackup);

  void toggleWifiOnly() =>
      state = state.copyWith(wifiOnly: !state.wifiOnly);
}

final _syncProvider =
    NotifierProvider<_SyncNotifier, _SyncState>(
        _SyncNotifier.new);

// ── Screen ────────────────────────────────────────────────────────────────────

class SyncBackupScreen extends ConsumerWidget {
  const SyncBackupScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(_syncProvider);
    final notifier = ref.read(_syncProvider.notifier);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return FarmScaffold(
      appBar: const FarmAppBar(
        title: 'Sync & Backup',
        subtitle: 'Data protection and cloud sync',
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.pagePaddingHorizontal,
          AppSpacing.md,
          AppSpacing.pagePaddingHorizontal,
          AppSpacing.xxl + 32,
        ),
        children: [
          // Status card
          Container(
            decoration: BoxDecoration(
              color: AppColors.primary.withAlpha(18),
              borderRadius: AppRadius.card,
              border: Border.all(
                  color: AppColors.primary.withAlpha(60)),
            ),
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withAlpha(40),
                    shape: BoxShape.circle,
                  ),
                  child: state.isSyncing
                      ? Padding(
                          padding: const EdgeInsets.all(12),
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primary,
                          ),
                        )
                      : const Icon(Icons.cloud_done_rounded,
                          color: AppColors.primary, size: 26),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        state.isSyncing ? 'Syncing…' : 'Data up to date',
                        style: tt.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary),
                      ),
                      Text(
                        state.lastSync != null
                            ? 'Last sync: ${_formatDateTime(state.lastSync!)}'
                            : 'Never synced',
                        style: tt.bodySmall?.copyWith(
                            color: AppColors.primary.withAlpha(180)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          // Sync settings
          Container(
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: AppRadius.card,
              boxShadow: AppShadows.level1,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(children: [
                    const Icon(Icons.settings_rounded,
                        size: 18, color: AppColors.primary),
                    const SizedBox(width: AppSpacing.sm),
                    Text('Sync Settings',
                        style: tt.titleSmall
                            ?.copyWith(fontWeight: FontWeight.w600)),
                  ]),
                ),
                const Divider(height: 1),
                SwitchListTile(
                  secondary: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.primary.withAlpha(20),
                      borderRadius:
                          BorderRadius.circular(AppRadius.sm),
                    ),
                    child: const Icon(Icons.backup_rounded,
                        color: AppColors.primary, size: 18),
                  ),
                  title: const Text('Auto Backup'),
                  subtitle: const Text('Backup data automatically every 24h'),
                  value: state.autoBackup,
                  onChanged: (_) => notifier.toggleAutoBackup(),
                  activeThumbColor: AppColors.primary,
                ),
                const Divider(height: 1, indent: 68),
                SwitchListTile(
                  secondary: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.info.withAlpha(20),
                      borderRadius:
                          BorderRadius.circular(AppRadius.sm),
                    ),
                    child: const Icon(Icons.wifi_rounded,
                        color: AppColors.info, size: 18),
                  ),
                  title: const Text('Wi-Fi Only'),
                  subtitle:
                      const Text('Sync only when connected to Wi-Fi'),
                  value: state.wifiOnly,
                  onChanged: (_) => notifier.toggleWifiOnly(),
                  activeThumbColor: AppColors.primary,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          // Storage usage
          Container(
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: AppRadius.card,
              boxShadow: AppShadows.level1,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(children: [
                    const Icon(Icons.storage_rounded,
                        size: 18, color: AppColors.primary),
                    const SizedBox(width: AppSpacing.sm),
                    Text('Storage',
                        style: tt.titleSmall
                            ?.copyWith(fontWeight: FontWeight.w600)),
                  ]),
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    children: [
                      _StorageRow(
                          label: 'Livestock data',
                          size: '1.2 MB',
                          color: AppColors.primary),
                      const SizedBox(height: AppSpacing.sm),
                      _StorageRow(
                          label: 'Payroll records',
                          size: '0.6 MB',
                          color: AppColors.secondary),
                      const SizedBox(height: AppSpacing.sm),
                      _StorageRow(
                          label: 'Financial records',
                          size: '0.3 MB',
                          color: AppColors.success),
                      const SizedBox(height: AppSpacing.sm),
                      _StorageRow(
                          label: 'Crop data',
                          size: '0.2 MB',
                          color: const Color(0xFF33691E)),
                      const SizedBox(height: AppSpacing.md),
                      const Divider(),
                      const SizedBox(height: AppSpacing.sm),
                      Row(children: [
                        Text('Total',
                            style: tt.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700)),
                        const Spacer(),
                        Text('2.3 MB',
                            style: tt.titleSmall?.copyWith(
                                fontWeight: FontWeight.w700,
                                color: AppColors.primary)),
                      ]),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          // Backup history
          Container(
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: AppRadius.card,
              boxShadow: AppShadows.level1,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(children: [
                    const Icon(Icons.history_rounded,
                        size: 18, color: AppColors.primary),
                    const SizedBox(width: AppSpacing.sm),
                    Text('Backup History',
                        style: tt.titleSmall
                            ?.copyWith(fontWeight: FontWeight.w600)),
                  ]),
                ),
                const Divider(height: 1),
                ..._backupHistory.map(
                  (b) => _BackupRow(entry: b),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          PrimaryButton(
            label: state.isSyncing ? 'Syncing…' : 'Sync Now',
            onPressed:
                state.isSyncing ? null : () => notifier.syncNow(),
            icon: const Icon(Icons.sync_rounded),
            isLoading: state.isSyncing,
            isExpanded: true,
          ),
        ],
      ),
    );
  }
}

// ── Sub-widgets ───────────────────────────────────────────────────────────────

class _StorageRow extends StatelessWidget {
  const _StorageRow(
      {required this.label, required this.size, required this.color});
  final String label;
  final String size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
            child: Text(label,
                style: tt.bodySmall)),
        Text(size,
            style: tt.bodySmall
                ?.copyWith(fontWeight: FontWeight.w600)),
      ],
    );
  }
}

class _BackupRow extends StatelessWidget {
  const _BackupRow({required this.entry});
  final _BackupEntry entry;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final color =
        entry.successful ? AppColors.success : AppColors.error;
    final icon = entry.successful
        ? Icons.check_circle_outline_rounded
        : Icons.error_outline_rounded;

    return ListTile(
      leading: Icon(icon, color: color, size: 22),
      title: Text(entry.label),
      subtitle: Text(_formatDateTime(entry.timestamp)),
      trailing: Text(
        entry.size,
        style: tt.bodySmall?.copyWith(
            color: cs.onSurfaceVariant, fontWeight: FontWeight.w600),
      ),
      dense: true,
    );
  }
}

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/farm_app_bar.dart';
import '../../../shared/widgets/farm_scaffold.dart';

class SyncBackupScreen extends StatelessWidget {
  const SyncBackupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return FarmScaffold(
      appBar: const FarmAppBar(
        title: 'Sync & Backup',
        subtitle: 'Cloud data management',
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.pagePaddingHorizontal),
        children: [
          const SizedBox(height: AppSpacing.lg),
          Icon(Icons.cloud_done_rounded, size: 64, color: AppColors.success),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Your data is secure',
            textAlign: TextAlign.center,
            style: tt.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'All your farm data is automatically synced to our secure cloud servers in real-time. '
            'No manual backups are required.',
            textAlign: TextAlign.center,
            style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: AppSpacing.xl),
          _InfoTile(
            icon: Icons.sync_rounded,
            title: 'Real-time sync',
            subtitle: 'Every change is saved to the cloud instantly.',
          ),
          const SizedBox(height: AppSpacing.sm),
          _InfoTile(
            icon: Icons.shield_rounded,
            title: 'Encrypted storage',
            subtitle: 'Your data is encrypted at rest and in transit.',
          ),
          const SizedBox(height: AppSpacing.sm),
          _InfoTile(
            icon: Icons.devices_rounded,
            title: 'Multi-device access',
            subtitle: 'Sign in from any device to access your data.',
          ),
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  final IconData icon;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: AppRadius.card,
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppColors.success.withAlpha(18),
              borderRadius: AppRadius.button,
            ),
            child: Icon(icon, color: AppColors.success, size: 20),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w600)),
                Text(subtitle, style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

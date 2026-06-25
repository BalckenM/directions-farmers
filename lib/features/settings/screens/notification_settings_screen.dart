import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mobile_app/core/theme/app_colors.dart';
import 'package:mobile_app/core/theme/app_radius.dart';
import 'package:mobile_app/core/theme/app_shadows.dart';
import 'package:mobile_app/core/theme/app_spacing.dart';
import 'package:mobile_app/shared/widgets/farm_app_bar.dart';
import 'package:mobile_app/shared/widgets/farm_scaffold.dart';
import 'package:mobile_app/shared/widgets/primary_button.dart';
import 'package:mobile_app/features/settings/providers/settings_ui_providers.dart';

// ── Screen ────────────────────────────────────────────────────────────────────

class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(notificationSettingsProvider);
    final notifier = ref.read(notificationSettingsProvider.notifier);
    final cs = Theme.of(context).colorScheme;

    Future<void> save() async {
      // State is already persisted in the provider; just confirm and pop.
      await Future.delayed(const Duration(milliseconds: 300));
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Notification preferences saved'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.success,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
        ),
      );
      Navigator.of(context).pop();
    }

    return FarmScaffold(
      appBar: const FarmAppBar(
        title: 'Notifications',
        subtitle: 'Alerts and reminders',
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.pagePaddingHorizontal,
          AppSpacing.md,
          AppSpacing.pagePaddingHorizontal,
          AppSpacing.xxl + 32,
        ),
        children: [
          _SectionCard(
            title: 'Livestock Alerts',
            icon: Icons.health_and_safety_rounded,
            cs: cs,
            children: [
              _NotifTile(
                icon: Icons.medical_services_rounded,
                iconColor: AppColors.error,
                label: 'Health Alerts',
                subtitle: 'Sick animals, treatment due',
                value: state.healthAlerts,
                onChanged: (_) => notifier.toggle('healthAlerts'),
              ),
              _NotifTile(
                icon: Icons.favorite_rounded,
                iconColor: AppColors.primary,
                label: 'Breeding Reminders',
                subtitle: 'Heat cycles, pregnancy milestones',
                value: state.breedingReminders,
                onChanged: (_) => notifier.toggle('breedingReminders'),
              ),
              _NotifTile(
                icon: Icons.monitor_weight_outlined,
                iconColor: AppColors.secondary,
                label: 'Weight Recording Due',
                subtitle: 'Animals due for weigh-in',
                value: state.weightDue,
                onChanged: (_) => notifier.toggle('weightDue'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          _SectionCard(
            title: 'Production',
            icon: Icons.water_drop_rounded,
            cs: cs,
            children: [
              _NotifTile(
                icon: Icons.trending_down_rounded,
                iconColor: AppColors.warning,
                label: 'Production Alerts',
                subtitle: 'Drops in milk or egg yield',
                value: state.productionAlerts,
                onChanged: (_) => notifier.toggle('productionAlerts'),
              ),
              _NotifTile(
                icon: Icons.summarize_rounded,
                iconColor: AppColors.info,
                label: 'Daily Digest',
                subtitle: 'Morning farm summary',
                value: state.dailyDigest,
                onChanged: (_) => notifier.toggle('dailyDigest'),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          PrimaryButton(
            label: 'Save Preferences',
            onPressed: save,
            icon: const Icon(Icons.save_rounded),
            isExpanded: true,
          ),
        ],
      ),
    );
  }
}

// ── Private widgets ───────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  const _SectionCard({
    required this.title,
    required this.icon,
    required this.children,
    required this.cs,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;
  final ColorScheme cs;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Container(
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
            child: Row(
              children: [
                Icon(icon, size: 18, color: AppColors.primary),
                const SizedBox(width: AppSpacing.sm),
                Text(title,
                    style: tt.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const Divider(height: 1),
          ...children,
        ],
      ),
    );
  }
}

class _NotifTile extends StatelessWidget {
  const _NotifTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return SwitchListTile(
      secondary: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: iconColor.withAlpha(20),
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Icon(icon, color: iconColor, size: 18),
      ),
      title: Text(label),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
      activeThumbColor: AppColors.primary,
    );
  }
}


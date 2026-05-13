import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/farm_app_bar.dart';
import '../../../shared/widgets/farm_scaffold.dart';
import '../../../shared/widgets/primary_button.dart';

// ── State ─────────────────────────────────────────────────────────────────────

class _NotifState {
  final bool healthAlerts;
  final bool breedingReminders;
  final bool weightDue;
  final bool productionAlerts;
  final bool dailyDigest;

  const _NotifState({
    this.healthAlerts = true,
    this.breedingReminders = true,
    this.weightDue = false,
    this.productionAlerts = true,
    this.dailyDigest = false,
  });

  _NotifState copyWith({
    bool? healthAlerts,
    bool? breedingReminders,
    bool? weightDue,
    bool? productionAlerts,
    bool? dailyDigest,
  }) =>
      _NotifState(
        healthAlerts: healthAlerts ?? this.healthAlerts,
        breedingReminders: breedingReminders ?? this.breedingReminders,
        weightDue: weightDue ?? this.weightDue,
        productionAlerts: productionAlerts ?? this.productionAlerts,
        dailyDigest: dailyDigest ?? this.dailyDigest,
      );
}

// ── Screen ────────────────────────────────────────────────────────────────────

class NotificationSettingsScreen extends ConsumerStatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  ConsumerState<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends ConsumerState<NotificationSettingsScreen> {
  _NotifState _state = const _NotifState();
  bool _submitting = false;

  Future<void> _save() async {
    setState(() => _submitting = true);
    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;
    setState(() => _submitting = false);
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

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

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
                value: _state.healthAlerts,
                onChanged: (v) =>
                    setState(() => _state = _state.copyWith(healthAlerts: v)),
              ),
              _NotifTile(
                icon: Icons.favorite_rounded,
                iconColor: AppColors.primary,
                label: 'Breeding Reminders',
                subtitle: 'Heat cycles, pregnancy milestones',
                value: _state.breedingReminders,
                onChanged: (v) => setState(
                    () => _state = _state.copyWith(breedingReminders: v)),
              ),
              _NotifTile(
                icon: Icons.monitor_weight_outlined,
                iconColor: AppColors.secondary,
                label: 'Weight Recording Due',
                subtitle: 'Animals due for weigh-in',
                value: _state.weightDue,
                onChanged: (v) =>
                    setState(() => _state = _state.copyWith(weightDue: v)),
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
                value: _state.productionAlerts,
                onChanged: (v) => setState(
                    () => _state = _state.copyWith(productionAlerts: v)),
              ),
              _NotifTile(
                icon: Icons.summarize_rounded,
                iconColor: AppColors.info,
                label: 'Daily Digest',
                subtitle: 'Morning farm summary',
                value: _state.dailyDigest,
                onChanged: (v) =>
                    setState(() => _state = _state.copyWith(dailyDigest: v)),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          PrimaryButton(
            label: 'Save Preferences',
            onPressed: _save,
            icon: const Icon(Icons.save_rounded),
            isLoading: _submitting,
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

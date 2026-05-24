import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/confirm_dialog.dart';
import '../../../shared/widgets/farm_app_bar.dart';
import '../../../shared/widgets/farm_scaffold.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/profile_image_provider.dart';
import 'upgrade_plan_sheet.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FarmScaffold(
      appBar: const FarmAppBar(
        title: 'Farm',
        subtitle: 'Manage your farm profile & settings',
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          // 1. Farm profile header
          const _FarmProfileHeader(),
          const SizedBox(height: AppSpacing.md),

          // 2. Quick action buttons
          const _QuickActionsRow(),
          const SizedBox(height: AppSpacing.lg),

          // 3. Settings sections
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.pagePaddingHorizontal,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _SettingsSection(
                  title: 'Farm Management',
                  items: [
                    _SettingsTile(
                      icon: Icons.agriculture_rounded,
                      iconColor: AppColors.primary,
                      label: 'Farm Profile',
                      subtitle: 'Name, location, and details',
                      onTap: () => context.push(AppRoutes.settingsFarm),
                    ),
                    _SettingsTile(
                      icon: Icons.landscape_rounded,
                      iconColor: AppColors.success,
                      label: 'Paddocks & Locations',
                      subtitle: 'Manage farm zones and fields',
                      onTap: () => context.push(AppRoutes.settingsPaddocks),
                    ),
                    _SettingsTile(
                      icon: Icons.biotech_rounded,
                      iconColor: AppColors.tertiary,
                      label: 'Breed Registry',
                      subtitle: 'Registered breeds and standards',
                      onTap: () => context.push(AppRoutes.settingsBreedRegistry),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                _SettingsSection(
                  title: 'Team & Access',
                  items: [
                    _SettingsTile(
                      icon: Icons.group_rounded,
                      iconColor: AppColors.secondary,
                      label: 'Users & Roles',
                      subtitle: 'Manage farm team access',
                      onTap: () => context.push(AppRoutes.settingsUsersRoles),
                    ),
                    _SettingsTile(
                      icon: Icons.history_rounded,
                      iconColor: AppColors.tertiary,
                      label: 'Activity Log',
                      subtitle: 'Audit trail of all actions',
                      onTap: () => context.push(AppRoutes.settingsActivityLog),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                _SettingsSection(
                  title: 'Preferences',
                  items: [
                    _SettingsTile(
                      icon: Icons.notifications_rounded,
                      iconColor: AppColors.warning,
                      label: 'Notifications',
                      subtitle: 'Alerts and reminders',
                      onTap: () =>
                          context.push(AppRoutes.settingsNotifications),
                    ),
                    _SettingsTile(
                      icon: Icons.straighten_rounded,
                      iconColor: AppColors.info,
                      label: 'Units & Measurements',
                      subtitle: 'Metric or imperial',
                      onTap: () => context.push(AppRoutes.settingsUnits),
                    ),
                    _SettingsTile(
                      icon: Icons.palette_rounded,
                      iconColor: AppColors.primary,
                      label: 'Appearance',
                      subtitle: 'Theme and display options',
                      onTap: () => context.push(AppRoutes.settingsTheme),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                _SettingsSection(
                  title: 'Data & Compliance',
                  items: [
                    _SettingsTile(
                      icon: Icons.cloud_upload_rounded,
                      iconColor: AppColors.tertiary,
                      label: 'Sync & Backup',
                      subtitle: 'Cloud data management',
                      onTap: () => context.push(AppRoutes.settingsSyncBackup),
                    ),
                    _SettingsTile(
                      icon: Icons.download_rounded,
                      iconColor: AppColors.success,
                      label: 'Export Data',
                      subtitle: 'CSV / PDF reports',
                      onTap: () => context.push(AppRoutes.settingsExportData),
                    ),
                    _SettingsTile(
                      icon: Icons.verified_user_rounded,
                      iconColor: AppColors.info,
                      label: 'Regulatory Reports',
                      subtitle: 'Compliance documentation',
                      onTap: () => context.push(AppRoutes.settingsRegulatoryReports),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                _SettingsSection(
                  title: 'App',
                  items: [
                    _SettingsTile(
                      icon: Icons.help_outline_rounded,
                      iconColor: AppColors.tertiary,
                      label: 'Help & Support',
                      subtitle: 'Documentation and contact',
                      onTap: () => context.push(AppRoutes.settingsHelp),
                    ),
                    _SettingsTile(
                      icon: Icons.info_outline_rounded,
                      iconColor: AppColors.onSurfaceVariant,
                      label: 'App Version',
                      subtitle: '1.0.0 (build 1)',
                      onTap: () {},
                    ),
                    _SettingsTile(
                      icon: Icons.privacy_tip_rounded,
                      iconColor: AppColors.onSurfaceVariant,
                      label: 'Privacy Policy',
                      onTap: () => showDialog<void>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Privacy Policy'),
                          content: const SingleChildScrollView(
                            child: Text(
                              '4Directions Farm Manager collects only the data you enter directly into the app, '
                              'including farm details, livestock records, payroll information, and financial data. '
                              'This data is stored securely on your device and optionally backed up to encrypted cloud storage. '
                              'We do not sell or share your personal information with third parties. '
                              'You may request deletion of your data at any time by contacting support@4directions.co.za. '
                              'Compliance with South Africa\'s POPIA (Protection of Personal Information Act) is our priority.',
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(),
                              child: const Text('Close'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    _SettingsTile(
                      icon: Icons.description_rounded,
                      iconColor: AppColors.onSurfaceVariant,
                      label: 'Terms of Service',
                      onTap: () => showDialog<void>(
                        context: context,
                        builder: (ctx) => AlertDialog(
                          title: const Text('Terms of Service'),
                          content: const SingleChildScrollView(
                            child: Text(
                              'By using 4Directions Farm Manager you agree to use the app solely for lawful farm '
                              'management purposes. The app is provided as-is without warranty of any kind. '
                              '4Directions is not liable for any loss of data or business arising from use of the app. '
                              'You are responsible for maintaining the confidentiality of your account credentials. '
                              'Payroll calculations are provided as a guide only — consult a registered payroll '
                              'practitioner or accountant to confirm statutory obligations.',
                            ),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(),
                              child: const Text('Close'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                _SettingsSection(
                  title: 'Account',
                  items: [
                    _SettingsTile(
                      icon: Icons.logout_rounded,
                      iconColor: AppColors.error,
                      label: 'Sign Out',
                      subtitle: 'Sign out of 4Directions',
                      onTap: () async {
                        final confirmed = await ConfirmDialog.show(
                          context: context,
                          title: 'Sign Out',
                          message:
                              'Are you sure you want to sign out of your account?',
                          confirmLabel: 'Sign Out',
                          isDestructive: true,
                        );
                        if (confirmed == true) {
                          ref.read(authProvider.notifier).logOut();
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          ),
        ],
      ),
    );
  }

}

// ── Farm profile header ───────────────────────────────────────────────────────

class _FarmProfileHeader extends ConsumerStatefulWidget {
  const _FarmProfileHeader();

  @override
  ConsumerState<_FarmProfileHeader> createState() => _FarmProfileHeaderState();
}

class _FarmProfileHeaderState extends ConsumerState<_FarmProfileHeader> {
  final _picker = ImagePicker();

  Future<void> _pickImage() async {
    final choice = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_rounded),
              title: const Text('Take photo'),
              onTap: () => Navigator.of(context).pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded),
              title: const Text('Choose from gallery'),
              onTap: () => Navigator.of(context).pop(ImageSource.gallery),
            ),
            if (ref.read(profileImageProvider) != null)
              ListTile(
                leading: const Icon(Icons.delete_rounded, color: Colors.red),
                title: const Text('Remove photo',
                    style: TextStyle(color: Colors.red)),
                onTap: () {
                  Navigator.of(context).pop();
                  ref.read(profileImageProvider.notifier).clearImage();
                },
              ),
          ],
        ),
      ),
    );
    if (choice == null) return;
    final file = await _picker.pickImage(
      source: choice,
      imageQuality: 80,
      maxWidth: 512,
    );
    if (file != null) {
      ref.read(profileImageProvider.notifier).setImage(file.path);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final user = ref.watch(currentUserProvider);
    final imagePath = ref.watch(profileImageProvider);

    final farmName = user?.farmName ?? 'Your Farm';
    final location = (user != null && user.province.isNotEmpty)
        ? '${user.province}, ${user.country}'
        : 'Location not set';

    return Container(
      margin: const EdgeInsets.all(AppSpacing.pagePaddingHorizontal),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withAlpha(22),
            AppColors.primary.withAlpha(8),
          ],
        ),
        borderRadius: AppRadius.card,
        border: Border.all(color: AppColors.primary.withAlpha(45), width: 1),
        boxShadow: AppShadows.level1,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar + name row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── tappable avatar ───────────────────────────────────────────
              GestureDetector(
                onTap: _pickImage,
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 32,
                      backgroundColor: AppColors.primary.withAlpha(20),
                      backgroundImage: imagePath != null
                          ? FileImage(File(imagePath))
                          : null,
                      child: imagePath == null
                          ? const Icon(
                              Icons.agriculture_rounded,
                              color: AppColors.primary,
                              size: 30,
                            )
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                          border: Border.all(
                              color: cs.surface, width: 2),
                        ),
                        child: const Icon(
                          Icons.camera_alt_rounded,
                          size: 12,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      farmName,
                      style: tt.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      location,
                      style: tt.bodySmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 6),
                    _ProBadge(),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),
          Divider(color: AppColors.primary.withAlpha(25), height: 1),
          const SizedBox(height: AppSpacing.md),

          // Stats strip
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _StatPill(
                icon: Icons.pets_rounded,
                value: '346',
                label: 'Animals',
              ),
              Container(width: 1, height: 32, color: cs.outlineVariant),
              _StatPill(
                icon: Icons.group_rounded,
                value: '8',
                label: 'Team',
              ),
              Container(width: 1, height: 32, color: cs.outlineVariant),
              _StatPill(
                icon: Icons.landscape_rounded,
                value: '3',
                label: 'Paddocks',
              ),
              Container(width: 1, height: 32, color: cs.outlineVariant),
              _StatPill(
                icon: Icons.calendar_today_rounded,
                value: '2019',
                label: 'Est.',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.secondary.withAlpha(20),
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(color: AppColors.secondary.withAlpha(80)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.star_rounded,
              color: AppColors.secondary, size: 12),
          const SizedBox(width: 3),
          Text(
            'Pro Plan',
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.secondary,
                  fontWeight: FontWeight.w700,
                  fontSize: 10,
                ),
          ),
        ],
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({
    required this.icon,
    required this.value,
    required this.label,
  });
  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColors.primary, size: 16),
        const SizedBox(height: 4),
        Text(
          value,
          style: tt.titleSmall?.copyWith(
            fontWeight: FontWeight.w800,
            color: AppColors.primary,
            height: 1,
          ),
        ),
        Text(
          label,
          style: tt.labelSmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 9,
          ),
        ),
      ],
    );
  }
}

// ── Quick actions row ─────────────────────────────────────────────────────────

class _QuickActionsRow extends StatelessWidget {
  const _QuickActionsRow();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.pagePaddingHorizontal,
      ),
      child: Row(
        children: [
          Expanded(
            child: _QuickBtn(
              icon: Icons.edit_rounded,
              label: 'Edit Profile',
              onTap: () => context.push(AppRoutes.settingsFarm),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: _QuickBtn(
              icon: Icons.group_add_rounded,
              label: 'Manage Team',
              onTap: () => context.push(AppRoutes.settingsAccount),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: _QuickBtn(
              icon: Icons.star_rounded,
              label: 'Upgrade',
              accent: AppColors.secondary,
              onTap: () => showUpgradePlanSheet(context),
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickBtn extends StatelessWidget {
  const _QuickBtn({
    required this.icon,
    required this.label,
    required this.onTap,
    this.accent,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final color = accent ?? AppColors.primary;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: AppRadius.card,
        child: Container(
          padding:
              const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
          decoration: BoxDecoration(
            color: color.withAlpha(14),
            borderRadius: AppRadius.card,
            border: Border.all(color: color.withAlpha(50), width: 1),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(height: 4),
              Text(
                label,
                style: tt.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w700,
                  fontSize: 10,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Settings section ──────────────────────────────────────────────────────────

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.title, required this.items});
  final String title;
  final List<_SettingsTile> items;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: AppSpacing.xs, bottom: 6),
          child: Text(
            title.toUpperCase(),
            style: tt.labelSmall?.copyWith(
              color: cs.onSurfaceVariant,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: AppRadius.card,
            boxShadow: AppShadows.level1,
            border: Border.all(color: cs.outlineVariant, width: 1),
          ),
          child: Material(
            color: cs.surface,
            borderRadius: AppRadius.card,
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
              for (int i = 0; i < items.length; i++) ...[
                items[i],
                if (i < items.length - 1)
                  Divider(
                    height: 1,
                    indent: AppSpacing.pagePaddingHorizontal + 40 + AppSpacing.md,
                    color: cs.outlineVariant,
                  ),
              ],
            ],
            ),
          ),
        ),
      ],
    );
  }
}

// ── Settings tile ─────────────────────────────────────────────────────────────

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.label,
    this.iconColor,
    this.subtitle,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final Color? iconColor;
  final String? subtitle;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final color = iconColor ?? AppColors.primary;

    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color.withAlpha(18),
          borderRadius: AppRadius.button,
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(label),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.chevron_right_rounded,
            color: cs.onSurfaceVariant,
            size: 20,
          ),
        ],
      ),
      onTap: onTap,
    );
  }
}

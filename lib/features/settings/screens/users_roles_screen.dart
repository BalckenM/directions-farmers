import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/user_role.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../features/auth/models/auth_user.dart';
import '../../../features/auth/providers/auth_provider.dart';
import '../../../shared/widgets/farm_app_bar.dart';
import '../../../shared/widgets/farm_scaffold.dart';

class UsersRolesScreen extends ConsumerWidget {
  const UsersRolesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final currentRole = ref.watch(userRoleProvider);
    final teamMembers = ref.watch(teamMembersProvider);

    return FarmScaffold(
      appBar: const FarmAppBar(title: 'Team & Roles'),
      floatingActionButton: currentRole.canManageSettings
          ? FloatingActionButton.extended(
              onPressed: () => _showInviteSheet(context, ref),
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.onPrimary,
              icon: const Icon(Icons.person_add_rounded),
              label: const Text('Invite Member'),
            )
          : null,
      body: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.md,
        ),
        children: [
          // ── Current user role card ─────────────────────────────────────
          _RoleHeroCard(user: currentUser, role: currentRole),
          const SizedBox(height: AppSpacing.lg),

          // ── Permissions summary ────────────────────────────────────────
          _SectionHeader(
            icon: Icons.verified_user_rounded,
            label: 'Your Permissions',
          ),
          const SizedBox(height: AppSpacing.sm),
          _PermissionsGrid(role: currentRole),
          const SizedBox(height: AppSpacing.lg),

          // ── Farm team ──────────────────────────────────────────────────
          if (currentUser != null) ...[
            _SectionHeader(
              icon: Icons.group_rounded,
              label: 'Farm Team',
              trailing: Text(
                '${teamMembers.length} member${teamMembers.length == 1 ? '' : 's'}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            if (teamMembers.isEmpty)
              _EmptyTeamCard(isOwner: currentUser.isOwner)
            else
              ...teamMembers.map(
                (m) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: _TeamMemberCard(
                    member: m,
                    canManage: currentRole.canManageSettings,
                    onChangeRole: currentRole.canManageSettings
                        ? () => _showRoleSheet(context, ref, m)
                        : null,
                    onRevoke: currentRole.canManageSettings
                        ? () => _confirmRevoke(context, m)
                        : null,
                  ),
                ),
              ),
          ],

          // bottom padding so FAB doesn't overlap last card
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }

  void _showInviteSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _InviteMemberSheet(),
    );
  }

  void _showRoleSheet(BuildContext context, WidgetRef ref, AuthUser member) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _ChangeRoleSheet(member: member),
    );
  }

  void _confirmRevoke(BuildContext context, AuthUser member) {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Revoke Access'),
        content: Text(
          '${member.fullName} will no longer be able to sign in. '
          'You can re-invite them at any time.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('${member.fullName} removed from farm team.'),
                  backgroundColor: AppColors.error,
                ),
              );
            },
            child: const Text('Revoke'),
          ),
        ],
      ),
    );
  }
}

// ── Role hero card ──────────────────────────────────────────────────────────

class _RoleHeroCard extends StatelessWidget {
  const _RoleHeroCard({required this.user, required this.role});

  final AuthUser? user;
  final UserRole role;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tt = theme.textTheme;
    final roleColor = _roleColor(role);
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            roleColor,
            roleColor.withAlpha(200),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: AppRadius.card,
        boxShadow: AppShadows.level3,
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          CircleAvatar(
            radius: 30,
            backgroundColor: Colors.white.withAlpha(50),
            child: Text(
              user != null
                  ? '${user!.firstName[0]}${user!.lastName[0]}'.toUpperCase()
                  : '?',
              style: tt.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          // Name + role
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user?.fullName ?? 'Unknown',
                  style: tt.titleMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                if (user?.jobTitle != null)
                  Text(
                    user!.jobTitle!,
                    style: tt.bodySmall
                        ?.copyWith(color: Colors.white.withAlpha(210)),
                  ),
                const SizedBox(height: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(50),
                    borderRadius: AppRadius.chip,
                    border: Border.all(
                        color: Colors.white.withAlpha(80), width: 1),
                  ),
                  child: Text(
                    role.displayName,
                    style: tt.labelSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Farm name badge
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Icon(
                user?.isOwner ?? false
                    ? Icons.admin_panel_settings_rounded
                    : Icons.badge_rounded,
                color: Colors.white.withAlpha(200),
                size: 20,
              ),
              const SizedBox(height: 4),
              Text(
                user?.isOwner ?? false ? 'Owner' : 'Staff',
                style: tt.labelSmall?.copyWith(
                  color: Colors.white.withAlpha(200),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Permissions grid ────────────────────────────────────────────────────────

class _PermissionsGrid extends StatelessWidget {
  const _PermissionsGrid({required this.role});

  final UserRole role;

  @override
  Widget build(BuildContext context) {
    final perms = [
      (
        icon: Icons.add_circle_rounded,
        label: 'Add Flock',
        granted: role.canAddFlock
      ),
      (
        icon: Icons.swap_horiz_rounded,
        label: 'Batch Status',
        granted: role.canChangeBatchStatus
      ),
      (
        icon: Icons.attach_money_rounded,
        label: 'Financials',
        granted: role.canEditFinancials
      ),
      (
        icon: Icons.medical_services_rounded,
        label: 'Medication',
        granted: role.canAdministerMedication
      ),
      (
        icon: Icons.bar_chart_rounded,
        label: 'Reports',
        granted: role.canViewReports
      ),
      (
        icon: Icons.settings_rounded,
        label: 'Settings',
        granted: role.canManageSettings
      ),
    ];

    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: perms
          .map((p) => _PermChip(icon: p.icon, label: p.label, granted: p.granted))
          .toList(),
    );
  }
}

class _PermChip extends StatelessWidget {
  const _PermChip({
    required this.icon,
    required this.label,
    required this.granted,
  });

  final IconData icon;
  final String label;
  final bool granted;

  @override
  Widget build(BuildContext context) {
    final color = granted ? AppColors.primary : AppColors.error;
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: color.withAlpha(18),
        borderRadius: AppRadius.chip,
        border: Border.all(color: color.withAlpha(60), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Icon(
            granted ? Icons.check_circle_rounded : Icons.cancel_rounded,
            size: 14,
            color: color,
          ),
        ],
      ),
    );
  }
}

// ── Section header ──────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.icon,
    required this.label,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: AppSpacing.iconMd, color: AppColors.primary),
        const SizedBox(width: AppSpacing.sm),
        Text(
          label,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
        ),
        if (trailing != null) ...[
          const Spacer(),
          trailing!,
        ],
      ],
    );
  }
}

// ── Team member card ────────────────────────────────────────────────────────

class _TeamMemberCard extends StatelessWidget {
  const _TeamMemberCard({
    required this.member,
    required this.canManage,
    this.onChangeRole,
    this.onRevoke,
  });

  final AuthUser member;
  final bool canManage;
  final VoidCallback? onChangeRole;
  final VoidCallback? onRevoke;

  @override
  Widget build(BuildContext context) {
    final role = UserRoleX.fromString(member.role);
    final tt = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: AppRadius.card,
        boxShadow: AppShadows.level1,
        border: Border.all(
          color: AppColors.primary.withAlpha(20),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          // Avatar
          CircleAvatar(
            radius: 22,
            backgroundColor: _roleColor(role).withAlpha(40),
            child: Text(
              '${member.firstName[0]}${member.lastName[0]}'.toUpperCase(),
              style: tt.bodyMedium?.copyWith(
                color: _roleColor(role),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.fullName,
                  style: tt.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (member.jobTitle != null)
                  Text(
                    member.jobTitle!,
                    style: tt.bodySmall?.copyWith(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withAlpha(140),
                    ),
                  ),
                const SizedBox(height: AppSpacing.xs),
                _RoleBadge(role: role),
              ],
            ),
          ),
          // Actions
          if (canManage)
            PopupMenuButton<String>(
              icon: Icon(
                Icons.more_vert_rounded,
                color: Theme.of(context).colorScheme.onSurface.withAlpha(140),
              ),
              onSelected: (v) {
                if (v == 'role') onChangeRole?.call();
                if (v == 'revoke') onRevoke?.call();
              },
              itemBuilder: (_) => [
                const PopupMenuItem(
                  value: 'role',
                  child: Row(
                    children: [
                      Icon(Icons.manage_accounts_rounded, size: 18),
                      SizedBox(width: AppSpacing.sm),
                      Text('Change Role'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'revoke',
                  child: Row(
                    children: [
                      Icon(Icons.person_remove_rounded, size: 18,
                          color: AppColors.error),
                      SizedBox(width: AppSpacing.sm),
                      Text('Revoke Access',
                          style: TextStyle(color: AppColors.error)),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _RoleBadge extends StatelessWidget {
  const _RoleBadge({required this.role});

  final UserRole role;

  @override
  Widget build(BuildContext context) {
    final color = _roleColor(role);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(25),
        borderRadius: AppRadius.chip,
        border: Border.all(color: color.withAlpha(70), width: 1),
      ),
      child: Text(
        role.displayName,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

// ── Empty team card ─────────────────────────────────────────────────────────

class _EmptyTeamCard extends StatelessWidget {
  const _EmptyTeamCard({required this.isOwner});

  final bool isOwner;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: AppColors.primary.withAlpha(10),
        borderRadius: AppRadius.card,
        border: Border.all(
          color: AppColors.primary.withAlpha(30),
          width: 1.5,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.group_add_rounded,
            size: AppSpacing.iconXl,
            color: AppColors.primary.withAlpha(100),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'No team members yet',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            isOwner
                ? 'Tap "Invite Member" to add workers, managers, or vets.'
                : 'Ask the farm owner to add team members.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color:
                      Theme.of(context).colorScheme.onSurface.withAlpha(140),
                ),
          ),
        ],
      ),
    );
  }
}

// ── Invite member bottom sheet ──────────────────────────────────────────────

class _InviteMemberSheet extends StatefulWidget {
  const _InviteMemberSheet();

  @override
  State<_InviteMemberSheet> createState() => _InviteMemberSheetState();
}

class _InviteMemberSheetState extends State<_InviteMemberSheet> {
  final _firstNameCtrl = TextEditingController();
  final _lastNameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  UserRole _selectedRole = UserRole.farmWorker;

  @override
  void dispose() {
    _firstNameCtrl.dispose();
    _lastNameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final firstName = _firstNameCtrl.text.trim();
    final lastName = _lastNameCtrl.text.trim();
    final email = _emailCtrl.text.trim();
    if (firstName.isEmpty || lastName.isEmpty || email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields.')),
      );
      return;
    }
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Invitation sent to $email as ${_selectedRole.displayName}.'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppRadius.xl)),
      ),
      padding: EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.lg + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withAlpha(40),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Invite Team Member',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Row(
            children: [
              Expanded(
                child: _SheetField(
                  controller: _firstNameCtrl,
                  label: 'First Name',
                  icon: Icons.person_rounded,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _SheetField(
                  controller: _lastNameCtrl,
                  label: 'Last Name',
                  icon: Icons.person_outline_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          _SheetField(
            controller: _emailCtrl,
            label: 'Email Address',
            icon: Icons.email_rounded,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Role',
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.sm,
            children: UserRole.values.map((r) {
              final selected = _selectedRole == r;
              final color = _roleColor(r);
              return FilterChip(
                label: Text(r.displayName),
                selected: selected,
                onSelected: (_) => setState(() => _selectedRole = r),
                selectedColor: color.withAlpha(40),
                checkmarkColor: color,
                labelStyle: TextStyle(
                  color: selected ? color : null,
                  fontWeight:
                      selected ? FontWeight.w700 : FontWeight.normal,
                ),
                side: BorderSide(
                  color: selected ? color : AppColors.primary.withAlpha(40),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _submit,
              icon: const Icon(Icons.send_rounded),
              label: const Text('Send Invitation'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding:
                    const EdgeInsets.symmetric(vertical: AppSpacing.md),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SheetField extends StatelessWidget {
  const _SheetField({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: AppSpacing.iconMd),
        border: OutlineInputBorder(
          borderRadius: AppRadius.input,
        ),
        filled: true,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
      ),
    );
  }
}

// ── Change role bottom sheet ────────────────────────────────────────────────

class _ChangeRoleSheet extends StatefulWidget {
  const _ChangeRoleSheet({required this.member});

  final AuthUser member;

  @override
  State<_ChangeRoleSheet> createState() => _ChangeRoleSheetState();
}

class _ChangeRoleSheetState extends State<_ChangeRoleSheet> {
  late UserRole _selected;

  @override
  void initState() {
    super.initState();
    _selected = UserRoleX.fromString(widget.member.role);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppRadius.xl)),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurface.withAlpha(40),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            'Change Role — ${widget.member.fullName}',
            style: theme.textTheme.titleMedium
                ?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: AppSpacing.md),
          ...UserRole.values.map((r) {
            return RadioListTile<UserRole>(
              value: r,
              groupValue: _selected,
              onChanged: (v) => setState(() => _selected = v!),
              title: Text(r.displayName),
              subtitle: Text(_roleDesc(r)),
              activeColor: AppColors.primary,
              contentPadding: EdgeInsets.zero,
            );
          }),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: FilledButton(
                  onPressed: () {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '${widget.member.firstName}\'s role updated to '
                          '${_selected.displayName}.',
                        ),
                        backgroundColor: AppColors.primary,
                      ),
                    );
                  },
                  style: FilledButton.styleFrom(
                      backgroundColor: AppColors.primary),
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Helpers ─────────────────────────────────────────────────────────────────

Color _roleColor(UserRole role) => switch (role) {
      UserRole.superAdmin => const Color(0xFF1E3A5F),    // navy
      UserRole.farmManager => const Color(0xFF00695C),   // teal
      UserRole.farmWorker => const Color(0xFF2E7D32),    // green
      UserRole.veterinarian => const Color(0xFF6A1B9A),  // purple
    };

String _roleDesc(UserRole role) => switch (role) {
      UserRole.superAdmin =>
        'Full access to all modules, settings, and team management.',
      UserRole.farmManager =>
        'Can manage livestock, crops, financials, and view reports.',
      UserRole.farmWorker =>
        'Can record daily activities. Cannot access financials.',
      UserRole.veterinarian =>
        'Can administer medications and view health records.',
    };

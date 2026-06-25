import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:mobile_app/core/theme/app_colors.dart';
import 'package:mobile_app/core/theme/app_radius.dart';
import 'package:mobile_app/core/theme/app_shadows.dart';
import 'package:mobile_app/core/theme/app_spacing.dart';
import 'package:mobile_app/shared/widgets/farm_app_bar.dart';
import 'package:mobile_app/shared/widgets/farm_scaffold.dart';
import 'package:mobile_app/shared/widgets/farm_text_field.dart';
import 'package:mobile_app/shared/widgets/primary_button.dart';
import 'package:mobile_app/features/auth/providers/auth_provider.dart';
import 'package:mobile_app/features/settings/providers/settings_providers.dart';

class AccountSettingsScreen extends ConsumerStatefulWidget {
  const AccountSettingsScreen({super.key});

  @override
  ConsumerState<AccountSettingsScreen> createState() =>
      _AccountSettingsScreenState();
}

class _AccountSettingsScreenState extends ConsumerState<AccountSettingsScreen> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _roleCtrl = TextEditingController();
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(currentUserProvider);
    _nameCtrl.text = user?.fullName ?? '';
    _emailCtrl.text = user?.email ?? '';
    _roleCtrl.text = user?.jobTitle ??
        (user?.isOwner == true ? 'Farm Owner' : user?.role ?? '');
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _roleCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    setState(() => _submitting = true);
    try {
      final nameParts = _nameCtrl.text.trim().split(' ');
      final firstName = nameParts.first;
      final lastName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

      await ref.read(settingsRepositoryProvider).updateProfile({
        'firstName': firstName,
        'lastName': lastName,
      });
      ref.invalidate(authProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Account updated'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.success,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
        ),
      );
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save: $e'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.error,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return FarmScaffold(
      appBar: const FarmAppBar(
        title: 'Account',
        subtitle: 'Profile and access',
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.pagePaddingHorizontal,
          AppSpacing.md,
          AppSpacing.pagePaddingHorizontal,
          AppSpacing.xxl + 32,
        ),
        children: [
          // Avatar section
          Center(
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 44,
                  backgroundColor: AppColors.primary.withAlpha(20),
                  child: const Icon(Icons.person_rounded,
                      size: 44, color: AppColors.primary),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: cs.surface, width: 2),
                    ),
                    child: const Icon(Icons.camera_alt_rounded,
                        size: 14, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            decoration: BoxDecoration(
              color: cs.surface,
              borderRadius: AppRadius.card,
              boxShadow: AppShadows.level1,
            ),
            padding: const EdgeInsets.all(AppSpacing.md),
            child: Column(
              children: [
                FarmTextField(
                  controller: _nameCtrl,
                  label: 'Full Name',
                  hint: 'Your name',
                  prefixIcon: const Icon(Icons.person_rounded),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: AppSpacing.md),
                FarmTextField(
                  controller: _emailCtrl,
                  label: 'Email',
                  hint: 'you@example.com',
                  prefixIcon: const Icon(Icons.email_rounded),
                  textInputAction: TextInputAction.next,
                ),
                const SizedBox(height: AppSpacing.md),
                FarmTextField(
                  controller: _roleCtrl,
                  label: 'Role',
                  hint: 'Farm Owner / Worker',
                  prefixIcon: const Icon(Icons.badge_rounded),
                  textInputAction: TextInputAction.done,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          PrimaryButton(
            label: 'Save Changes',
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

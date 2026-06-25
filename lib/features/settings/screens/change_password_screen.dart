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
import 'package:mobile_app/features/settings/providers/settings_providers.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _submitting = true);
    try {
      await ref.read(settingsRepositoryProvider).changePassword(
            currentPassword: _currentCtrl.text,
            newPassword: _newCtrl.text,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Password changed successfully'),
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
          content: Text(e.toString()),
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
        title: 'Change Password',
        subtitle: 'Update your account password',
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pagePaddingHorizontal,
            AppSpacing.md,
            AppSpacing.pagePaddingHorizontal,
            AppSpacing.xxl + 32,
          ),
          children: [
            // Info banner
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.info.withValues(alpha: 0.08),
                borderRadius: AppRadius.card,
                border: Border.all(
                  color: AppColors.info.withValues(alpha: 0.25),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.lock_outline_rounded,
                    color: AppColors.info,
                    size: 20,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      'Use a strong password of at least 8 characters with a mix of letters, numbers, and symbols.',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.info,
                        height: 1.4,
                      ),
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
                    controller: _currentCtrl,
                    label: 'Current Password',
                    hint: 'Enter your current password',
                    prefixIcon: const Icon(Icons.lock_rounded),
                    obscureText: true,
                    textInputAction: TextInputAction.next,
                    validator: (v) {
                      if (v == null || v.isEmpty) {
                        return 'Current password is required';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const Divider(height: 1),
                  const SizedBox(height: AppSpacing.md),
                  FarmTextField(
                    controller: _newCtrl,
                    label: 'New Password',
                    hint: 'At least 8 characters',
                    prefixIcon: const Icon(Icons.lock_open_rounded),
                    obscureText: true,
                    textInputAction: TextInputAction.next,
                    validator: (v) {
                      if (v == null || v.length < 8) {
                        return 'Password must be at least 8 characters';
                      }
                      if (v == _currentCtrl.text) {
                        return 'New password must differ from current password';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  FarmTextField(
                    controller: _confirmCtrl,
                    label: 'Confirm New Password',
                    hint: 'Re-enter new password',
                    prefixIcon: const Icon(Icons.lock_reset_rounded),
                    obscureText: true,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _submit(),
                    validator: (v) {
                      if (v != _newCtrl.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            PrimaryButton(
              label: 'Update Password',
              onPressed: _submit,
              icon: const Icon(Icons.check_rounded),
              isLoading: _submitting,
              isExpanded: true,
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../../core/constants/livestock_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';

/// Full-screen overlay prompt shown when a notifiable disease is recorded.
///
/// Displays the disease name, required immediate actions, and DAFF emergency
/// contact. Requires the user to actively confirm before dismissing.
///
/// Usage:
/// ```dart
/// NotifiableDiseasePrompt.show(
///   context,
///   diseaseKey: 'fmd',
///   onConfirm: () { /* mark as reported */ },
/// );
/// ```
class NotifiableDiseasePrompt extends StatelessWidget {
  const NotifiableDiseasePrompt({
    super.key,
    required this.diseaseKey,
    this.onConfirm,
    this.onDismiss,
  });

  final String diseaseKey;
  final VoidCallback? onConfirm;
  final VoidCallback? onDismiss;

  /// Shows the prompt as a bottom sheet / full-screen dialog.
  static Future<void> show(
    BuildContext context, {
    required String diseaseKey,
    VoidCallback? onConfirm,
    VoidCallback? onDismiss,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      isDismissible: false,
      enableDrag: false,
      builder: (_) => NotifiableDiseasePrompt(
        diseaseKey: diseaseKey,
        onConfirm: onConfirm ?? () => Navigator.of(context).pop(),
        onDismiss: onDismiss ?? () => Navigator.of(context).pop(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label =
        LivestockConstants.notifiableDiseaseLabels[diseaseKey] ?? diseaseKey;
    final action =
        LivestockConstants.notifiableDiseaseActions[diseaseKey] ??
            'Contact DAFF and your state vet immediately.';

    return SafeArea(
      child: Container(
        margin: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          0,
          AppSpacing.md,
          AppSpacing.md,
        ),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: AppRadius.dialog,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Container(
              decoration: BoxDecoration(
                color: AppColors.error,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppRadius.lg),
                ),
              ),
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.white,
                    size: 28,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'NOTIFIABLE DISEASE',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: Colors.white70,
                            letterSpacing: 1,
                          ),
                        ),
                        Text(
                          label,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Body
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Legal notice
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.errorContainer,
                      borderRadius: AppRadius.card,
                    ),
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    child: Text(
                      'Reporting notifiable diseases to the State Vet and DAFF is '
                      'legally required under the Animal Diseases Act 35 of 1984.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: AppColors.error,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // Required actions
                  Text(
                    'Required Actions',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    action,
                    style: theme.textTheme.bodyMedium,
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // DAFF contact card
                  _ContactCard(
                    icon: Icons.phone_outlined,
                    label: 'DAFF Emergency Hotline',
                    value: LivestockConstants.daffEmergencyNumber,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  _ContactCard(
                    icon: Icons.local_hospital_outlined,
                    label: 'Your State Vet',
                    value: 'Contact provincial DAFF office',
                  ),

                  const SizedBox(height: AppSpacing.md),

                  // RMIS note
                  Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        size: 14,
                        color: AppColors.secondary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'Record your DAFF incident reference number after reporting.',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppColors.secondary,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: AppSpacing.lg),

                  // Action buttons
                  FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor: AppColors.error,
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.button,
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      onConfirm?.call();
                    },
                    icon: const Icon(Icons.check, color: Colors.white),
                    label: const Text(
                      'I understand — I will report to DAFF',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(44),
                      shape: RoundedRectangleBorder(
                        borderRadius: AppRadius.button,
                      ),
                    ),
                    onPressed: () {
                      Navigator.of(context).pop();
                      onDismiss?.call();
                    },
                    child: const Text('Dismiss'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactCard extends StatelessWidget {
  const _ContactCard({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: AppRadius.card,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: AppSpacing.xs,
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),
          const SizedBox(width: AppSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.outline,
                ),
              ),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

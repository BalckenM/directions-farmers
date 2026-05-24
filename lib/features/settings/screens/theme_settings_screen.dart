import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/theme_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/farm_app_bar.dart';
import '../../../shared/widgets/farm_scaffold.dart';
import '../../../shared/widgets/primary_button.dart';
import '../providers/settings_ui_providers.dart';

// ── Screen ────────────────────────────────────────────────────────────────────────────────────────

class ThemeSettingsScreen extends ConsumerWidget {
  const ThemeSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedMode = ref.watch(themeModeProvider);
    final selectedAccent = ref.watch(accentProvider);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return FarmScaffold(
      appBar: const FarmAppBar(
        title: 'Appearance',
        subtitle: 'Theme and display',
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.pagePaddingHorizontal,
          AppSpacing.md,
          AppSpacing.pagePaddingHorizontal,
          AppSpacing.xxl + 32,
        ),
        children: [
          // Theme mode section
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
                  child: Row(
                    children: [
                      const Icon(
                        Icons.brightness_6_rounded,
                        size: 18,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'Theme Mode',
                        style: tt.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: SegmentedButton<ThemeMode>(
                    segments: const [
                      ButtonSegment(
                        value: ThemeMode.system,
                        icon: Icon(Icons.brightness_auto_rounded),
                        label: Text('Auto'),
                      ),
                      ButtonSegment(
                        value: ThemeMode.light,
                        icon: Icon(Icons.light_mode_rounded),
                        label: Text('Light'),
                      ),
                      ButtonSegment(
                        value: ThemeMode.dark,
                        icon: Icon(Icons.dark_mode_rounded),
                        label: Text('Dark'),
                      ),
                    ],
                    selected: {selectedMode},
                    onSelectionChanged: (v) {
                      ref.read(themeModeProvider.notifier).set(v.first);
                    },
                    style: SegmentedButton.styleFrom(
                      selectedBackgroundColor: cs.primaryContainer,
                      selectedForegroundColor: cs.onPrimaryContainer,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          // Accent colour section
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
                  child: Row(
                    children: [
                      const Icon(
                        Icons.palette_rounded,
                        size: 18,
                        color: AppColors.primary,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text(
                        'Accent Colour',
                        style: tt.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Wrap(
                    spacing: AppSpacing.md,
                    runSpacing: AppSpacing.sm,
                    children: [
                      for (int i = 0; i < accentOptions.length; i++)
                        GestureDetector(
                          onTap: () => ref.read(accentProvider.notifier).set(i),
                          child: Column(
                            children: [
                              Container(
                                width: 52,
                                height: 52,
                                decoration: BoxDecoration(
                                  color: accentOptions[i].color,
                                  shape: BoxShape.circle,
                                  border: selectedAccent == i
                                      ? Border.all(
                                          color: cs.onSurface,
                                          width: 3,
                                        )
                                      : null,
                                ),
                                child: selectedAccent == i
                                    ? const Icon(
                                        Icons.check_rounded,
                                        color: Colors.white,
                                        size: 24,
                                      )
                                    : null,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                accentOptions[i].label,
                                style: tt.labelSmall,
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          PrimaryButton(
            label: 'Apply',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: const Text('Theme applied'),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: AppColors.success,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                ),
              );
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.check_rounded),
            isExpanded: true,
          ),
        ],
      ),
    );
  }
}

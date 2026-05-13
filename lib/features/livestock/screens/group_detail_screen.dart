import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/farm_app_bar.dart';
import '../../../shared/widgets/farm_scaffold.dart';
import '../../../shared/widgets/status_chip.dart';
import '../models/group.dart';
import '../providers/groups_provider.dart';

class GroupDetailScreen extends ConsumerWidget {
  const GroupDetailScreen({super.key, required this.groupId});
  final String groupId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupsAsync = ref.watch(groupsProvider);
    final localStore = ref.watch(localGroupStoreProvider);

    return groupsAsync.when(
      loading: () => const Scaffold(
          body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
      data: (groups) {
        // Check local store first (for newly added groups)
        final localGroup = localStore[groupId];
        final group = localGroup ??
            groups.cast<Group?>().firstWhere(
                  (g) => g?.id == groupId,
                  orElse: () => null,
                );

        if (group == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('Group not found')),
          );
        }

        return FarmScaffold(
          appBar: FarmAppBar(
            title: group.name,
            subtitle: group.species[0].toUpperCase() +
                group.species.substring(1),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () =>
                    context.push(AppRoutes.editGroupPath(group.id)),
                tooltip: 'Edit Group',
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.pagePaddingHorizontal,
              AppSpacing.md,
              AppSpacing.pagePaddingHorizontal,
              AppSpacing.xxl,
            ),
            children: [
              // Overview card
              _InfoCard(
                title: 'Overview',
                icon: Icons.info_outline_rounded,
                children: [
                  _InfoRow(
                    icon: Icons.pets_rounded,
                    label: 'Animal Count',
                    value: '${group.animalCount}',
                  ),
                  if (group.purpose != null)
                    _InfoRow(
                      icon: Icons.flag_outlined,
                      label: 'Purpose',
                      value: group.displayPurpose,
                    ),
                  if (group.location != null)
                    _InfoRow(
                      icon: Icons.location_on_outlined,
                      label: 'Location',
                      value: group.location!,
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              // Stats card
              if (group.avgWeightKg != null || group.avgAgeMonths != null)
                _InfoCard(
                  title: 'Averages',
                  icon: Icons.bar_chart_rounded,
                  children: [
                    if (group.avgWeightKg != null)
                      _InfoRow(
                        icon: Icons.monitor_weight_outlined,
                        label: 'Avg Weight',
                        value: '${group.avgWeightKg!.toStringAsFixed(1)} kg',
                      ),
                    if (group.avgAgeMonths != null)
                      _InfoRow(
                        icon: Icons.calendar_today_outlined,
                        label: 'Avg Age',
                        value:
                            '${group.avgAgeMonths!.toStringAsFixed(1)} months',
                      ),
                  ],
                ),
              if (group.avgWeightKg != null || group.avgAgeMonths != null)
                const SizedBox(height: AppSpacing.md),
              // Description
              if (group.description != null)
                _InfoCard(
                  title: 'Description',
                  icon: Icons.notes_rounded,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.sm),
                      child: Text(
                        group.description!,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: AppSpacing.xl),
              // Quick stats chips
              Wrap(
                spacing: AppSpacing.sm,
                runSpacing: AppSpacing.sm,
                children: [
                  StatusChip(
                    label: '${group.animalCount} animals',
                    color: AppColors.info,
                    icon: Icons.pets_rounded,
                    small: false,
                  ),
                  if (group.purpose != null)
                    StatusChip(
                      label: group.displayPurpose,
                      color: AppColors.secondary,
                      icon: Icons.flag_outlined,
                      small: false,
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.title,
    required this.icon,
    required this.children,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: AppRadius.card,
        boxShadow: AppShadows.level1,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.sm),
            child: Row(
              children: [
                Icon(icon, size: 18, color: AppColors.primary),
                const SizedBox(width: AppSpacing.sm),
                Text(title,
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow(
      {required this.icon, required this.label, required this.value});

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Colors.grey),
          const SizedBox(width: AppSpacing.sm),
          Text(label,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: Colors.grey[600])),
          const Spacer(),
          Text(value,
              style: theme.textTheme.bodyMedium
                  ?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_shadows.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/farm_app_bar.dart';
import '../../../shared/widgets/farm_scaffold.dart';
import '../../../shared/widgets/loading_shimmer.dart';
import '../../../shared/widgets/status_chip.dart';
import '../models/group.dart';
import '../providers/groups_provider.dart';

class GroupsScreen extends ConsumerWidget {
  const GroupsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final groupsAsync = ref.watch(groupsProvider);

    return FarmScaffold(
      appBar: const FarmAppBar(
        title: 'Groups & Herds',
        subtitle: 'Manage your animal groups',
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.addGroup),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Group'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: groupsAsync.when(
        loading: () => LoadingShimmer.list(count: 5),
        error: (e, _) => ErrorState(
          message: e.toString(),
          onRetry: () => ref.invalidate(groupsProvider),
        ),
        data: (groups) {
          if (groups.isEmpty) {
            return const Center(
              child: EmptyState(
                title: 'No Groups Yet',
                subtitle: 'Create your first animal group or herd.',
                icon: Icon(Icons.group_outlined, size: 64),
              ),
            );
          }

          // Group by species
          final bySpecies = <String, List<Group>>{};
          for (final g in groups) {
            bySpecies.putIfAbsent(g.species, () => []).add(g);
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.pagePaddingHorizontal,
              AppSpacing.md,
              AppSpacing.pagePaddingHorizontal,
              AppSpacing.xxl + 32,
            ),
            children: [
              for (final entry in bySpecies.entries) ...[
                _SpeciesHeader(species: entry.key),
                const SizedBox(height: AppSpacing.sm),
                for (final group in entry.value) ...[
                  _GroupCard(group: group),
                  const SizedBox(height: AppSpacing.sm),
                ],
                const SizedBox(height: AppSpacing.md),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _SpeciesHeader extends StatelessWidget {
  const _SpeciesHeader({required this.species});
  final String species;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = species[0].toUpperCase() + species.substring(1);
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        label,
        style: theme.textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _GroupCard extends StatelessWidget {
  const _GroupCard({required this.group});
  final Group group;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return GestureDetector(
      onTap: () => context.push(AppRoutes.groupDetailPath(group.id)),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: AppRadius.card,
          boxShadow: AppShadows.level1,
        ),
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            CircleAvatar(
              radius: 22,
              backgroundColor: AppColors.primary.withAlpha(30),
              child: Icon(Icons.group_rounded,
                  color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(group.name,
                      style: theme.textTheme.bodyLarge
                          ?.copyWith(fontWeight: FontWeight.w600)),
                  if (group.location != null) ...[
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Icon(Icons.location_on_outlined,
                            size: 12,
                            color: theme.colorScheme.onSurfaceVariant),
                        const SizedBox(width: 2),
                        Text(group.location!,
                            style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant)),
                      ],
                    ),
                  ],
                  const SizedBox(height: AppSpacing.xs),
                  Wrap(
                    spacing: AppSpacing.xs,
                    children: [
                      StatusChip(
                        label: '${group.animalCount} animals',
                        color: AppColors.info,
                        icon: Icons.pets_rounded,
                        small: true,
                      ),
                      if (group.purpose != null)
                        StatusChip(
                          label: group.displayPurpose,
                          color: AppColors.secondary,
                          icon: Icons.flag_outlined,
                          small: true,
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded,
                color: theme.colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}

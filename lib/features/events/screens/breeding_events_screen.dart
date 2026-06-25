import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mobile_app/core/constants/livestock_constants.dart';
import 'package:mobile_app/core/router/app_routes.dart';
import 'package:mobile_app/core/theme/app_colors.dart';
import 'package:mobile_app/core/theme/app_radius.dart';
import 'package:mobile_app/core/theme/app_shadows.dart';
import 'package:mobile_app/core/theme/app_spacing.dart';
import 'package:mobile_app/shared/widgets/empty_state.dart';
import 'package:mobile_app/shared/widgets/error_state.dart';
import 'package:mobile_app/shared/widgets/farm_app_bar.dart';
import 'package:mobile_app/shared/widgets/farm_scaffold.dart';
import 'package:mobile_app/shared/widgets/loading_shimmer.dart';
import 'package:mobile_app/shared/widgets/status_chip.dart';
import 'package:mobile_app/features/events/models/breeding_event.dart';
import 'package:mobile_app/features/events/providers/events_providers.dart';

// ── Screen ───────────────────────────────────────────────────────────────────

class BreedingEventsScreen extends ConsumerWidget {
  const BreedingEventsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final species =
        GoRouterState.of(context).uri.queryParameters['species'] ?? '';
    final eventsAsync = ref.watch(breedingEventsBySpeciesProvider(species));
    final speciesLabel = species.isNotEmpty
        ? LivestockConstants.displayName(species)
        : null;

    return FarmScaffold(
      appBar: FarmAppBar(
        title: 'Breeding Events',
        subtitle: speciesLabel != null
            ? '$speciesLabel — Mating & pregnancy tracking'
            : 'Mating & pregnancy tracking',
      ),
      floatingActionButton: FloatingActionButton.extended(heroTag: null, 
        onPressed: () => context.push(AppRoutes.addRecordBreeding),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Record Event'),
      ),
      body: eventsAsync.when(
        loading: () => LoadingShimmer.list(count: 8),
        error: (err, _) => ErrorState(
          message: err.toString(),
          onRetry: () =>
              ref.invalidate(breedingEventsBySpeciesProvider(species)),
        ),
        data: (events) {
          if (events.isEmpty) {
            return EmptyState(
              title: 'No breeding events',
              subtitle: speciesLabel != null
                  ? 'No breeding events recorded for $speciesLabel yet.'
                  : 'Record mating and pregnancy events here.',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.pagePaddingHorizontal,
              AppSpacing.md,
              AppSpacing.pagePaddingHorizontal,
              AppSpacing.xxl,
            ),
            itemCount: events.length,
            itemBuilder: (context, i) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _BreedingTile(event: events[i]),
            ),
          );
        },
      ),
    );
  }
}

class _BreedingTile extends StatelessWidget {
  const _BreedingTile({required this.event});
  final BreedingEvent event;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final pregnancyColor = switch (event.pregnancyResult) {
      'confirmed' => AppColors.success,
      'negative' => AppColors.error,
      'pending' => AppColors.warning,
      _ => AppColors.outline,
    };

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: AppRadius.card,
        boxShadow: AppShadows.level1,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.secondary.withAlpha(30),
                  borderRadius: AppRadius.button,
                ),
                child: const Icon(
                  Icons.favorite_rounded,
                  color: AppColors.secondary,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      event.animalId,
                      style: tt.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      event.serviceDate,
                      style: tt.labelSmall?.copyWith(
                        color: cs.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              StatusChip(
                label: event.displayType,
                color: AppColors.secondary,
                small: true,
              ),
            ],
          ),
          if (event.sireName != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Sire: ${event.sireName} (${event.sireBreed ?? ''})',
              style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
            ),
          ],
          if (event.serviceMethod != null) ...[
            const SizedBox(height: 2),
            Text(
              'Method: ${event.serviceMethod}',
              style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
            ),
          ],
          if (event.pregnancyResult != null ||
              event.expectedBirthDate != null) ...[
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                if (event.pregnancyResult != null)
                  StatusChip(
                    label: event.pregnancyResult!.toUpperCase(),
                    color: pregnancyColor,
                    small: true,
                  ),
                if (event.expectedBirthDate != null) ...[
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'EBD: ${event.expectedBirthDate}',
                    style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ],
              ],
            ),
          ],
        ],
      ),
    );
  }
}

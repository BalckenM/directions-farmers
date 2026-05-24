import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/livestock_constants.dart';
import '../../../core/router/app_routes.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
import '../../../shared/widgets/withdrawal_countdown.dart';
import '../providers/events_providers.dart';
import '../models/health_event.dart';

class HealthEventsScreen extends ConsumerWidget {
  const HealthEventsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final species =
        GoRouterState.of(context).uri.queryParameters['species'] ?? '';
    final eventsAsync = ref.watch(healthEventsBySpeciesProvider(species));
    final speciesLabel = species.isNotEmpty
        ? LivestockConstants.displayName(species)
        : null;

    return FarmScaffold(
      appBar: FarmAppBar(
        title: 'Health Events',
        subtitle: speciesLabel != null
            ? '$speciesLabel — Vaccinations & treatments'
            : 'Vaccinations & treatments',
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.addRecordHealth),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Add Event'),
      ),
      body: eventsAsync.when(
        loading: () => LoadingShimmer.list(count: 8),
        error: (err, _) => ErrorState(
          message: err.toString(),
          onRetry: () => ref.invalidate(healthEventsBySpeciesProvider(species)),
        ),
        data: (events) {
          if (events.isEmpty) {
            return EmptyState(
              title: 'No health events',
              subtitle: speciesLabel != null
                  ? 'No health events recorded for $speciesLabel yet.'
                  : 'Record your first treatment or vaccination.',
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
              child: _HealthEventTile(event: events[i]),
            ),
          );
        },
      ),
    );
  }
}

class _HealthEventTile extends StatelessWidget {
  const _HealthEventTile({required this.event});
  final HealthEvent event;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final typeColor = switch (event.eventType) {
      'vaccination' => AppColors.success,
      'treatment' => AppColors.warning,
      'examination' => AppColors.tertiary,
      'surgery' => AppColors.error,
      _ => AppColors.outline,
    };

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: AppRadius.card,
        boxShadow: AppShadows.level1,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: typeColor.withAlpha(30),
              borderRadius: AppRadius.button,
            ),
            child: Icon(Icons.health_and_safety_rounded,
                color: typeColor, size: 22),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    StatusChip(label: event.displayType, color: typeColor, small: true),
                    const SizedBox(width: AppSpacing.xs),
                    Text(event.eventDate,
                        style: tt.labelSmall?.copyWith(
                            color: cs.onSurfaceVariant)),
                  ],
                ),
                if (event.description != null) ...[
                  const SizedBox(height: 4),
                  Text(event.description!,
                      style: tt.bodyMedium
                          ?.copyWith(fontWeight: FontWeight.w600)),
                ],
                if (event.productName != null) ...[
                  const SizedBox(height: 2),
                  Text(event.productName!,
                      style: tt.bodySmall
                          ?.copyWith(color: cs.onSurfaceVariant)),
                ],
                if (event.animalId.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text('Animal: ${event.animalId}',
                      style: tt.labelSmall
                          ?.copyWith(color: cs.onSurfaceVariant)),
                ],
                if (event.withdrawalDays != null &&
                    event.withdrawalDays! > 0 &&
                    event.withdrawalEndDate != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  WithdrawalCountdown(
                    productName: event.productName ?? 'Medication',
                    withdrawalEndDate: event.withdrawalEndDate!,
                    daysRemaining: event.withdrawalDays!,
                    compact: true,
                  ),
                ],
              ],
            ),
          ),
          if (event.costZar != null)
            Text(
              'R${event.costZar!.toStringAsFixed(0)}',
              style: tt.labelMedium?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
        ],
      ),
    );
  }
}


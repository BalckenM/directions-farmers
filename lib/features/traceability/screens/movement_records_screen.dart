import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/error_state.dart';
import '../../../shared/widgets/farm_app_bar.dart';
import '../../../shared/widgets/farm_scaffold.dart';
import '../../../shared/widgets/loading_shimmer.dart';
import '../../../shared/widgets/movement_permit_card.dart';
import '../providers/traceability_providers.dart';

// ── Screen ───────────────────────────────────────────────────────────────────

class MovementRecordsScreen extends ConsumerWidget {
  const MovementRecordsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recordsAsync = ref.watch(movementRecordsProvider);

    return FarmScaffold(
      appBar: const FarmAppBar(
        title: 'Movement Records',
        subtitle: 'B313 permits & RMIS submissions',
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push(AppRoutes.addMovementRecord),
        icon: const Icon(Icons.add_road_rounded),
        label: const Text('New B313 Permit'),
      ),
      body: recordsAsync.when(
        loading: () => LoadingShimmer.list(count: 5),
        error: (err, _) => ErrorState(
          message: err.toString(),
          onRetry: () => ref.invalidate(movementRecordsProvider),
        ),
        data: (records) {
          if (records.isEmpty) {
            return const EmptyState(
              title: 'No movement records',
              subtitle:
                  'Record B313 livestock movement permits here.',
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.pagePaddingHorizontal,
              AppSpacing.md,
              AppSpacing.pagePaddingHorizontal,
              AppSpacing.xxl,
            ),
            itemCount: records.length,
            itemBuilder: (context, i) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: MovementPermitCard(record: records[i], compact: true),
            ),
          );
        },
      ),
    );
  }
}



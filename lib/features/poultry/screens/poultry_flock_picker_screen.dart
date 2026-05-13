import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/farm_scaffold.dart';
import '../../../shared/widgets/farm_app_bar.dart';
import '../providers/poultry_providers.dart';

/// Generic flock picker — selects a flock then immediately navigates to
/// the per-flock route indicated by [target].
///
/// Supported targets:
///   'daily-add'    → addPoultryDailyRecord(flockId)
///   'feed-phases'  → feedPhases(flockId)
///   'financial'    → financialScreen(flockId)
class PoultryFlockPickerScreen extends ConsumerWidget {
  const PoultryFlockPickerScreen({super.key, required this.target});

  final String target;

  String _routeFor(String flockId) => switch (target) {
        'daily-add' => AppRoutes.addPoultryDailyRecord(flockId),
        'feed-phases' => AppRoutes.feedPhases(flockId),
        'financial' => AppRoutes.financialScreen(flockId),
        _ => AppRoutes.flockDetailPath(flockId),
      };

  String get _title => switch (target) {
        'daily-add' => 'Daily Records',
        'feed-phases' => 'Feed Phases',
        'financial' => 'Financials',
        _ => 'Select Flock',
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final flocksAsync = ref.watch(flocksProvider);
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return FarmScaffold(
      drawer: null,
      appBar: FarmAppBar(title: _title),
      body: flocksAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (flocks) {
          if (flocks.isEmpty) {
            return const Center(child: Text('No flocks found. Add a flock first.'));
          }
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
                child: Text('Select a flock',
                    style: tt.titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
              ),
              Expanded(
                child: ListView.builder(
                  itemCount: flocks.length,
                  itemBuilder: (_, i) {
                    final f = flocks[i];
                    return ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: AppColors.poultryColorContainer,
                        child: Icon(Icons.egg_outlined,
                            color: AppColors.poultryColor),
                      ),
                      title: Text(f.batchName),
                      subtitle: Text(
                        '${f.productionType.toUpperCase()} · ${f.currentCount} birds · Day ${f.dayOfAge}',
                        style: tt.bodySmall?.copyWith(color: cs.outline),
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push(_routeFor(f.id)),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

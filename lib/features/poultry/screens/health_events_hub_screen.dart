import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_routes.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/farm_scaffold.dart';
import '../../../shared/widgets/farm_app_bar.dart';
import '../models/flock.dart';
import '../providers/poultry_providers.dart';

class HealthEventsHubScreen extends ConsumerStatefulWidget {
  const HealthEventsHubScreen({super.key, required this.flockId});

  final String flockId;

  @override
  ConsumerState<HealthEventsHubScreen> createState() =>
      _HealthEventsHubScreenState();
}

class _HealthEventsHubScreenState
    extends ConsumerState<HealthEventsHubScreen> {
  String? _selectedFlockId;

  String get _effectiveFlockId => _selectedFlockId ?? widget.flockId;

  @override
  Widget build(BuildContext context) {
    if (_effectiveFlockId.isEmpty) {
      return _buildFlockPicker(context);
    }
    return _buildEventList(context);
  }

  Widget _buildFlockPicker(BuildContext context) {
    final flocksAsync = ref.watch(flocksProvider);
    final tt = Theme.of(context).textTheme;
    return FarmScaffold(
      drawer: null,
      appBar: const FarmAppBar(title: 'Health Events'),
      body: flocksAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (flocks) {
          if (flocks.isEmpty) {
            return const Center(child: Text('No flocks found.'));
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
                        child: Icon(Icons.monitor_heart_outlined,
                            color: AppColors.poultryColor),
                      ),
                      title: Text(f.batchName),
                      subtitle: Text(
                        '${f.productionType.toUpperCase()} · ${f.currentCount} birds · Day ${f.dayOfAge}',
                        style: tt.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.outline),
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () =>
                          setState(() => _selectedFlockId = f.id),
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

  Widget _buildEventList(BuildContext context) {
    final eventsAsync =
        ref.watch(flockDiseaseEventsProvider(_effectiveFlockId));
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return FarmScaffold(
      drawer: null,
      appBar: FarmAppBar(
        title: 'Health Events',
        leading: widget.flockId.isEmpty
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() => _selectedFlockId = null),
              )
            : null,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.poultryColor,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Log Event'),
        onPressed: () =>
            context.push(AppRoutes.addDiseaseEvent(_effectiveFlockId)),
      ),
      body: eventsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (events) {
          if (events.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.health_and_safety_outlined,
                      size: 48, color: cs.outline),
                  const SizedBox(height: AppSpacing.md),
                  Text('No health events recorded.',
                      style: tt.bodyMedium?.copyWith(color: cs.outline)),
                  const SizedBox(height: AppSpacing.sm),
                  Text('Tap + to log a new event.',
                      style: tt.bodySmall?.copyWith(color: cs.outline)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.pagePaddingHorizontal,
              vertical: AppSpacing.pagePaddingVertical,
            ),
            itemCount: events.length,
            itemBuilder: (_, i) => _DiseaseEventCard(event: events[i]),
          );
        },
      ),
    );
  }
}

class _DiseaseEventCard extends StatelessWidget {
  const _DiseaseEventCard({required this.event});
  final DiseaseEvent event;

  Color _severityColor() => switch (event.severity) {
        'emergency' => Colors.red.shade700,
        'high' => Colors.red,
        'medium' => Colors.orange,
        _ => Colors.green,
      };

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final color = _severityColor();

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 4,
              height: 52,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(event.disease,
                            style: tt.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w600)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          event.severity.toUpperCase(),
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: color),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${event.date} · ${event.affectedCount} affected',
                    style: tt.bodySmall?.copyWith(color: cs.outline),
                  ),
                  if (event.symptoms != null) ...[
                    const SizedBox(height: 2),
                    Text(event.symptoms!,
                        style: tt.bodySmall?.copyWith(color: cs.outline),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis),
                  ],
                  if (event.outcome != null) ...[
                    const SizedBox(height: 2),
                    Text('Outcome: ${event.outcome}',
                        style: tt.bodySmall
                            ?.copyWith(color: Colors.green.shade700)),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

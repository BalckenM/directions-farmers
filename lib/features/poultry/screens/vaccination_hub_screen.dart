import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/farm_scaffold.dart';
import '../../../shared/widgets/farm_app_bar.dart';
import '../models/flock.dart';
import '../providers/poultry_providers.dart';

class VaccinationHubScreen extends ConsumerStatefulWidget {
  const VaccinationHubScreen({super.key, required this.flockId});

  final String flockId;

  @override
  ConsumerState<VaccinationHubScreen> createState() =>
      _VaccinationHubScreenState();
}

class _VaccinationHubScreenState extends ConsumerState<VaccinationHubScreen> {
  String? _selectedFlockId;

  String get _effectiveFlockId => _selectedFlockId ?? widget.flockId;

  @override
  Widget build(BuildContext context) {
    if (_effectiveFlockId.isEmpty) {
      return _buildFlockPicker(context);
    }
    return _buildSchedule(context);
  }

  Widget _buildFlockPicker(BuildContext context) {
    final flocksAsync = ref.watch(flocksProvider);
    final tt = Theme.of(context).textTheme;
    return FarmScaffold(
      drawer: null,
      appBar: const FarmAppBar(title: 'Vaccination Schedule'),
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
                        child: Icon(Icons.vaccines_outlined,
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

  Widget _buildSchedule(BuildContext context) {
    final scheduleAsync =
        ref.watch(flockVaccinationProvider(_effectiveFlockId));
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return FarmScaffold(
      drawer: null,
      appBar: FarmAppBar(
        title: 'Vaccination Schedule',
        leading: widget.flockId.isEmpty
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => setState(() => _selectedFlockId = null),
              )
            : null,
      ),
      body: scheduleAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (schedule) {
          if (schedule == null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.vaccines_outlined,
                      size: 48, color: cs.outline),
                  const SizedBox(height: AppSpacing.md),
                  Text('No vaccination schedule found for this flock.',
                      style: tt.bodyMedium?.copyWith(color: cs.outline),
                      textAlign: TextAlign.center),
                ],
              ),
            );
          }

          final completed = schedule.completedCount;
          final total = schedule.schedule.length;

          return ListView(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.pagePaddingHorizontal,
              vertical: AppSpacing.pagePaddingVertical,
            ),
            children: [
              // Summary chip row
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundColor:
                            AppColors.poultryColor.withValues(alpha: 0.12),
                        child: const Icon(Icons.vaccines_outlined,
                            color: AppColors.poultryColor),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${schedule.strain} · ${schedule.productionType.toUpperCase()}',
                              style: tt.titleSmall
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              'Placement: ${schedule.placementDate}',
                              style: tt.bodySmall
                                  ?.copyWith(color: cs.outline),
                            ),
                          ],
                        ),
                      ),
                      _StatusBadge(
                          label: '$completed/$total done',
                          color: completed == total
                              ? Colors.green
                              : AppColors.poultryColor),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              ...schedule.schedule.map((v) => _VaccineCard(item: v)),
            ],
          );
        },
      ),
    );
  }
}

class _VaccineCard extends StatelessWidget {
  const _VaccineCard({required this.item});
  final VaccineItem item;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final isCompleted = item.isCompleted;
    final statusColor =
        isCompleted ? Colors.green : item.isOverdue ? Colors.red : Colors.orange;

    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              isCompleted
                  ? Icons.check_circle_outline
                  : Icons.radio_button_unchecked,
              color: statusColor,
              size: 22,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(item.vaccine,
                            style: tt.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w600)),
                      ),
                      _StatusBadge(
                          label: item.status.toUpperCase(),
                          color: statusColor),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text('Day ${item.targetDay} · ${item.method}',
                      style: tt.bodySmall?.copyWith(color: cs.outline)),
                  if (item.product != null) ...[
                    const SizedBox(height: 2),
                    Text('Product: ${item.product}',
                        style: tt.bodySmall?.copyWith(color: cs.outline)),
                  ],
                  if (isCompleted && item.completedDate != null)
                    Text('Given: ${item.completedDate}  ·  By: ${item.administeredBy ?? '—'}',
                        style: tt.bodySmall?.copyWith(color: Colors.green.shade700)),
                  if (!isCompleted && item.dueDate != null)
                    Text('Due: ${item.dueDate}',
                        style: tt.bodySmall
                            ?.copyWith(color: Colors.orange.shade700)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
            fontSize: 11, fontWeight: FontWeight.w600, color: color),
      ),
    );
  }
}

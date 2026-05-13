import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/farm_app_bar.dart';
import '../../../shared/widgets/farm_scaffold.dart';
import '../models/apiculture.dart';
import '../providers/apiculture_providers.dart';

class HiveDetailScreen extends ConsumerStatefulWidget {
  const HiveDetailScreen({super.key, required this.hiveId});

  final String hiveId;

  @override
  ConsumerState<HiveDetailScreen> createState() => _HiveDetailScreenState();
}

class _HiveDetailScreenState extends ConsumerState<HiveDetailScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hiveAsync = ref.watch(hiveDetailProvider(widget.hiveId));

    return hiveAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
      data: (hive) {
        if (hive == null) {
          return const Scaffold(body: Center(child: Text('Hive not found')));
        }
        return _HiveDetailView(
            hiveId: widget.hiveId, hive: hive, tabs: _tabs);
      },
    );
  }
}

class _HiveDetailView extends ConsumerWidget {
  const _HiveDetailView({
    required this.hiveId,
    required this.hive,
    required this.tabs,
  });

  final String hiveId;
  final Hive hive;
  final TabController tabs;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inspectionsAsync =
        ref.watch(hiveInspectionHistoryProvider(hiveId));

    return FarmScaffold(
      appBar: FarmAppBar(
        title: 'Hive ${hive.hiveNumber}',
        subtitle:
            '${hive.hiveType} · ${hive.beeSubspecies}',
        bottom: TabBar(
          controller: tabs,
          indicatorColor: AppColors.beesColor,
          labelColor: AppColors.beesColor,
          unselectedLabelColor:
              Theme.of(context).colorScheme.onSurfaceVariant,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Inspections'),
          ],
        ),
      ),
      body: TabBarView(
        controller: tabs,
        children: [
          _OverviewTab(hive: hive),
          _InspectionsTab(inspectionsAsync: inspectionsAsync),
        ],
      ),
    );
  }
}

// ── Overview Tab ──────────────────────────────────────────────────────────────

class _OverviewTab extends StatelessWidget {
  const _OverviewTab({required this.hive});

  final Hive hive;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Colony health ─────────────────────────────────────────────────
          _SectionTitle('Colony Health'),
          const SizedBox(height: AppSpacing.sm),

          // Colony strength
          Row(
            children: [
              const Text('Colony strength', style: TextStyle(fontSize: 13)),
              const Spacer(),
              Text('${hive.colonyStrengthScore ?? 0}/10',
                  style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.beesColor)),
            ],
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: ((hive.colonyStrengthScore ?? 0).clamp(0, 10) / 10)
                  .toDouble(),
              minHeight: 8,
              backgroundColor:
                  Theme.of(context).colorScheme.surfaceContainerHighest,
              valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.beesColor),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          // Queen info
          _InfoRow(label: 'Queen status', value: hive.queenStatus ?? '—'),
          _InfoRow(
              label: 'Queen age',
              value: hive.queenAgeMonths != null
                  ? '${hive.queenAgeMonths} months'
                  : '—'),
          _InfoRow(
              label: 'Queen marked',
              value: hive.queenMarked == true ? 'Yes' : 'No'),
          if (hive.queenColorYear != null)
            _InfoRow(label: 'Queen colour year', value: hive.queenColorYear!),

          const SizedBox(height: AppSpacing.md),
          _SectionTitle('Honey & Varroa'),
          const SizedBox(height: AppSpacing.sm),

          _InfoRow(
              label: 'Honey stores (frames)',
              value: '${hive.honeyStoresFrames ?? 0}'),
          _InfoRow(
              label: 'Supers on',
              value: '${hive.supersOn ?? 0}'),
          _InfoRow(
              label: 'Total honey harvested',
              value: hive.totalHoneyHarvestedKg != null
                  ? '${hive.totalHoneyHarvestedKg!.toStringAsFixed(1)} kg'
                  : '—'),

          const Divider(height: AppSpacing.lg * 2),

          if (hive.varroaInfestationRatePct != null) ...[
            Row(
              children: [
                Icon(
                  Icons.pest_control_outlined,
                  color: hive.isVarroaAlert ? Colors.red : Colors.green,
                  size: 18,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                    'Varroa infestation rate: ${hive.varroaInfestationRatePct!.toStringAsFixed(1)}%',
                    style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: hive.isVarroaAlert
                            ? Colors.red
                            : Colors.green)),
              ],
            ),
            if (hive.isVarroaAlert)
              const Padding(
                padding: EdgeInsets.only(top: 4),
                child: Text(
                    '⚠ Above treatment threshold (3%). Apply oxalic acid or amitraz.',
                    style: TextStyle(fontSize: 12, color: Colors.red)),
              ),
            const SizedBox(height: AppSpacing.sm),
            _InfoRow(
                label: 'Last varroa count',
                value: hive.varroaLastCountDate ?? '—'),
          ],

          const SizedBox(height: AppSpacing.md),
          _SectionTitle('Schedule'),
          const SizedBox(height: AppSpacing.sm),
          _InfoRow(
              label: 'Last inspection',
              value: hive.lastInspectionDate ?? '—'),
          _InfoRow(
              label: 'Next inspection due',
              value: hive.nextInspectionDue ?? '—'),
          if (hive.inspectionOverdue == true)
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text('⚠ Inspection overdue',
                  style: TextStyle(
                      fontSize: 12,
                      color: Colors.orange,
                      fontWeight: FontWeight.w600)),
            ),

          const SizedBox(height: AppSpacing.md),
          _SectionTitle('Hive Info'),
          const SizedBox(height: AppSpacing.sm),
          _InfoRow(label: 'Type', value: hive.hiveType),
          _InfoRow(
              label: 'Installation date',
              value: hive.installationDate ?? '—'),
          _InfoRow(label: 'Origin', value: hive.origin ?? '—'),

          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}

// ── Inspections Tab ───────────────────────────────────────────────────────────

class _InspectionsTab extends StatelessWidget {
  const _InspectionsTab({required this.inspectionsAsync});

  final AsyncValue<List<HiveInspection>> inspectionsAsync;

  @override
  Widget build(BuildContext context) {
    return inspectionsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (inspections) => inspections.isEmpty
          ? const Center(child: Text('No inspection records'))
          : ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: inspections.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(height: AppSpacing.sm),
              itemBuilder: (_, i) =>
                  _InspectionCard(inspection: inspections[i]),
            ),
    );
  }
}

class _InspectionCard extends StatelessWidget {
  const _InspectionCard({required this.inspection});

  final HiveInspection inspection;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Text(inspection.inspectionDate,
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700)),
                const Spacer(),
                if (inspection.swarmCellsPresent == true)
                  _Tag(label: 'Swarm cells', color: Colors.orange),
                if (inspection.diseaseSigns != null &&
                    inspection.diseaseSigns!.isNotEmpty)
                  _Tag(label: 'Disease', color: Colors.red),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            // Inspector + weather
            Text(
                '${inspection.inspector ?? '—'} · ${inspection.weather ?? '—'}',
                style: theme.textTheme.bodySmall
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(height: AppSpacing.sm),

            // Key observations
            Wrap(
              spacing: AppSpacing.md,
              runSpacing: 4,
              children: [
                if (inspection.colonyTemperament != null)
                  _ObsChip(
                      label: 'Temperament: ${inspection.colonyTemperament}'),
                if (inspection.beePopulationFrames != null)
                  _ObsChip(
                      label: 'Pop: ${inspection.beePopulationFrames} frames'),
                if (inspection.broodFrames != null)
                  _ObsChip(
                      label: 'Brood: ${inspection.broodFrames} frames'),
                if (inspection.honeyStoresFrames != null)
                  _ObsChip(
                      label: 'Honey: ${inspection.honeyStoresFrames} frames'),
                _ObsChip(
                    label:
                        'Queen seen: ${inspection.queenSeen == true ? 'Yes' : 'No'}'),
                if (inspection.eggsSeen == true)
                  _ObsChip(label: 'Eggs seen'),
              ],
            ),

            if (inspection.actionTaken != null &&
                inspection.actionTaken!.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.xs),
              Text('Action: ${inspection.actionTaken}',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: AppColors.beesColor)),
            ],
          ],
        ),
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  const _Tag({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 4),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontSize: 10, fontWeight: FontWeight.w700)),
    );
  }
}

class _ObsChip extends StatelessWidget {
  const _ObsChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label, style: const TextStyle(fontSize: 11)),
    );
  }
}

// ── Shared helpers ────────────────────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700, color: AppColors.beesColor));
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(label,
              style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant)),
          const Spacer(),
          Text(value,
              style: theme.textTheme.bodySmall
                  ?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

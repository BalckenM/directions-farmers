import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/farm_app_bar.dart';
import '../../../shared/widgets/farm_scaffold.dart';
import '../models/sow.dart';
import '../providers/pigs_providers.dart';

class SowDetailScreen extends ConsumerStatefulWidget {
  const SowDetailScreen({super.key, required this.sowId});

  final String sowId;

  @override
  ConsumerState<SowDetailScreen> createState() => _SowDetailScreenState();
}

class _SowDetailScreenState extends ConsumerState<SowDetailScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sowAsync = ref.watch(sowDetailProvider(widget.sowId));

    return sowAsync.when(
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (e, _) => Scaffold(body: Center(child: Text('Error: $e'))),
      data: (sow) {
        if (sow == null) {
          return const Scaffold(body: Center(child: Text('Sow not found')));
        }
        return _SowDetailView(sowId: widget.sowId, sow: sow, tabs: _tabs);
      },
    );
  }
}

class _SowDetailView extends ConsumerWidget {
  const _SowDetailView({
    required this.sowId,
    required this.sow,
    required this.tabs,
  });

  final String sowId;
  final Sow sow;
  final TabController tabs;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final farrowingAsync = ref.watch(sowFarrowingHistoryProvider(sowId));
    final serviceAsync = ref.watch(sowServiceHistoryProvider(sowId));

    return FarmScaffold(
      appBar: FarmAppBar(
        title: sow.displayName,
        subtitle:
            '${sow.breed} · Parity ${sow.pigSpecific?.parity ?? 0}',
        bottom: TabBar(
          controller: tabs,
          indicatorColor: AppColors.pigColor,
          labelColor: AppColors.pigColor,
          unselectedLabelColor:
              Theme.of(context).colorScheme.onSurfaceVariant,
          tabs: const [
            Tab(text: 'Overview'),
            Tab(text: 'Farrowing'),
            Tab(text: 'Services'),
          ],
        ),
      ),
      body: TabBarView(
        controller: tabs,
        children: [
          _OverviewTab(sow: sow),
          _FarrowingTab(farrowingAsync: farrowingAsync),
          _ServicesTab(serviceAsync: serviceAsync),
        ],
      ),
    );
  }
}

// ── Overview Tab ──────────────────────────────────────────────────────────────

class _OverviewTab extends StatelessWidget {
  const _OverviewTab({required this.sow});

  final Sow sow;

  @override
  Widget build(BuildContext context) {
    final ps = sow.pigSpecific;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Alert banners ─────────────────────────────────────────────────
          if (ps?.isPsyAlert == true)
            _AlertBanner(
              icon: Icons.warning_amber_outlined,
              message:
                  'PSY below target (${ps!.psyCurrentYear?.toStringAsFixed(1) ?? '?'} vs 22). Review breeding efficiency.',
              color: AppColors.warning,
            ),
          if (ps?.isPreWeanAlert == true)
            _AlertBanner(
              icon: Icons.child_friendly_outlined,
              message:
                  'Pre-wean mortality above threshold (${ps!.preWeanMortalityPct?.toStringAsFixed(1) ?? '?'}%). Check housing & nutrition.',
              color: AppColors.error,
            ),

          // ── Reproductive status ───────────────────────────────────────────
          _SectionTitle('Reproductive Status'),
          const SizedBox(height: AppSpacing.sm),
          _InfoRow(label: 'Current stage', value: sow.currentStage),
          _InfoRow(label: 'Parity', value: '${ps?.parity ?? 0}'),
          if (sow.isPregnant) ...[
            _InfoRow(
                label: 'Expected farrowing',
                value: ps?.expectedFarrowingDate ?? '—'),
            if (sow.daysToFarrowing != null)
              _InfoRow(
                  label: 'Days to farrowing',
                  value: sow.daysToFarrowing! == 0
                      ? 'Due today'
                      : '${sow.daysToFarrowing}d'),
          ],
          if (ps?.lastServiceDate != null)
            _InfoRow(label: 'Last service date', value: ps!.lastServiceDate!),
          if (ps?.weanToServiceDays != null)
            _InfoRow(
                label: 'Wean-to-service days',
                value: '${ps!.weanToServiceDays}d'),

          const SizedBox(height: AppSpacing.md),

          // ── Productivity ──────────────────────────────────────────────────
          _SectionTitle('Productivity'),
          const SizedBox(height: AppSpacing.sm),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: AppSpacing.sm,
            crossAxisSpacing: AppSpacing.sm,
            childAspectRatio: 2.2,
            children: [
              _KpiCard(
                label: 'PSY (Year)',
                value: ps?.psyCurrentYear?.toStringAsFixed(1) ?? '—',
                icon: Icons.child_friendly_outlined,
                alert: ps?.isPsyAlert == true,
              ),
              _KpiCard(
                label: 'Born alive (life)',
                value: '${ps?.totalBornAliveLifetime ?? 0}',
                icon: Icons.favorite_border,
              ),
              _KpiCard(
                label: 'Pre-wean mort.',
                value: ps?.preWeanMortalityPct != null
                    ? '${ps!.preWeanMortalityPct!.toStringAsFixed(1)}%'
                    : '—',
                icon: Icons.trending_down,
                alert: ps?.isPreWeanAlert == true,
              ),
              _KpiCard(
                label: 'Litter weaned',
                value: '${ps?.currentLitterWeaned ?? 0}',
                icon: Icons.groups_outlined,
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // ── Body condition ────────────────────────────────────────────────
          _SectionTitle('Body Condition'),
          const SizedBox(height: AppSpacing.sm),
          if (sow.bodyConditionScore != null)
            _InfoRow(
                label: 'BCS (1–5)',
                value: sow.bodyConditionScore!.toStringAsFixed(1)),
          if (ps?.backfatMm != null)
            _InfoRow(
                label: 'Backfat (mm)', value: '${ps!.backfatMm} mm'),

          const SizedBox(height: AppSpacing.md),

          // ── Current litter ────────────────────────────────────────────────
          if (sow.isLactating) ...[
            _SectionTitle('Current Litter'),
            const SizedBox(height: AppSpacing.sm),
            _InfoRow(
                label: 'Total born', value: '${ps?.totalBorn ?? 0}'),
            _InfoRow(
                label: 'Born alive', value: '${ps?.bornAlive ?? 0}'),
            _InfoRow(
                label: 'Born dead', value: '${ps?.bornDead ?? 0}'),
            _InfoRow(
                label: 'Avg birth weight',
                value: ps?.avgBirthWeightKg != null
                    ? '${ps!.avgBirthWeightKg!.toStringAsFixed(2)} kg'
                    : '—'),
          ],

          const SizedBox(height: AppSpacing.md),

          // ── Basic info ────────────────────────────────────────────────────
          _SectionTitle('Animal Info'),
          const SizedBox(height: AppSpacing.sm),
          _InfoRow(label: 'Tag', value: sow.tagNumber),
          if (sow.name != null) _InfoRow(label: 'Name', value: sow.name!),
          _InfoRow(label: 'Breed', value: sow.breed),
          if (sow.dateOfBirth != null)
            _InfoRow(label: 'Date of birth', value: sow.dateOfBirth!),
          if (sow.penId != null)
            _InfoRow(label: 'Pen', value: sow.penId!),

          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}

// ── Farrowing Tab ─────────────────────────────────────────────────────────────

class _FarrowingTab extends StatelessWidget {
  const _FarrowingTab({required this.farrowingAsync});

  final AsyncValue<List<FarrowingRecord>> farrowingAsync;

  @override
  Widget build(BuildContext context) {
    return farrowingAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (records) => records.isEmpty
          ? const Center(child: Text('No farrowing records'))
          : ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: records.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(height: AppSpacing.sm),
              itemBuilder: (_, i) =>
                  _FarrowingCard(record: records[i]),
            ),
    );
  }
}

class _FarrowingCard extends StatelessWidget {
  const _FarrowingCard({required this.record});

  final FarrowingRecord record;

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
            Row(
              children: [
                Text('Parity ${record.parity}',
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700)),
                const Spacer(),
                Text(record.farrowingDate ?? '—',
                    style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant)),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.lg,
              runSpacing: 4,
              children: [
                _Stat(label: 'Total born', value: '${record.totalBorn ?? 0}'),
                _Stat(label: 'Born alive', value: '${record.bornAlive ?? 0}'),
                _Stat(
                    label: 'Born dead', value: '${record.bornDead ?? 0}'),
                _Stat(
                    label: 'Weaned', value: '${record.weaned ?? 0}'),
                if (record.preWeanMortalityPct != null)
                  _Stat(
                      label: 'Pre-wean mort.',
                      value:
                          '${record.preWeanMortalityPct!.toStringAsFixed(1)}%',
                      alert: record.preWeanMortalityPct! > 12),
                if (record.avgBirthWeightKg != null)
                  _Stat(
                      label: 'Avg BW',
                      value:
                          '${record.avgBirthWeightKg!.toStringAsFixed(2)} kg'),
              ],
            ),
            if (record.weaningDate != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text('Weaned: ${record.weaningDate}',
                  style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant)),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Services Tab ──────────────────────────────────────────────────────────────

class _ServicesTab extends StatelessWidget {
  const _ServicesTab({required this.serviceAsync});

  final AsyncValue<List<SowServiceRecord>> serviceAsync;

  @override
  Widget build(BuildContext context) {
    return serviceAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
      data: (records) => records.isEmpty
          ? const Center(child: Text('No service records'))
          : ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: records.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(height: AppSpacing.sm),
              itemBuilder: (_, i) =>
                  _ServiceCard(record: records[i]),
            ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({required this.record});

  final SowServiceRecord record;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isConfirmed = record.pregnancyResult?.toLowerCase() == 'pregnant' ||
        record.pregnancyResult?.toLowerCase() == 'confirmed';
    final isNegative = record.pregnancyResult?.toLowerCase() == 'negative' ||
        record.pregnancyResult?.toLowerCase() == 'open';

    return Card(
      shape: RoundedRectangleBorder(borderRadius: AppRadius.card),
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(record.serviceDate ?? '—',
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700)),
                const Spacer(),
                if (record.pregnancyResult != null)
                  _ResultChip(
                      result: record.pregnancyResult!,
                      isConfirmed: isConfirmed,
                      isNegative: isNegative),
              ],
            ),
            const SizedBox(height: AppSpacing.xs),
            Wrap(
              spacing: AppSpacing.lg,
              runSpacing: 4,
              children: [
                if (record.boarTag != null)
                  _Stat(label: 'Boar', value: record.boarTag!),
                if (record.serviceMethod != null)
                  _Stat(label: 'Method', value: record.serviceMethod!),
                if (record.weanToServiceDays != null)
                  _Stat(
                      label: 'W-S days',
                      value: '${record.weanToServiceDays}d'),
              ],
            ),
            if (record.expectedFarrowingDate != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text('Exp. farrowing: ${record.expectedFarrowingDate}',
                  style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant)),
            ],
          ],
        ),
      ),
    );
  }
}

class _ResultChip extends StatelessWidget {
  const _ResultChip({
    required this.result,
    required this.isConfirmed,
    required this.isNegative,
  });

  final String result;
  final bool isConfirmed;
  final bool isNegative;

  @override
  Widget build(BuildContext context) {
    final color = isConfirmed
        ? Colors.green
        : isNegative
            ? Colors.red
            : Colors.orange;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(result,
          style: TextStyle(
              color: color, fontSize: 11, fontWeight: FontWeight.w700)),
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
            fontWeight: FontWeight.w700, color: AppColors.pigColor));
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

class _KpiCard extends StatelessWidget {
  const _KpiCard({
    required this.label,
    required this.value,
    required this.icon,
    this.alert = false,
  });

  final String label;
  final String value;
  final IconData icon;
  final bool alert;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = alert ? AppColors.error : AppColors.pigColor;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: alert
            ? AppColors.error.withValues(alpha: 0.08)
            : AppColors.pigColorContainer,
        borderRadius: AppRadius.card,
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: AppSpacing.xs),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(value,
                    style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800, color: color)),
                Text(label,
                    style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontSize: 10),
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, this.alert = false});

  final String label;
  final String value;
  final bool alert;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value,
            style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: alert ? AppColors.error : null)),
        Text(label,
            style: theme.textTheme.labelSmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant)),
      ],
    );
  }
}

class _AlertBanner extends StatelessWidget {
  const _AlertBanner({
    required this.icon,
    required this.message,
    required this.color,
  });

  final IconData icon;
  final String message;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: AppRadius.card,
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(message,
                style: TextStyle(
                    color: color, fontSize: 12, fontWeight: FontWeight.w500)),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/farm_app_bar.dart';
import '../../../shared/widgets/farm_scaffold.dart';
import '../providers/poultry_providers.dart';

class BreederRecordsScreen extends ConsumerWidget {
  const BreederRecordsScreen({super.key, required this.flockId});
  final String flockId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(breederRecordProvider);

    return FarmScaffold(
      appBar: FarmAppBar(title: 'Breeder Records'),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.poultryColor,
        foregroundColor: Colors.white,
        onPressed: () => _showAddSheet(context, ref),
        child: const Icon(Icons.add),
      ),
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (map) {
          final records = map[flockId] ?? [];
          return records.isEmpty
              ? const Center(
                  child: Padding(
                    padding: EdgeInsets.all(AppSpacing.xl),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.egg_outlined, size: 56, color: Colors.grey),
                        SizedBox(height: AppSpacing.md),
                        Text('No breeder records logged',
                            style: TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  itemCount: records.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.sm),
                  itemBuilder: (_, i) =>
                      _BreederCard(record: records[i], flockId: flockId),
                );
        },
      ),
    );
  }

  void _showAddSheet(BuildContext context, WidgetRef ref) {
    final dateCtrl =
        TextEditingController(text: DateTime.now().toIso8601String().substring(0, 10));
    final weekCtrl = TextEditingController();
    final eggsSetCtrl = TextEditingController();
    final eggsCandleCtrl = TextEditingController();
    final eggsFertileCtrl = TextEditingController();
    final eggsHatchedCtrl = TextEditingController();
    final avgChickWtCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: AppSpacing.pagePaddingHorizontal,
          right: AppSpacing.pagePaddingHorizontal,
          top: AppSpacing.lg,
          bottom: MediaQuery.viewInsetsOf(ctx).bottom + AppSpacing.lg,
        ),
        child: Form(
          key: formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Log Breeder Record',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: AppSpacing.md),
                TextFormField(
                  controller: dateCtrl,
                  decoration: const InputDecoration(
                      labelText: 'Date (YYYY-MM-DD)',
                      border: OutlineInputBorder()),
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: weekCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                            labelText: 'Week of Age',
                            border: OutlineInputBorder()),
                        validator: (v) => int.tryParse(v ?? '') == null
                            ? 'Required'
                            : null,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: TextFormField(
                        controller: eggsSetCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                            labelText: 'Eggs Set',
                            border: OutlineInputBorder()),
                        validator: (v) => int.tryParse(v ?? '') == null
                            ? 'Required'
                            : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: eggsCandleCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                            labelText: 'Eggs Candled',
                            border: OutlineInputBorder()),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: TextFormField(
                        controller: eggsFertileCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                            labelText: 'Eggs Fertile',
                            border: OutlineInputBorder()),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: eggsHatchedCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                            labelText: 'Eggs Hatched',
                            border: OutlineInputBorder()),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: TextFormField(
                        controller: avgChickWtCtrl,
                        keyboardType:
                            const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                            labelText: 'Avg Chick Wt (g)',
                            border: OutlineInputBorder()),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                TextFormField(
                  controller: notesCtrl,
                  maxLines: 2,
                  decoration: const InputDecoration(
                      labelText: 'Notes — optional',
                      border: OutlineInputBorder()),
                ),
                const SizedBox(height: AppSpacing.md),
                FilledButton(
                  style: FilledButton.styleFrom(
                      backgroundColor: AppColors.poultryColor,
                      minimumSize: const Size.fromHeight(48)),
                  onPressed: () {
                    if (formKey.currentState?.validate() ?? false) {
                      ref.read(breederRecordProvider.notifier).add(BreederRecord(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        flockId: flockId,
                        date: dateCtrl.text.trim(),
                        weekOfAge: int.parse(weekCtrl.text.trim()),
                        eggsSet: int.parse(eggsSetCtrl.text.trim()),
                        eggsCandles: int.tryParse(eggsCandleCtrl.text.trim()),
                        eggsFertile: int.tryParse(eggsFertileCtrl.text.trim()),
                        eggsHatched: int.tryParse(eggsHatchedCtrl.text.trim()),
                        avgChickWeightG:
                            double.tryParse(avgChickWtCtrl.text.trim()),
                        notes: notesCtrl.text.trim().isEmpty
                            ? null
                            : notesCtrl.text.trim(),
                      ));
                      Navigator.pop(ctx);
                    }
                  },
                  child: const Text('Save'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BreederCard extends ConsumerWidget {
  const _BreederCard({required this.record, required this.flockId});
  final BreederRecord record;
  final String flockId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final fertilityPct = record.fertilityPct;
    final hatchRatePct = record.hatchRatePct;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.card,
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.poultryColor.withAlpha(26),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text('Wk ${record.weekOfAge}',
                      style: theme.textTheme.labelSmall
                          ?.copyWith(color: AppColors.poultryColor)),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text('Eggs Set: ${record.eggsSet}',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(fontWeight: FontWeight.bold)),
                const Spacer(),
                Text(record.date,
                    style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant)),
                IconButton(
                  icon: Icon(Icons.delete_outline,
                      size: 18,
                      color: theme.colorScheme.error.withAlpha(180)),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () async {
                    final confirmed = await showDialog<bool>(
                      context: context,
                      builder: (_) => AlertDialog(
                        title: const Text('Delete Record'),
                        content:
                            const Text('Remove this breeder record?'),
                        actions: [
                          TextButton(
                              onPressed: () =>
                                  Navigator.pop(context, false),
                              child: const Text('Cancel')),
                          TextButton(
                              onPressed: () =>
                                  Navigator.pop(context, true),
                              style: TextButton.styleFrom(
                                  foregroundColor:
                                      theme.colorScheme.error),
                              child: const Text('Delete')),
                        ],
                      ),
                    );
                    if (confirmed == true) {
                      ref
                          .read(breederRecordProvider.notifier)
                          .delete(flockId, record.id);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.md,
              children: [
                if (record.eggsCandles != null)
                  _Stat(label: 'Candled', value: '${record.eggsCandles}'),
                if (record.eggsFertile != null)
                  _Stat(label: 'Fertile', value: '${record.eggsFertile}'),
                if (record.eggsHatched != null)
                  _Stat(label: 'Hatched', value: '${record.eggsHatched}'),
                if (fertilityPct != null)
                  _Stat(
                      label: 'Fertility',
                      value: '${fertilityPct.toStringAsFixed(1)}%',
                      color: fertilityPct >= 85
                          ? AppColors.success
                          : AppColors.warning),
                if (hatchRatePct != null)
                  _Stat(
                      label: 'Hatch Rate',
                      value: '${hatchRatePct.toStringAsFixed(1)}%',
                      color: hatchRatePct >= 80
                          ? AppColors.success
                          : AppColors.warning),
                if (record.avgChickWeightG != null)
                  _Stat(
                      label: 'Avg Chick Wt',
                      value:
                          '${record.avgChickWeightG!.toStringAsFixed(1)}g'),
              ],
            ),
            if (record.notes != null) ...[
              const SizedBox(height: 4),
              Text(record.notes!,
                  style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant)),
            ],
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({required this.label, required this.value, this.color});
  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label,
            style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant)),
        Text(value,
            style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }
}

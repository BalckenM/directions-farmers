import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/farm_app_bar.dart';
import '../../../shared/widgets/farm_scaffold.dart';
import '../providers/poultry_providers.dart';

class LitterManagementScreen extends ConsumerWidget {
  const LitterManagementScreen({super.key, required this.flockId});
  final String flockId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final records = ref.watch(litterRecordProvider)[flockId] ?? [];

    return FarmScaffold(
      appBar: FarmAppBar(title: 'Litter Management'),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.poultryColor,
        foregroundColor: Colors.white,
        onPressed: () => _showAddSheet(context, ref),
        child: const Icon(Icons.add),
      ),
      body: records.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.layers_outlined, size: 56, color: Colors.grey),
                    SizedBox(height: AppSpacing.md),
                    Text('No litter records yet',
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
                  _LitterCard(record: records[i], flockId: flockId),
            ),
    );
  }

  void _showAddSheet(BuildContext context, WidgetRef ref) {
    final dateCtrl =
        TextEditingController(text: DateTime.now().toIso8601String().substring(0, 10));
    final depthCtrl = TextEditingController();
    final materialCtrl = TextEditingController();
    final actionCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    String selectedType = LitterRecord.eventTypes.first;
    String selectedCondition = LitterRecord.conditions.first;
    final formKey = GlobalKey<FormState>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => Padding(
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
                  Text('Log Litter Record',
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
                  DropdownButtonFormField<String>(
                    initialValue: selectedType,
                    decoration: const InputDecoration(
                        labelText: 'Event Type',
                        border: OutlineInputBorder()),
                    items: LitterRecord.eventTypes
                        .map((t) => DropdownMenuItem(
                            value: t,
                            child: Text(t
                                .replaceAll('_', ' ')
                                .split(' ')
                                .map((w) =>
                                    w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}')
                                .join(' '))))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => selectedType = v);
                    },
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  DropdownButtonFormField<String>(
                    initialValue: selectedCondition,
                    decoration: const InputDecoration(
                        labelText: 'Condition',
                        border: OutlineInputBorder()),
                    items: LitterRecord.conditions
                        .map((c) => DropdownMenuItem(
                            value: c,
                            child: Text(LitterRecord.conditionLabel(c))))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => selectedCondition = v);
                    },
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextFormField(
                    controller: depthCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: const InputDecoration(
                        labelText: 'Depth (cm) — optional',
                        border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextFormField(
                    controller: materialCtrl,
                    decoration: const InputDecoration(
                        labelText: 'Material — optional',
                        border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextFormField(
                    controller: actionCtrl,
                    decoration: const InputDecoration(
                        labelText: 'Action Taken — optional',
                        border: OutlineInputBorder()),
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
                        ref.read(litterRecordProvider.notifier).add(LitterRecord(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          flockId: flockId,
                          date: dateCtrl.text.trim(),
                          eventType: selectedType,
                          condition: selectedCondition,
                          depthCm: double.tryParse(depthCtrl.text.trim()),
                          material: materialCtrl.text.trim().isEmpty
                              ? null
                              : materialCtrl.text.trim(),
                          actionTaken: actionCtrl.text.trim().isEmpty
                              ? null
                              : actionCtrl.text.trim(),
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
      ),
    );
  }
}

class _LitterCard extends ConsumerWidget {
  const _LitterCard({required this.record, required this.flockId});
  final LitterRecord record;
  final String flockId;

  Color _conditionColor(String c) => switch (c) {
        'good' => AppColors.success,
        'fair' => AppColors.warning,
        'poor' => AppColors.error,
        _ => AppColors.error,
      };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final condColor = _conditionColor(record.condition);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.card,
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 6,
              height: 60,
              decoration: BoxDecoration(
                color: condColor,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Chip(
                        label: Text(
                          record.eventType
                              .replaceAll('_', ' ')
                              .split(' ')
                              .map((w) => w.isEmpty
                                  ? w
                                  : '${w[0].toUpperCase()}${w.substring(1)}')
                              .join(' '),
                          style: const TextStyle(fontSize: 11),
                        ),
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Chip(
                        label: Text(
                          LitterRecord.conditionLabel(record.condition),
                          style: TextStyle(fontSize: 11, color: condColor),
                        ),
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                        backgroundColor: condColor.withAlpha(26),
                      ),
                      const Spacer(),
                      Text(record.date,
                          style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant)),
                    ],
                  ),
                  if (record.depthCm != null)
                    Text('Depth: ${record.depthCm!.toStringAsFixed(1)} cm',
                        style: theme.textTheme.bodySmall),
                  if (record.material != null)
                    Text('Material: ${record.material}',
                        style: theme.textTheme.bodySmall),
                  if (record.actionTaken != null)
                    Text('Action: ${record.actionTaken}',
                        style: theme.textTheme.bodySmall),
                  if (record.notes != null)
                    Text(record.notes!,
                        style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant)),
                ],
              ),
            ),
            IconButton(
              icon: Icon(Icons.delete_outline,
                  size: 18, color: theme.colorScheme.error.withAlpha(180)),
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Delete Record'),
                    content: const Text('Remove this litter record?'),
                    actions: [
                      TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: const Text('Cancel')),
                      TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: TextButton.styleFrom(
                              foregroundColor: theme.colorScheme.error),
                          child: const Text('Delete')),
                    ],
                  ),
                );
                if (confirmed == true) {
                  ref
                      .read(litterRecordProvider.notifier)
                      .delete(flockId, record.id);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

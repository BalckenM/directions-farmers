import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/farm_app_bar.dart';
import '../../../shared/widgets/farm_scaffold.dart';
import '../providers/poultry_providers.dart';

class BiosecurityLogScreen extends ConsumerWidget {
  const BiosecurityLogScreen({super.key, required this.flockId});
  final String flockId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final logs = ref.watch(biosecurityLogProvider)[flockId] ?? [];

    return FarmScaffold(
      appBar: FarmAppBar(title: 'Biosecurity Log'),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.poultryColor,
        foregroundColor: Colors.white,
        onPressed: () => _showAddSheet(context, ref),
        child: const Icon(Icons.add),
      ),
      body: logs.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.health_and_safety_outlined,
                        size: 56, color: Colors.grey),
                    SizedBox(height: AppSpacing.md),
                    Text('No biosecurity events logged',
                        style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: logs.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(height: AppSpacing.sm),
              itemBuilder: (_, i) {
                final log = logs[i];
                return _LogCard(log: log, flockId: flockId);
              },
            ),
    );
  }

  void _showAddSheet(BuildContext context, WidgetRef ref) {
    final dateCtrl =
        TextEditingController(text: DateTime.now().toIso8601String().substring(0, 10));
    final personnelCtrl = TextEditingController();
    final productsCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    String selectedType = BiosecurityLog.eventTypes.first;
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
                  Text('Log Biosecurity Event',
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
                    items: BiosecurityLog.eventTypes
                        .map((t) => DropdownMenuItem(
                            value: t, child: Text(BiosecurityLog.label(t))))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => selectedType = v);
                    },
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextFormField(
                    controller: personnelCtrl,
                    decoration: const InputDecoration(
                        labelText: 'Personnel',
                        border: OutlineInputBorder()),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextFormField(
                    controller: productsCtrl,
                    decoration: const InputDecoration(
                        labelText: 'Products Used (optional)',
                        border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextFormField(
                    controller: notesCtrl,
                    maxLines: 2,
                    decoration: const InputDecoration(
                        labelText: 'Notes (optional)',
                        border: OutlineInputBorder()),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  FilledButton(
                    style: FilledButton.styleFrom(
                        backgroundColor: AppColors.poultryColor,
                        minimumSize: const Size.fromHeight(48)),
                    onPressed: () {
                      if (formKey.currentState?.validate() ?? false) {
                        ref.read(biosecurityLogProvider.notifier).add(BiosecurityLog(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          flockId: flockId,
                          date: dateCtrl.text.trim(),
                          eventType: selectedType,
                          personnel: personnelCtrl.text.trim(),
                          productsUsed: productsCtrl.text.trim().isEmpty
                              ? null
                              : productsCtrl.text.trim(),
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

class _LogCard extends ConsumerWidget {
  const _LogCard({required this.log, required this.flockId});
  final BiosecurityLog log;
  final String flockId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
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
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.poultryColor.withAlpha(26),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.health_and_safety_outlined,
                  size: 20, color: AppColors.poultryColor),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(BiosecurityLog.label(log.eventType),
                            style: theme.textTheme.bodyMedium
                                ?.copyWith(fontWeight: FontWeight.bold)),
                      ),
                      Text(log.date,
                          style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant)),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text('Personnel: ${log.personnel}',
                      style: theme.textTheme.bodySmall),
                  if (log.productsUsed != null)
                    Text('Products: ${log.productsUsed}',
                        style: theme.textTheme.bodySmall),
                  if (log.notes != null)
                    Text(log.notes!,
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
                    title: const Text('Delete Event'),
                    content:
                        const Text('Remove this biosecurity log entry?'),
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
                  ref.read(biosecurityLogProvider.notifier).delete(flockId, log.id);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

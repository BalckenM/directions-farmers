import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../shared/widgets/farm_app_bar.dart';
import '../../../shared/widgets/farm_scaffold.dart';
import '../providers/poultry_providers.dart';

class MoltManagementScreen extends ConsumerWidget {
  const MoltManagementScreen({super.key, required this.flockId});
  final String flockId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final events = ref.watch(moltEventProvider)[flockId] ?? [];

    return FarmScaffold(
      appBar: FarmAppBar(title: 'Molt Management'),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.poultryColor,
        foregroundColor: Colors.white,
        onPressed: () => _showAddSheet(context, ref),
        child: const Icon(Icons.add),
      ),
      body: events.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.xl),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.loop_outlined, size: 56, color: Colors.grey),
                    SizedBox(height: AppSpacing.md),
                    Text('No molt events recorded',
                        style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: events.length,
              separatorBuilder: (_, _) =>
                  const SizedBox(height: AppSpacing.sm),
              itemBuilder: (_, i) =>
                  _MoltCard(event: events[i], flockId: flockId),
            ),
    );
  }

  void _showAddSheet(BuildContext context, WidgetRef ref) {
    final startDateCtrl =
        TextEditingController(text: DateTime.now().toIso8601String().substring(0, 10));
    final returnLayCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    final feedRestCtrl = TextEditingController(text: '10');
    final durationCtrl = TextEditingController(text: '8');
    String selectedType = 'natural';
    final moltTypes = ['natural', 'induced', 'force'];
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
                  Text('Log Molt Event',
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: AppSpacing.md),
                  TextFormField(
                    controller: startDateCtrl,
                    decoration: const InputDecoration(
                        labelText: 'Molt Start Date (YYYY-MM-DD)',
                        border: OutlineInputBorder()),
                    validator: (v) =>
                        v == null || v.isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  DropdownButtonFormField<String>(
                    initialValue: selectedType,
                    decoration: const InputDecoration(
                        labelText: 'Molt Type',
                        border: OutlineInputBorder()),
                    items: moltTypes
                        .map((t) => DropdownMenuItem(
                            value: t,
                            child: Text('${t[0].toUpperCase()}${t.substring(1)}')))
                        .toList(),
                    onChanged: (v) {
                      if (v != null) setState(() => selectedType = v);
                    },
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: feedRestCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                              labelText: 'Feed Restriction Days',
                              border: OutlineInputBorder()),
                          validator: (v) => int.tryParse(v ?? '') == null
                              ? 'Enter a number'
                              : null,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: TextFormField(
                          controller: durationCtrl,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                              labelText: 'Duration (weeks)',
                              border: OutlineInputBorder()),
                          validator: (v) => int.tryParse(v ?? '') == null
                              ? 'Enter a number'
                              : null,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  TextFormField(
                    controller: returnLayCtrl,
                    decoration: const InputDecoration(
                        labelText: 'Expected Return to Lay (YYYY-MM-DD) — optional',
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
                        ref.read(moltEventProvider.notifier).add(MoltEvent(
                          id: DateTime.now().millisecondsSinceEpoch.toString(),
                          flockId: flockId,
                          moltStartDate: startDateCtrl.text.trim(),
                          moltType: selectedType,
                          feedRestrictionDays:
                              int.parse(feedRestCtrl.text.trim()),
                          expectedDurationWeeks:
                              int.parse(durationCtrl.text.trim()),
                          returnToLayDate: returnLayCtrl.text.trim().isEmpty
                              ? null
                              : returnLayCtrl.text.trim(),
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

class _MoltCard extends ConsumerWidget {
  const _MoltCard({required this.event, required this.flockId});
  final MoltEvent event;
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
              child: Icon(Icons.loop_outlined,
                  size: 20, color: AppColors.poultryColor),
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
                          '${event.moltType[0].toUpperCase()}${event.moltType.substring(1)} Molt',
                          style: const TextStyle(fontSize: 11),
                        ),
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                        backgroundColor:
                            AppColors.poultryColor.withAlpha(26),
                      ),
                      const Spacer(),
                      Text(event.moltStartDate,
                          style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                      'Feed restriction: ${event.feedRestrictionDays} days  |  Duration: ${event.expectedDurationWeeks} weeks',
                      style: theme.textTheme.bodySmall),
                  if (event.returnToLayDate != null)
                    Text('Return to lay: ${event.returnToLayDate}',
                        style: theme.textTheme.bodySmall),
                  if (event.notes != null)
                    Text(event.notes!,
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
                    content: const Text('Remove this molt event?'),
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
                      .read(moltEventProvider.notifier)
                      .delete(flockId, event.id);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}

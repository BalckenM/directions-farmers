import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/farm_scaffold.dart';
import '../../../../shared/widgets/farm_app_bar.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../models/pay_group.dart';
import '../../providers/payroll_providers.dart';
import '../../providers/payroll_action_providers.dart';

class AddEditPayGroupScreen extends ConsumerStatefulWidget {
  const AddEditPayGroupScreen({super.key, this.id});
  final String? id;

  @override
  ConsumerState<AddEditPayGroupScreen> createState() =>
      _AddEditPayGroupScreenState();
}

class _AddEditPayGroupScreenState
    extends ConsumerState<AddEditPayGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  PayFrequency _frequency = PayFrequency.monthly;
  int _dayOffset = 25;

  @override
  void initState() {
    super.initState();
    if (widget.id != null) {
      final group = ref
          .read(payGroupsProvider)
          .where((g) => g.id == widget.id)
          .firstOrNull;
      if (group != null) {
        _nameCtrl.text = group.name;
        _descCtrl.text = group.description ?? '';
        _frequency = group.frequency;
        _dayOffset = group.payDayOffset;
      }
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  List<int> get _dayOffsetOptions => switch (_frequency) {
        PayFrequency.weekly => List.generate(5, (i) => i + 1),
        PayFrequency.daily => [1],
        _ => List.generate(28, (i) => i + 1),
      };

  String _dayOffsetLabel(int offset) => switch (_frequency) {
        PayFrequency.weekly => const [
            'Monday',
            'Tuesday',
            'Wednesday',
            'Thursday',
            'Friday'
          ][offset - 1],
        _ => 'Day $offset',
      };

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.id != null;
    final notifierState = ref.watch(payGroupNotifierProvider);
    final options = _dayOffsetOptions;
    final currentOffset = options.contains(_dayOffset) ? _dayOffset : options.first;

    return FarmScaffold(
      appBar: FarmAppBar(title: isEdit ? 'Edit Pay Group' : 'Add Pay Group'),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Group Name *'),
              textCapitalization: TextCapitalization.words,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<PayFrequency>(
              initialValue: _frequency,
              decoration: const InputDecoration(labelText: 'Pay Frequency'),
              items: PayFrequency.values
                  .map((f) => DropdownMenuItem(
                      value: f,
                      child: Text(switch (f) {
                        PayFrequency.weekly => 'Weekly',
                        PayFrequency.biweekly => 'Bi-Weekly',
                        PayFrequency.monthly => 'Monthly',
                        PayFrequency.daily => 'Daily',
                      })))
                  .toList(),
              onChanged: (v) => setState(() {
                _frequency = v!;
                _dayOffset = _dayOffsetOptions.first;
              }),
            ),
            if (_frequency != PayFrequency.daily) ...[
              const SizedBox(height: 12),
              DropdownButtonFormField<int>(
                initialValue: currentOffset,
                decoration: InputDecoration(
                  labelText: _frequency == PayFrequency.weekly
                      ? 'Pay Day of Week'
                      : 'Pay Day of Month',
                ),
                items: options
                    .map((d) => DropdownMenuItem(
                        value: d, child: Text(_dayOffsetLabel(d))))
                    .toList(),
                onChanged: (v) => setState(() => _dayOffset = v!),
              ),
            ],
            const SizedBox(height: 12),
            TextFormField(
              controller: _descCtrl,
              decoration:
                  const InputDecoration(labelText: 'Description (optional)'),
              maxLines: 2,
            ),
            const SizedBox(height: 24),
            PrimaryButton(
              label: isEdit ? 'Update' : 'Create',
              isLoading: notifierState is AsyncLoading,
              onPressed:
                  notifierState is AsyncLoading ? null : () => _save(isEdit),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _save(bool isEdit) async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final now = DateTime.now();
    final existing = isEdit
        ? ref.read(payGroupsProvider).where((g) => g.id == widget.id).firstOrNull
        : null;
    final group = PayGroup(
      id: existing?.id ?? 'pg_${now.millisecondsSinceEpoch}',
      name: _nameCtrl.text.trim(),
      frequency: _frequency,
      payDayOffset: _frequency == PayFrequency.daily ? 1 : _dayOffset,
      description: _descCtrl.text.trim().isNotEmpty
          ? _descCtrl.text.trim()
          : null,
      isActive: existing?.isActive ?? true,
      createdAt: existing?.createdAt ?? now,
    );

    final notifier = ref.read(payGroupNotifierProvider.notifier);
    final result =
        isEdit ? await notifier.update(group) : await notifier.add(group);

    if (!mounted) return;
    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text(isEdit ? 'Pay group updated.' : 'Pay group created.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
      context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to save. Please try again.'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}

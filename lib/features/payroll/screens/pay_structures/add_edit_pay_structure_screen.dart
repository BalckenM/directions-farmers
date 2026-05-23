import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/widgets/farm_scaffold.dart';
import '../../../../shared/widgets/farm_app_bar.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../models/pay_structure.dart';
import '../../providers/payroll_providers.dart';
import '../../providers/payroll_action_providers.dart';

class AddEditPayStructureScreen extends ConsumerStatefulWidget {
  const AddEditPayStructureScreen({super.key, this.id});
  final String? id;

  @override
  ConsumerState<AddEditPayStructureScreen> createState() =>
      _AddEditPayStructureScreenState();
}

class _AddEditPayStructureScreenState
    extends ConsumerState<AddEditPayStructureScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _rateCtrl = TextEditingController();
  WageType _wageType = WageType.monthlySalary;
  bool _nmwaEnforced = true;

  String _wageTypeLabel(WageType t) => switch (t) {
        WageType.monthlySalary => 'Monthly Salary',
        WageType.hourlyRate => 'Hourly Rate',
        WageType.dailyRate => 'Daily Rate',
        WageType.piecework => 'Piecework',
      };

  @override
  void initState() {
    super.initState();
    if (widget.id != null) {
      final structure = ref
          .read(payStructuresProvider)
          .where((s) => s.id == widget.id)
          .firstOrNull;
      if (structure != null) {
        _nameCtrl.text = structure.name;
        _rateCtrl.text = structure.baseRate.toStringAsFixed(2);
        _wageType = structure.wageType;
        _nmwaEnforced = structure.nmwaEnforced;
      }
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _rateCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.id != null;
    final notifierState = ref.watch(payStructureNotifierProvider);
    return FarmScaffold(
      appBar: FarmAppBar(
          title: isEdit ? 'Edit Pay Structure' : 'Add Pay Structure'),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(labelText: 'Name *'),
              textCapitalization: TextCapitalization.words,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Required' : null,
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<WageType>(
              initialValue: _wageType,
              decoration: const InputDecoration(labelText: 'Wage Type'),
              items: WageType.values
                  .map((t) => DropdownMenuItem(
                      value: t, child: Text(_wageTypeLabel(t))))
                  .toList(),
              onChanged: (v) => setState(() => _wageType = v!),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _rateCtrl,
              decoration: InputDecoration(
                labelText: _wageType == WageType.monthlySalary
                    ? 'Monthly Salary (R) *'
                    : _wageType == WageType.dailyRate
                        ? 'Daily Rate (R) *'
                        : _wageType == WageType.piecework
                            ? 'Rate per Unit (R) *'
                            : 'Hourly Rate (R) *',
              ),
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Required';
                if (double.tryParse(v.trim()) == null) {
                  return 'Enter a valid number';
                }
                if (double.parse(v.trim()) <= 0) {
                  return 'Must be greater than 0';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              value: _nmwaEnforced,
              onChanged: (v) => setState(() => _nmwaEnforced = v),
              title: const Text('Enforce NMWA'),
              subtitle: const Text('Auto-check minimum wage compliance'),
              contentPadding: EdgeInsets.zero,
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
        ? ref
            .read(payStructuresProvider)
            .where((s) => s.id == widget.id)
            .firstOrNull
        : null;
    final structure = PayStructure(
      id: existing?.id ?? 'ps_${now.millisecondsSinceEpoch}',
      name: _nameCtrl.text.trim(),
      wageType: _wageType,
      baseRate: double.parse(_rateCtrl.text.trim()),
      nmwaEnforced: _nmwaEnforced,
      createdAt: existing?.createdAt ?? now,
    );

    final notifier = ref.read(payStructureNotifierProvider.notifier);
    final result = isEdit
        ? await notifier.update(structure)
        : await notifier.add(structure);

    if (!mounted) return;
    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              isEdit ? 'Pay structure updated.' : 'Pay structure created.'),
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

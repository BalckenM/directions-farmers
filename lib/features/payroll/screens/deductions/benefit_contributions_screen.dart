import 'package:flutter/material.dart';
import 'package:mobile_app/core/theme/app_colors.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mobile_app/features/payroll/models/benefit_contribution.dart';
import 'package:mobile_app/features/payroll/providers/payroll_action_providers.dart';
import 'package:mobile_app/features/payroll/providers/payroll_providers.dart';
import 'package:mobile_app/shared/widgets/farm_app_bar.dart';
import 'package:mobile_app/shared/widgets/farm_scaffold.dart';

final _zar = NumberFormat.currency(
  locale: 'en_ZA',
  symbol: 'R ',
  decimalDigits: 2,
);
final _dateFmt = DateFormat('d MMM y');

class BenefitContributionsScreen extends ConsumerWidget {
  const BenefitContributionsScreen({super.key, this.employeeId});

  /// When set, only contributions for this employee are shown.
  final String? employeeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final all = employeeId != null
        ? ref.watch(benefitContributionsByEmployeeProvider(employeeId!))
        : ref.watch(benefitContributionsProvider);

    return FarmScaffold(
      appBar: FarmAppBar(
        title: employeeId != null
            ? 'Benefit Contributions'
            : 'All Benefit Contributions',
      ),
      floatingActionButton: FloatingActionButton.extended(
        heroTag: null,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Add Contribution',
          style: TextStyle(color: Colors.white),
        ),
        onPressed: () => _showSheet(context, ref, null),
      ),
      body: all.isEmpty
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.account_balance_outlined,
                      size: 56,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'No benefit contributions yet.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Tap + to add pension, provident fund,\nmedical aid or retirement annuity.',
                      style: TextStyle(color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              itemCount: all.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final bc = all[i];
                return _BcTile(
                  bc: bc,
                  onEdit: () => _showSheet(context, ref, bc),
                  onDelete: () => _confirmDelete(context, ref, bc),
                );
              },
            ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    WidgetRef ref,
    BenefitContribution bc,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete contribution?'),
        content: Text(
          'Remove ${bc.type.label}${bc.fundName != null ? ' (${bc.fundName})' : ''}? '
          'This cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      await ref
          .read(benefitContributionNotifierProvider.notifier)
          .delete(bc.id);
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Contribution deleted.')));
      }
    }
  }

  void _showSheet(
    BuildContext context,
    WidgetRef ref,
    BenefitContribution? existing,
  ) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _BcSheet(employeeId: employeeId, existing: existing),
    );
  }
}

// ── Tile ──────────────────────────────────────────────────────────────────────

class _BcTile extends StatelessWidget {
  const _BcTile({
    required this.bc,
    required this.onEdit,
    required this.onDelete,
  });

  final BenefitContribution bc;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  Color get _typeColor => switch (bc.type) {
    BenefitType.pension => AppColors.primary,
    BenefitType.provident => AppColors.success,
    BenefitType.medicalAid => AppColors.error,
    BenefitType.retirementAnnuity => AppColors.secondary,
  };

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final color = _typeColor;

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.fromLTRB(16, 8, 8, 8),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(Icons.account_balance_outlined, color: color, size: 20),
        ),
        title: Text(
          bc.type.label,
          style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (bc.fundName != null)
              Text(
                bc.fundName!,
                style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              ),
            const SizedBox(height: 2),
            Row(
              children: [
                Text(
                  'EE: ${_zar.format(bc.employeeAmount)}',
                  style: tt.labelSmall?.copyWith(color: AppColors.primary),
                ),
                const SizedBox(width: 8),
                Text(
                  'ER: ${_zar.format(bc.employerAmount)}',
                  style: tt.labelSmall?.copyWith(color: AppColors.success),
                ),
              ],
            ),
            const SizedBox(height: 2),
            Text(
              'From ${_dateFmt.format(bc.effectiveFrom)}'
              '${bc.effectiveTo != null ? ' to ${_dateFmt.format(bc.effectiveTo!)}' : ''}',
              style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
            ),
          ],
        ),
        isThreeLine: true,
        trailing: PopupMenuButton<String>(
          onSelected: (v) {
            if (v == 'edit') onEdit();
            if (v == 'delete') onDelete();
          },
          itemBuilder: (_) => const [
            PopupMenuItem(
              value: 'edit',
              child: ListTile(
                leading: Icon(Icons.edit_outlined),
                title: Text('Edit'),
                contentPadding: EdgeInsets.zero,
              ),
            ),
            PopupMenuItem(
              value: 'delete',
              child: ListTile(
                leading: Icon(Icons.delete_outline, color: Colors.red),
                title: Text('Delete', style: TextStyle(color: Colors.red)),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Add / Edit sheet ──────────────────────────────────────────────────────────

class _BcSheet extends ConsumerStatefulWidget {
  const _BcSheet({required this.employeeId, required this.existing});

  final String? employeeId;
  final BenefitContribution? existing;

  @override
  ConsumerState<_BcSheet> createState() => _BcSheetState();
}

class _BcSheetState extends ConsumerState<_BcSheet> {
  final _formKey = GlobalKey<FormState>();
  final _eeCtrl = TextEditingController();
  final _erCtrl = TextEditingController();
  final _fundCtrl = TextEditingController();
  final _memberCtrl = TextEditingController();

  BenefitType _type = BenefitType.pension;
  DateTime? _effectiveFrom;
  DateTime? _effectiveTo;
  String? _selectedEmployeeId;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final bc = widget.existing;
    if (bc != null) {
      _type = bc.type;
      _eeCtrl.text = bc.employeeAmount.toStringAsFixed(2);
      _erCtrl.text = bc.employerAmount.toStringAsFixed(2);
      _fundCtrl.text = bc.fundName ?? '';
      _memberCtrl.text = bc.memberNumber ?? '';
      _effectiveFrom = bc.effectiveFrom;
      _effectiveTo = bc.effectiveTo;
      _selectedEmployeeId = bc.employeeId;
    } else {
      _selectedEmployeeId = widget.employeeId;
    }
  }

  @override
  void dispose() {
    _eeCtrl.dispose();
    _erCtrl.dispose();
    _fundCtrl.dispose();
    _memberCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate(bool isFrom) async {
    final result = await showDatePicker(
      context: context,
      initialDate: isFrom
          ? (_effectiveFrom ?? DateTime.now())
          : (_effectiveTo ?? DateTime.now()),
      firstDate: DateTime(2000),
      lastDate: DateTime(2050),
    );
    if (result != null) {
      setState(() {
        if (isFrom) {
          _effectiveFrom = result;
        } else {
          _effectiveTo = result;
        }
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_effectiveFrom == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an effective from date.')),
      );
      return;
    }
    if (_selectedEmployeeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an employee.')),
      );
      return;
    }
    setState(() => _saving = true);

    final bc = BenefitContribution(
      id:
          widget.existing?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      employeeId: _selectedEmployeeId!,
      type: _type,
      employeeAmount: double.tryParse(_eeCtrl.text.replaceAll(',', '.')) ?? 0,
      employerAmount: double.tryParse(_erCtrl.text.replaceAll(',', '.')) ?? 0,
      effectiveFrom: _effectiveFrom!,
      effectiveTo: _effectiveTo,
      fundName: _fundCtrl.text.trim().isEmpty ? null : _fundCtrl.text.trim(),
      memberNumber: _memberCtrl.text.trim().isEmpty
          ? null
          : _memberCtrl.text.trim(),
    );

    final notifier = ref.read(benefitContributionNotifierProvider.notifier);
    if (widget.existing != null) {
      await notifier.update(bc);
    } else {
      await notifier.add(bc);
    }

    if (!mounted) return;
    setState(() => _saving = false);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.existing != null
              ? 'Contribution updated.'
              : 'Contribution added.',
        ),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final employees = ref.watch(activeEmployeesProvider);
    final cs = Theme.of(context).colorScheme;
    final isEdit = widget.existing != null;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        24,
        16,
        24,
        MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: cs.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),

              Text(
                isEdit ? 'Edit Contribution' : 'Add Benefit Contribution',
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 20),

              // Employee selector (only if no fixed employeeId)
              if (widget.employeeId == null) ...[
                DropdownButtonFormField<String>(
                  initialValue: _selectedEmployeeId,
                  decoration: const InputDecoration(
                    labelText: 'Employee *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person_outline),
                  ),
                  items: employees
                      .map(
                        (e) => DropdownMenuItem(
                          value: e.id,
                          child: Text('${e.firstName} ${e.lastName}'),
                        ),
                      )
                      .toList(),
                  onChanged: (v) => setState(() => _selectedEmployeeId = v),
                  validator: (v) => v == null ? 'Required' : null,
                ),
                const SizedBox(height: 16),
              ],

              // Type
              DropdownButtonFormField<BenefitType>(
                initialValue: _type,
                decoration: const InputDecoration(
                  labelText: 'Benefit Type *',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.account_balance_outlined),
                ),
                items: BenefitType.values
                    .map(
                      (t) => DropdownMenuItem(
                        value: t,
                        child: Text('${t.label} (SARS ${t.sarsCode})'),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _type = v ?? _type),
              ),
              const SizedBox(height: 16),

              // Amounts
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _eeCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                      ],
                      decoration: const InputDecoration(
                        labelText: 'Employee Amount (R) *',
                        border: OutlineInputBorder(),
                        prefixText: 'R ',
                      ),
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Required';
                        if (double.tryParse(v.replaceAll(',', '.')) == null) {
                          return 'Invalid';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _erCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                      ],
                      decoration: const InputDecoration(
                        labelText: 'Employer Amount (R)',
                        border: OutlineInputBorder(),
                        prefixText: 'R ',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Fund name
              TextFormField(
                controller: _fundCtrl,
                decoration: const InputDecoration(
                  labelText: 'Fund / Scheme Name',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.business_outlined),
                  hintText: 'e.g. Discovery Health Standard',
                ),
              ),
              const SizedBox(height: 16),

              // Member number
              TextFormField(
                controller: _memberCtrl,
                decoration: const InputDecoration(
                  labelText: 'Member / Scheme Number',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.badge_outlined),
                ),
              ),
              const SizedBox(height: 16),

              // Effective from / to
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _pickDate(true),
                      borderRadius: BorderRadius.circular(8),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Effective From *',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.calendar_today_outlined),
                          suffixIcon: _effectiveFrom != null
                              ? null
                              : const Icon(Icons.arrow_drop_down),
                        ),
                        child: Text(
                          _effectiveFrom != null
                              ? _dateFmt.format(_effectiveFrom!)
                              : 'Select date',
                          style: _effectiveFrom != null
                              ? null
                              : TextStyle(color: Theme.of(context).hintColor),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: () => _pickDate(false),
                      borderRadius: BorderRadius.circular(8),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          labelText: 'Effective To',
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.calendar_today_outlined),
                          suffixIcon: _effectiveTo != null
                              ? IconButton(
                                  icon: const Icon(Icons.clear, size: 18),
                                  onPressed: () =>
                                      setState(() => _effectiveTo = null),
                                )
                              : const Icon(Icons.arrow_drop_down),
                        ),
                        child: Text(
                          _effectiveTo != null
                              ? _dateFmt.format(_effectiveTo!)
                              : 'Open-ended',
                          style: _effectiveTo != null
                              ? null
                              : TextStyle(color: Theme.of(context).hintColor),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              FilledButton(
                onPressed: _saving ? null : _save,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size.fromHeight(48),
                ),
                child: _saving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : Text(isEdit ? 'Update Contribution' : 'Add Contribution'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

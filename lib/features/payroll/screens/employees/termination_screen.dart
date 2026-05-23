// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../shared/widgets/farm_scaffold.dart';
import '../../../../shared/widgets/farm_app_bar.dart';
import '../../models/payroll_employee.dart';
import '../../providers/payroll_providers.dart';
import '../../providers/payroll_action_providers.dart';
import '../../theme/payroll_tokens.dart';

typedef _C = PayrollTokens;
final _mFmt = DateFormat('d MMM y');

/// Termination wizard for a payroll employee.
///
/// Steps:
///   1. Reason & last day
///   2. Notice period & severance
///   3. Clearance checklist
///   4. Confirm & submit
class TerminationScreen extends ConsumerStatefulWidget {
  const TerminationScreen({super.key, required this.employeeId});
  final String employeeId;

  @override
  ConsumerState<TerminationScreen> createState() => _TerminationScreenState();
}

class _TerminationScreenState extends ConsumerState<TerminationScreen> {
  int _step = 0;
  bool _submitting = false;

  // Step 1 state
  _TermReason? _reason;
  DateTime _lastDay = DateTime.now();
  final _reasonNotesCtrl = TextEditingController();

  // Step 2 state
  int _noticePeriodDays = 0;
  final _severanceCtrl = TextEditingController();

  // Step 3 state
  final _clearanceItems = {
    'Uniform / PPE returned': false,
    'Company vehicle / equipment returned': false,
    'Access cards / keys returned': false,
    'Company-issued phone / laptop returned': false,
    'Final timesheet approved': false,
    'Leave encashment calculated': false,
    'Outstanding loans / deductions settled': false,
  };

  @override
  void dispose() {
    _reasonNotesCtrl.dispose();
    _severanceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final employees = ref.watch(employeesProvider);
    final employee =
        employees.where((e) => e.id == widget.employeeId).firstOrNull;

    if (employee == null) {
      return FarmScaffold(
        appBar: const FarmAppBar(title: 'Terminate Employee'),
        body: const Center(child: Text('Employee not found')),
      );
    }

    return FarmScaffold(
      appBar: FarmAppBar(
        title: 'Terminate Employee',
        subtitle: employee.fullName,
      ),
      body: Column(
        children: [
          _StepIndicator(currentStep: _step, totalSteps: 4),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _buildCurrentStep(context, employee),
            ),
          ),
          _buildNavButtons(context),
        ],
      ),
    );
  }

  Widget _buildCurrentStep(BuildContext context, PayrollEmployee employee) {
    return switch (_step) {
      0 => _StepReason(
          reason: _reason,
          lastDay: _lastDay,
          notesCtrl: _reasonNotesCtrl,
          onReasonChanged: (r) => setState(() => _reason = r),
          onLastDayChanged: (d) => setState(() => _lastDay = d),
        ),
      1 => _StepNotice(
          employee: employee,
          lastDay: _lastDay,
          noticePeriodDays: _noticePeriodDays,
          severanceCtrl: _severanceCtrl,
          onNoticeChanged: (v) => setState(() => _noticePeriodDays = v),
        ),
      2 => _StepClearance(
          items: _clearanceItems,
          onToggle: (k, v) => setState(() => _clearanceItems[k] = v),
        ),
      3 => _StepConfirm(
          employee: employee,
          reason: _reason,
          lastDay: _lastDay,
          noticePeriodDays: _noticePeriodDays,
          severancePay: double.tryParse(_severanceCtrl.text),
          notesCtrl: _reasonNotesCtrl,
          clearanceItems: _clearanceItems,
        ),
      _ => const SizedBox.shrink(),
    };
  }

  Widget _buildNavButtons(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
      decoration: BoxDecoration(
        color: cs.surface,
        border: Border(top: BorderSide(color: cs.outlineVariant)),
      ),
      child: Row(
        children: [
          if (_step > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _step--),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('Back'),
              ),
            ),
          if (_step > 0) const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _submitting ? null : _onNextOrSubmit,
              style: ElevatedButton.styleFrom(
                backgroundColor: _step < 3 ? _C.navy : _C.rose,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(48),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
              ),
              child: _submitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : Text(
                      _step < 3 ? 'Continue' : 'Confirm Termination',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void _onNextOrSubmit() {
    if (_step < 3) {
      if (_step == 0 && _reason == null) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Please select a termination reason')));
        return;
      }
      setState(() => _step++);
    } else {
      _confirmTermination();
    }
  }

  Future<void> _confirmTermination() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirm Termination'),
        content: const Text(
            'This will permanently terminate the employee. '
            'This action cannot be undone. Are you sure?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: _C.rose),
            child: const Text('Yes, Terminate',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _submitting = true);
    final notifier = ref.read(employeeNotifierProvider.notifier);
    final reasonStr = _reason?.label ?? 'Resignation';
    final notes = _reasonNotesCtrl.text.trim();
    final fullReason = notes.isNotEmpty ? '$reasonStr — $notes' : reasonStr;

    final result = await notifier.terminate(
        widget.employeeId, _lastDay, fullReason);
    setState(() => _submitting = false);

    if (!mounted) return;
    if (result != null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Employee terminated successfully')));
      context.pop();
      context.pop(); // pop back to employee list
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Termination failed. Please try again.')));
    }
  }
}

// ─── Reason options ───────────────────────────────────────────────────────────

enum _TermReason {
  resignation('Resignation', Icons.exit_to_app_outlined),
  dismissal('Dismissal for misconduct', Icons.warning_amber_outlined),
  retrenchment('Retrenchment', Icons.business_center_outlined),
  endOfContract('End of contract', Icons.event_available_outlined),
  retirement('Retirement', Icons.elderly_outlined),
  death('Death in service', Icons.sentiment_very_dissatisfied_outlined),
  constructiveDismissal('Constructive dismissal', Icons.gavel_outlined);

  const _TermReason(this.label, this.icon);
  final String label;
  final IconData icon;
}

// ─── Step 1: Reason & Last Day ────────────────────────────────────────────────

class _StepReason extends StatelessWidget {
  const _StepReason({
    required this.reason,
    required this.lastDay,
    required this.notesCtrl,
    required this.onReasonChanged,
    required this.onLastDayChanged,
  });

  final _TermReason? reason;
  final DateTime lastDay;
  final TextEditingController notesCtrl;
  final ValueChanged<_TermReason?> onReasonChanged;
  final ValueChanged<DateTime> onLastDayChanged;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Reason for Termination',
            style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        ..._TermReason.values.map((r) => _ReasonTile(
              reason: r,
              selected: reason == r,
              onTap: () => onReasonChanged(r),
            )),
        const SizedBox(height: 16),
        Text('Last Working Day',
            style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: lastDay,
              firstDate: DateTime(2000),
              lastDate: DateTime.now().add(const Duration(days: 365)),
            );
            if (picked != null) onLastDayChanged(picked);
          },
          borderRadius: BorderRadius.circular(10),
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              border: Border.all(color: cs.outline),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(Icons.calendar_today_outlined,
                    size: 18, color: cs.onSurfaceVariant),
                const SizedBox(width: 10),
                Text(_mFmt.format(lastDay), style: tt.bodyMedium),
                const Spacer(),
                Icon(Icons.edit_outlined,
                    size: 16, color: cs.onSurfaceVariant),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        Text('Additional Notes',
            style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        TextField(
          controller: notesCtrl,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Optional context, HR notes, etc.',
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10)),
            isDense: true,
            contentPadding: const EdgeInsets.all(12),
          ),
        ),
      ],
    );
  }
}

class _ReasonTile extends StatelessWidget {
  const _ReasonTile({
    required this.reason,
    required this.selected,
    required this.onTap,
  });
  final _TermReason reason;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? _C.navy : cs.outlineVariant,
              width: selected ? 2 : 1,
            ),
            color: selected
                ? _C.navy.withValues(alpha: 0.06)
                : cs.surface,
          ),
          child: Row(
            children: [
              Icon(reason.icon,
                  size: 18,
                  color: selected ? _C.navy : cs.onSurfaceVariant),
              const SizedBox(width: 10),
              Text(reason.label,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight:
                          selected ? FontWeight.w700 : FontWeight.w400)),
              const Spacer(),
              if (selected)
                Icon(Icons.check_circle,
                    size: 18, color: _C.navy),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Step 2: Notice & Severance ───────────────────────────────────────────────

class _StepNotice extends StatelessWidget {
  const _StepNotice({
    required this.employee,
    required this.lastDay,
    required this.noticePeriodDays,
    required this.severanceCtrl,
    required this.onNoticeChanged,
  });
  final PayrollEmployee employee;
  final DateTime lastDay;
  final int noticePeriodDays;
  final TextEditingController severanceCtrl;
  final ValueChanged<int> onNoticeChanged;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    // Simplified BCEA notice guidance
    final yearsService =
        lastDay.difference(employee.startDate).inDays / 365;
    final guidedNotice = yearsService < 1
        ? 7
        : yearsService < 4
            ? 14
            : 28;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Notice Period & Final Pay',
            style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _C.sky.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _C.sky.withValues(alpha: 0.4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('BCEA Minimum Notice Guidance',
                  style: tt.labelMedium
                      ?.copyWith(fontWeight: FontWeight.w700, color: _C.sky)),
              const SizedBox(height: 4),
              Text(
                'Based on ${yearsService.toStringAsFixed(1)} years of service: '
                'minimum $guidedNotice days notice.',
                style: tt.bodySmall,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text('Notice Period (days)',
            style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        Row(
          children: [
            IconButton(
              onPressed: noticePeriodDays > 0
                  ? () => onNoticeChanged(noticePeriodDays - 1)
                  : null,
              icon: const Icon(Icons.remove_circle_outline),
              color: _C.navy,
            ),
            Expanded(
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  border: Border.all(color: cs.outlineVariant),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text('$noticePeriodDays days',
                    style: tt.titleMedium
                        ?.copyWith(fontWeight: FontWeight.w700)),
              ),
            ),
            IconButton(
              onPressed: () => onNoticeChanged(noticePeriodDays + 1),
              icon: const Icon(Icons.add_circle_outline),
              color: _C.navy,
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text('Severance Pay (R)', style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        TextField(
          controller: severanceCtrl,
          keyboardType:
              const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            hintText: '0.00 (leave blank if not applicable)',
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10)),
            isDense: true,
            contentPadding: const EdgeInsets.all(12),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _C.amber.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _C.amber.withValues(alpha: 0.4)),
          ),
          child: Text(
            'Remember: UIF declaration must be submitted within 15 days of termination. '
            'Final payslip including accrued leave pay must be issued on or before the last working day.',
            style: tt.bodySmall?.copyWith(color: _C.amber),
          ),
        ),
      ],
    );
  }
}

// ─── Step 3: Clearance Checklist ─────────────────────────────────────────────

class _StepClearance extends StatelessWidget {
  const _StepClearance({
    required this.items,
    required this.onToggle,
  });
  final Map<String, bool> items;
  final void Function(String key, bool value) onToggle;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final completedCount = items.values.where((v) => v).length;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Clearance Checklist',
            style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text(
          '$completedCount / ${items.length} items completed',
          style: tt.bodySmall?.copyWith(
              color: completedCount == items.length
                  ? _C.green
                  : Theme.of(context).colorScheme.onSurfaceVariant),
        ),
        const SizedBox(height: 12),
        ...items.entries.map((entry) => CheckboxListTile(
              value: entry.value,
              title: Text(entry.key, style: tt.bodyMedium),
              activeColor: _C.green,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
              onChanged: (v) => onToggle(entry.key, v ?? false),
            )),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _C.rose.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _C.rose.withValues(alpha: 0.3)),
          ),
          child: Text(
            'Clearance checklist items are advisory. You can proceed without '
            'completing all items but note that outstanding items will be recorded.',
            style: tt.bodySmall,
          ),
        ),
      ],
    );
  }
}

// ─── Step 4: Confirmation Summary ────────────────────────────────────────────

class _StepConfirm extends StatelessWidget {
  const _StepConfirm({
    required this.employee,
    required this.reason,
    required this.lastDay,
    required this.noticePeriodDays,
    required this.severancePay,
    required this.notesCtrl,
    required this.clearanceItems,
  });
  final PayrollEmployee employee;
  final _TermReason? reason;
  final DateTime lastDay;
  final int noticePeriodDays;
  final double? severancePay;
  final TextEditingController notesCtrl;
  final Map<String, bool> clearanceItems;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final completedClearance =
        clearanceItems.values.where((v) => v).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Confirm Termination',
            style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        const SizedBox(height: 4),
        Text('Please review all details before confirming.',
            style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
        const SizedBox(height: 16),
        _ConfirmRow(label: 'Employee', value: employee.fullName),
        _ConfirmRow(
            label: 'Reason',
            value: reason?.label ?? '—',
            valueColor: _C.rose),
        _ConfirmRow(label: 'Last Working Day', value: _mFmt.format(lastDay)),
        _ConfirmRow(
            label: 'Notice Period', value: '$noticePeriodDays days'),
        _ConfirmRow(
          label: 'Severance Pay',
          value: severancePay != null
              ? 'R ${severancePay!.toStringAsFixed(2)}'
              : 'N/A',
        ),
        _ConfirmRow(
          label: 'Clearance',
          value:
              '$completedClearance / ${clearanceItems.length} items done',
          valueColor: completedClearance == clearanceItems.length
              ? _C.green
              : _C.amber,
        ),
        if (notesCtrl.text.trim().isNotEmpty)
          _ConfirmRow(label: 'Notes', value: notesCtrl.text.trim()),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: _C.rose.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: _C.rose.withValues(alpha: 0.4)),
          ),
          child: Row(
            children: [
              const Icon(Icons.warning_amber_outlined,
                  size: 18, color: _C.rose),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'This action is irreversible. The employee status will be set to '
                  '"Terminated" and access to all payroll runs will be revoked.',
                  style: tt.bodySmall?.copyWith(color: _C.rose),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ConfirmRow extends StatelessWidget {
  const _ConfirmRow({required this.label, required this.value, this.valueColor});
  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(label,
                style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant)),
          ),
          Expanded(
            child: Text(value,
                style: tt.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600, color: valueColor)),
          ),
        ],
      ),
    );
  }
}

// ─── Step Indicator ───────────────────────────────────────────────────────────

class _StepIndicator extends StatelessWidget {
  const _StepIndicator(
      {required this.currentStep, required this.totalSteps});
  final int currentStep;
  final int totalSteps;

  static const _labels = ['Reason', 'Notice', 'Clearance', 'Confirm'];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Container(
      color: cs.surfaceContainerLow,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: List.generate(totalSteps, (i) {
          final done = i < currentStep;
          final active = i == currentStep;
          return Expanded(
            child: Row(
              children: [
                Column(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: done
                          ? _C.green
                          : active
                              ? _C.navy
                              : cs.outlineVariant,
                      child: done
                          ? const Icon(Icons.check, size: 14, color: Colors.white)
                          : Text('${i + 1}',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: active
                                      ? Colors.white
                                      : cs.onSurfaceVariant)),
                    ),
                    const SizedBox(height: 2),
                    Text(_labels[i],
                        style: tt.labelSmall?.copyWith(
                            color: active ? _C.navy : cs.onSurfaceVariant,
                            fontWeight: active
                                ? FontWeight.w700
                                : FontWeight.w400)),
                  ],
                ),
                if (i < totalSteps - 1)
                  Expanded(
                    child: Divider(
                      color: done ? _C.green : cs.outlineVariant,
                      thickness: 2,
                      endIndent: 4,
                      indent: 4,
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

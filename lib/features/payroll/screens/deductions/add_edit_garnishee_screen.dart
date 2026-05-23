// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../shared/widgets/farm_app_bar.dart';
import '../../../../shared/widgets/farm_scaffold.dart';
import '../../models/garnishee_order.dart';
import '../../providers/payroll_action_providers.dart';
import '../../providers/payroll_providers.dart';
import '../../theme/payroll_tokens.dart';

typedef _C = PayrollTokens;
final _mFmt = DateFormat('d MMM y');

/// Add or edit a garnishee (court emoluments attachment) order.
///
/// - Pass [orderId] to enter edit mode.
/// - Pass [preselectedEmployeeId] to pre-fill the employee dropdown.
class AddEditGarnisheeScreen extends ConsumerStatefulWidget {
  const AddEditGarnisheeScreen({
    super.key,
    this.orderId,
    this.preselectedEmployeeId,
  });

  final String? orderId;
  final String? preselectedEmployeeId;

  @override
  ConsumerState<AddEditGarnisheeScreen> createState() =>
      _AddEditGarnisheeScreenState();
}

class _AddEditGarnisheeScreenState
    extends ConsumerState<AddEditGarnisheeScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _submitting = false;
  late bool _isEditMode;

  // ─── field controllers ─────────────────────────────────────────────────────
  String? _selectedEmployeeId;
  final _courtOrderRefCtrl = TextEditingController();
  final _creditorNameCtrl = TextEditingController();
  final _monthlyAmtCtrl = TextEditingController();
  final _totalOwedCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  DateTime _startDate = DateTime.now();
  GarnisheeStatus _status = GarnisheeStatus.active;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.orderId != null;
    _selectedEmployeeId = widget.preselectedEmployeeId;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isEditMode && _courtOrderRefCtrl.text.isEmpty) {
      final order =
          ref.read(garnisheeByIdProvider(widget.orderId!));
      if (order != null) _populateFromOrder(order);
    }
  }

  void _populateFromOrder(GarnisheeOrder order) {
    _selectedEmployeeId = order.employeeId;
    _courtOrderRefCtrl.text = order.courtOrderRef;
    _creditorNameCtrl.text = order.creditorName;
    _monthlyAmtCtrl.text = order.monthlyDeductionAmount.toStringAsFixed(2);
    _totalOwedCtrl.text = order.totalOwed.toStringAsFixed(2);
    _notesCtrl.text = order.notes ?? '';
    _startDate = order.createdAt;
    _status = order.status;
  }

  @override
  void dispose() {
    _courtOrderRefCtrl.dispose();
    _creditorNameCtrl.dispose();
    _monthlyAmtCtrl.dispose();
    _totalOwedCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedEmployeeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select an employee')));
      return;
    }
    setState(() => _submitting = true);

    final notifier = ref.read(garnisheeNotifierProvider.notifier);
    final now = DateTime.now();

    if (_isEditMode) {
      final existing = ref.read(garnisheeByIdProvider(widget.orderId!));
      if (existing == null) {
        setState(() => _submitting = false);
        return;
      }
      final updated = existing.copyWith(
        employeeId: _selectedEmployeeId,
        courtOrderRef: _courtOrderRefCtrl.text.trim(),
        creditorName: _creditorNameCtrl.text.trim(),
        monthlyDeductionAmount:
            double.tryParse(_monthlyAmtCtrl.text.trim()) ?? 0,
        totalOwed: double.tryParse(_totalOwedCtrl.text.trim()) ?? 0,
        notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
        status: _status,
        satisfiedAt: _status == GarnisheeStatus.satisfied ? now : null,
      );
      await notifier.update(updated);
    } else {
      final newOrder = GarnisheeOrder(
        id: 'gar_${DateTime.now().millisecondsSinceEpoch}',
        employeeId: _selectedEmployeeId!,
        courtOrderRef: _courtOrderRefCtrl.text.trim(),
        creditorName: _creditorNameCtrl.text.trim(),
        monthlyDeductionAmount:
            double.tryParse(_monthlyAmtCtrl.text.trim()) ?? 0,
        totalOwed: double.tryParse(_totalOwedCtrl.text.trim()) ?? 0,
        amountDeducted: 0,
        status: _status,
        createdAt: _startDate,
        notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      );
      await notifier.add(newOrder);
    }

    setState(() => _submitting = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(_isEditMode
              ? 'Garnishee order updated'
              : 'Garnishee order registered')));
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final employees = ref.watch(employeesProvider);
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return FarmScaffold(
      appBar: FarmAppBar(
        title: _isEditMode ? 'Edit Garnishee Order' : 'Register Garnishee Order',
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── Info banner ──────────────────────────────────────────────
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _C.amber.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _C.amber.withValues(alpha: 0.4)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, size: 16, color: _C.amber),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Under BCEA/NCA, total non-statutory deductions may not exceed 25% of net pay. '
                      'The system will raise a compliance alert if this cap is exceeded.',
                      style: tt.bodySmall?.copyWith(color: _C.amber),
                    ),
                  ),
                ],
              ),
            ),

            _sectionLabel(context, 'Employee'),
            DropdownButtonFormField<String>(
              initialValue: _selectedEmployeeId,
              decoration: _fieldDecoration('Select employee', context),
              items: employees
                  .map((e) => DropdownMenuItem(
                      value: e.id, child: Text(e.fullName)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedEmployeeId = v),
              validator: (v) =>
                  v == null ? 'Please select an employee' : null,
            ),
            const SizedBox(height: 12),

            _sectionLabel(context, 'Court Order Details'),
            TextFormField(
              controller: _courtOrderRefCtrl,
              decoration:
                  _fieldDecoration('Court order reference number', context),
              textCapitalization: TextCapitalization.characters,
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Court order reference is required'
                  : null,
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _creditorNameCtrl,
              decoration: _fieldDecoration('Creditor / applicant name', context),
              textCapitalization: TextCapitalization.words,
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Creditor name is required'
                  : null,
            ),
            const SizedBox(height: 16),

            _sectionLabel(context, 'Financial Details'),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _monthlyAmtCtrl,
                    decoration: _fieldDecoration('Monthly deduction (R)', context),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Required';
                      if (double.tryParse(v.trim()) == null) return 'Invalid amount';
                      if ((double.tryParse(v.trim()) ?? 0) <= 0) return 'Must be > 0';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: _totalOwedCtrl,
                    decoration: _fieldDecoration('Total owed (R)', context),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Required';
                      if (double.tryParse(v.trim()) == null) return 'Invalid amount';
                      if ((double.tryParse(v.trim()) ?? 0) <= 0) return 'Must be > 0';
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ── Date picker ──────────────────────────────────────────────
            _sectionLabel(context, 'Order Date'),
            InkWell(
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: _startDate,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now().add(const Duration(days: 365)),
                );
                if (picked != null) setState(() => _startDate = picked);
              },
              borderRadius: BorderRadius.circular(10),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                decoration: BoxDecoration(
                  border: Border.all(color: cs.outline),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  children: [
                    Icon(Icons.calendar_today_outlined,
                        size: 18, color: cs.onSurfaceVariant),
                    const SizedBox(width: 10),
                    Text(_mFmt.format(_startDate),
                        style: tt.bodyMedium),
                    const Spacer(),
                    Icon(Icons.edit_outlined,
                        size: 16, color: cs.onSurfaceVariant),
                  ],
                ),
              ),
            ),

            // ── Status (edit mode only) ───────────────────────────────────
            if (_isEditMode) ...[
              const SizedBox(height: 16),
              _sectionLabel(context, 'Status'),
              DropdownButtonFormField<GarnisheeStatus>(
                initialValue: _status,
                decoration: _fieldDecoration('Status', context),
                items: GarnisheeStatus.values
                    .map((s) => DropdownMenuItem(
                        value: s, child: Text(_statusLabel(s))))
                    .toList(),
                onChanged: (v) =>
                    v != null ? setState(() => _status = v) : null,
              ),
            ],

            const SizedBox(height: 16),
            _sectionLabel(context, 'Notes (optional)'),
            TextFormField(
              controller: _notesCtrl,
              decoration: _fieldDecoration(
                  'Additional notes about this order…', context),
              maxLines: 3,
              maxLength: 500,
            ),

            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _submitting ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _C.navy,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: _submitting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : Text(
                        _isEditMode ? 'Save Changes' : 'Register Order',
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 16),
                      ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration(String hint, BuildContext context) {
    return InputDecoration(
      hintText: hint,
      isDense: true,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    );
  }

  Widget _sectionLabel(BuildContext context, String text) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Text(
        text,
        style: tt.labelMedium
            ?.copyWith(fontWeight: FontWeight.w700, color: cs.onSurface),
      ),
    );
  }

  String _statusLabel(GarnisheeStatus s) => switch (s) {
        GarnisheeStatus.active    => 'Active',
        GarnisheeStatus.satisfied => 'Satisfied (paid in full)',
        GarnisheeStatus.suspended => 'Suspended',
        GarnisheeStatus.cancelled => 'Cancelled',
      };
}

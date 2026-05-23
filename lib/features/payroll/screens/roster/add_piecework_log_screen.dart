import '../../theme/payroll_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/piecework_log.dart';
import '../../providers/payroll_providers.dart';
import '../../providers/payroll_action_providers.dart';

class AddPieceworkLogScreen extends ConsumerStatefulWidget {
  const AddPieceworkLogScreen({super.key, this.preselectedEmployeeId, this.preselectedDate});
  final String? preselectedEmployeeId;
  final DateTime? preselectedDate;

  @override
  ConsumerState<AddPieceworkLogScreen> createState() => _AddPieceworkLogScreenState();
}

class _AddPieceworkLogScreenState extends ConsumerState<AddPieceworkLogScreen> {
  final _formKey = GlobalKey<FormState>();
  final _quantityCtrl  = TextEditingController();
  final _rateCtrl      = TextEditingController();
  final _unitCtrl      = TextEditingController();
  final _notesCtrl     = TextEditingController();

  String? _employeeId;
  late DateTime _date;
  String? _shiftId;
  String _payrollCode = 'GRAPE_PICK';
  bool _saving = false;

  static const List<String> _activityCodes = [
    'GRAPE_PICK', 'APPLE_PICK', 'SUPERVISION', 'OTHER',
  ];

  @override
  void initState() {
    super.initState();
    _employeeId = widget.preselectedEmployeeId;
    _date = widget.preselectedDate ?? DateTime.now();
  }

  @override
  void dispose() {
    _quantityCtrl.dispose();
    _rateCtrl.dispose();
    _unitCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  String _fmt(DateTime d) {
    const months = ['','Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${d.day.toString().padLeft(2,'0')} ${months[d.month]} ${d.year}';
  }

  DateTime _mondayOf(DateTime d) {
    return d.subtract(Duration(days: d.weekday - 1));
  }

  double get _computedGross {
    final q = double.tryParse(_quantityCtrl.text) ?? 0.0;
    final r = double.tryParse(_rateCtrl.text) ?? 0.0;
    return q * r;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_employeeId == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Select an employee'), backgroundColor: PayrollTokens.rose,
      ));
      return;
    }
    setState(() => _saving = true);
    final now = DateTime.now();
    final log = PieceworkLog(
      id: 'pw_${now.millisecondsSinceEpoch}',
      employeeId: _employeeId!,
      date: _date,
      shiftId: _shiftId,
      payrollCode: _payrollCode,
      unit: _unitCtrl.text.trim().isEmpty ? 'unit' : _unitCtrl.text.trim(),
      quantity: double.parse(_quantityCtrl.text),
      ratePerUnit: double.parse(_rateCtrl.text),
      recordedByUserId: 'usr_manager',
      notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
      createdAt: now,
    );
    final result = await ref.read(pieceworkNotifierProvider.notifier).addLog(log);
    if (!mounted) return;
    setState(() => _saving = false);
    if (result != null) {
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Failed to save piecework log'), backgroundColor: PayrollTokens.rose,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final employees = ref.watch(activeEmployeesProvider);
    final monday   = _mondayOf(_date);
    final shifts   = ref.watch(shiftsProvider(ShiftFilter(
        weekStart: monday,
        employeeId: _employeeId)));

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 244, 246, 249),
      appBar: AppBar(
        backgroundColor: PayrollTokens.navy,
        foregroundColor: Colors.white,
        title: const Text('Log Piecework',
            style: TextStyle(fontWeight: FontWeight.w700)),
        elevation: 0,
        actions: [
          if (_saving)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                  width: 20, height: 20,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2)),
            )
          else
            TextButton(
              onPressed: _save,
              child: const Text('SAVE',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w700)),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── Worker & Date ────────────────────────────────────────────
            _SectionCard(title: 'Worker & Date', children: [
              DropdownButtonFormField<String>(
                initialValue: _employeeId,
                decoration: _inputDec('Employee', icon: Icons.person_outline),
                hint: const Text('Select employee'),
                items: employees
                    .map((e) => DropdownMenuItem(
                          value: e.id,
                          child: Text(e.fullName,
                              overflow: TextOverflow.ellipsis),
                        ))
                    .toList(),
                onChanged: (v) => setState(() {
                  _employeeId = v;
                  _shiftId = null; // reset shift when employee changes
                }),
                validator: (v) => v == null ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(
                      color: PayrollTokens.navy.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.calendar_today,
                      color: PayrollTokens.navy, size: 20),
                ),
                title: const Text('Date',
                    style: TextStyle(fontSize: 12, color: Colors.grey)),
                subtitle: Text(_fmt(_date),
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: PayrollTokens.navy)),
                onTap: () async {
                  final d = await showDatePicker(
                    context: context,
                    initialDate: _date,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                  );
                  if (d != null) setState(() { _date = d; _shiftId = null; });
                },
                trailing:
                    const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
              ),
            ]),
            const SizedBox(height: 16),

            // ── Shift (optional) ────────────────────────────────────────
            _SectionCard(title: 'Shift (optional)', children: [
              DropdownButtonFormField<String?>(
                initialValue: _shiftId,
                decoration:
                    _inputDec('Link to shift', icon: Icons.schedule_outlined),
                hint: const Text('None'),
                items: [
                  const DropdownMenuItem(value: null, child: Text('None')),
                  ...shifts.map((s) => DropdownMenuItem(
                        value: s.id,
                        child: Text(
                            '${s.taskCode}  ${s.startTime}–${s.endTime}',
                            overflow: TextOverflow.ellipsis),
                      )),
                ],
                onChanged: (v) => setState(() => _shiftId = v),
              ),
            ]),
            const SizedBox(height: 16),

            // ── Activity ────────────────────────────────────────────────
            _SectionCard(title: 'Activity', children: [
              DropdownButtonFormField<String>(
                initialValue: _payrollCode,
                decoration:
                    _inputDec('Activity code', icon: Icons.category_outlined),
                items: _activityCodes
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => _payrollCode = v);
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _unitCtrl,
                decoration: _inputDec('Unit (e.g. kg, crates)',
                    icon: Icons.straighten_outlined),
              ),
            ]),
            const SizedBox(height: 16),

            // ── Quantity & Rate ─────────────────────────────────────────
            _SectionCard(title: 'Quantity & Rate', children: [
              Row(children: [
                Expanded(
                  child: TextFormField(
                    controller: _quantityCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: _inputDec('Quantity', icon: Icons.numbers),
                    onChanged: (_) => setState(() {}),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Required';
                      if (double.tryParse(v) == null) return 'Invalid number';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _rateCtrl,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    decoration: _inputDec('Rate / unit (R)',
                        icon: Icons.attach_money),
                    onChanged: (_) => setState(() {}),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Required';
                      if (double.tryParse(v) == null) return 'Invalid number';
                      return null;
                    },
                  ),
                ),
              ]),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                decoration: BoxDecoration(
                  color: PayrollTokens.navy.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Computed Gross',
                        style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: PayrollTokens.navy)),
                    Text('R ${_computedGross.toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: PayrollTokens.teal)),
                  ],
                ),
              ),
            ]),
            const SizedBox(height: 16),

            // ── Notes ───────────────────────────────────────────────────
            _SectionCard(title: 'Notes (optional)', children: [
              TextFormField(
                controller: _notesCtrl,
                maxLines: 3,
                decoration:
                    _inputDec('Notes', icon: Icons.notes),
              ),
            ]),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// ── Helpers ──────────────────────────────────────────────────────────────────

InputDecoration _inputDec(String label, {IconData? icon}) => InputDecoration(
      labelText: label,
      prefixIcon: icon != null ? Icon(icon, size: 20, color: Colors.grey) : null,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      filled: true,
      fillColor: Colors.white,
    );

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade200)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title.toUpperCase(),
                style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.1,
                    color: Colors.grey.shade600)),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }
}
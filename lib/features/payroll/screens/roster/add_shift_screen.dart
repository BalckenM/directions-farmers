import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/shift.dart';
import '../../providers/payroll_action_providers.dart';
import '../../providers/payroll_providers.dart';
import '../../theme/payroll_tokens.dart';

class AddShiftScreen extends ConsumerStatefulWidget {
  const AddShiftScreen({super.key, this.editShift, this.preselectedDate});
  final Shift? editShift;
  final DateTime? preselectedDate;

  @override
  ConsumerState<AddShiftScreen> createState() => _AddShiftScreenState();
}

class _AddShiftScreenState extends ConsumerState<AddShiftScreen> {
  final _formKey = GlobalKey<FormState>();

  late DateTime _date;
  late TextEditingController _startCtrl;
  late TextEditingController _endCtrl;
  late TextEditingController _taskCodeCtrl;
  late TextEditingController _fieldCtrl;
  late TextEditingController _notesCtrl;
  List<String> _selectedEmployeeIds = [];
  String? _supervisorId;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final s = widget.editShift;
    _date = s?.date ?? widget.preselectedDate ?? DateTime.now();
    _startCtrl = TextEditingController(text: s?.startTime ?? '07:00');
    _endCtrl = TextEditingController(text: s?.endTime ?? '17:00');
    _taskCodeCtrl = TextEditingController(text: s?.taskCode ?? '');
    _fieldCtrl = TextEditingController(text: s?.fieldOrArea ?? '');
    _notesCtrl = TextEditingController(text: s?.notes ?? '');
    _selectedEmployeeIds = List.of(s?.employeeIds ?? []);
    _supervisorId = s?.supervisorId;
  }

  @override
  void dispose() {
    _startCtrl.dispose();
    _endCtrl.dispose();
    _taskCodeCtrl.dispose();
    _fieldCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  String _fmt(DateTime d) {
    const months = [
      '',
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${d.day.toString().padLeft(2, '0')} ${months[d.month]} ${d.year}';
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _pickTime(TextEditingController ctrl) async {
    final parts = ctrl.text.split(':');
    final init = TimeOfDay(
      hour: int.tryParse(parts[0]) ?? 7,
      minute: int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0,
    );
    final picked = await showTimePicker(context: context, initialTime: init);
    if (picked != null) {
      ctrl.text =
          '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedEmployeeIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Select at least one worker'),
          backgroundColor: PayrollTokens.rose,
        ),
      );
      return;
    }
    setState(() => _saving = true);
    final notifier = ref.read(shiftNotifierProvider.notifier);
    Shift? result;
    if (widget.editShift != null) {
      result = await notifier.update(
        widget.editShift!.copyWith(
          date: _date,
          startTime: _startCtrl.text,
          endTime: _endCtrl.text,
          employeeIds: _selectedEmployeeIds,
          taskCode: _taskCodeCtrl.text.trim(),
          fieldOrArea: _fieldCtrl.text.trim().isEmpty
              ? null
              : _fieldCtrl.text.trim(),
          supervisorId: _supervisorId,
          notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
        ),
      );
    } else {
      final now = DateTime.now();
      result = await notifier.add(
        Shift(
          id: 'shift_${now.millisecondsSinceEpoch}',
          date: _date,
          startTime: _startCtrl.text,
          endTime: _endCtrl.text,
          employeeIds: _selectedEmployeeIds,
          taskCode: _taskCodeCtrl.text.trim(),
          fieldOrArea: _fieldCtrl.text.trim().isEmpty
              ? null
              : _fieldCtrl.text.trim(),
          status: ShiftStatus.planned,
          supervisorId: _supervisorId,
          notes: _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim(),
          createdAt: now,
        ),
      );
    }
    if (!mounted) return;
    setState(() => _saving = false);
    if (result != null) {
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to save shift'),
          backgroundColor: PayrollTokens.rose,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final employees = ref.watch(activeEmployeesProvider);
    final isEdit = widget.editShift != null;

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 244, 246, 249),
      appBar: AppBar(
        backgroundColor: PayrollTokens.navy,
        foregroundColor: Colors.white,
        title: Text(
          isEdit ? 'Edit Shift' : 'New Shift',
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        elevation: 0,
        actions: [
          if (_saving)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2,
                ),
              ),
            )
          else
            TextButton(
              onPressed: _save,
              child: const Text(
                'SAVE',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _SectionCard(
              title: 'Shift Details',
              children: [
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: PayrollTokens.navy.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.calendar_today,
                      color: PayrollTokens.navy,
                      size: 20,
                    ),
                  ),
                  title: const Text(
                    'Date',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  subtitle: Text(
                    _fmt(_date),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: PayrollTokens.navy,
                    ),
                  ),
                  onTap: _pickDate,
                  trailing: const Icon(
                    Icons.chevron_right,
                    size: 18,
                    color: Colors.grey,
                  ),
                ),
                const Divider(height: 1),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _timeField('Start Time', _startCtrl)),
                    const SizedBox(width: 12),
                    Expanded(child: _timeField('End Time', _endCtrl)),
                  ],
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _taskCodeCtrl,
                  decoration: _inputDec('Task / Pay Code', icon: Icons.qr_code),
                  textCapitalization: TextCapitalization.characters,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _fieldCtrl,
                  decoration: _inputDec(
                    'Field / Area (optional)',
                    icon: Icons.location_on_outlined,
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _notesCtrl,
                  maxLines: 2,
                  decoration: _inputDec('Notes (optional)', icon: Icons.notes),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Assign Workers (${_selectedEmployeeIds.length} selected)',
              children: employees.isEmpty
                  ? [
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text(
                          'No active workers.',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    ]
                  : employees.map((emp) {
                      final sel = _selectedEmployeeIds.contains(emp.id);
                      return CheckboxListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        title: Text(
                          emp.fullName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        subtitle: Text(
                          emp.occupationTitle,
                          style: const TextStyle(
                            fontSize: 11,
                            color: Colors.grey,
                          ),
                        ),
                        secondary: CircleAvatar(
                          radius: 16,
                          backgroundColor: PayrollTokens.teal.withValues(
                            alpha: 0.12,
                          ),
                          child: Text(
                            '${emp.firstName[0]}${emp.lastName[0]}',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: PayrollTokens.teal,
                            ),
                          ),
                        ),
                        value: sel,
                        activeColor: PayrollTokens.teal,
                        onChanged: (v) => setState(() {
                          if (v == true) {
                            _selectedEmployeeIds.add(emp.id);
                          } else {
                            _selectedEmployeeIds.remove(emp.id);
                          }
                        }),
                      );
                    }).toList(),
            ),
            const SizedBox(height: 16),
            _SectionCard(
              title: 'Supervisor',
              children: [
                DropdownButtonFormField<String?>(
                  initialValue: _supervisorId,
                  decoration: _inputDec(
                    'Supervisor (optional)',
                    icon: Icons.manage_accounts_outlined,
                  ),
                  items: [
                    const DropdownMenuItem(value: null, child: Text('None')),
                    ...employees.map(
                      (e) => DropdownMenuItem(
                        value: e.id,
                        child: Text(e.fullName),
                      ),
                    ),
                  ],
                  onChanged: (v) => setState(() => _supervisorId = v),
                ),
              ],
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: PayrollTokens.teal,
        foregroundColor: Colors.white,
        onPressed: _saving ? null : _save,
        icon: const Icon(Icons.check),
        label: Text(isEdit ? 'Update Shift' : 'Create Shift'),
      ),
    );
  }

  Widget _timeField(String label, TextEditingController ctrl) {
    return GestureDetector(
      onTap: () => _pickTime(ctrl),
      child: AbsorbPointer(
        child: TextFormField(
          controller: ctrl,
          decoration: _inputDec(label, icon: Icons.access_time),
          validator: (v) {
            if (v == null || v.isEmpty) return 'Required';
            if (!RegExp(r'^\d{2}:\d{2}$').hasMatch(v)) return 'HH:MM';
            return null;
          },
        ),
      ),
    );
  }

  InputDecoration _inputDec(String label, {IconData? icon}) => InputDecoration(
    labelText: label,
    prefixIcon: icon != null ? Icon(icon, size: 20, color: Colors.grey) : null,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
  );
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: PayrollTokens.navy,
                  letterSpacing: 0.4,
                ),
              ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: children,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

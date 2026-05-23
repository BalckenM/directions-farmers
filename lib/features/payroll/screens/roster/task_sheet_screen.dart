import '../../theme/payroll_tokens.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/task_assignment.dart';
import '../../models/shift.dart';
import '../../providers/payroll_providers.dart';
import '../../data/payroll_repository.dart';


class TaskSheetScreen extends ConsumerWidget {
  const TaskSheetScreen({super.key, required this.shiftId});
  final String shiftId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allShifts = ref.watch(shiftsProvider(const ShiftFilter()));
    final shift = allShifts.where((s) => s.id == shiftId).firstOrNull;
    final tasks = ref.watch(taskAssignmentsProvider(TaskFilter(date: shift?.date)));
    final employees = ref.watch(activeEmployeesProvider);

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 244, 246, 249),
      appBar: AppBar(
        backgroundColor: PayrollTokens.navy, foregroundColor: Colors.white,
        title: const Text('Task Sheet', style: TextStyle(fontWeight: FontWeight.w700)),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Add Task',
            onPressed: () => _showAddTaskSheet(context, ref, shift),
          ),
        ],
      ),
      body: shift == null
          ? const Center(child: Text('Shift not found'))
          : Column(children: [
              _ShiftHeader(shift: shift, employees: employees),
              Expanded(
                child: tasks.isEmpty
                    ? _emptyState()
                    : ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: tasks.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 10),
                        itemBuilder: (ctx, i) => _TaskCard(
                          task: tasks[i],
                          employees: employees,
                        ),
                      ),
              ),
            ]),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(Icons.assignment_outlined, size: 64, color: Colors.grey[300]),
        const SizedBox(height: 12),
        const Text('No tasks assigned yet',
            style: TextStyle(color: Colors.grey, fontSize: 16, fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        const Text('Tap + to add a job card for this shift',
            style: TextStyle(color: Colors.grey, fontSize: 13)),
      ]),
    );
  }

  void _showAddTaskSheet(BuildContext context, WidgetRef ref, Shift? shift) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddTaskSheet(shift: shift, ref: ref),
    );
  }
}

class _ShiftHeader extends StatelessWidget {
  const _ShiftHeader({required this.shift, required this.employees});
  final Shift shift;
  final List employees;

  String _fmt(DateTime d) {
    const months = ['','Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${d.day.toString().padLeft(2,'0')} ${months[d.month]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    final Color statusColor = switch (shift.status) {
      ShiftStatus.planned    => PayrollTokens.indigo,
      ShiftStatus.inProgress => PayrollTokens.amber,
      ShiftStatus.completed  => PayrollTokens.green,
      ShiftStatus.cancelled  => PayrollTokens.rose,
    };
    return Container(
      color: PayrollTokens.navy,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: statusColor.withValues(alpha: 0.5)),
            ),
            child: Text(shift.status.name.toUpperCase(),
                style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: statusColor)),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text('${shift.startTime} - ${shift.endTime}',
                style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ),
        ]),
        const SizedBox(height: 8),
        Text(shift.taskCode,
            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
        const SizedBox(height: 4),
        Row(children: [
          const Icon(Icons.calendar_today, color: Colors.white60, size: 14),
          const SizedBox(width: 4),
          Text(_fmt(shift.date), style: const TextStyle(color: Colors.white70, fontSize: 13)),
          if (shift.fieldOrArea != null) ...[
            const SizedBox(width: 12),
            const Icon(Icons.location_on_outlined, color: Colors.white60, size: 14),
            const SizedBox(width: 4),
            Text(shift.fieldOrArea!, style: const TextStyle(color: Colors.white70, fontSize: 13)),
          ],
          const Spacer(),
          const Icon(Icons.group_outlined, color: Colors.white60, size: 14),
          const SizedBox(width: 4),
          Text('${shift.employeeIds.length} workers',
              style: const TextStyle(color: Colors.white70, fontSize: 13)),
        ]),
      ]),
    );
  }
}

class _TaskCard extends StatelessWidget {
  const _TaskCard({required this.task, required this.employees});
  final TaskAssignment task;
  final List employees;

  (Color, Color) _statusColors(TaskAssignmentStatus s) => switch (s) {
    TaskAssignmentStatus.assigned   => (PayrollTokens.indigo, PayrollTokens.indigo),
    TaskAssignmentStatus.inProgress => (PayrollTokens.amber, PayrollTokens.amber),
    TaskAssignmentStatus.completed  => (PayrollTokens.green, PayrollTokens.green),
    TaskAssignmentStatus.cancelled  => (PayrollTokens.rose, PayrollTokens.rose),
  };

  String _employeeName() {
    final emp = employees.where((e) => e.id == task.employeeId).firstOrNull;
    return emp?.fullName ?? 'Unknown Worker';
  }

  @override
  Widget build(BuildContext context) {
    final (color, _) = _statusColors(task.status);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(children: [
        Container(
          width: 4, height: 80,
          decoration: BoxDecoration(
            color: color,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(12), bottomLeft: Radius.circular(12)),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(
                  child: Text(task.description,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: PayrollTokens.navy)),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: color.withValues(alpha: 0.3)),
                  ),
                  child: Text(task.status.name.toUpperCase(),
                      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color)),
                ),
              ]),
              const SizedBox(height: 6),
              Row(children: [
                const Icon(Icons.person_outline, size: 14, color: Colors.grey),
                const SizedBox(width: 4),
                Text(_employeeName(), style: const TextStyle(fontSize: 12, color: Colors.grey)),
                if (task.fieldOrArea != null) ...[
                  const SizedBox(width: 10),
                  const Icon(Icons.location_on_outlined, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(task.fieldOrArea!, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ]),
              if (task.payrollCode.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(children: [
                    const Icon(Icons.qr_code, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(task.payrollCode, style: const TextStyle(fontSize: 12, color: Colors.grey, fontFamily: 'monospace')),
                  ]),
                ),
            ]),
          ),
        ),
      ]),
    );
  }
}

class _AddTaskSheet extends StatefulWidget {
  const _AddTaskSheet({required this.shift, required this.ref});
  final Shift? shift;
  final WidgetRef ref;

  @override
  State<_AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends State<_AddTaskSheet> {
  final _descCtrl = TextEditingController();
  final _codeCtrl = TextEditingController();
  final _fieldCtrl = TextEditingController();
  String? _selectedEmployeeId;
  bool _saving = false;

  @override
  void dispose() {
    _descCtrl.dispose(); _codeCtrl.dispose(); _fieldCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final employees = widget.ref.watch(activeEmployeesProvider);
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.fromLTRB(20, 16, 20, 20 + bottom),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Center(child: Container(width: 36, height: 4,
            decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
        const SizedBox(height: 16),
        const Text('New Task Assignment',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: PayrollTokens.navy)),
        const SizedBox(height: 16),
        DropdownButtonFormField<String>(
          initialValue: _selectedEmployeeId,
          decoration: _inputDec('Worker', icon: Icons.person_outline),
          items: employees.map((e) => DropdownMenuItem(value: e.id, child: Text(e.fullName))).toList(),
          onChanged: (v) => setState(() => _selectedEmployeeId = v),
        ),
        const SizedBox(height: 12),
        TextFormField(controller: _descCtrl,
            decoration: _inputDec('Task Description', icon: Icons.assignment_outlined)),
        const SizedBox(height: 12),
        TextFormField(controller: _codeCtrl, textCapitalization: TextCapitalization.characters,
            decoration: _inputDec('Pay Code', icon: Icons.qr_code)),
        const SizedBox(height: 12),
        TextFormField(controller: _fieldCtrl,
            decoration: _inputDec('Field / Area (optional)', icon: Icons.location_on_outlined)),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            style: FilledButton.styleFrom(backgroundColor: PayrollTokens.teal),
            onPressed: _saving ? null : _save,
            child: _saving
                ? const SizedBox(width: 20, height: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Assign Task'),
          ),
        ),
      ]),
    );
  }

  InputDecoration _inputDec(String label, {IconData? icon}) => InputDecoration(
    labelText: label,
    prefixIcon: icon != null ? Icon(icon, size: 20, color: Colors.grey) : null,
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    filled: true, fillColor: const Color.fromARGB(255, 244, 246, 249),
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
  );

  Future<void> _save() async {
    if (_selectedEmployeeId == null || _descCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Worker and description are required'), backgroundColor: PayrollTokens.rose,
      ));
      return;
    }
    setState(() => _saving = true);
    final now = DateTime.now();
    final repo = widget.ref.read(payrollRepositoryProvider);
    repo.addTaskAssignment(TaskAssignment(
      id: 'task_${now.millisecondsSinceEpoch}',
      employeeId: _selectedEmployeeId!,
      date: widget.shift?.date ?? now,
      shiftId: widget.shift?.id,
      payrollCode: _codeCtrl.text.trim().isEmpty ? 'GENERAL' : _codeCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      fieldOrArea: _fieldCtrl.text.trim().isEmpty ? null : _fieldCtrl.text.trim(),
      status: TaskAssignmentStatus.assigned,
      createdAt: now,
    ));
    widget.ref.invalidate(payrollRepositoryProvider);
    if (mounted) Navigator.of(context).pop();
  }
}
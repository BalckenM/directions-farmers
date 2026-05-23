import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/farm_app_bar.dart';
import '../../../../shared/widgets/farm_dropdown.dart';
import '../../../../shared/widgets/farm_scaffold.dart';
import '../../../../shared/widgets/farm_text_field.dart';
import '../../../../shared/widgets/primary_button.dart';
import '../../../../shared/widgets/status_chip.dart';
import '../../models/attendance_record.dart';
import '../../providers/payroll_action_providers.dart';
import '../../providers/payroll_providers.dart';
import '../../theme/payroll_tokens.dart';

final _df = DateFormat('d MMM');
final _dfFull = DateFormat('d MMMM y');

// --- Status helpers -----------------------------------------------------------

Color _statusColor(AttendanceStatus s) => switch (s) {
  AttendanceStatus.present => PayrollTokens.teal,
  AttendanceStatus.absent => PayrollTokens.rose,
  AttendanceStatus.late => PayrollTokens.amber,
  AttendanceStatus.onLeave => PayrollTokens.sky,
  AttendanceStatus.halfDay => PayrollTokens.purple,
  AttendanceStatus.publicHoliday => PayrollTokens.indigo,
};

String _statusLabel(AttendanceStatus s) => switch (s) {
  AttendanceStatus.present => 'Present',
  AttendanceStatus.absent => 'Absent',
  AttendanceStatus.late => 'Late',
  AttendanceStatus.onLeave => 'On Leave',
  AttendanceStatus.halfDay => 'Half Day',
  AttendanceStatus.publicHoliday => 'Public Holiday',
};

// --- Screen -------------------------------------------------------------------

class AttendanceLogScreen extends ConsumerStatefulWidget {
  const AttendanceLogScreen({super.key});

  @override
  ConsumerState<AttendanceLogScreen> createState() =>
      _AttendanceLogScreenState();
}

class _AttendanceLogScreenState extends ConsumerState<AttendanceLogScreen> {
  String? _selectedEmployeeId;
  DateTime? _fromDate;
  DateTime? _toDate;

  @override
  Widget build(BuildContext context) {
    final employees = ref.watch(activeEmployeesProvider);
    final filter = AttendanceFilter(
      employeeId: _selectedEmployeeId,
      fromDate: _fromDate,
      toDate: _toDate,
    );
    final records = ref.watch(attendanceProvider(filter));
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    // Group records by date descending
    final Map<String, List<AttendanceRecord>> grouped = {};
    for (final r in records) {
      final key =
          '${r.date.year}-${r.date.month.toString().padLeft(2, '0')}-${r.date.day.toString().padLeft(2, '0')}';
      grouped.putIfAbsent(key, () => []).add(r);
    }
    final dates = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

    return FarmScaffold(
      appBar: FarmAppBar(
        title: 'Attendance Log',
        actions: [
          IconButton(
            icon: const Icon(Icons.add_task_rounded),
            tooltip: 'Record Exception',
            onPressed: () => _openExceptionSheet(context),
          ),
          IconButton(
            icon: const Icon(Icons.fingerprint_rounded),
            tooltip: 'Clock In / Out',
            onPressed: () => context.push(AppRoutes.payrollClockIn),
          ),
        ],
      ),
      body: Column(
        children: [
          // -- Filter bar -----------------------------------------------------
          Container(
            color: cs.surfaceContainerLowest,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: FarmDropdown<String?>(
                    label: 'Employee',
                    value: _selectedEmployeeId,
                    items: [
                      const DropdownMenuItem<String?>(
                        value: null,
                        child: Text('All'),
                      ),
                      ...employees.map(
                        (e) => DropdownMenuItem<String?>(
                          value: e.id,
                          child: Text(
                            e.fullName,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ],
                    onChanged: (v) => setState(() => _selectedEmployeeId = v),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                _DateBtn(
                  label: _fromDate != null ? _df.format(_fromDate!) : 'From',
                  onTap: () async {
                    final d = await showDatePicker(
                      context: context,
                      initialDate: _fromDate ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (d != null) setState(() => _fromDate = d);
                  },
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.xs,
                  ),
                  child: Text(
                    '�',
                    style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ),
                _DateBtn(
                  label: _toDate != null ? _df.format(_toDate!) : 'To',
                  onTap: () async {
                    final d = await showDatePicker(
                      context: context,
                      initialDate: _toDate ?? DateTime.now(),
                      firstDate: DateTime(2020),
                      lastDate: DateTime.now(),
                    );
                    if (d != null) setState(() => _toDate = d);
                  },
                ),
                if (_fromDate != null ||
                    _toDate != null ||
                    _selectedEmployeeId != null)
                  IconButton(
                    icon: Icon(
                      Icons.clear_rounded,
                      size: 18,
                      color: cs.onSurfaceVariant,
                    ),
                    tooltip: 'Clear filters',
                    onPressed: () => setState(() {
                      _fromDate = _toDate = _selectedEmployeeId = null;
                    }),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),

          // -- Records list ---------------------------------------------------
          Expanded(
            child: records.isEmpty
                ? const EmptyState(
                    icon: Icon(Icons.calendar_today_outlined),
                    title: 'No attendance records',
                    subtitle:
                        'Records will appear here after clock-ins are logged.',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      vertical: AppSpacing.sm,
                    ),
                    itemCount: dates.length,
                    itemBuilder: (context, i) {
                      final dateKey = dates[i];
                      final dayRecords = grouped[dateKey]!;
                      final parsedDate = DateTime.parse(dateKey);
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(
                              AppSpacing.md,
                              AppSpacing.sm,
                              AppSpacing.md,
                              AppSpacing.xs,
                            ),
                            child: Text(
                              _dfFull.format(parsedDate),
                              style: tt.labelLarge?.copyWith(
                                color: PayrollTokens.navy,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          ...dayRecords.map(
                            (r) => _RecordTile(r, employees, cs, tt),
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  void _openExceptionSheet(BuildContext ctx) {
    showModalBottomSheet(
      context: ctx,
      isScrollControlled: true,
      useSafeArea: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => _ExceptionSheet(ref: ref),
    );
  }
}

// --- Record tile --------------------------------------------------------------

class _RecordTile extends StatelessWidget {
  const _RecordTile(this.r, this.employees, this.cs, this.tt);
  final AttendanceRecord r;
  final List<dynamic> employees;
  final ColorScheme cs;
  final TextTheme tt;

  @override
  Widget build(BuildContext context) {
    final empIdx = employees.indexWhere((e) => e.id == r.employeeId);
    final emp = empIdx >= 0 ? employees[empIdx] : null;
    final empName = emp != null
        ? '${emp.firstName} ${emp.lastName}'
        : r.employeeId;
    final statusColor = _statusColor(r.status);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 3,
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Row(
          children: [
            // Status indicator
            Container(
              width: 4,
              height: 40,
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    empName,
                    style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${r.clockInTime ?? '�'} ? ${r.clockOutTime ?? '�'}'
                    '${r.hoursWorked != null ? '  �  ${r.hoursWorked!.toStringAsFixed(1)} hrs' : ''}',
                    style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                StatusChip(
                  label: _statusLabel(r.status),
                  color: statusColor,
                  small: true,
                ),
                if ((r.overtimeHours ?? 0) > 0) ...[
                  const SizedBox(height: 4),
                  StatusChip(
                    label: '+${r.overtimeHours!.toStringAsFixed(1)} OT',
                    color: PayrollTokens.amber,
                    small: true,
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// --- Exception sheet ----------------------------------------------------------

class _ExceptionSheet extends ConsumerStatefulWidget {
  const _ExceptionSheet({required this.ref});
  final WidgetRef ref;

  @override
  ConsumerState<_ExceptionSheet> createState() => _ExceptionSheetState();
}

class _ExceptionSheetState extends ConsumerState<_ExceptionSheet> {
  String? _employeeId;
  DateTime _date = DateTime.now();
  AttendanceStatus _status = AttendanceStatus.absent;
  final _notesCtrl = TextEditingController();

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final employees = ref.watch(activeEmployeesProvider);
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.only(
        left: AppSpacing.md,
        right: AppSpacing.md,
        top: AppSpacing.md,
        bottom: MediaQuery.viewInsetsOf(context).bottom + AppSpacing.lg,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text('Record Exception', style: tt.titleLarge)),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          FarmDropdown<String?>(
            label: 'Employee',
            value: _employeeId,
            hint: 'Select employee',
            prefixIcon: const Icon(Icons.person_outline_rounded),
            items: [
              const DropdownMenuItem<String?>(
                value: null,
                child: Text('Select employee'),
              ),
              ...employees.map(
                (e) => DropdownMenuItem<String?>(
                  value: e.id,
                  child: Text(e.fullName),
                ),
              ),
            ],
            onChanged: (v) => setState(() => _employeeId = v),
          ),
          const SizedBox(height: AppSpacing.sm),

          // Date picker
          InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () async {
              final d = await showDatePicker(
                context: context,
                initialDate: _date,
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
              );
              if (d != null) setState(() => _date = d);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm + 2,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: cs.outline),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_today_outlined,
                    size: 18,
                    color: cs.onSurfaceVariant,
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(_dfFull.format(_date), style: tt.bodyMedium),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    color: cs.onSurfaceVariant,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm),

          FarmDropdown<AttendanceStatus>(
            label: 'Exception Type',
            value: _status,
            prefixIcon: const Icon(Icons.flag_outlined),
            items:
                [
                      AttendanceStatus.absent,
                      AttendanceStatus.late,
                      AttendanceStatus.halfDay,
                      AttendanceStatus.onLeave,
                      AttendanceStatus.publicHoliday,
                    ]
                    .map(
                      (s) => DropdownMenuItem(
                        value: s,
                        child: Text(_statusLabel(s)),
                      ),
                    )
                    .toList(),
            onChanged: (v) => setState(() => _status = v!),
          ),
          const SizedBox(height: AppSpacing.sm),

          FarmTextField(
            controller: _notesCtrl,
            label: 'Notes (optional)',
            hint: 'Add any relevant notes',
            prefixIcon: const Icon(Icons.notes_outlined),
            maxLines: 2,
          ),
          const SizedBox(height: AppSpacing.lg),

          PrimaryButton(
            label: 'Record Exception',
            onPressed: _employeeId == null ? null : _submit,
          ),
        ],
      ),
    );
  }

  Future<void> _submit() async {
    await ref
        .read(attendanceNotifierProvider.notifier)
        .markAbsent(
          employeeId: _employeeId!,
          date: _date,
          reason: _status,
          notes: _notesCtrl.text.isEmpty ? null : _notesCtrl.text,
        );
    if (mounted) Navigator.pop(context);
  }
}

// --- Date filter button -------------------------------------------------------

class _DateBtn extends StatelessWidget {
  const _DateBtn({required this.label, required this.onTap});
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          border: Border.all(color: cs.outline),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          style: TextStyle(fontSize: 12, color: cs.onSurfaceVariant),
        ),
      ),
    );
  }
}

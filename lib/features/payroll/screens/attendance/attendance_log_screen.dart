import 'package:flutter/material.dart';
import 'package:mobile_app/core/theme/app_colors.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import 'package:mobile_app/core/router/app_routes.dart';
import 'package:mobile_app/core/theme/app_spacing.dart';
import 'package:mobile_app/shared/widgets/empty_state.dart';
import 'package:mobile_app/shared/widgets/farm_app_bar.dart';
import 'package:mobile_app/shared/widgets/farm_dropdown.dart';
import 'package:mobile_app/shared/widgets/farm_scaffold.dart';
import 'package:mobile_app/shared/widgets/farm_text_field.dart';
import 'package:mobile_app/shared/widgets/primary_button.dart';
import 'package:mobile_app/shared/widgets/status_chip.dart';
import 'package:mobile_app/features/payroll/models/attendance_record.dart';
import 'package:mobile_app/features/payroll/providers/payroll_action_providers.dart';
import 'package:mobile_app/features/payroll/providers/payroll_providers.dart';
import 'package:mobile_app/features/payroll/theme/payroll_tokens.dart';

final _df = DateFormat('d MMM');
final _dfFull = DateFormat('d MMMM y');

// --- Status helpers -----------------------------------------------------------

Color _statusColor(AttendanceStatus s) => switch (s) {
  AttendanceStatus.present => AppColors.success,
  AttendanceStatus.absent => AppColors.error,
  AttendanceStatus.late => AppColors.warning,
  AttendanceStatus.onLeave => PayrollTokens.sky,
  AttendanceStatus.halfDay => AppColors.secondary,
  AttendanceStatus.publicHoliday => AppColors.primary,
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Row 1 — employee
                FarmDropdown<String?>(
                  label: 'Employee',
                  value: _selectedEmployeeId,
                  items: [
                    const DropdownMenuItem<String?>(
                      value: null,
                      child: Text('All employees'),
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
                const SizedBox(height: AppSpacing.sm),
                // Row 2 — date range
                Row(
                  children: [
                    Expanded(
                      child: _DateBtn(
                        label: _fromDate != null
                            ? 'From  ${_df.format(_fromDate!)}'
                            : 'From date',
                        icon: Icons.calendar_today_outlined,
                        active: _fromDate != null,
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
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: _DateBtn(
                        label: _toDate != null
                            ? 'To  ${_df.format(_toDate!)}'
                            : 'To date',
                        icon: Icons.event_outlined,
                        active: _toDate != null,
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
                    ),
                    if (_fromDate != null ||
                        _toDate != null ||
                        _selectedEmployeeId != null) ...[
                      const SizedBox(width: AppSpacing.xs),
                      IconButton(
                        icon: const Icon(Icons.clear_rounded, size: 18),
                        tooltip: 'Clear filters',
                        onPressed: () => setState(() {
                          _fromDate = _toDate = _selectedEmployeeId = null;
                        }),
                      ),
                    ],
                  ],
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
                                color: AppColors.primary,
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
        vertical: AppSpacing.sm,
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
                    '${r.clockInTime ?? '--'} \u2192 ${r.clockOutTime ?? '--'}'
                    '${r.hoursWorked != null ? '  \u00b7  ${r.hoursWorked!.toStringAsFixed(1)} hrs' : ''}',
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
                    color: AppColors.warning,
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
            items: [
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
  const _DateBtn({
    required this.label,
    required this.onTap,
    this.icon,
    this.active = false,
  });
  final String label;
  final VoidCallback onTap;
  final IconData? icon;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final borderColor = active ? cs.primary : cs.outline;
    final textColor = active ? cs.primary : cs.onSurfaceVariant;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical: 8,
        ),
        decoration: BoxDecoration(
          color: active ? cs.primary.withValues(alpha: 0.08) : null,
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, size: 14, color: textColor),
              const SizedBox(width: 4),
            ],
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: textColor,
                  fontWeight: active ? FontWeight.w600 : FontWeight.normal,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

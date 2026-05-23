import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/farm_app_bar.dart';
import '../../../../shared/widgets/farm_scaffold.dart';
import '../../models/attendance_record.dart';
import '../../providers/payroll_action_providers.dart';
import '../../providers/payroll_providers.dart';
import '../../theme/payroll_tokens.dart';

final _fmtDate = DateFormat('d MMM y');

String _statusLabel(AttendanceStatus s) => switch (s) {
      AttendanceStatus.absent        => 'Absent',
      AttendanceStatus.late          => 'Late',
      AttendanceStatus.halfDay       => 'Half Day',
      AttendanceStatus.present       => 'Present',
      AttendanceStatus.onLeave       => 'On Leave',
      AttendanceStatus.publicHoliday => 'Public Holiday',
    };

(Color, IconData) _statusStyle(AttendanceStatus s) => switch (s) {
      AttendanceStatus.absent        => (PayrollTokens.rose,  Icons.cancel_outlined),
      AttendanceStatus.late          => (PayrollTokens.amber, Icons.watch_later_outlined),
      AttendanceStatus.halfDay       => (PayrollTokens.sky,   Icons.looks_one_outlined),
      AttendanceStatus.present       => (PayrollTokens.green, Icons.check_circle_outline),
      AttendanceStatus.onLeave       => (PayrollTokens.teal,  Icons.event_available_outlined),
      AttendanceStatus.publicHoliday => (PayrollTokens.navy,  Icons.flag_outlined),
    };

class AttendanceExceptionsScreen extends ConsumerStatefulWidget {
  const AttendanceExceptionsScreen({super.key});

  @override
  ConsumerState<AttendanceExceptionsScreen> createState() =>
      _AttendanceExceptionsScreenState();
}

class _AttendanceExceptionsScreenState
    extends ConsumerState<AttendanceExceptionsScreen> {
  AttendanceStatus? _filterStatus;

  static const _statusFilters = <AttendanceStatus?>[
    null,
    AttendanceStatus.absent,
    AttendanceStatus.late,
    AttendanceStatus.halfDay,
  ];

  static const _filterLabels = <AttendanceStatus?, String>{
    null:                    'All',
    AttendanceStatus.absent:  'Absent',
    AttendanceStatus.late:    'Late',
    AttendanceStatus.halfDay: 'Half Day',
  };

  @override
  Widget build(BuildContext context) {
    final tt  = Theme.of(context).textTheme;
    final now  = DateTime.now();
    final from = now.subtract(const Duration(days: 30));
    final all  = ref.watch(
        attendanceProvider(AttendanceFilter(fromDate: from, toDate: now)));

    final exceptions = all.where((r) {
      final isException = r.status == AttendanceStatus.absent ||
          r.status == AttendanceStatus.late ||
          r.status == AttendanceStatus.halfDay;
      if (!isException) return false;
      if (_filterStatus != null && r.status != _filterStatus) return false;
      return true;
    }).toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    final employees = ref.watch(activeEmployeesProvider);

    return FarmScaffold(
      appBar: FarmAppBar(
        title: 'Attendance Exceptions',
        actions: [
          if (exceptions.isNotEmpty)
            Center(
              child: Container(
                margin: const EdgeInsets.only(right: AppSpacing.md),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: PayrollTokens.rose,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${exceptions.length} exceptions',
                  style: tt.labelSmall?.copyWith(
                      color: Colors.white, fontWeight: FontWeight.w700),
                ),
              ),
            ),
        ],
      ),
      body: Column(children: [
        // ── Filter chips ───────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _statusFilters.map((s) {
                return Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: FilterChip(
                    label: Text(_filterLabels[s] ?? ''),
                    selected: _filterStatus == s,
                    onSelected: (_) => setState(() => _filterStatus = s),
                  ),
                );
              }).toList(),
            ),
          ),
        ),

        // ── List ───────────────────────────────────────────────────────
        Expanded(
          child: exceptions.isEmpty
              ? const EmptyState(
                  icon: Icon(Icons.check_circle_outline_rounded,
                      size: 56, color: PayrollTokens.green),
                  title: 'No exceptions',
                  subtitle:
                      'All attendance records are clear for this period.',
                )
              : RefreshIndicator(
                  onRefresh: () async => ref.invalidate(
                      attendanceProvider(AttendanceFilter(
                          fromDate: from, toDate: now))),
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(
                        AppSpacing.md, AppSpacing.xs,
                        AppSpacing.md, 100),
                    itemCount: exceptions.length,
                    separatorBuilder: (_, _) =>
                        const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (ctx, i) => _ExceptionCard(
                      record: exceptions[i],
                      employees: employees,
                    ),
                  ),
                ),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Exception Card
// ─────────────────────────────────────────────────────────────────────────────

class _ExceptionCard extends ConsumerWidget {
  const _ExceptionCard({
    required this.record,
    required this.employees,
  });
  final AttendanceRecord record;
  final List employees;

  String _methodLabel(AttendanceMethod m) => switch (m) {
        AttendanceMethod.manual    => 'Manual',
        AttendanceMethod.gps       => 'GPS',
        AttendanceMethod.qrCode    => 'QR Code',
        AttendanceMethod.biometric => 'Biometric',
      };

  void _showResolveSheet(BuildContext context, WidgetRef ref) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Resolve Exception',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: PayrollTokens.navy),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Choose how to resolve this attendance exception:',
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 16),
                ListTile(
                  leading: const Icon(Icons.event_available_outlined,
                      color: PayrollTokens.teal),
                  title: const Text('Approve Absence',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Mark as approved leave'),
                  onTap: () {
                    Navigator.pop(ctx);
                    ref
                        .read(attendanceNotifierProvider.notifier)
                        .resolveException(
                          record: record,
                          resolvedStatus: AttendanceStatus.onLeave,
                          note: 'Absence approved by manager',
                        );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.watch_later_outlined,
                      color: PayrollTokens.amber),
                  title: const Text('Excuse Late Arrival',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Mark lateness as excused'),
                  onTap: () {
                    Navigator.pop(ctx);
                    ref
                        .read(attendanceNotifierProvider.notifier)
                        .resolveException(
                          record: record,
                          resolvedStatus: AttendanceStatus.present,
                          note: 'Late arrival excused by manager',
                        );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.check_circle_outline,
                      color: PayrollTokens.green),
                  title: const Text('Mark Present',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Override to present'),
                  onTap: () {
                    Navigator.pop(ctx);
                    ref
                        .read(attendanceNotifierProvider.notifier)
                        .resolveException(
                          record: record,
                          resolvedStatus: AttendanceStatus.present,
                          note: 'Overridden to present by manager',
                        );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs   = Theme.of(context).colorScheme;
    final tt   = Theme.of(context).textTheme;
    final emp  = employees.where((e) => e.id == record.employeeId).firstOrNull;
    final name = emp?.fullName ?? record.employeeId;
    final (color, icon) = _statusStyle(record.status);

    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      clipBehavior: Clip.antiAlias,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Accent bar
            Container(width: 4, color: color),
            // Avatar
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppSpacing.sm, AppSpacing.md,
                  AppSpacing.xs, AppSpacing.md),
              child: CircleAvatar(
                radius: 20,
                backgroundColor: color.withValues(alpha: 0.12),
                child: Icon(icon, size: 20, color: color),
              ),
            ),
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.sm, AppSpacing.md,
                    AppSpacing.md, AppSpacing.md),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Expanded(
                          child: Text(name,
                              style: tt.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: PayrollTokens.navy)),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm - 1, vertical: 3),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                                color: color.withValues(alpha: 0.3)),
                          ),
                          child: Text(_statusLabel(record.status),
                              style: tt.labelSmall?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: color)),
                        ),
                      ]),
                      const SizedBox(height: 6),
                      Row(children: [
                        Icon(Icons.calendar_today_outlined,
                            size: 12, color: cs.onSurfaceVariant),
                        const SizedBox(width: AppSpacing.xs),
                        Text(_fmtDate.format(record.date),
                            style: tt.labelSmall
                                ?.copyWith(color: cs.onSurfaceVariant)),
                        const SizedBox(width: AppSpacing.sm),
                        Icon(Icons.touch_app_outlined,
                            size: 12, color: cs.onSurfaceVariant),
                        const SizedBox(width: AppSpacing.xs),
                        Text(_methodLabel(record.method),
                            style: tt.labelSmall
                                ?.copyWith(color: cs.onSurfaceVariant)),
                      ]),
                      if (record.notes != null)
                        Padding(
                          padding: const EdgeInsets.only(top: AppSpacing.xs),
                          child: Text(record.notes!,
                              style: tt.bodySmall?.copyWith(
                                  color: cs.onSurfaceVariant,
                                  fontStyle: FontStyle.italic),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis),
                        ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          style: TextButton.styleFrom(
                            foregroundColor: PayrollTokens.navy,
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(60, 28),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          onPressed: () => _showResolveSheet(context, ref),
                          child: const Text('Resolve',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700, fontSize: 12)),
                        ),
                      ),
                    ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

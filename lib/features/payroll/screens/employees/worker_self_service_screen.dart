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
import '../../models/attendance_record.dart';
import '../../models/leave_balance.dart';
import '../../models/payslip.dart';
import '../../providers/payroll_providers.dart';
import '../../theme/payroll_tokens.dart';

final _zar = NumberFormat.currency(
  locale: 'en_ZA',
  symbol: 'R ',
  decimalDigits: 0,
);
final _dfSlip = DateFormat('d MMM y');
final _dfAtt = DateFormat('EEE d MMM y');

// ─── Root screen ──────────────────────────────────────────────────────────────

class WorkerSelfServiceScreen extends ConsumerStatefulWidget {
  const WorkerSelfServiceScreen({super.key});

  @override
  ConsumerState<WorkerSelfServiceScreen> createState() =>
      _WorkerSelfServiceScreenState();
}

class _WorkerSelfServiceScreenState
    extends ConsumerState<WorkerSelfServiceScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  String? _employeeId;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final employees = ref.watch(activeEmployeesProvider);
    final selected = _employeeId != null
        ? employees.where((e) => e.id == _employeeId).firstOrNull
        : null;

    return FarmScaffold(
      appBar: FarmAppBar(
        title: 'Worker Self-Service',
        bottom: TabBar(
          controller: _tabs,
          labelColor: PayrollTokens.navy,
          unselectedLabelColor: cs.onSurfaceVariant,
          indicatorColor: PayrollTokens.navy,
          tabs: const [
            Tab(icon: Icon(Icons.receipt_long_outlined), text: 'Payslips'),
            Tab(icon: Icon(Icons.event_available_outlined), text: 'Leave'),
            Tab(icon: Icon(Icons.schedule_outlined), text: 'Attendance'),
          ],
        ),
      ),
      body: Column(
        children: [
          // ── Employee selector ────────────────────────────────────────────
          Container(
            color: cs.surface,
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              AppSpacing.sm,
            ),
            child: FarmDropdown<String?>(
              label: 'Select Worker',
              value: _employeeId,
              hint: 'Choose an employee',
              prefixIcon: const Icon(Icons.person_search_outlined),
              items: [
                const DropdownMenuItem<String?>(
                  value: null,
                  child: Text('— Choose an employee —'),
                ),
                ...employees.map(
                  (e) => DropdownMenuItem<String?>(
                    value: e.id,
                    child: Text(
                      '${e.firstName} ${e.lastName}',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ],
              onChanged: (v) => setState(() => _employeeId = v),
            ),
          ),

          // ── Summary card ─────────────────────────────────────────────────
          if (selected != null)
            Container(
              margin: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.md,
                0,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: PayrollTokens.navy.withValues(alpha: 0.07),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: PayrollTokens.navy.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: PayrollTokens.navy.withValues(alpha: 0.15),
                    radius: 22,
                    child: Text(
                      '${selected.firstName[0]}${selected.lastName[0]}',
                      style: tt.titleSmall?.copyWith(
                        color: PayrollTokens.navy,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${selected.firstName} ${selected.lastName}',
                          style: tt.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          '${selected.occupationTitle}  ·  '
                          '${PayrollTokens.engagementLabel(selected.engagementType)}',
                          style: tt.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // ── Tab views ────────────────────────────────────────────────────
          Expanded(
            child: _employeeId == null
                ? const Center(
                    child: EmptyState(
                      icon: Icon(Icons.person_outline_rounded),
                      title: 'No worker selected',
                      subtitle: 'Select a worker above to view their records.',
                    ),
                  )
                : TabBarView(
                    controller: _tabs,
                    children: [
                      _PayslipsTab(employeeId: _employeeId!),
                      _LeaveTab(employeeId: _employeeId!),
                      _AttendanceTab(employeeId: _employeeId!),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

// ─── Tab 1 — Payslips ─────────────────────────────────────────────────────────

class _PayslipsTab extends ConsumerWidget {
  const _PayslipsTab({required this.employeeId});
  final String employeeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final payslips = ref.watch(
      payslipsProvider(PayslipFilter(employeeId: employeeId)),
    );

    if (payslips.isEmpty) {
      return const EmptyState(
        icon: Icon(Icons.receipt_long_outlined),
        title: 'No payslips yet',
        subtitle: 'Payslips will appear here after payroll runs.',
      );
    }

    final sorted = List<Payslip>.from(payslips)
      ..sort((a, b) => b.payDate.compareTo(a.payDate));

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: sorted.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, i) {
        final ps = sorted[i];
        return Material(
          color: cs.surface,
          borderRadius: BorderRadius.circular(12),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => context.push(AppRoutes.payrollPayslipDetail(ps.id)),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                border: Border.all(color: cs.outlineVariant),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: PayrollTokens.teal.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.receipt_outlined,
                      color: PayrollTokens.teal,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_dfSlip.format(ps.periodStart)} – '
                          '${_dfSlip.format(ps.periodEnd)}',
                          style: tt.bodySmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          'Pay date: ${_dfSlip.format(ps.payDate)}',
                          style: tt.labelSmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    _zar.format(ps.netPay),
                    style: tt.titleSmall?.copyWith(
                      color: PayrollTokens.teal,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 12,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ─── Tab 2 — Leave balances ────────────────────────────────────────────────────

class _LeaveTab extends ConsumerWidget {
  const _LeaveTab({required this.employeeId});
  final String employeeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final balances = ref.watch(leaveBalancesProvider(employeeId));
    final requests = ref.watch(
      leaveRequestsProvider(LeaveRequestFilter(employeeId: employeeId)),
    );
    final leaveTypes = ref.watch(leaveTypesProvider);
    final leaveTypeMap = {for (final lt in leaveTypes) lt.id: lt.name};

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        // ── Balance cards ──────────────────────────────────────────────────
        if (balances.isEmpty)
          const EmptyState(
            icon: Icon(Icons.event_available_outlined),
            title: 'No leave balances',
            subtitle: 'Leave balances will appear here once configured.',
          )
        else ...[
          Text(
            'Leave Balances',
            style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.sm),
          ...balances.map((b) => _LeaveBalanceCard(balance: b)),
          const SizedBox(height: AppSpacing.md),
        ],

        // ── Request leave button ───────────────────────────────────────────
        FilledButton.icon(
          style: FilledButton.styleFrom(backgroundColor: PayrollTokens.teal),
          icon: const Icon(Icons.add_rounded),
          label: const Text('Request Leave'),
          onPressed: () => context.push(AppRoutes.payrollLeaveRequest),
        ),

        // ── Recent requests ────────────────────────────────────────────────
        if (requests.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Recent Leave Requests',
            style: tt.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: AppSpacing.sm),
          ...requests
              .take(10)
              .map(
                (r) => Container(
                  margin: const EdgeInsets.only(bottom: AppSpacing.sm),
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: cs.surface,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: cs.outlineVariant),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              leaveTypeMap[r.leaveTypeId] ?? r.leaveTypeId,
                              style: tt.bodySmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '${_dfSlip.format(r.startDate)} – '
                              '${_dfSlip.format(r.endDate)}',
                              style: tt.labelSmall?.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: PayrollTokens.leaveStatusColor(
                            r.status,
                          ).withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          PayrollTokens.leaveStatusLabel(r.status),
                          style: tt.labelSmall?.copyWith(
                            color: PayrollTokens.leaveStatusColor(r.status),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
        ],
      ],
    );
  }
}

class _LeaveBalanceCard extends StatelessWidget {
  const _LeaveBalanceCard({required this.balance});
  final LeaveBalance balance;

  Color _barColor(double pct) => pct > 0.5
      ? PayrollTokens.green
      : pct > 0.25
      ? PayrollTokens.amber
      : PayrollTokens.rose;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final pct = balance.totalEntitled > 0
        ? (balance.remaining / balance.totalEntitled).clamp(0.0, 1.0)
        : 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      padding: const EdgeInsets.all(AppSpacing.sm + 2),
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: cs.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                balance.leaveTypeName,
                style: tt.bodySmall?.copyWith(fontWeight: FontWeight.w700),
              ),
              Text(
                '${balance.remaining.toStringAsFixed(1)} / '
                '${balance.totalEntitled.toStringAsFixed(1)} days',
                style: tt.labelSmall?.copyWith(color: cs.onSurfaceVariant),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: 6,
              backgroundColor: cs.surfaceContainerHighest,
              valueColor: AlwaysStoppedAnimation<Color>(_barColor(pct)),
            ),
          ),
          if (balance.pending > 0) ...[
            const SizedBox(height: 4),
            Text(
              '${balance.pending.toStringAsFixed(1)} days pending approval',
              style: tt.labelSmall?.copyWith(color: PayrollTokens.amber),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Tab 3 — Attendance ───────────────────────────────────────────────────────

class _AttendanceTab extends ConsumerWidget {
  const _AttendanceTab({required this.employeeId});
  final String employeeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final records = ref.watch(
      attendanceProvider(AttendanceFilter(employeeId: employeeId)),
    );

    if (records.isEmpty) {
      return const EmptyState(
        icon: Icon(Icons.schedule_outlined),
        title: 'No attendance records',
        subtitle: 'Clock-in records will appear here.',
      );
    }

    final sorted = List<AttendanceRecord>.from(records)
      ..sort((a, b) => b.date.compareTo(a.date));

    // Compute summary for last 30 days
    final cutoff = DateTime.now().subtract(const Duration(days: 30));
    final recent = sorted.where((r) => r.date.isAfter(cutoff)).toList();
    final totalHours = recent.fold(0.0, (s, r) => s + (r.hoursWorked ?? 0));
    final totalOt = recent.fold(0.0, (s, r) => s + (r.overtimeHours ?? 0));

    return Column(
      children: [
        // ── 30-day summary ────────────────────────────────────────────────
        Container(
          margin: const EdgeInsets.all(AppSpacing.md),
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: PayrollTokens.navy.withValues(alpha: 0.07),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: PayrollTokens.navy.withValues(alpha: 0.2),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _AttStat(
                label: 'Days (30d)',
                value: '${recent.length}',
                color: PayrollTokens.navy,
              ),
              _AttStat(
                label: 'Hours (30d)',
                value: totalHours.toStringAsFixed(1),
                color: PayrollTokens.teal,
              ),
              _AttStat(
                label: 'OT Hours (30d)',
                value: totalOt.toStringAsFixed(1),
                color: totalOt > 0 ? PayrollTokens.amber : cs.onSurfaceVariant,
              ),
            ],
          ),
        ),

        // ── Records list ──────────────────────────────────────────────────
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              0,
              AppSpacing.md,
              AppSpacing.md,
            ),
            itemCount: sorted.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.xs),
            itemBuilder: (context, i) {
              final r = sorted[i];
              final isOpen = r.clockOutTime == null && r.clockInTime != null;
              return Container(
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
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color:
                            (isOpen ? PayrollTokens.amber : PayrollTokens.green)
                                .withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        isOpen
                            ? Icons.timelapse_rounded
                            : Icons.check_circle_outline,
                        color: isOpen
                            ? PayrollTokens.amber
                            : PayrollTokens.green,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _dfAtt.format(r.date),
                            style: tt.bodySmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            [
                              if (r.clockInTime != null) 'In: ${r.clockInTime}',
                              if (r.clockOutTime != null)
                                'Out: ${r.clockOutTime}',
                              if (isOpen) 'Not clocked out',
                            ].join('  ·  '),
                            style: tt.labelSmall?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (r.hoursWorked != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${r.hoursWorked!.toStringAsFixed(1)} h',
                            style: tt.bodySmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              color: PayrollTokens.navy,
                            ),
                          ),
                          if ((r.overtimeHours ?? 0) > 0)
                            Text(
                              'OT: ${r.overtimeHours!.toStringAsFixed(1)} h',
                              style: tt.labelSmall?.copyWith(
                                color: PayrollTokens.amber,
                              ),
                            ),
                        ],
                      ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _AttStat extends StatelessWidget {
  const _AttStat({
    required this.label,
    required this.value,
    required this.color,
  });
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: tt.titleMedium?.copyWith(
            color: color,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(
          label,
          style: tt.labelSmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

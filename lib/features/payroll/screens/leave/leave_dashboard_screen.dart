import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/alert_banner.dart';
import '../../../../shared/widgets/farm_app_bar.dart';
import '../../../../shared/widgets/farm_scaffold.dart';
import '../../../../shared/widgets/kpi_row.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/status_chip.dart';
import '../../models/leave_request.dart';
import '../../models/payroll_employee.dart';
import '../../models/leave_type.dart';
import '../../providers/payroll_providers.dart';
import '../../theme/payroll_tokens.dart';
import '../../widgets/payroll_widgets.dart';

final _dateFmt = DateFormat('d MMM y');

// ─── Screen ───────────────────────────────────────────────────────────────────

class LeaveDashboardScreen extends ConsumerWidget {
  const LeaveDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pending    = ref.watch(pendingLeaveRequestsProvider);
    final allLeave   = ref.watch(leaveRequestsProvider(const LeaveRequestFilter()));
    final employees  = ref.watch(employeesProvider);
    final leaveTypes = ref.watch(leaveTypesProvider);
    final tt = Theme.of(context).textTheme;

    final empMap  = {for (final e in employees)  e.id: e};
    final typeMap = {for (final t in leaveTypes) t.id: t};

    final approved = allLeave.where((r) => r.status == LeaveStatus.approved).length;
    final rejected = allLeave.where((r) => r.status == LeaveStatus.rejected).length;

    return FarmScaffold(
      appBar: const FarmAppBar(title: 'Leave'),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(pendingLeaveRequestsProvider);
          ref.invalidate(leaveRequestsProvider);
        },
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.md,
            AppSpacing.xl,
          ),
          children: [
          // ── Pending alert ─────────────────────────────────────────────────────
          if (pending.isNotEmpty) ...[
            AlertBanner(
              type: AlertBannerType.warning,
              title:
                  '${pending.length} leave request${pending.length == 1 ? '' : 's'} awaiting approval.',
            ),
            const SizedBox(height: AppSpacing.md),
          ],

          // ── KPI summary ───────────────────────────────────────────────────────
          KpiRow(
            items: [
              KpiItem(
                label: 'Pending',
                value: pending.length.toString(),
                color: PayrollTokens.amber,
                icon: Icons.pending_actions_rounded,
              ),
              KpiItem(
                label: 'Approved',
                value: approved.toString(),
                color: PayrollTokens.teal,
                icon: Icons.check_circle_outline_rounded,
              ),
              KpiItem(
                label: 'Rejected',
                value: rejected.toString(),
                color: PayrollTokens.rose,
                icon: Icons.cancel_outlined,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // ── Quick actions ─────────────────────────────────────────────────────
          PrSectionCard(
            title: 'Quick Actions',
            icon: Icons.flash_on_rounded,
            iconColor: PayrollTokens.navy,
            children: [
              _ActionTile(
                icon: Icons.add_circle_outline_rounded,
                iconColor: PayrollTokens.navy,
                label: 'New Leave Request',
                onTap: () => context.push(AppRoutes.payrollLeaveRequest),
              ),
              const Divider(height: 1),
              _ActionTile(
                icon: Icons.check_circle_outline_rounded,
                iconColor: PayrollTokens.teal,
                label: 'Approve / Reject',
                badge: pending.isNotEmpty ? pending.length : null,
                onTap: () => context.push(AppRoutes.payrollLeaveApproval),
              ),
              const Divider(height: 1),
              _ActionTile(
                icon: Icons.balance_rounded,
                iconColor: PayrollTokens.amber,
                label: 'Leave Balances',
                onTap: () => context.push(AppRoutes.payrollLeaveBalances),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          // ── Recent requests ───────────────────────────────────────────────────
          SectionHeader(
            title: 'Recent Requests',
            actionLabel: 'View all',
            onAction: () => context.push(AppRoutes.payrollLeaveApproval),
          ),
          const SizedBox(height: AppSpacing.sm),

          if (allLeave.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
              child: Center(
                child: Text(
                  'No leave requests found.',
                  style: tt.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            )
          else
            ...allLeave.take(8).map(
              (r) => _LeaveRequestTile(
                request:   r,
                employee:  empMap[r.employeeId],
                leaveType: typeMap[r.leaveTypeId],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Action tile ──────────────────────────────────────────────────────────────

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.iconColor,
    this.badge,
  });

  final IconData     icon;
  final Color        iconColor;
  final String       label;
  final VoidCallback onTap;
  final int?         badge;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm,
          vertical:   AppSpacing.sm,
        ),
        child: Row(
          children: [
            Container(
              width:  38,
              height: 38,
              decoration: BoxDecoration(
                color:        iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Text(
                label,
                style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
              ),
            ),
            if (badge != null)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical:   2,
                ),
                decoration: BoxDecoration(
                  color:        PayrollTokens.amber,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  '$badge',
                  style: const TextStyle(
                    color:      Colors.white,
                    fontSize:   12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            const SizedBox(width: AppSpacing.xs),
            Icon(Icons.chevron_right_rounded, color: cs.onSurfaceVariant, size: 18),
          ],
        ),
      ),
    );
  }
}

// ─── Leave request tile ───────────────────────────────────────────────────────

class _LeaveRequestTile extends StatelessWidget {
  const _LeaveRequestTile({
    required this.request,
    required this.employee,
    required this.leaveType,
  });

  final LeaveRequest      request;
  final PayrollEmployee?  employee;
  final LeaveType?        leaveType;

  @override
  Widget build(BuildContext context) {
    final cs          = Theme.of(context).colorScheme;
    final tt          = Theme.of(context).textTheme;
    final statusColor = PayrollTokens.leaveStatusColor(request.status);

    final empName  = employee != null
        ? '${employee!.firstName} ${employee!.lastName}'
        : 'Unknown Employee';
    final typeName = leaveType?.name ?? 'Leave';

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color:        cs.surface,
          borderRadius: BorderRadius.circular(12),
          border:       Border.all(color: cs.outlineVariant),
        ),
        child: Row(
          children: [
            // Avatar initial
            CircleAvatar(
              radius:          20,
              backgroundColor: statusColor.withValues(alpha: 0.12),
              child: Text(
                empName.isNotEmpty ? empName[0].toUpperCase() : '?',
                style: TextStyle(
                  color:      statusColor,
                  fontWeight: FontWeight.w700,
                  fontSize:   15,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Primary: employee name + leave type
                  Text(
                    empName,
                    style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color:        PayrollTokens.sky.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(4),
                          border:       Border.all(
                              color: PayrollTokens.sky.withValues(alpha: 0.3)),
                        ),
                        child: Text(
                          typeName,
                          style: TextStyle(
                            fontSize:   10,
                            fontWeight: FontWeight.w700,
                            color:      PayrollTokens.sky,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          '${_dateFmt.format(request.startDate)} – '
                          '${_dateFmt.format(request.endDate)}  ·  '
                          '${request.daysRequested.toStringAsFixed(0)} '
                          'day${request.daysRequested == 1 ? '' : 's'}',
                          style: tt.labelSmall
                              ?.copyWith(color: cs.onSurfaceVariant),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  // Reason as tertiary info if present
                  if (request.reason.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      request.reason,
                      style: tt.labelSmall?.copyWith(
                        color:     cs.onSurfaceVariant,
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            StatusChip(
              label: PayrollTokens.leaveStatusLabel(request.status),
              color: statusColor,
              small: true,
            ),
          ],
        ),
      ),
    );
  }
}

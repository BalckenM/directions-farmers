import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/farm_app_bar.dart';
import '../../../../shared/widgets/farm_scaffold.dart';
import '../../../../shared/widgets/progress_bar.dart';
import '../../../../shared/widgets/status_chip.dart';
import '../../models/payroll_employee.dart';
import '../../providers/payroll_providers.dart';
import '../../theme/payroll_tokens.dart';
import '../../widgets/payroll_widgets.dart';

final _dateFmt = DateFormat('d MMM y');
final _zarFmt = NumberFormat.currency(
  locale: 'en_ZA',
  symbol: 'R ',
  decimalDigits: 0,
);

// ─── Helpers ─────────────────────────────────────────────────────────────────

String _fmtDate(DateTime d) => _dateFmt.format(d);

Color _statusColor(EmploymentStatus s) => switch (s) {
  EmploymentStatus.active => AppColors.success,
  EmploymentStatus.terminated => AppColors.error,
  _ => AppColors.error,
};

String _empStatusLabel(EmploymentStatus s) => switch (s) {
  EmploymentStatus.active => 'Active',
  EmploymentStatus.inactive => 'Inactive',
  EmploymentStatus.terminated => 'Terminated',
};

// ─── Screen ───────────────────────────────────────────────────────────────────

class EmployeeDetailScreen extends ConsumerWidget {
  const EmployeeDetailScreen({super.key, required this.employeeId});
  final String employeeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final employee = ref.watch(employeeProvider(employeeId));
    if (employee == null) {
      return FarmScaffold(
        appBar: const FarmAppBar(title: 'Employee'),
        body: const EmptyState(
          icon: Icon(Icons.person_off_outlined, size: 56),
          title: 'Employee not found',
          subtitle: 'This record may have been removed.',
        ),
      );
    }

    return FarmScaffold(
      appBar: FarmAppBar(
        title: employee.fullName,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit employee',
            onPressed: () =>
                context.push(AppRoutes.payrollEditEmployee(employee.id)),
          ),
          if (employee.status != EmploymentStatus.terminated)
            IconButton(
              icon: const Icon(Icons.person_remove_outlined),
              tooltip: 'Terminate employee',
              color: PayrollTokens.rose,
              onPressed: () =>
                  context.push(AppRoutes.payrollEmployeeTerminate(employee.id)),
            ),
        ],
      ),
      body: DefaultTabController(
        length: 4,
        child: Column(
          children: [
            // ── Header card ──────────────────────────────────────────────────
            _EmployeeHeader(employee: employee),

            // ── Tabs ─────────────────────────────────────────────────────────
            TabBar(
              labelColor: PayrollTokens.navy,
              indicatorColor: PayrollTokens.navy,
              dividerColor: Theme.of(context).colorScheme.outlineVariant,
              tabs: const [
                Tab(text: 'Profile'),
                Tab(text: 'Contracts'),
                Tab(text: 'Leave'),
                Tab(text: 'Payslips'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _ProfileTab(employee: employee),
                  _ContractTab(employeeId: employeeId),
                  _LeaveTab(employeeId: employeeId),
                  _PayslipsTab(employeeId: employeeId),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Header ───────────────────────────────────────────────────────────────────

class _EmployeeHeader extends StatelessWidget {
  const _EmployeeHeader({required this.employee});
  final PayrollEmployee employee;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    // Two initials: first letter of first name + first letter of last name
    final initials =
        '${employee.firstName.isNotEmpty ? employee.firstName[0] : ''}'
                '${employee.lastName.isNotEmpty ? employee.lastName[0] : ''}'
            .toUpperCase();

    return Container(
      color: cs.surface,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: PayrollTokens.navy.withValues(alpha: 0.12),
            child: Text(
              initials.isNotEmpty ? initials : '?',
              style: const TextStyle(
                color: PayrollTokens.navy,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  employee.fullName,
                  style: tt.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  employee.occupationTitle,
                  style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ),
          StatusChip(
            label: _empStatusLabel(employee.status),
            color: _statusColor(employee.status),
          ),
        ],
      ),
    );
  }
}

// ─── Profile tab ──────────────────────────────────────────────────────────────

class _ProfileTab extends StatelessWidget {
  const _ProfileTab({required this.employee});
  final PayrollEmployee employee;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        PrSectionCard(
          title: 'Personal Information',
          icon: Icons.person_outline_rounded,
          iconColor: PayrollTokens.navy,
          children: [
            PrInfoRow(
              label: 'ID / Passport',
              value: employee.idOrPassportNumber,
            ),
            PrInfoRow(label: 'Phone', value: employee.phone ?? '—'),
            PrInfoRow(label: 'Email', value: employee.email ?? '—'),
            PrInfoRow(label: 'Address', value: employee.address),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        PrSectionCard(
          title: 'Employment',
          icon: Icons.work_outline_rounded,
          iconColor: PayrollTokens.teal,
          children: [
            PrInfoRow(label: 'Occupation', value: employee.occupationTitle),
            PrInfoRow(
              label: 'Type',
              value: PayrollTokens.engagementLabel(employee.engagementType),
            ),
            PrInfoRow(label: 'Start Date', value: _fmtDate(employee.startDate)),
            PrInfoRow(
              label: 'Status',
              value: _empStatusLabel(employee.status),
              valueColor: _statusColor(employee.status),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        PrSectionCard(
          title: 'Next of Kin',
          icon: Icons.family_restroom_rounded,
          iconColor: PayrollTokens.purple,
          children: [
            PrInfoRow(label: 'Name', value: employee.nextOfKinName),
            PrInfoRow(label: 'Phone', value: employee.nextOfKinPhone),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        PrSectionCard(
          title: 'Pay & Benefits',
          icon: Icons.payments_outlined,
          iconColor: PayrollTokens.amber,
          children: [
            PrInfoRow(
              label: 'Payment Method',
              value: PayrollTokens.disbursementLabel(
                employee.disbursementMethod,
              ),
            ),
            if (employee.bankName != null)
              PrInfoRow(label: 'Bank', value: employee.bankName!),
            if (employee.bankAccountNumber != null)
              PrInfoRow(
                label: 'Account No.',
                value: employee.bankAccountNumber!,
              ),
            PrInfoRow(
              label: 'Housing Benefit',
              value: employee.hasHousingBenefit ? 'Yes' : 'No',
              valueColor: employee.hasHousingBenefit ? AppColors.success : null,
            ),
            PrInfoRow(
              label: 'Food Benefit',
              value: employee.hasFoodBenefit ? 'Yes' : 'No',
              valueColor: employee.hasFoodBenefit ? AppColors.success : null,
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xl),
      ],
    );
  }
}

// ─── Contracts tab ────────────────────────────────────────────────────────────

class _ContractTab extends ConsumerWidget {
  const _ContractTab({required this.employeeId});
  final String employeeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final contracts = ref.watch(contractsProvider(employeeId));
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    if (contracts.isEmpty) {
      return const EmptyState(
        icon: Icon(Icons.description_outlined, size: 56),
        title: 'No contracts on file',
        subtitle: 'Contracts added for this employee will appear here.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: contracts.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (_, i) {
        final c = contracts[i];
        final statusColor = PayrollTokens.contractStatusColor(c.status);
        return Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: cs.outlineVariant),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: PayrollTokens.navy.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.description_outlined,
                  color: PayrollTokens.navy,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      c.jobDescription,
                      style: tt.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${PayrollTokens.contractTypeLabel(c.type)} · From ${_fmtDate(c.startDate)}',
                      style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              StatusChip(
                label: PayrollTokens.contractStatusLabel(c.status),
                color: statusColor,
                small: true,
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Leave tab ────────────────────────────────────────────────────────────────

class _LeaveTab extends ConsumerWidget {
  const _LeaveTab({required this.employeeId});
  final String employeeId;

  // Semantic color per leave type name (heuristic on name, not ID)
  static Color _leaveTypeColor(String typeName) {
    final lower = typeName.toLowerCase();
    if (lower.contains('annual')) {
      return PayrollTokens.teal;
    }
    if (lower.contains('sick')) {
      return PayrollTokens.rose;
    }
    if (lower.contains('maternity') || lower.contains('paternity')) {
      return PayrollTokens.purple;
    }
    if (lower.contains('family')) {
      return PayrollTokens.amber;
    }
    if (lower.contains('unpaid')) {
      return const Color(0xFF757575);
    }
    if (lower.contains('study')) {
      return PayrollTokens.indigo;
    }
    return PayrollTokens.sky;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final balances = ref.watch(leaveBalancesProvider(employeeId));
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    if (balances.isEmpty) {
      return const EmptyState(
        icon: Icon(Icons.event_available_outlined, size: 56),
        title: 'No leave balances',
        subtitle: 'Leave entitlements will appear here once configured.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: balances.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (_, i) {
        final b = balances[i];
        final typeColor = _leaveTypeColor(b.leaveTypeName);
        final fraction = b.totalEntitled > 0
            ? (b.taken / b.totalEntitled).clamp(0.0, 1.0)
            : 0.0;
        final isLow = b.remaining < 2;
        final barColor = isLow ? AppColors.error : typeColor;

        return Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: cs.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isLow
                  ? AppColors.error.withValues(alpha: 0.4)
                  : cs.outlineVariant,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: typeColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Text(
                      b.leaveTypeName,
                      style: tt.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Text(
                    '${b.remaining.toStringAsFixed(1)} days left',
                    style: tt.bodySmall?.copyWith(
                      color: isLow ? AppColors.error : cs.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              ProgressBar(value: fraction, color: barColor, height: 6),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Taken ${b.taken.toStringAsFixed(1)} of ${b.totalEntitled.toStringAsFixed(1)} days',
                style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Payslips tab ─────────────────────────────────────────────────────────────

class _PayslipsTab extends ConsumerWidget {
  const _PayslipsTab({required this.employeeId});
  final String employeeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final payslips = ref.watch(
      payslipsProvider(PayslipFilter(employeeId: employeeId)),
    );
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    if (payslips.isEmpty) {
      return const EmptyState(
        icon: Icon(Icons.receipt_long_outlined, size: 56),
        title: 'No payslips yet',
        subtitle: 'Payslips will appear here after each completed pay run.',
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: payslips.length,
      separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (_, i) {
        final p = payslips[i];
        final period = DateFormat('MMM y').format(p.periodStart);
        return Material(
          color: cs.surface,
          borderRadius: BorderRadius.circular(12),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => context.push(AppRoutes.payrollPayslipDetail(p.id)),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm + 2,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: cs.outlineVariant),
              ),
              child: Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
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
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          period,
                          style: tt.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Gross ${_zarFmt.format(p.grossPay)}',
                          style: tt.bodySmall?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    _zarFmt.format(p.netPay),
                    style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w700),
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/farm_scaffold.dart';
import '../../../../shared/widgets/farm_app_bar.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/status_chip.dart';
import '../../models/payslip.dart';
import '../../providers/payroll_providers.dart';
import '../../theme/payroll_tokens.dart';
import '../../widgets/pr_amount_badge.dart';


class PayslipListScreen extends ConsumerWidget {
  const PayslipListScreen({super.key, this.employeeId});
  final String? employeeId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final payslips = ref.watch(
        payslipsProvider(PayslipFilter(employeeId: employeeId)));
    final employees = ref.watch(activeEmployeesProvider);
    final empMap = {for (final e in employees) e.id: '${e.firstName} ${e.lastName}'};

    return FarmScaffold(
      appBar: const FarmAppBar(title: 'Payslips'),
      body: payslips.isEmpty
          ? const EmptyState(
              icon: Icon(Icons.receipt_long_outlined),
              title: 'No payslips yet',
              subtitle: 'Payslips will appear here after payroll runs.',
            )
          : ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.md),
              itemCount: payslips.length,
              separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (_, i) => _PayslipCard(
                payslip: payslips[i],
                employeeName: empMap[payslips[i].employeeId],
                showEmployee: employeeId == null,
              ),
            ),
    );
  }
}

class _PayslipCard extends StatelessWidget {
  const _PayslipCard({
    required this.payslip,
    this.employeeName,
    required this.showEmployee,
  });

  final Payslip payslip;
  final String? employeeName;
  final bool showEmployee;

  static final _period = DateFormat('MMMM yyyy');
  static final _date   = DateFormat('d MMM yyyy');
  static final _zar    = NumberFormat.currency(locale: 'en_ZA', symbol: 'R ', decimalDigits: 0);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final now = DateTime.now();
    final isPaid = payslip.payDate.isBefore(now) || payslip.payDate.isAtSameMomentAs(now);

    final initials = (employeeName ?? payslip.employeeId)
        .split(' ')
        .take(2)
        .map((p) => p.isEmpty ? '' : p[0].toUpperCase())
        .join();

    return InkWell(
      onTap: () => GoRouter.of(context).push(AppRoutes.payrollPayslipDetail(payslip.id)),
      borderRadius: AppRadius.card,
      child: Container(
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: AppRadius.card,
          border: Border.all(color: cs.outlineVariant),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ── Left accent bar ────────────────────────────────────
              Container(
                width: 4,
                decoration: BoxDecoration(
                  color: isPaid ? PayrollTokens.teal : PayrollTokens.navy,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(16),
                    bottomLeft: Radius.circular(16),
                  ),
                ),
              ),
              // ── Content ───────────────────────────────────────────
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md, vertical: AppSpacing.md),
                  child: Row(
                    children: [
                      // Avatar
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: PayrollTokens.navy.withValues(alpha: 0.08),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          initials,
                          style: tt.titleSmall?.copyWith(
                              color: PayrollTokens.navy, fontWeight: FontWeight.w700),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      // Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    _period.format(payslip.periodStart),
                                    style: tt.titleSmall?.copyWith(
                                        fontWeight: FontWeight.w700),
                                  ),
                                ),
                                PrAmountBadge(
                                  amount: _zar.format(payslip.netPay),
                                  backgroundColor: PayrollTokens.teal.withValues(alpha: 0.12),
                                  textColor: PayrollTokens.teal,
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            if (showEmployee && employeeName != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 4),
                                child: Text(
                                  employeeName!,
                                  style: tt.bodySmall?.copyWith(
                                      color: cs.onSurfaceVariant,
                                      fontWeight: FontWeight.w500),
                                ),
                              ),
                            Row(
                              children: [
                                Icon(Icons.calendar_today_outlined,
                                    size: 12,
                                    color: cs.onSurfaceVariant),
                                const SizedBox(width: 4),
                                Text(
                                  'Pay date: ${_date.format(payslip.payDate)}',
                                  style: tt.bodySmall?.copyWith(
                                      color: cs.onSurfaceVariant),
                                ),
                                const Spacer(),
                                StatusChip(
                                  label: isPaid ? 'Paid' : 'Pending',
                                  color: isPaid ? PayrollTokens.green : PayrollTokens.navy,
                                  icon: isPaid
                                      ? Icons.check_circle_outline
                                      : Icons.schedule_outlined,
                                  small: true,
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Gross ${_zar.format(payslip.grossPay)}  ·  '
                              'Deductions ${_zar.format(payslip.totalDeductions)}',
                              style: tt.bodySmall?.copyWith(
                                  color: cs.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Icon(Icons.chevron_right_rounded,
                          color: cs.onSurfaceVariant),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

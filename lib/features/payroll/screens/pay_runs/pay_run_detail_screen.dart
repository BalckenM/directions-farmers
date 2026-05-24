import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../core/router/app_routes.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/farm_app_bar.dart';
import '../../../../shared/widgets/farm_scaffold.dart';
import '../../../../shared/widgets/status_chip.dart';
import '../../models/pay_run.dart';
import '../../providers/payroll_action_providers.dart';
import '../../providers/payroll_providers.dart';
import '../../widgets/payroll_widgets.dart';

import '../../theme/payroll_tokens.dart';

final _zar = NumberFormat.currency(locale: 'en_ZA', symbol: 'R ', decimalDigits: 0);
final _df  = DateFormat('d MMM y');
final _mf  = DateFormat('MMMM y');

class PayRunDetailScreen extends ConsumerWidget {
  const PayRunDetailScreen({super.key, required this.payRunId});
  final String payRunId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final payRun = ref.watch(payRunProvider(payRunId));
    if (payRun == null) {
      return const FarmScaffold(
        appBar: FarmAppBar(title: 'Pay Run'),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final payslips  = ref.watch(payslipsProvider(PayslipFilter(payRunId: payRunId)));
    final employees = ref.watch(activeEmployeesProvider);
    final alerts    = ref.watch(complianceAlertsProvider)
        .where((a) => payRun.complianceAlertIds.contains(a.id))
        .toList();
    final isLoading = ref.watch(payRunNotifierProvider) is AsyncLoading;
    final tt  = Theme.of(context).textTheme;
    final cs  = Theme.of(context).colorScheme;

    final canApprove  = payRun.status == PayRunStatus.pendingApproval;
    final canDisburse = payRun.status == PayRunStatus.approved;

    return FarmScaffold(
      appBar: FarmAppBar(title: 'Pay Run · ${_mf.format(payRun.periodStart)}'),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          // -- Period & Status header -----------------------------------------
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [PayrollTokens.navy, Color.fromARGB(255, 46, 89, 132)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${_df.format(payRun.periodStart)} – ${_df.format(payRun.periodEnd)}',
                          style: tt.titleMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Pay date: ${_df.format(payRun.payDate)}',
                          style: tt.bodySmall?.copyWith(
                            color: Colors.white.withValues(alpha: 0.75),
                          ),
                        ),
                      ],
                    ),
                  ),
                  StatusChip(
                    label: PayrollTokens.payRunStatusLabel(payRun.status),
                    color: PayrollTokens.payRunStatusColor(payRun.status),
                  ),
                ]),
                const SizedBox(height: AppSpacing.md),
                Row(children: [
                  _HeaderStat(
                    label: 'Employees',
                    value: '${payRun.employeeCount}',
                    icon: Icons.people_outline,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  _HeaderStat(
                    label: 'Gross',
                    value: _zar.format(payRun.totalGross),
                    icon: Icons.account_balance_wallet_outlined,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  _HeaderStat(
                    label: 'Net',
                    value: _zar.format(payRun.totalNet),
                    icon: Icons.payments_outlined,
                  ),
                ]),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // -- Financial summary ----------------------------------------------
          PrSectionCard(
            title: 'Financial Summary',
            icon: Icons.summarize_outlined,
            iconColor: PayrollTokens.teal,
            children: [
              PrInfoRow(
                label: 'Total Gross',
                value: _zar.format(payRun.totalGross),
              ),
              PrInfoRow(
                label: 'Total Deductions',
                value: '- ${_zar.format(payRun.totalDeductions)}',
                valueColor: PayrollTokens.rose,
              ),
              const Divider(height: 16),
              PrInfoRow(
                label: 'Net Pay',
                value: _zar.format(payRun.totalNet),
                valueColor: PayrollTokens.green,
                valueStyle: const TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // -- Compliance alerts ----------------------------------------------
          if (alerts.isNotEmpty) ...[
            PrSectionCard(
              title: '${alerts.length} Compliance Alert${alerts.length == 1 ? '' : 's'}',
              icon: Icons.warning_amber_rounded,
              iconColor: PayrollTokens.rose,
              children: alerts.map((a) {
                final isCrit = a.severity.name == 'critical';
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(children: [
                    Container(
                      width: 8, height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isCrit ? PayrollTokens.rose : PayrollTokens.amber,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        '${a.title}: ${a.description}',
                        style: tt.bodySmall,
                      ),
                    ),
                  ]),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.md),
          ],

          // -- Employee payslips ----------------------------------------------
          PrSectionCard(
            title: '${payslips.length} Employees',
            icon: Icons.receipt_long_outlined,
            iconColor: PayrollTokens.navy,
            children: payslips.map((ps) {
              final emp = employees.firstWhere(
                (e) => e.id == ps.employeeId,
                orElse: () => employees.first,
              );
              return _PayslipTile(
                ps: ps,
                emp: emp,
                tt: tt,
                cs: cs,
                onView: () => context.push(AppRoutes.payrollPayslipDetail(ps.id)),
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.lg),

          // -- Actions --------------------------------------------------------
          if (canApprove)
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(backgroundColor: PayrollTokens.green),
                onPressed: isLoading ? null : () => _confirmApprove(context, ref, payRun),
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Approve Pay Run'),
              ),
            ),

          if (canDisburse)
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                style: FilledButton.styleFrom(backgroundColor: PayrollTokens.teal),
                onPressed: isLoading ? null : () => _confirmDisburse(context, ref, payRun),
                child: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Disburse Payments'),
              ),
            ),

          if (payRun.status == PayRunStatus.disbursed)
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: PayrollTokens.green.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: PayrollTokens.green.withValues(alpha: 0.3)),
              ),
              child: Row(children: [
                const Icon(Icons.check_circle, color: PayrollTokens.green),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    'Disbursed${payRun.disbursedAt != null ? ' on ${_df.format(payRun.disbursedAt!)}' : ''}',
                    style: tt.bodyMedium?.copyWith(
                      color: PayrollTokens.green, fontWeight: FontWeight.w600),
                  ),
                ),
              ]),
            ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }

  Future<void> _confirmApprove(
      BuildContext ctx, WidgetRef ref, PayRun payRun) async {
    final ok = await _showPayRunConfirmSheet(
      context:      ctx,
      accentColor:  PayrollTokens.green,
      headerIcon:   Icons.check_circle_outline_rounded,
      title:        'Approve Pay Run',
      periodLabel:  _mf.format(payRun.periodStart),
      employees:    payRun.employeeCount,
      gross:        payRun.totalGross,
      net:          payRun.totalNet,
      payDate:      _df.format(payRun.payDate),
      actionLabel:  'Approve',
    );
    if (ok != true || !ctx.mounted) return;
    await ref.read(payRunNotifierProvider.notifier).approvePayRun(payRun.id);
    if (!ctx.mounted) return;
    ScaffoldMessenger.of(ctx).showSnackBar(
      const SnackBar(
        content: Text('Pay run approved.'),
        backgroundColor: PayrollTokens.green,
      ),
    );
  }

  Future<void> _confirmDisburse(
      BuildContext ctx, WidgetRef ref, PayRun payRun) async {
    final ok = await _showPayRunConfirmSheet(
      context:      ctx,
      accentColor:  PayrollTokens.teal,
      headerIcon:   Icons.payments_outlined,
      title:        'Disburse Payments',
      periodLabel:  _mf.format(payRun.periodStart),
      employees:    payRun.employeeCount,
      gross:        payRun.totalGross,
      net:          payRun.totalNet,
      payDate:      _df.format(payRun.payDate),
      actionLabel:  'Disburse',
    );
    if (ok != true || !ctx.mounted) return;
    await ref.read(payRunNotifierProvider.notifier).disbursePayRun(payRun.id);
    if (!ctx.mounted) return;
    ScaffoldMessenger.of(ctx).showSnackBar(
      const SnackBar(
        content: Text('Payments disbursed successfully.'),
        backgroundColor: PayrollTokens.teal,
      ),
    );
  }
}

// ─── Pay-run confirmation bottom sheet ───────────────────────────────────────

Future<bool?> _showPayRunConfirmSheet({
  required BuildContext context,
  required Color     accentColor,
  required IconData  headerIcon,
  required String    title,
  required String    periodLabel,
  required int       employees,
  required double    gross,
  required double    net,
  required String    payDate,
  required String    actionLabel,
}) {
  final zar = NumberFormat.currency(locale: 'en_ZA', symbol: 'R ', decimalDigits: 0);
  return showModalBottomSheet<bool>(
    context:       context,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            const SizedBox(height: 12),
            Container(
              width: 36, height: 4,
              decoration: BoxDecoration(
                color:        Colors.grey.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),

            // Coloured icon header
            Container(
              width: 56, height: 56,
              decoration: BoxDecoration(
                color:        accentColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(headerIcon, color: accentColor, size: 28),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: Theme.of(ctx).textTheme.titleLarge
                  ?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              periodLabel,
              style: Theme.of(ctx).textTheme.bodySmall
                  ?.copyWith(color: Theme.of(ctx).colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 20),

            // Summary table
            _ConfirmRow(label: 'Employees', value: '$employees'),
            _ConfirmRow(label: 'Gross Pay',  value: zar.format(gross)),
            _ConfirmRow(label: 'Net Pay',    value: zar.format(net),    bold: true, color: accentColor),
            _ConfirmRow(label: 'Pay Date',   value: payDate),
            const SizedBox(height: 24),

            // Action buttons
            Row(children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(ctx, false),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton(
                  style: FilledButton.styleFrom(backgroundColor: accentColor),
                  onPressed: () => Navigator.pop(ctx, true),
                  child: Text(actionLabel),
                ),
              ),
            ]),
          ],
        ),
      ),
    ),
  );
}

class _ConfirmRow extends StatelessWidget {
  const _ConfirmRow({
    required this.label,
    required this.value,
    this.bold  = false,
    this.color,
  });
  final String  label;
  final String  value;
  final bool    bold;
  final Color?  color;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(children: [
        Expanded(
          child: Text(
            label,
            style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
          ),
        ),
        Text(
          value,
          style: tt.bodyMedium?.copyWith(
            fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
            color:      color ?? cs.onSurface,
          ),
        ),
      ]),
    );
  }
}

// --- Helpers ------------------------------------------------------------------


class _HeaderStat extends StatelessWidget {
  const _HeaderStat({
    required this.label,
    required this.value,
    required this.icon,
  });
  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Icon(icon, size: 12, color: Colors.white.withValues(alpha: 0.7)),
            const SizedBox(width: 4),
            Text(label,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 10,
                )),
          ]),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 12,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _PayslipTile extends StatelessWidget {
  const _PayslipTile({
    required this.ps,
    required this.emp,
    required this.tt,
    required this.cs,
    required this.onView,
  });
  final dynamic ps;
  final dynamic emp;
  final TextTheme tt;
  final ColorScheme cs;
  final VoidCallback onView;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: ExpansionTile(
        tilePadding: EdgeInsets.zero,
        leading: CircleAvatar(
          radius: 20,
          backgroundColor: PayrollTokens.navy.withValues(alpha: 0.1),
          child: Text(
            '${emp.firstName[0]}${emp.lastName[0]}',
            style: const TextStyle(
                color: PayrollTokens.navy, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          '${emp.firstName} ${emp.lastName}',
          style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          emp.occupationTitle,
          style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              NumberFormat.currency(
                      locale: 'en_ZA', symbol: 'R ', decimalDigits: 0)
                  .format(ps.netPay),

              style: tt.bodyMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: PayrollTokens.green,
              ),
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.xs, 0, AppSpacing.xs, AppSpacing.sm),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: onView,
                  icon: const Icon(Icons.description_outlined, size: 16),
                  label: const Text('View Payslip'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: PayrollTokens.navy,
                    side: const BorderSide(color: PayrollTokens.navy),
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md, vertical: AppSpacing.xs),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:mobile_app/core/router/app_routes.dart';
import 'package:mobile_app/core/theme/app_colors.dart';
import 'package:mobile_app/features/payroll/models/compliance_alert.dart';
import 'package:mobile_app/features/payroll/models/pay_group.dart';
import 'package:mobile_app/features/payroll/models/pay_run.dart';
import 'package:mobile_app/features/payroll/models/payroll_employee.dart';
import 'package:mobile_app/features/payroll/providers/payroll_action_providers.dart';
import 'package:mobile_app/features/payroll/providers/payroll_providers.dart';
import 'package:mobile_app/features/payroll/widgets/payroll_widgets.dart';
import 'package:mobile_app/shared/widgets/avatar_widget.dart';
import 'package:mobile_app/shared/widgets/farm_app_bar.dart';
import 'package:mobile_app/shared/widgets/farm_scaffold.dart';

// ─── Helpers ──────────────────────────────────────────────────────────────────
final _zar = NumberFormat.currency(
  locale: 'en_ZA',
  symbol: 'R ',
  decimalDigits: 0,
);
final _df = DateFormat('d MMM yyyy');
final _mf = DateFormat('MMMM yyyy');

// ─── Run Payroll Screen ───────────────────────────────────────────────────────
class RunPayrollScreen extends ConsumerStatefulWidget {
  const RunPayrollScreen({super.key});

  @override
  ConsumerState<RunPayrollScreen> createState() => _RunPayrollScreenState();
}

class _RunPayrollScreenState extends ConsumerState<RunPayrollScreen> {
  int _step = 0; // 0=select, 1=pre-report, 2=review, 3=disburse

  String? _selectedPayGroupId;
  late DateTime _periodStart;
  late DateTime _periodEnd;
  PayRun? _calculatedRun;
  bool _isCalculating = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _periodStart = DateTime(now.year, now.month, 1);
    _periodEnd = DateTime(now.year, now.month + 1, 0);
  }

  @override
  Widget build(BuildContext context) {
    // Watch shared providers here in the stateful parent so that children
    // (_StepSelectPeriod, _StepPreReport) never trigger a first-subscription
    // flush mid-build, which causes the setState-during-build crash.
    final allEmployees = ref.watch(activeEmployeesProvider);
    final allAlerts = ref
        .watch(complianceAlertsProvider)
        .where((a) => a.isOpen)
        .toList();
    final payGroups = ref.watch(activePayGroupsProvider);
    final pgEmployees = _selectedPayGroupId != null
        ? allEmployees
              .where((e) => e.payGroupId == _selectedPayGroupId)
              .toList()
        : <PayrollEmployee>[];
    final pgAlerts = pgEmployees.isEmpty
        ? <ComplianceAlert>[]
        : allAlerts
              .where((a) => pgEmployees.any((e) => e.id == a.employeeId))
              .toList();
    return FarmScaffold(
      appBar: FarmAppBar(
        title: 'Run Payroll',
        actions: [
          if (_step > 0)
            TextButton.icon(
              onPressed: () => setState(() {
                _step = 0;
                _calculatedRun = null;
              }),
              icon: const Icon(Icons.refresh),
              label: const Text('Restart'),
            ),
        ],
      ),
      body: Column(
        children: [
          _StepIndicator(currentStep: _step),
          Expanded(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: switch (_step) {
                0 => _StepSelectPeriod(
                  key: const ValueKey(0),
                  payGroups: payGroups,
                  payGroupId: _selectedPayGroupId,
                  periodStart: _periodStart,
                  periodEnd: _periodEnd,
                  employees: allEmployees,
                  onPayGroupChanged: (v) =>
                      setState(() => _selectedPayGroupId = v),
                  onPeriodStartChanged: (d) => setState(() => _periodStart = d),
                  onPeriodEndChanged: (d) => setState(() => _periodEnd = d),
                  onNext: _goToPreReport,
                ),
                1 => _StepPreReport(
                  key: const ValueKey(1),
                  employees: pgEmployees,
                  empAlerts: pgAlerts,
                  periodStart: _periodStart,
                  periodEnd: _periodEnd,
                  onBack: () => setState(() => _step = 0),
                  onCalculate: _runCalculation,
                  isCalculating: _isCalculating,
                ),
                2 => _StepReviewCalculation(
                  key: const ValueKey(2),
                  payRunId: _calculatedRun!.id,
                  onBack: () => setState(() => _step = 1),
                  onApprove: _approveRun,
                ),
                3 => _StepDisbursement(
                  key: const ValueKey(3),
                  payRunId: _calculatedRun!.id,
                ),
                _ => const SizedBox.shrink(),
              },
            ),
          ),
        ],
      ),
    );
  }

  void _goToPreReport() {
    if (_selectedPayGroupId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a pay group.')),
      );
      return;
    }
    setState(() => _step = 1);
  }

  Future<void> _runCalculation() async {
    if (_isCalculating) return; // prevent duplicate taps
    setState(() => _isCalculating = true);
    try {
      final run = await ref
          .read(payRunNotifierProvider.notifier)
          .calculatePayRun(
            payGroupId: _selectedPayGroupId!,
            periodStart: _periodStart,
            periodEnd: _periodEnd,
            payDate: _periodEnd,
          );
      if (!mounted) return;
      if (run == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Calculation failed — check inputs.')),
        );
        return;
      }
      setState(() {
        _calculatedRun = run;
        _step = 2;
      });
    } finally {
      if (mounted) setState(() => _isCalculating = false);
    }
  }

  Future<void> _approveRun() async {
    final run = await ref
        .read(payRunNotifierProvider.notifier)
        .approvePayRun(_calculatedRun!.id);
    if (!mounted) return;
    if (run == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Approval failed — please try again.')),
      );
      return;
    }
    setState(() {
      _calculatedRun = run;
      _step = 3;
    });
  }
}

// ─── Step Indicator ───────────────────────────────────────────────────────────
class _StepIndicator extends StatelessWidget {
  const _StepIndicator({required this.currentStep});
  final int currentStep;

  static const _labels = ['Period', 'Pre-Check', 'Review', 'Disburse'];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: List.generate(_labels.length * 2 - 1, (i) {
          if (i.isOdd) {
            return Expanded(
              child: Container(
                height: 2,
                color: i ~/ 2 < currentStep
                    ? AppColors.primary
                    : cs.outlineVariant,
              ),
            );
          }
          final step = i ~/ 2;
          final done = step < currentStep;
          final active = step == currentStep;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: done || active
                    ? AppColors.primary
                    : cs.outlineVariant,
                child: done
                    ? const Icon(Icons.check, size: 14, color: Colors.white)
                    : Text(
                        '${step + 1}',
                        style: TextStyle(
                          fontSize: 12,
                          color: active ? Colors.white : cs.onSurfaceVariant,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              const SizedBox(height: 4),
              Text(
                _labels[step],
                style: tt.labelSmall?.copyWith(
                  color: active ? AppColors.primary : cs.onSurfaceVariant,
                  fontWeight: active ? FontWeight.bold : FontWeight.normal,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ],
          );
        }),
      ),
    );
  }
}

// ─── Step 0: Select Period ────────────────────────────────────────────────────
class _StepSelectPeriod extends StatelessWidget {
  const _StepSelectPeriod({
    super.key,
    required this.payGroups,
    required this.payGroupId,
    required this.periodStart,
    required this.periodEnd,
    required this.employees,
    required this.onPayGroupChanged,
    required this.onPeriodStartChanged,
    required this.onPeriodEndChanged,
    required this.onNext,
  });
  final List<PayGroup> payGroups;
  final String? payGroupId;
  final DateTime periodStart;
  final DateTime periodEnd;
  final List<PayrollEmployee> employees;
  final ValueChanged<String?> onPayGroupChanged;
  final ValueChanged<DateTime> onPeriodStartChanged;
  final ValueChanged<DateTime> onPeriodEndChanged;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Select Pay Group & Period', style: tt.titleLarge),
          const SizedBox(height: 4),
          Text(
            'Choose the pay group and period to process.',
            style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 24),
          DropdownButtonFormField<String>(
            initialValue: payGroupId,
            decoration: const InputDecoration(
              labelText: 'Pay Group *',
              prefixIcon: Icon(Icons.group_work),
              border: OutlineInputBorder(),
            ),
            items: payGroups
                .map(
                  (g) => DropdownMenuItem<String>(
                    value: g.id,
                    child: Text(g.name),
                  ),
                )
                .toList(),
            onChanged: onPayGroupChanged,
          ),
          const SizedBox(height: 16),
          _DateRow(
            label: 'Period Start',
            date: periodStart,
            onPick: onPeriodStartChanged,
          ),
          const SizedBox(height: 12),
          _DateRow(
            label: 'Period End',
            date: periodEnd,
            onPick: onPeriodEndChanged,
          ),
          if (payGroupId != null) ...[
            const SizedBox(height: 24),
            _EmployeeCountCard(
              employeeCount: employees
                  .where((e) => e.payGroupId == payGroupId)
                  .length,
              periodStart: periodStart,
              periodEnd: periodEnd,
            ),
          ],
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onNext,
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Continue to Pre-Payroll Check'),
            ),
          ),
        ],
      ),
    );
  }
}

class _DateRow extends StatelessWidget {
  const _DateRow({
    required this.label,
    required this.date,
    required this.onPick,
  });
  final String label;
  final DateTime date;
  final ValueChanged<DateTime> onPick;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date,
          firstDate: DateTime(2020),
          lastDate: DateTime(2030),
        );
        if (picked != null) onPick(picked);
      },
      borderRadius: BorderRadius.circular(8),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.calendar_today),
          border: const OutlineInputBorder(),
        ),
        child: Text(_df.format(date)),
      ),
    );
  }
}

class _EmployeeCountCard extends StatelessWidget {
  const _EmployeeCountCard({
    required this.employeeCount,
    required this.periodStart,
    required this.periodEnd,
  });
  final int employeeCount;
  final DateTime periodStart;
  final DateTime periodEnd;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.people_outline_rounded, color: AppColors.success),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$employeeCount employee${employeeCount == 1 ? '' : 's'}',
                style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              Text(
                '${_df.format(periodStart)} – ${_df.format(periodEnd)}',
                style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Step 1: Pre-payroll Report ───────────────────────────────────────────────
class _StepPreReport extends StatefulWidget {
  const _StepPreReport({
    super.key,
    required this.employees,
    required this.empAlerts,
    required this.periodStart,
    required this.periodEnd,
    required this.onBack,
    required this.onCalculate,
    required this.isCalculating,
  });
  final List<PayrollEmployee> employees;
  final List<ComplianceAlert> empAlerts;
  final DateTime periodStart;
  final DateTime periodEnd;
  final VoidCallback onBack;
  final VoidCallback onCalculate;
  final bool isCalculating;

  @override
  State<_StepPreReport> createState() => _StepPreReportState();
}

class _StepPreReportState extends State<_StepPreReport> {
  bool _showEmployeeList = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    // Group alerts by severity
    final criticalAlerts = widget.empAlerts
        .where((a) => a.severity == ComplianceSeverity.critical)
        .toList();
    final warningAlerts = widget.empAlerts
        .where((a) => a.severity == ComplianceSeverity.warning)
        .toList();
    final infoAlerts = widget.empAlerts
        .where((a) => a.severity == ComplianceSeverity.info)
        .toList();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Pre-Payroll Report', style: tt.titleLarge),
          const SizedBox(height: 4),
          Text(
            '${_mf.format(widget.periodStart)} \u2022 ${widget.employees.length} employees',
            style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 20),

          // ── Compliance Alerts Summary ──
          if (widget.empAlerts.isNotEmpty) ...[
            Container(
              decoration: BoxDecoration(
                color: cs.surfaceContainerLow,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: cs.outlineVariant),
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.warning_amber_rounded,
                          color: AppColors.warning, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Compliance Alerts',
                        style: tt.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: () =>
                            context.push(AppRoutes.payrollCompliance),
                        icon: const Icon(Icons.open_in_new, size: 14),
                        label: const Text('View All'),
                        style: TextButton.styleFrom(
                          visualDensity: VisualDensity.compact,
                          textStyle: tt.labelSmall,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Alert counts by severity
                  if (criticalAlerts.isNotEmpty)
                    _AlertCountRow(
                      label: 'Critical',
                      count: criticalAlerts.length,
                      color: cs.error,
                    ),
                  if (warningAlerts.isNotEmpty)
                    _AlertCountRow(
                      label: 'Warning',
                      count: warningAlerts.length,
                      color: AppColors.warning,
                    ),
                  if (infoAlerts.isNotEmpty)
                    _AlertCountRow(
                      label: 'Info',
                      count: infoAlerts.length,
                      color: cs.primary,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ] else ...[
            Container(
              decoration: BoxDecoration(
                color: AppColors.success.withAlpha(15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.success.withAlpha(60)),
              ),
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.check_circle_rounded,
                      color: AppColors.success, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'No compliance alerts',
                    style: tt.bodyMedium?.copyWith(
                      color: AppColors.success,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // ── Employees Summary ──
          Container(
            decoration: BoxDecoration(
              color: cs.surfaceContainerLow,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: cs.outlineVariant),
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.people_outline, color: cs.primary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      '${widget.employees.length} Employees',
                      style: tt.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () => setState(
                          () => _showEmployeeList = !_showEmployeeList),
                      icon: Icon(
                        _showEmployeeList
                            ? Icons.expand_less
                            : Icons.expand_more,
                        size: 16,
                      ),
                      label: Text(_showEmployeeList ? 'Hide' : 'View List'),
                      style: TextButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                        textStyle: tt.labelSmall,
                      ),
                    ),
                  ],
                ),
                if (_showEmployeeList) ...[
                  const SizedBox(height: 8),
                  const Divider(height: 1),
                  const SizedBox(height: 8),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 300),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: widget.employees.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (_, i) {
                        final e = widget.employees[i];
                        final initials =
                            '${e.firstName.isNotEmpty ? e.firstName[0] : ''}'
                                    '${e.lastName.isNotEmpty ? e.lastName[0] : ''}'
                                .toUpperCase();
                        final alertCount = widget.empAlerts
                            .where((a) => a.employeeId == e.id)
                            .length;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            children: [
                              AvatarWidget(
                                imageUrl: e.profileImageUrl,
                                initials: initials,
                                radius: 16,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  '${e.firstName} ${e.lastName}',
                                  style: tt.bodySmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (alertCount > 0)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.warning.withAlpha(25),
                                    borderRadius: BorderRadius.circular(99),
                                  ),
                                  child: Text(
                                    '$alertCount',
                                    style: tt.labelSmall?.copyWith(
                                      color: AppColors.warning,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 10,
                                    ),
                                  ),
                                )
                              else
                                Icon(Icons.check_circle_outline,
                                    size: 14, color: AppColors.success),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 24),
          // ── Navigation Buttons ──
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: widget.onBack,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Back'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: FilledButton.icon(
                  onPressed:
                      widget.isCalculating ? null : widget.onCalculate,
                  icon: widget.isCalculating
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.calculate),
                  label: Text(
                    widget.isCalculating
                        ? 'Calculating\u2026'
                        : 'Calculate Payroll',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AlertCountRow extends StatelessWidget {
  const _AlertCountRow({
    required this.label,
    required this.count,
    required this.color,
  });
  final String label;
  final int count;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(label, style: tt.bodySmall),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: color.withAlpha(20),
              borderRadius: BorderRadius.circular(99),
            ),
            child: Text(
              '$count',
              style: tt.labelSmall?.copyWith(
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Step 2: Review Calculation ───────────────────────────────────────────────
class _StepReviewCalculation extends ConsumerWidget {
  const _StepReviewCalculation({
    super.key,
    required this.payRunId,
    required this.onBack,
    required this.onApprove,
  });
  final String payRunId;
  final VoidCallback onBack;
  final VoidCallback onApprove;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final payRun = ref.watch(payRunProvider(payRunId));
    final payslips = ref.watch(
      payslipsProvider(PayslipFilter(payRunId: payRunId)),
    );
    final employees = ref.watch(activeEmployeesProvider);
    final isLoading = ref.watch(payRunNotifierProvider) is AsyncLoading;

    if (payRun == null) return const Center(child: CircularProgressIndicator());

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Review Calculated Payroll', style: tt.titleLarge),
          Text(
            '${_mf.format(payRun.periodStart)} \u00b7 ${payRun.employeeCount} employees',
            style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant),
          ),
          const SizedBox(height: 16),
          _TotalsSection(payRun: payRun),
          if (payRun.complianceAlertIds.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.error.withValues(alpha: 0.4),
                ),
              ),
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Icon(Icons.error_outline_rounded, color: AppColors.error),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${payRun.complianceAlertIds.length} compliance alert(s) raised. Review before approving.',
                      style: tt.bodySmall?.copyWith(color: AppColors.error),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          Text('Employee Breakdown', style: tt.titleSmall),
          const SizedBox(height: 8),
          ...payslips.map((ps) {
            final emp = employees.firstWhere(
              (e) => e.id == ps.employeeId,
              orElse: () => employees.first,
            );
            final initials =
                '${emp.firstName.isNotEmpty ? emp.firstName[0] : ''}'
                        '${emp.lastName.isNotEmpty ? emp.lastName[0] : ''}'
                    .toUpperCase();
            return Card(
              child: ExpansionTile(
                leading: AvatarWidget(
                  imageUrl: emp.profileImageUrl,
                  initials: initials,
                  radius: 20,
                ),
                title: Text('${emp.firstName} ${emp.lastName}'),
                subtitle: Text(_zar.format(ps.netPay)),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Column(
                      children: [
                        _LineRow('Basic Wage', ps.basicWage),
                        if (ps.overtimePay > 0)
                          _LineRow('Overtime', ps.overtimePay),
                        if (ps.holidayPay > 0)
                          _LineRow('Holiday Pay', ps.holidayPay),
                        if (ps.inKindHousing > 0)
                          _LineRow('Housing (in-kind)', ps.inKindHousing),
                        if (ps.inKindFood > 0)
                          _LineRow('Food (in-kind)', ps.inKindFood),
                        const Divider(),
                        _LineRow('Gross Pay', ps.grossPay, bold: true),
                        ...ps.deductions.map(
                          (d) =>
                              _LineRow(d.description, -d.amount, isRed: true),
                        ),
                        const Divider(),
                        _LineRow(
                          'Net Pay',
                          ps.netPay,
                          bold: true,
                          isGreen: true,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: isLoading ? null : onBack,
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Back'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.success,
                  ),
                  onPressed: isLoading ? null : onApprove,
                  icon: isLoading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.check_circle_outline_rounded),
                  label: const Text('Approve Pay Run'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ─── Step 3: Disbursement ─────────────────────────────────────────────────────
class _StepDisbursement extends ConsumerStatefulWidget {
  const _StepDisbursement({super.key, required this.payRunId});
  final String payRunId;

  @override
  ConsumerState<_StepDisbursement> createState() => _StepDisbursementState();
}

class _StepDisbursementState extends ConsumerState<_StepDisbursement> {
  bool _disbursed = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final payRun = ref.watch(payRunProvider(widget.payRunId));
    final isLoading = ref.watch(payRunNotifierProvider) is AsyncLoading;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 16),
          // Animated check icon
          _DisbursementAnimation(
            disbursed: _disbursed,
            child: Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.success.withValues(alpha: 0.3),
                  width: 2,
                ),
              ),
              child: Icon(
                _disbursed
                    ? Icons.check_circle_rounded
                    : Icons.task_alt_rounded,
                size: 52,
                color: AppColors.success,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            _disbursed ? 'Payments Initiated!' : 'Pay Run Approved!',
            style: tt.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          if (payRun != null) ...[
            Text(
              _disbursed
                  ? 'Payroll for ${_mf.format(payRun.periodStart)} has been disbursed successfully.'
                  : 'Payroll for ${_mf.format(payRun.periodStart)} is approved and ready for disbursement.',
              textAlign: TextAlign.center,
              style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            _TotalsSection(payRun: payRun),
          ],
          const SizedBox(height: 32),
          if (!_disbursed)
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.success,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                onPressed: isLoading
                    ? null
                    : () async {
                        HapticFeedback.mediumImpact();
                        await ref
                            .read(payRunNotifierProvider.notifier)
                            .disbursePayRun(widget.payRunId);
                        if (!context.mounted) return;
                        HapticFeedback.heavyImpact();
                        setState(() => _disbursed = true);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: const Text(
                              'Pay run disbursed \u2014 payments initiated.',
                            ),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      },
                icon: isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send_rounded),
                label: const Text(
                  'Disburse Payments',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Done \u2014 View Pay Runs'),
          ),
        ],
      ),
    );
  }
}

// ─── Disbursement animation wrapper ──────────────────────────────────────────
class _DisbursementAnimation extends StatefulWidget {
  const _DisbursementAnimation({required this.disbursed, required this.child});
  final bool disbursed;
  final Widget child;

  @override
  State<_DisbursementAnimation> createState() => _DisbursementAnimationState();
}

class _DisbursementAnimationState extends State<_DisbursementAnimation>
    with SingleTickerProviderStateMixin {
  late final AnimationController _checkCtrl;
  late final Animation<double> _checkScale;

  @override
  void initState() {
    super.initState();
    _checkCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _checkScale = CurvedAnimation(parent: _checkCtrl, curve: Curves.elasticOut);
    Future.delayed(const Duration(milliseconds: 200), () {
      if (mounted) _checkCtrl.forward();
    });
  }

  @override
  void didUpdateWidget(_DisbursementAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.disbursed && widget.disbursed) {
      _checkCtrl
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _checkCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(scale: _checkScale, child: widget.child);
  }
}

// ─── Totals section (replaces _TotalsCard) ────────────────────────────────────
class _TotalsSection extends StatelessWidget {
  const _TotalsSection({required this.payRun});
  final PayRun payRun;

  @override
  Widget build(BuildContext context) {
    return PrSectionCard(
      title: 'Payroll Summary',
      icon: Icons.summarize_outlined,
      iconColor: AppColors.primary,
      children: [
        _LineRow('Total Gross', payRun.totalGross),
        _LineRow('Total Deductions', -payRun.totalDeductions, isRed: true),
        const Divider(height: 16),
        _LineRow('Net Pay', payRun.totalNet, bold: true, isGreen: true),
      ],
    );
  }
}

// ─── Line row ─────────────────────────────────────────────────────────────────
class _LineRow extends StatelessWidget {
  const _LineRow(
    this.label,
    this.amount, {
    this.bold = false,
    this.isRed = false,
    this.isGreen = false,
  });
  final String label;
  final double amount;
  final bool bold;
  final bool isRed;
  final bool isGreen;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final color = isRed
        ? AppColors.error
        : isGreen
        ? AppColors.success
        : null;
    final style =
        (bold
                ? tt.bodyMedium?.copyWith(fontWeight: FontWeight.bold)
                : tt.bodyMedium)
            ?.copyWith(color: color ?? cs.onSurface);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(child: Text(label, style: style)),
          Text(
            '${amount < 0 ? "\u2212 " : ""}${_zar.format(amount.abs())}',
            style: style,
          ),
        ],
      ),
    );
  }
}

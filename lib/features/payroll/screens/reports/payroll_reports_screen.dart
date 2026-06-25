import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:mobile_app/core/theme/app_colors.dart';
import 'package:mobile_app/core/theme/app_spacing.dart';
import 'package:mobile_app/shared/widgets/farm_scaffold.dart';
import 'package:mobile_app/shared/widgets/farm_app_bar.dart';
import 'package:mobile_app/features/payroll/models/leave_request.dart';
import 'package:mobile_app/features/payroll/models/leave_type.dart';
import 'package:mobile_app/features/payroll/models/pay_group.dart';
import 'package:mobile_app/features/payroll/models/pay_run.dart';
import 'package:mobile_app/features/payroll/providers/payroll_providers.dart';
import 'package:mobile_app/features/payroll/theme/payroll_tokens.dart';
import 'package:mobile_app/features/payroll/models/employer_config.dart';

// ─── Formatters ───────────────────────────────────────────────────────────────

final _zarFmt =
    NumberFormat.currency(locale: 'en_ZA', symbol: 'R ', decimalDigits: 0);
final _shortFmt = DateFormat('d MMM');

String _compact(double v) {
  if (v >= 1000000) return 'R ${(v / 1000000).toStringAsFixed(1)}M';
  if (v >= 1000) return 'R ${(v / 1000).toStringAsFixed(0)}K';
  return 'R ${v.toStringAsFixed(0)}';
}

String _fmtDate(DateTime dt) =>
    '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';

// ─── Report types ─────────────────────────────────────────────────────────────

enum _ReportType {
  paySummary('Pay Run Summary', Icons.summarize_outlined,
      Color(0xFF1E3A5F)),
  statutory('Statutory Deductions', Icons.account_balance_outlined,
      Color(0xFF0277BD)),
  leave('Leave Analysis', Icons.beach_access_outlined,
      Color(0xFF00695C)),
  workforce('Workforce Overview', Icons.people_outlined,
      Color(0xFF16A34A)),
  deductions('Deductions Breakdown', Icons.remove_circle_outline,
      Color(0xFFC62828));

  final String label;
  final IconData icon;
  final Color color;
  const _ReportType(this.label, this.icon, this.color);
}

bool _inRange(DateTime date, DateTime? from, DateTime? to) {
  if (from != null && date.isBefore(from)) return false;
  if (to != null) {
    final end = DateTime(to.year, to.month, to.day, 23, 59, 59, 999);
    if (date.isAfter(end)) return false;
  }
  return true;
}

// ─── Screen ───────────────────────────────────────────────────────────────────

class PayrollReportsScreen extends ConsumerStatefulWidget {
  const PayrollReportsScreen({super.key});

  @override
  ConsumerState<PayrollReportsScreen> createState() =>
      _PayrollReportsScreenState();
}

class _PayrollReportsScreenState
    extends ConsumerState<PayrollReportsScreen> {
  _ReportType _reportType = _ReportType.paySummary;
  DateTime? _fromDate;
  DateTime? _toDate;
  String? _payGroupId;
  PayRunStatus? _status;

  Future<void> _pickFrom() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _fromDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: _toDate ?? DateTime.now(),
    );
    if (d != null) setState(() => _fromDate = d);
  }

  Future<void> _pickTo() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _toDate ?? DateTime.now(),
      firstDate: _fromDate ?? DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (d != null) setState(() => _toDate = d);
  }

  @override
  Widget build(BuildContext context) {
    final allPayRuns = ref.watch(allPayRunsProvider);
    final allPayslips = ref.watch(payslipsProvider(const PayslipFilter()));
    final leaveRequests =
        ref.watch(leaveRequestsProvider(const LeaveRequestFilter()));
    final leaveTypes = ref.watch(leaveTypesProvider);
    final stats = ref.watch(payrollDashboardStatsProvider);
    final employer = ref.watch(employerConfigProvider);
    final payGroups = ref.watch(activePayGroupsProvider);

    // ── Apply filters ──────────────────────────────────────────────────────
    final filteredRuns = allPayRuns.where((r) {
      if (_payGroupId != null && r.payGroupId != _payGroupId) return false;
      if (_status != null && r.status != _status) return false;
      return _inRange(r.payDate, _fromDate, _toDate);
    }).toList()
      ..sort((a, b) => b.payDate.compareTo(a.payDate));

    final disbursedRuns =
        filteredRuns.where((r) => r.status == PayRunStatus.disbursed).toList();

    double totalGross = 0, totalNet = 0, totalDeductions = 0;
    for (final r in disbursedRuns) {
      totalGross += r.totalGross;
      totalNet += r.totalNet;
      totalDeductions += r.totalDeductions;
    }

    // Payslips scoped to filtered run IDs
    final rangeRunIds = filteredRuns.map((r) => r.id).toSet();
    double uifTotal = 0, payeTotal = 0, voluntaryTotal = 0;
    final Map<String, double> allDeductionTotals = {};
    for (final ps in allPayslips) {
      if (!rangeRunIds.contains(ps.payRunId)) continue; // scoped to filtered runs
      for (final d in ps.deductions) {
        if (d.code == 'UIF_EE') uifTotal += d.amount;
        if (d.code == 'PAYE') payeTotal += d.amount;
        if (!d.isStatutory) voluntaryTotal += d.amount;
        final key = d.description.isNotEmpty ? d.description : d.code;
        allDeductionTotals[key] = (allDeductionTotals[key] ?? 0) + d.amount;
      }
    }
    final sortedDeductions = allDeductionTotals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Leave data scoped to date range
    final leaveTypeMap = {for (final lt in leaveTypes) lt.id: lt.name};
    final Map<String, int> leaveTakenByType = {};
    final Map<String, int> leavePendingByType = {};
    for (final lr in leaveRequests) {
      if (!_inRange(lr.startDate, _fromDate, _toDate)) continue;
      final name = leaveTypeMap[lr.leaveTypeId] ?? lr.leaveTypeId;
      if (lr.status == LeaveStatus.approved) {
        leaveTakenByType[name] =
            (leaveTakenByType[name] ?? 0) + lr.daysRequested.round();
      }
      if (lr.status == LeaveStatus.pending) {
        leavePendingByType[name] =
            (leavePendingByType[name] ?? 0) + lr.daysRequested.round();
      }
    }
    final totalDaysTaken = leaveTakenByType.values.fold(0, (s, v) => s + v);
    final totalDaysPending =
        leavePendingByType.values.fold(0, (s, v) => s + v);
    final pendingLeave = leaveRequests
        .where((lr) =>
            lr.status == LeaveStatus.pending &&
            _inRange(lr.startDate, _fromDate, _toDate))
        .toList();

    Future<void> doExport() async {
      try {
        await Printing.layoutPdf(
          name:
              'Payroll_Report_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf',
          onLayout: (_) => _buildReportPdf(
            reportType: _reportType,
            employer: employer,
            stats: stats,
            disbursedRuns: disbursedRuns,
            totalGross: totalGross,
            totalNet: totalNet,
            totalDeductions: totalDeductions,
            uifTotal: uifTotal,
            payeTotal: payeTotal,
            voluntaryTotal: voluntaryTotal,
            leaveTypes: leaveTypes,
            leaveTakenByType: leaveTakenByType,
            leavePendingByType: leavePendingByType,
            range: (_fromDate != null && _toDate != null)
                ? DateTimeRange(start: _fromDate!, end: _toDate!)
                : null,
          ),
        );
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: AppColors.error,
          ));
        }
      }
    }

    return FarmScaffold(
      appBar: FarmAppBar(
        title: 'Payroll Reports',
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined,
                color: Color(0xFFD32F2F)),
            tooltip: 'Export PDF',
            onPressed: doExport,
          ),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: [
          // ── Horizontal filter bar ─────────────────────────────────────────
          _FilterBar(
            reportType: _reportType,
            fromDate: _fromDate,
            toDate: _toDate,
            payGroupId: _payGroupId,
            payGroups: payGroups,
            status: _status,
            onReportTypeChanged: (t) => setState(() => _reportType = t),
            onPickFrom: _pickFrom,
            onPickTo: _pickTo,
            onClearDates: (_fromDate != null || _toDate != null)
                ? () => setState(() { _fromDate = null; _toDate = null; })
                : null,
            onPayGroupChanged: (id) => setState(() => _payGroupId = id),
            onStatusChanged: (s) => setState(() => _status = s),
          ),

          const SizedBox(height: AppSpacing.md),

          // ── Report content ────────────────────────────────────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: _ReportContent(
              reportType: _reportType,
              filteredRuns: filteredRuns,
              disbursedRuns: disbursedRuns,
              totalGross: totalGross,
              totalNet: totalNet,
              totalDeductions: totalDeductions,
              uifTotal: uifTotal,
              payeTotal: payeTotal,
              voluntaryTotal: voluntaryTotal,
              sortedDeductions: sortedDeductions,
              stats: stats,
              leaveTypes: leaveTypes,
              leaveTakenByType: leaveTakenByType,
              leavePendingByType: leavePendingByType,
              totalDaysTaken: totalDaysTaken,
              totalDaysPending: totalDaysPending,
              pendingLeave: pendingLeave,
              leaveTypeMap: leaveTypeMap,
            ),
          ),

          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }
}

// ─── Horizontal filter bar ────────────────────────────────────────────────────

class _FilterBar extends StatelessWidget {
  final _ReportType reportType;
  final DateTime? fromDate;
  final DateTime? toDate;
  final String? payGroupId;
  final List<PayGroup> payGroups;
  final PayRunStatus? status;
  final ValueChanged<_ReportType> onReportTypeChanged;
  final VoidCallback onPickFrom;
  final VoidCallback onPickTo;
  final VoidCallback? onClearDates;
  final ValueChanged<String?> onPayGroupChanged;
  final ValueChanged<PayRunStatus?> onStatusChanged;

  const _FilterBar({
    required this.reportType,
    required this.fromDate,
    required this.toDate,
    required this.payGroupId,
    required this.payGroups,
    required this.status,
    required this.onReportTypeChanged,
    required this.onPickFrom,
    required this.onPickTo,
    required this.onClearDates,
    required this.onPayGroupChanged,
    required this.onStatusChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Container(
      color: cs.surface,
      child: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md, vertical: AppSpacing.sm),
            child: Row(
              children: [
                // ── Report type ──────────────────────────────────────────
                _FilterDropdown<_ReportType>(
                  icon: reportType.icon,
                  iconColor: reportType.color,
                  label: reportType.label,
                  items: _ReportType.values
                      .map((t) => PopupMenuItem(
                            value: t,
                            child: Row(children: [
                              Icon(t.icon, size: 16, color: t.color),
                              const SizedBox(width: 8),
                              Text(t.label),
                            ]),
                          ))
                      .toList(),
                  onSelected: onReportTypeChanged,
                  isActive: true,
                ),
                const SizedBox(width: AppSpacing.sm),

                // ── From date (app pattern: showDatePicker) ──────────────
                _DateBtn(
                  label: fromDate != null
                      ? 'From  ${_fmtDate(fromDate!)}'
                      : 'From date',
                  icon: Icons.calendar_today_outlined,
                  active: fromDate != null,
                  onTap: onPickFrom,
                ),
                const SizedBox(width: AppSpacing.xs),

                // ── To date ──────────────────────────────────────────────
                _DateBtn(
                  label: toDate != null
                      ? 'To  ${_fmtDate(toDate!)}'
                      : 'To date',
                  icon: Icons.event_outlined,
                  active: toDate != null,
                  onTap: onPickTo,
                ),

                // ── Clear dates ──────────────────────────────────────────
                if (onClearDates != null) ...[
                  const SizedBox(width: AppSpacing.xs),
                  IconButton(
                    icon: const Icon(Icons.clear_rounded, size: 18),
                    tooltip: 'Clear dates',
                    onPressed: onClearDates,
                    color: AppColors.error,
                  ),
                ],
                const SizedBox(width: AppSpacing.sm),

                // ── Pay group ────────────────────────────────────────────
                _FilterDropdown<String?>(
                  icon: Icons.group_work_outlined,
                  iconColor: const Color(0xFF6A1B9A),
                  label: payGroupId == null
                      ? 'All Groups'
                      : (payGroups
                              .where((g) => g.id == payGroupId)
                              .firstOrNull
                              ?.name ??
                          'Group'),
                  items: [
                    PopupMenuItem(
                        value: null,
                        child: Row(children: [
                          const Icon(Icons.group_work_outlined,
                              size: 16, color: Color(0xFF6A1B9A)),
                          const SizedBox(width: 8),
                          const Text('All Groups'),
                        ])),
                    ...payGroups.map((g) => PopupMenuItem(
                        value: g.id,
                        child: Row(children: [
                          const Icon(Icons.group_outlined,
                              size: 16, color: Color(0xFF6A1B9A)),
                          const SizedBox(width: 8),
                          Text(g.name),
                        ]))),
                  ],
                  onSelected: onPayGroupChanged,
                  isActive: payGroupId != null,
                ),
                const SizedBox(width: AppSpacing.sm),

                // ── Status ───────────────────────────────────────────────
                _FilterDropdown<PayRunStatus?>(
                  icon: Icons.flag_rounded,
                  iconColor: status != null
                      ? PayrollTokens.payRunStatusColor(status!)
                      : const Color(0xFFF57F17),
                  label: status == null
                      ? 'All Statuses'
                      : PayrollTokens.payRunStatusLabel(status!),
                  items: [
                    PopupMenuItem(
                        value: null,
                        child: Row(children: [
                          const Icon(Icons.flag_outlined,
                              size: 16, color: Color(0xFFF57F17)),
                          const SizedBox(width: 8),
                          const Text('All Statuses'),
                        ])),
                    ...PayRunStatus.values.map((s) {
                      final c = PayrollTokens.payRunStatusColor(s);
                      return PopupMenuItem(
                          value: s,
                          child: Row(children: [
                            Icon(Icons.flag_rounded, size: 16, color: c),
                            const SizedBox(width: 8),
                            Text(PayrollTokens.payRunStatusLabel(s)),
                          ]));
                    }),
                  ],
                  onSelected: onStatusChanged,
                  isActive: status != null,
                ),
              ],
            ),
          ),
          Divider(height: 1, color: cs.outlineVariant),
        ],
      ),
    );
  }
}

// ─── Date button — same style as attendance_log_screen._DateBtn ───────────────

class _DateBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool active;
  final VoidCallback onTap;

  const _DateBtn({
    required this.label,
    required this.icon,
    required this.active,
    required this.onTap,
  });

  // Calendar icon is always teal — active darkens it, inactive is softer
  static const _calendarColor = Color(0xFF00695C);

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final iconCol =
        active ? _calendarColor : _calendarColor.withValues(alpha: 0.7);
    final textColor = active ? _calendarColor : cs.onSurface;
    final borderColor =
        active ? _calendarColor : cs.outline;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.sm, vertical: 8),
        decoration: BoxDecoration(
          color: active
              ? _calendarColor.withValues(alpha: 0.08)
              : _calendarColor.withValues(alpha: 0.04),
          border: Border.all(color: borderColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: iconCol),
            const SizedBox(width: 4),
            Text(label,
                style: TextStyle(
                    fontSize: 12,
                    color: textColor,
                    fontWeight:
                        active ? FontWeight.w600 : FontWeight.normal)),
          ],
        ),
      ),
    );
  }
}

class _FilterDropdown<T> extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final List<PopupMenuEntry<T>> items;
  final ValueChanged<T> onSelected;
  final bool isActive;

  const _FilterDropdown({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.items,
    required this.onSelected,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final activeColor = isActive ? iconColor : iconColor.withValues(alpha: 0.7);
    final borderColor = isActive ? iconColor : cs.outlineVariant;
    final bgColor = isActive
        ? iconColor.withValues(alpha: 0.08)
        : iconColor.withValues(alpha: 0.04);

    return PopupMenuButton<T>(
      onSelected: onSelected,
      itemBuilder: (_) => items,
      offset: const Offset(0, 40),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
              color: borderColor, width: isActive ? 1.5 : 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: activeColor),
            const SizedBox(width: 6),
            Text(label,
                style: tt.labelSmall?.copyWith(
                    color: isActive ? iconColor : cs.onSurface,
                    fontWeight: isActive
                        ? FontWeight.w600
                        : FontWeight.w500)),
            const SizedBox(width: 4),
            Icon(Icons.expand_more_rounded,
                size: 14, color: activeColor),
          ],
        ),
      ),
    );
  }
}

// ─── Report content dispatcher ────────────────────────────────────────────────

class _ReportContent extends StatelessWidget {
  final _ReportType reportType;
  final List<PayRun> filteredRuns;
  final List<PayRun> disbursedRuns;
  final double totalGross;
  final double totalNet;
  final double totalDeductions;
  final double uifTotal;
  final double payeTotal;
  final double voluntaryTotal;
  final List<MapEntry<String, double>> sortedDeductions;
  final PayrollDashboardStats stats;
  final List<LeaveType> leaveTypes;
  final Map<String, int> leaveTakenByType;
  final Map<String, int> leavePendingByType;
  final int totalDaysTaken;
  final int totalDaysPending;
  final List<LeaveRequest> pendingLeave;
  final Map<String, String> leaveTypeMap;

  const _ReportContent({
    required this.reportType,
    required this.filteredRuns,
    required this.disbursedRuns,
    required this.totalGross,
    required this.totalNet,
    required this.totalDeductions,
    required this.uifTotal,
    required this.payeTotal,
    required this.voluntaryTotal,
    required this.sortedDeductions,
    required this.stats,
    required this.leaveTypes,
    required this.leaveTakenByType,
    required this.leavePendingByType,
    required this.totalDaysTaken,
    required this.totalDaysPending,
    required this.pendingLeave,
    required this.leaveTypeMap,
  });

  @override
  Widget build(BuildContext context) {
    return switch (reportType) {
      _ReportType.paySummary => _PaySummaryReport(
          filteredRuns: filteredRuns,
          disbursedRuns: disbursedRuns,
          totalGross: totalGross,
          totalNet: totalNet,
          totalDeductions: totalDeductions,
        ),
      _ReportType.statutory => _StatutoryReport(
          uif: uifTotal,
          paye: payeTotal,
          voluntary: voluntaryTotal,
          sortedDeductions: sortedDeductions,
          disbursedCount: disbursedRuns.length,
        ),
      _ReportType.leave => _LeaveReport(
          leaveTypes: leaveTypes,
          taken: leaveTakenByType,
          pending: leavePendingByType,
          totalTaken: totalDaysTaken,
          totalPending: totalDaysPending,
          pendingRequests: pendingLeave,
          leaveTypeMap: leaveTypeMap,
        ),
      _ReportType.workforce => _WorkforceReport(stats: stats),
      _ReportType.deductions => _DeductionsReport(
          sortedDeductions: sortedDeductions,
          uif: uifTotal,
          paye: payeTotal,
          voluntary: voluntaryTotal,
        ),
    };
  }
}

// ─── Pay summary report ───────────────────────────────────────────────────────

class _PaySummaryReport extends StatelessWidget {
  final List<PayRun> filteredRuns;
  final List<PayRun> disbursedRuns;
  final double totalGross;
  final double totalNet;
  final double totalDeductions;

  const _PaySummaryReport({
    required this.filteredRuns,
    required this.disbursedRuns,
    required this.totalGross,
    required this.totalNet,
    required this.totalDeductions,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _KpiStrip(items: [
          _KpiItem(label: 'Total Runs', value: filteredRuns.length.toString(),
              color: PayrollTokens.navy, icon: Icons.receipt_long_outlined),
          _KpiItem(label: 'Disbursed', value: disbursedRuns.length.toString(),
              color: PayrollTokens.green, icon: Icons.check_circle_outline),
          _KpiItem(label: 'Gross', value: _compact(totalGross),
              color: PayrollTokens.teal, icon: Icons.payments_outlined),
          _KpiItem(label: 'Net Pay', value: _compact(totalNet),
              color: AppColors.success,
              icon: Icons.account_balance_wallet_outlined),
        ]),
        const SizedBox(height: AppSpacing.md),
        _SectionCard(
          title: 'Payroll Breakdown',
          subtitle: 'Disbursed runs only',
          child: totalGross == 0
              ? const _EmptyState(
                  message: 'No disbursed pay runs in selected range')
              : Column(children: [
                  _HorizBar(label: 'Gross Pay', value: totalGross,
                      maxValue: totalGross, color: PayrollTokens.navy,
                      icon: Icons.payments_outlined),
                  const SizedBox(height: AppSpacing.md),
                  _HorizBar(label: 'Net Pay', value: totalNet,
                      maxValue: totalGross, color: PayrollTokens.teal,
                      icon: Icons.account_balance_wallet_outlined),
                  const SizedBox(height: AppSpacing.md),
                  _HorizBar(label: 'Deductions', value: totalDeductions,
                      maxValue: totalGross, color: AppColors.warning,
                      icon: Icons.money_off_outlined),
                ]),
        ),
        const SizedBox(height: AppSpacing.md),
        _SectionCard(
          title: 'Pay Run History',
          subtitle:
              '${filteredRuns.length} record${filteredRuns.length == 1 ? '' : 's'}',
          child: _PayRunTable(runs: filteredRuns),
        ),
      ],
    );
  }
}

// ─── Statutory deductions report ──────────────────────────────────────────────

class _StatutoryReport extends StatelessWidget {
  final double uif;
  final double paye;
  final double voluntary;
  final List<MapEntry<String, double>> sortedDeductions;
  final int disbursedCount;

  const _StatutoryReport({
    required this.uif,
    required this.paye,
    required this.voluntary,
    required this.sortedDeductions,
    required this.disbursedCount,
  });

  @override
  Widget build(BuildContext context) {
    final total = uif + paye + voluntary;
    final maxVal = math.max(math.max(uif, paye), voluntary);
    return Column(
      children: [
        _KpiStrip(items: [
          _KpiItem(label: 'UIF (EE)', value: _compact(uif),
              color: PayrollTokens.sky, icon: Icons.shield_outlined),
          _KpiItem(label: 'PAYE', value: _compact(paye),
              color: PayrollTokens.navy, icon: Icons.account_balance_outlined),
          _KpiItem(label: 'Voluntary', value: _compact(voluntary),
              color: AppColors.secondary, icon: Icons.list_alt_outlined),
          _KpiItem(label: 'Total', value: _compact(total),
              color: PayrollTokens.rose, icon: Icons.calculate_outlined),
        ]),
        const SizedBox(height: AppSpacing.md),
        _SectionCard(
          title: 'Statutory Breakdown',
          subtitle: '$disbursedCount disbursed runs',
          child: total == 0
              ? const _EmptyState(
                  message: 'No statutory deductions in selected range')
              : Column(children: [
                  _HorizBar(label: 'UIF (Employee)', value: uif,
                      maxValue: maxVal, color: PayrollTokens.sky,
                      icon: Icons.shield_outlined),
                  const SizedBox(height: AppSpacing.md),
                  _HorizBar(label: 'PAYE Tax', value: paye,
                      maxValue: maxVal, color: PayrollTokens.navy,
                      icon: Icons.account_balance_outlined),
                  const SizedBox(height: AppSpacing.md),
                  _HorizBar(label: 'Voluntary', value: voluntary,
                      maxValue: maxVal, color: AppColors.secondary,
                      icon: Icons.list_alt_outlined),
                ]),
        ),
        if (sortedDeductions.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          _SectionCard(
            title: 'All Deduction Lines',
            subtitle: '${sortedDeductions.length} unique codes',
            child: Column(
              children: sortedDeductions.take(10).map((e) => Padding(
                    padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                    child: _HorizBar(
                        label: e.key, value: e.value,
                        maxValue: sortedDeductions.first.value,
                        color: PayrollTokens.navy,
                        icon: Icons.remove_outlined),
                  )).toList(),
            ),
          ),
        ],
      ],
    );
  }
}

// ─── Leave analysis report ────────────────────────────────────────────────────

class _LeaveReport extends StatelessWidget {
  final List<LeaveType> leaveTypes;
  final Map<String, int> taken;
  final Map<String, int> pending;
  final int totalTaken;
  final int totalPending;
  final List<LeaveRequest> pendingRequests;
  final Map<String, String> leaveTypeMap;

  const _LeaveReport({
    required this.leaveTypes,
    required this.taken,
    required this.pending,
    required this.totalTaken,
    required this.totalPending,
    required this.pendingRequests,
    required this.leaveTypeMap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Column(
      children: [
        _KpiStrip(items: [
          _KpiItem(label: 'Days Taken', value: totalTaken.toString(),
              color: AppColors.success, icon: Icons.check_circle_outline),
          _KpiItem(label: 'Days Pending', value: totalPending.toString(),
              color: AppColors.warning, icon: Icons.pending_outlined),
          _KpiItem(label: 'Leave Types', value: leaveTypes.length.toString(),
              color: PayrollTokens.teal, icon: Icons.category_outlined),
          _KpiItem(label: 'Pending Req.', value: pendingRequests.length.toString(),
              color: PayrollTokens.amber,
              icon: Icons.hourglass_empty_outlined),
        ]),
        const SizedBox(height: AppSpacing.md),
        _SectionCard(
          title: 'Leave by Type',
          subtitle: 'Taken vs pending per category',
          child: leaveTypes.isEmpty
              ? const _EmptyState(message: 'No leave types configured')
              : _LeaveSummary(
                  leaveTypes: leaveTypes, taken: taken, pending: pending),
        ),
        if (pendingRequests.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          _SectionCard(
            title: 'Pending Leave Requests',
            subtitle: '${pendingRequests.length} awaiting approval',
            child: Column(
              children: pendingRequests.take(10).map((lr) {
                final typeName =
                    leaveTypeMap[lr.leaveTypeId] ?? lr.leaveTypeId;
                return Column(children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(children: [
                      Container(
                        width: 36, height: 36,
                        decoration: BoxDecoration(
                          color: AppColors.warning.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.person_outlined,
                            size: 16, color: AppColors.warning),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(lr.employeeId,
                                style: tt.bodySmall
                                    ?.copyWith(fontWeight: FontWeight.w600)),
                            Text(
                                '$typeName · ${lr.daysRequested.toStringAsFixed(0)} day${lr.daysRequested == 1 ? '' : 's'}',
                                style: tt.labelSmall?.copyWith(
                                    color: cs.onSurfaceVariant, fontSize: 10)),
                          ],
                        ),
                      ),
                      Text(
                          '${_shortFmt.format(lr.startDate)} – ${_shortFmt.format(lr.endDate)}',
                          style: tt.labelSmall?.copyWith(
                              color: cs.onSurfaceVariant, fontSize: 10)),
                    ]),
                  ),
                  Divider(height: 1, color: cs.outlineVariant),
                ]);
              }).toList(),
            ),
          ),
        ],
      ],
    );
  }
}

// ─── Workforce overview report ────────────────────────────────────────────────

class _WorkforceReport extends StatelessWidget {
  final PayrollDashboardStats stats;
  const _WorkforceReport({required this.stats});

  @override
  Widget build(BuildContext context) {
    final total =
        stats.permanentCount + stats.seasonalCount + stats.casualCount;
    return Column(
      children: [
        _KpiStrip(items: [
          _KpiItem(label: 'Total Active',
              value: stats.totalActiveEmployees.toString(),
              color: AppColors.primary, icon: Icons.people_outlined),
          _KpiItem(label: 'Permanent',
              value: stats.permanentCount.toString(),
              color: PayrollTokens.navy, icon: Icons.badge_outlined),
          _KpiItem(label: 'Seasonal',
              value: stats.seasonalCount.toString(),
              color: PayrollTokens.sky, icon: Icons.calendar_today_outlined),
          _KpiItem(label: 'Casual', value: stats.casualCount.toString(),
              color: const Color(0xFF81D4FA),
              icon: Icons.person_outline_rounded),
        ]),
        const SizedBox(height: AppSpacing.md),
        _SectionCard(
          title: 'Employment Composition',
          subtitle: '$total classified employees',
          child: total == 0
              ? const _EmptyState(message: 'No workforce data')
              : Row(children: [
                  SizedBox(
                    width: 130, height: 130,
                    child: CustomPaint(
                      painter: _DonutPainter(
                        segments: [
                          _DonutSegment(
                              value: stats.permanentCount.toDouble(),
                              color: PayrollTokens.navy),
                          _DonutSegment(
                              value: stats.seasonalCount.toDouble(),
                              color: PayrollTokens.sky),
                          _DonutSegment(
                              value: stats.casualCount.toDouble(),
                              color: const Color(0xFF81D4FA)),
                        ],
                        total: total.toDouble(),
                        centerText: total.toString(),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.lg),
                  Expanded(
                    child: Column(children: [
                      _LegendItem(color: PayrollTokens.navy,
                          label: 'Permanent',
                          count: stats.permanentCount, total: total),
                      const SizedBox(height: AppSpacing.sm),
                      _LegendItem(color: PayrollTokens.sky,
                          label: 'Seasonal',
                          count: stats.seasonalCount, total: total),
                      const SizedBox(height: AppSpacing.sm),
                      _LegendItem(color: const Color(0xFF81D4FA),
                          label: 'Casual',
                          count: stats.casualCount, total: total),
                    ]),
                  ),
                ]),
        ),
        const SizedBox(height: AppSpacing.md),
        _SectionCard(
          title: 'Employment Type Distribution',
          child: total == 0
              ? const _EmptyState(message: 'No data')
              : Column(children: [
                  _HorizBar(label: 'Permanent',
                      value: stats.permanentCount.toDouble(),
                      maxValue: total.toDouble(), color: PayrollTokens.navy,
                      icon: Icons.badge_outlined),
                  const SizedBox(height: AppSpacing.md),
                  _HorizBar(label: 'Seasonal',
                      value: stats.seasonalCount.toDouble(),
                      maxValue: total.toDouble(), color: PayrollTokens.sky,
                      icon: Icons.calendar_today_outlined),
                  const SizedBox(height: AppSpacing.md),
                  _HorizBar(label: 'Casual',
                      value: stats.casualCount.toDouble(),
                      maxValue: total.toDouble(),
                      color: const Color(0xFF81D4FA),
                      icon: Icons.person_outline_rounded),
                ]),
        ),
      ],
    );
  }
}

// ─── Deductions breakdown report ──────────────────────────────────────────────

class _DeductionsReport extends StatelessWidget {
  final List<MapEntry<String, double>> sortedDeductions;
  final double uif;
  final double paye;
  final double voluntary;

  const _DeductionsReport({
    required this.sortedDeductions,
    required this.uif,
    required this.paye,
    required this.voluntary,
  });

  @override
  Widget build(BuildContext context) {
    final grandTotal = sortedDeductions.fold(0.0, (s, e) => s + e.value);
    return Column(
      children: [
        _KpiStrip(items: [
          _KpiItem(label: 'Total Deducted', value: _compact(grandTotal),
              color: PayrollTokens.rose, icon: Icons.remove_circle_outline),
          _KpiItem(label: 'Statutory', value: _compact(uif + paye),
              color: PayrollTokens.navy, icon: Icons.account_balance_outlined),
          _KpiItem(label: 'Voluntary', value: _compact(voluntary),
              color: AppColors.secondary, icon: Icons.list_alt_outlined),
          _KpiItem(label: 'Line Items',
              value: sortedDeductions.length.toString(),
              color: PayrollTokens.teal, icon: Icons.numbers_outlined),
        ]),
        const SizedBox(height: AppSpacing.md),
        _SectionCard(
          title: 'All Deduction Lines',
          subtitle: 'Sorted by value',
          child: sortedDeductions.isEmpty
              ? const _EmptyState(
                  message: 'No deductions in selected range')
              : Column(
                  children: sortedDeductions.map((e) {
                    final isStatutory =
                        e.key.toUpperCase().contains('UIF') ||
                            e.key.toUpperCase().contains('PAYE') ||
                            e.key.toUpperCase().contains('SDL');
                    return Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.md),
                      child: _HorizBar(
                        label: e.key,
                        value: e.value,
                        maxValue: sortedDeductions.first.value,
                        color: isStatutory
                            ? PayrollTokens.navy
                            : AppColors.secondary,
                        icon: isStatutory
                            ? Icons.account_balance_outlined
                            : Icons.remove_outlined,
                      ),
                    );
                  }).toList(),
                ),
        ),
      ],
    );
  }
}

// ─── Shared KPI strip ─────────────────────────────────────────────────────────

class _KpiItem {
  final String label;
  final String value;
  final Color color;
  final IconData icon;
  const _KpiItem(
      {required this.label,
      required this.value,
      required this.color,
      required this.icon});
}

class _KpiStrip extends StatelessWidget {
  final List<_KpiItem> items;
  const _KpiStrip({required this.items});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Row(
      children: items
          .map((item) => Expanded(
                child: Container(
                  margin: EdgeInsets.only(
                      right: item == items.last ? 0 : AppSpacing.xs),
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm, vertical: 10),
                  decoration: BoxDecoration(
                    color: cs.surface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: cs.outlineVariant),
                    boxShadow: [
                      BoxShadow(
                          color: Colors.black.withValues(alpha: 0.03),
                          blurRadius: 4,
                          offset: const Offset(0, 1)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 26, height: 26,
                        decoration: BoxDecoration(
                          color: item.color.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(item.icon, size: 13, color: item.color),
                      ),
                      const SizedBox(height: 6),
                      Text(item.value,
                          style: tt.titleSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: cs.onSurface,
                              fontSize: 13)),
                      Text(item.label,
                          style: tt.labelSmall?.copyWith(
                              color: cs.onSurfaceVariant,
                              fontSize: 9,
                              height: 1.2),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis),
                    ],
                  ),
                ),
              ))
          .toList(),
    );
  }
}

// ─── Section card ─────────────────────────────────────────────────────────────

class _SectionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final Widget child;
  const _SectionCard(
      {required this.title, this.subtitle, required this.child});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Container(
      decoration: BoxDecoration(
        color: cs.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: cs.outlineVariant),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
                AppSpacing.md, AppSpacing.md, AppSpacing.md, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: tt.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w700)),
                if (subtitle != null)
                  Text(subtitle!,
                      style: tt.labelSmall
                          ?.copyWith(color: cs.onSurfaceVariant)),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Divider(height: 1, color: cs.outlineVariant),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: child,
          ),
        ],
      ),
    );
  }
}

// ─── Horizontal progress bar ──────────────────────────────────────────────────

class _HorizBar extends StatelessWidget {
  final String label;
  final double value;
  final double maxValue;
  final Color color;
  final IconData icon;

  const _HorizBar({
    required this.label,
    required this.value,
    required this.maxValue,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final cs = Theme.of(context).colorScheme;
    final fraction =
        maxValue > 0 ? (value / maxValue).clamp(0.0, 1.0) : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Expanded(
              child: Text(label,
                  style: tt.labelSmall?.copyWith(
                      color: cs.onSurfaceVariant,
                      fontWeight: FontWeight.w500),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis)),
          const SizedBox(width: AppSpacing.sm),
          Text(_zarFmt.format(value),
              style: tt.labelSmall?.copyWith(
                  fontWeight: FontWeight.w700, color: cs.onSurface)),
        ]),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: fraction,
            minHeight: 8,
            backgroundColor: color.withValues(alpha: 0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }
}

// ─── Donut chart ──────────────────────────────────────────────────────────────

class _DonutSegment {
  final double value;
  final Color color;
  const _DonutSegment({required this.value, required this.color});
}

class _DonutPainter extends CustomPainter {
  final List<_DonutSegment> segments;
  final double total;
  final String centerText;

  _DonutPainter(
      {required this.segments,
      required this.total,
      required this.centerText});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;
    const strokeWidth = 22.0;
    const gap = 0.04;
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    double start = -math.pi / 2;
    for (final seg in segments) {
      if (seg.value <= 0) continue;
      final sweep = (seg.value / total) * (2 * math.pi) - gap;
      paint.color = seg.color;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
        start,
        sweep.clamp(0.01, 2 * math.pi),
        false,
        paint,
      );
      start += sweep + gap;
    }

    final numPainter = TextPainter(
      text: TextSpan(
          text: centerText,
          style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: Color(0xFF111827))),
      textDirection: ui.TextDirection.ltr,
    )..layout();
    numPainter.paint(
        canvas,
        Offset(center.dx - numPainter.width / 2,
            center.dy - numPainter.height / 2 - 6));

    final lblPainter = TextPainter(
      text: const TextSpan(
          text: 'Total',
          style: TextStyle(fontSize: 10, color: Color(0xFF6B7280))),
      textDirection: ui.TextDirection.ltr,
    )..layout();
    lblPainter.paint(
        canvas,
        Offset(center.dx - lblPainter.width / 2,
            center.dy + numPainter.height / 2 - 4));
  }

  @override
  bool shouldRepaint(_DonutPainter old) =>
      old.total != total || old.centerText != centerText;
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;
  final int count;
  final int total;
  const _LegendItem(
      {required this.color,
      required this.label,
      required this.count,
      required this.total});

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;
    final pct = total > 0 ? (count / total * 100).round() : 0;
    return Row(children: [
      Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
              color: color, borderRadius: BorderRadius.circular(2))),
      const SizedBox(width: AppSpacing.sm),
      Expanded(child: Text(label, style: tt.bodySmall)),
      Text('$count',
          style: tt.bodySmall?.copyWith(fontWeight: FontWeight.w700)),
      const SizedBox(width: AppSpacing.xs),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
            color: color.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(4)),
        child: Text('$pct%',
            style: tt.labelSmall?.copyWith(
                color: color, fontWeight: FontWeight.w600, fontSize: 10)),
      ),
    ]);
  }
}

// ─── Pay run history table ────────────────────────────────────────────────────

class _PayRunTable extends StatelessWidget {
  final List<PayRun> runs;
  const _PayRunTable({required this.runs});

  String _shortStatus(PayRunStatus s) => switch (s) {
        PayRunStatus.draft => 'Draft',
        PayRunStatus.calculated => 'Calc',
        PayRunStatus.pendingApproval => 'Pending',
        PayRunStatus.approved => 'Approved',
        PayRunStatus.disbursed => 'Disbursed',
        PayRunStatus.cancelled => 'Cancelled',
      };

  @override
  Widget build(BuildContext context) {
    if (runs.isEmpty) {
      return const _EmptyState(message: 'No pay runs match current filters');
    }
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final hdr = tt.labelSmall?.copyWith(
        fontWeight: FontWeight.w600,
        color: cs.onSurfaceVariant,
        fontSize: 10);
    return Column(children: [
      Padding(
        padding: const EdgeInsets.only(bottom: AppSpacing.sm),
        child: Row(children: [
          Expanded(flex: 3, child: Text('Period', style: hdr)),
          Expanded(
              flex: 2,
              child: Text('Gross', style: hdr, textAlign: TextAlign.end)),
          Expanded(
              flex: 2,
              child: Text('Net', style: hdr, textAlign: TextAlign.end)),
          Expanded(
              flex: 2,
              child:
                  Text('Status', style: hdr, textAlign: TextAlign.end)),
        ]),
      ),
      Divider(height: 1, color: cs.outlineVariant),
      ...runs.map((r) {
        final statusColor = PayrollTokens.payRunStatusColor(r.status);
        final period =
            '${_shortFmt.format(r.periodStart)}–${_shortFmt.format(r.periodEnd)}';
        return Column(children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 10),
            child: Row(children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(period,
                        style: tt.bodySmall
                            ?.copyWith(fontWeight: FontWeight.w600)),
                    Text(DateFormat('MMM y').format(r.payDate),
                        style: tt.labelSmall?.copyWith(
                            color: cs.onSurfaceVariant, fontSize: 10)),
                  ],
                ),
              ),
              Expanded(
                  flex: 2,
                  child: Text(_zarFmt.format(r.totalGross),
                      style: tt.bodySmall,
                      textAlign: TextAlign.end)),
              Expanded(
                flex: 2,
                child: Text(_zarFmt.format(r.totalNet),
                    style: tt.bodySmall?.copyWith(
                        color: AppColors.success,
                        fontWeight: FontWeight.w600),
                    textAlign: TextAlign.end),
              ),
              Expanded(
                flex: 2,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8)),
                    child: Text(_shortStatus(r.status),
                        style: tt.labelSmall?.copyWith(
                            color: statusColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 10)),
                  ),
                ),
              ),
            ]),
          ),
          Divider(height: 1, color: cs.outlineVariant),
        ]);
      }),
    ]);
  }
}

// ─── Leave summary bars ───────────────────────────────────────────────────────

class _LeaveSummary extends StatelessWidget {
  final List<LeaveType> leaveTypes;
  final Map<String, int> taken;
  final Map<String, int> pending;
  const _LeaveSummary(
      {required this.leaveTypes,
      required this.taken,
      required this.pending});

  @override
  Widget build(BuildContext context) {
    final maxDays = leaveTypes.fold<int>(0, (m, lt) {
      final t = (taken[lt.name] ?? 0) + (pending[lt.name] ?? 0);
      return t > m ? t : m;
    });
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Column(
      children: leaveTypes.map((lt) {
        final t = taken[lt.name] ?? 0;
        final p = pending[lt.name] ?? 0;
        final max = maxDays > 0 ? maxDays : 1;
        return Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(children: [
                Expanded(
                    child: Text(lt.name,
                        style: tt.labelMedium
                            ?.copyWith(fontWeight: FontWeight.w600))),
                _MiniPill(label: '$t taken', color: AppColors.success),
                const SizedBox(width: 4),
                _MiniPill(label: '$p pending', color: AppColors.warning),
              ]),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Stack(children: [
                  Container(height: 7, color: cs.surfaceContainerHigh),
                  FractionallySizedBox(
                    widthFactor: (t / max).clamp(0.0, 1.0),
                    child: Container(
                        height: 7,
                        color: AppColors.success.withValues(alpha: 0.75)),
                  ),
                ]),
              ),
              if (p > 0) ...[
                const SizedBox(height: 2),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: Stack(children: [
                    Container(height: 4, color: cs.surfaceContainerHigh),
                    FractionallySizedBox(
                      widthFactor: (p / max).clamp(0.0, 1.0),
                      child: Container(
                          height: 4,
                          color: AppColors.warning.withValues(alpha: 0.65)),
                    ),
                  ]),
                ),
              ],
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _MiniPill extends StatelessWidget {
  final String label;
  final Color color;
  const _MiniPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8)),
      child: Text(label,
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600, color: color, fontSize: 10)),
    );
  }
}

// ─── Empty state ──────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final String message;
  const _EmptyState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
      child: Center(
        child: Column(children: [
          Icon(Icons.inbox_outlined,
              size: 32,
              color: Theme.of(context)
                  .colorScheme
                  .onSurfaceVariant
                  .withValues(alpha: 0.4)),
          const SizedBox(height: AppSpacing.sm),
          Text(message,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant)),
        ]),
      ),
    );
  }
}

// ─── PDF export ───────────────────────────────────────────────────────────────

Future<Uint8List> _buildReportPdf({
  required _ReportType reportType,
  required EmployerConfig employer,
  required PayrollDashboardStats stats,
  required List<PayRun> disbursedRuns,
  required double totalGross,
  required double totalNet,
  required double totalDeductions,
  required double uifTotal,
  required double payeTotal,
  required double voluntaryTotal,
  required List<LeaveType> leaveTypes,
  required Map<String, int> leaveTakenByType,
  required Map<String, int> leavePendingByType,
  required DateTimeRange? range,
}) async {
  final doc =
      pw.Document(title: '${reportType.label} Report', author: employer.name);
  final navy = PdfColor.fromHex('1E3A5F');
  final teal = PdfColor.fromHex('00695C');
  final green = PdfColor.fromHex('2E7D32');
  final grey = PdfColor.fromHex('757575');
  final amber = PdfColor.fromHex('F57F17');
  final cur =
      NumberFormat.currency(locale: 'en_ZA', symbol: 'R ', decimalDigits: 2);
  final dateFmt = DateFormat('d MMMM y');
  final shortFmt = DateFormat('d MMM y');
  final rangeLabel = range != null
      ? '${dateFmt.format(range.start)} – ${dateFmt.format(range.end)}'
      : 'All Time';

  String statusLabel(PayRunStatus s) => switch (s) {
        PayRunStatus.draft => 'Draft',
        PayRunStatus.calculated => 'Calculated',
        PayRunStatus.pendingApproval => 'Pending',
        PayRunStatus.approved => 'Approved',
        PayRunStatus.disbursed => 'Disbursed',
        PayRunStatus.cancelled => 'Cancelled',
      };

  doc.addPage(pw.MultiPage(
    pageFormat: PdfPageFormat.a4,
    margin: const pw.EdgeInsets.symmetric(horizontal: 36, vertical: 32),
    header: (_) => pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(employer.name,
                style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                    color: navy)),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(reportType.label.toUpperCase(),
                    style: pw.TextStyle(
                        fontSize: 10,
                        fontWeight: pw.FontWeight.bold,
                        color: grey)),
                pw.Text(rangeLabel,
                    style: pw.TextStyle(fontSize: 8, color: grey)),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 2),
        pw.Text(employer.statutoryLine,
            style: pw.TextStyle(fontSize: 8, color: grey)),
        pw.SizedBox(height: 2),
        pw.Text('Generated: ${dateFmt.format(DateTime.now())}',
            style: pw.TextStyle(fontSize: 9, color: grey)),
        pw.Divider(color: navy, thickness: 1.5),
        pw.SizedBox(height: 4),
      ],
    ),
    build: (_) => [
      if (reportType == _ReportType.paySummary ||
          reportType == _ReportType.deductions) ...[
        _pdfSectionHeader('PAYROLL TOTALS (DISBURSED RUNS)', navy),
        pw.SizedBox(height: 6),
        pw.Row(children: [
          _pdfStatBox('Total Gross', cur.format(totalGross), green),
          pw.SizedBox(width: 8),
          _pdfStatBox('Total Net', cur.format(totalNet), teal),
          pw.SizedBox(width: 8),
          _pdfStatBox('Total Deductions', cur.format(totalDeductions), amber),
        ]),
        pw.SizedBox(height: 14),
        _pdfSectionHeader('PAY RUN HISTORY', navy),
        pw.SizedBox(height: 6),
        if (disbursedRuns.isEmpty)
          pw.Text('No disbursed pay runs in the selected period.',
              style: pw.TextStyle(color: grey, fontSize: 9))
        else
          pw.TableHelper.fromTextArray(
            headers: [
              'Period', 'Pay Date', 'Gross', 'Net', 'Deductions', 'Status'
            ],
            headerStyle: pw.TextStyle(
                fontWeight: pw.FontWeight.bold,
                color: PdfColors.white,
                fontSize: 8),
            headerDecoration: pw.BoxDecoration(color: navy),
            cellStyle: const pw.TextStyle(fontSize: 8),
            cellAlignments: {
              0: pw.Alignment.centerLeft,
              1: pw.Alignment.center,
              2: pw.Alignment.centerRight,
              3: pw.Alignment.centerRight,
              4: pw.Alignment.centerRight,
              5: pw.Alignment.center,
            },
            data: disbursedRuns.take(20).map((r) => [
                  '${shortFmt.format(r.periodStart)} – ${shortFmt.format(r.periodEnd)}',
                  shortFmt.format(r.payDate),
                  cur.format(r.totalGross),
                  cur.format(r.totalNet),
                  cur.format(r.totalDeductions),
                  statusLabel(r.status),
                ]).toList(),
          ),
        pw.SizedBox(height: 14),
      ],
      if (reportType == _ReportType.statutory ||
          reportType == _ReportType.deductions) ...[
        _pdfSectionHeader('STATUTORY DEDUCTIONS', navy),
        pw.SizedBox(height: 6),
        pw.Row(children: [
          _pdfStatBox('UIF (EE)', cur.format(uifTotal), grey),
          pw.SizedBox(width: 8),
          _pdfStatBox('PAYE', cur.format(payeTotal), navy),
          pw.SizedBox(width: 8),
          _pdfStatBox('Voluntary', cur.format(voluntaryTotal), teal),
        ]),
        pw.SizedBox(height: 14),
      ],
      if (reportType == _ReportType.workforce ||
          reportType == _ReportType.paySummary) ...[
        _pdfSectionHeader('WORKFORCE SUMMARY', navy),
        pw.SizedBox(height: 6),
        pw.Row(children: [
          _pdfStatBox('Active', stats.totalActiveEmployees.toString(), green),
          pw.SizedBox(width: 8),
          _pdfStatBox('Permanent', stats.permanentCount.toString(), navy),
          pw.SizedBox(width: 8),
          _pdfStatBox('Seasonal', stats.seasonalCount.toString(), teal),
          pw.SizedBox(width: 8),
          _pdfStatBox('Casual', stats.casualCount.toString(), grey),
        ]),
        pw.SizedBox(height: 14),
      ],
      if (reportType == _ReportType.leave && leaveTypes.isNotEmpty) ...[
        _pdfSectionHeader('LEAVE SUMMARY', teal),
        pw.SizedBox(height: 6),
        pw.TableHelper.fromTextArray(
          headers: ['Leave Type', 'Days Taken', 'Days Pending'],
          headerStyle: pw.TextStyle(
              fontWeight: pw.FontWeight.bold,
              color: PdfColors.white,
              fontSize: 9),
          headerDecoration: pw.BoxDecoration(color: teal),
          cellStyle: const pw.TextStyle(fontSize: 9),
          cellAlignments: {
            0: pw.Alignment.centerLeft,
            1: pw.Alignment.center,
            2: pw.Alignment.center,
          },
          data: leaveTypes
              .map((lt) => [
                    lt.name,
                    (leaveTakenByType[lt.name] ?? 0).toString(),
                    (leavePendingByType[lt.name] ?? 0).toString(),
                  ])
              .toList(),
        ),
        pw.SizedBox(height: 14),
      ],
      pw.Divider(color: grey),
      pw.Text(
          'Generated by ${employer.name} Management System. '
          'Period: $rangeLabel. For official use only.',
          style: pw.TextStyle(fontSize: 7, color: grey)),
    ],
  ));

  return Uint8List.fromList(await doc.save());
}

pw.Widget _pdfSectionHeader(String title, PdfColor color) => pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(title,
            style: pw.TextStyle(
                fontSize: 9,
                fontWeight: pw.FontWeight.bold,
                color: color)),
        pw.Divider(color: color, thickness: 0.5),
      ],
    );

pw.Widget _pdfStatBox(String label, String value, PdfColor color) =>
    pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.all(8),
        decoration: pw.BoxDecoration(
          border: pw.Border(left: pw.BorderSide(color: color, width: 3)),
          color: PdfColors.grey100,
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(value,
                style: pw.TextStyle(
                    fontSize: 11,
                    fontWeight: pw.FontWeight.bold,
                    color: color)),
            pw.SizedBox(height: 2),
            pw.Text(label,
                style: const pw.TextStyle(
                    fontSize: 7, color: PdfColors.grey600)),
          ],
        ),
      ),
    );

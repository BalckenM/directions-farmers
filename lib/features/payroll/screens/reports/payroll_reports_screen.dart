import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/farm_scaffold.dart';
import '../../../../shared/widgets/farm_app_bar.dart';
import '../../../../shared/widgets/stat_card.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../models/leave_request.dart';
import '../../models/leave_type.dart';
import '../../models/pay_run.dart';
import '../../providers/payroll_providers.dart';
import '../../theme/payroll_tokens.dart';
import '../../models/employer_config.dart';

final _zarFmt  = NumberFormat.currency(locale: 'en_ZA', symbol: 'R ', decimalDigits: 0);
final _shortFmt = DateFormat('d MMM');

class PayrollReportsScreen extends ConsumerWidget {
  const PayrollReportsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allPayRuns    = ref.watch(allPayRunsProvider);
    final allPayslips   = ref.watch(payslipsProvider(const PayslipFilter()));
    final leaveRequests = ref.watch(leaveRequestsProvider(const LeaveRequestFilter()));
    final leaveTypes    = ref.watch(leaveTypesProvider);
    final stats         = ref.watch(payrollDashboardStatsProvider);
    final employer      = ref.watch(employerConfigProvider);
    final tt            = Theme.of(context).textTheme;
    final cs            = Theme.of(context).colorScheme;

    final disbursedRuns = allPayRuns
        .where((r) => r.status == PayRunStatus.disbursed)
        .toList()
      ..sort((a, b) => b.payDate.compareTo(a.payDate));

    double totalGross = 0, totalNet = 0, totalDeductions = 0;
    for (final r in disbursedRuns) {
      totalGross      += r.totalGross;
      totalNet        += r.totalNet;
      totalDeductions += r.totalDeductions;
    }

    double uifTotal = 0, payeTotal = 0, voluntaryTotal = 0;
    for (final ps in allPayslips) {
      for (final d in ps.deductions) {
        if (d.code == 'UIF_EE')  uifTotal       += d.amount;
        if (d.code == 'PAYE')    payeTotal       += d.amount;
        if (!d.isStatutory)      voluntaryTotal  += d.amount;
      }
    }

    final leaveTypeMap = {for (final lt in leaveTypes) lt.id: lt.name};
    final Map<String, int> leaveTakenByType   = {};
    final Map<String, int> leavePendingByType = {};
    for (final lr in leaveRequests) {
      final name = leaveTypeMap[lr.leaveTypeId] ?? lr.leaveTypeId;
      if (lr.status == LeaveStatus.approved) {
        leaveTakenByType[name] = (leaveTakenByType[name] ?? 0) + lr.daysRequested.round();
      }
      if (lr.status == LeaveStatus.pending) {
        leavePendingByType[name] = (leavePendingByType[name] ?? 0) + lr.daysRequested.round();
      }
    }

    Future<void> doExport() async {
      try {
        await Printing.layoutPdf(
          name: 'Payroll_Report_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf',
          onLayout: (_) => _buildReportPdf(
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
          ),
        );
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('Export failed: $e'),
            backgroundColor: PayrollTokens.rose,
          ));
        }
      }
    }

    return FarmScaffold(
      appBar: FarmAppBar(
        title: 'Payroll Reports',
        actions: [
          IconButton(
            icon: const Icon(Icons.download_outlined),
            tooltip: 'Export Report',
            onPressed: doExport,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          // ── Workforce summary ─────────────────────────────────────────────────
          const SectionHeader(title: 'Workforce Summary'),
          const SizedBox(height: AppSpacing.sm),
          // 2×2 grid avoids cramped 4-in-a-row on narrow phones
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: AppSpacing.sm,
            mainAxisSpacing: AppSpacing.sm,
            childAspectRatio: 2.4,
            children: [
              StatCard(
                label: 'Active Employees',
                value: stats.totalActiveEmployees.toString(),
                icon: Icons.group_outlined,
                accentColor: PayrollTokens.green,
              ),
              StatCard(
                label: 'Permanent',
                value: stats.permanentCount.toString(),
                icon: Icons.badge_outlined,
                accentColor: PayrollTokens.navy,
              ),
              StatCard(
                label: 'Seasonal',
                value: stats.seasonalCount.toString(),
                icon: Icons.calendar_today_outlined,
                accentColor: PayrollTokens.sky,
              ),
              StatCard(
                label: 'Casual',
                value: stats.casualCount.toString(),
                icon: Icons.person_outline_rounded,
                accentColor: PayrollTokens.teal,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // ── Payroll totals ────────────────────────────────────────────────────
          const SectionHeader(title: 'Payroll Totals (All Disbursed Runs)'),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(child: StatCard(
                label: 'Total Gross',
                value: _zarFmt.format(totalGross),
                icon: Icons.payments_outlined,
                accentColor: PayrollTokens.green,
              )),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: StatCard(
                label: 'Total Net',
                value: _zarFmt.format(totalNet),
                icon: Icons.account_balance_wallet_outlined,
                accentColor: PayrollTokens.teal,
              )),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: StatCard(
                label: 'Deductions',
                value: _zarFmt.format(totalDeductions),
                icon: Icons.money_off_outlined,
                accentColor: PayrollTokens.amber,
              )),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // ── Statutory deductions ──────────────────────────────────────────────
          const SectionHeader(title: 'Statutory Deductions Breakdown'),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(child: StatCard(
                label: 'UIF (EE)',
                value: _zarFmt.format(uifTotal),
                icon: Icons.shield_outlined,
                accentColor: PayrollTokens.indigo,
              )),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: StatCard(
                label: 'PAYE',
                value: _zarFmt.format(payeTotal),
                icon: Icons.account_balance_outlined,
                accentColor: PayrollTokens.navy,
              )),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: StatCard(
                label: 'Voluntary',
                value: _zarFmt.format(voluntaryTotal),
                icon: Icons.list_alt_outlined,
                accentColor: PayrollTokens.purple,
              )),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // ── Pay run history ───────────────────────────────────────────────────
          const SectionHeader(title: 'Pay Run History'),
          const SizedBox(height: AppSpacing.sm),
          Card(
            elevation: 1,
            child: allPayRuns.isEmpty
                ? const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(child: Text('No pay runs recorded.')),
                  )
                : Column(
                    children: [
                      _tableHeader(context),
                      const Divider(height: 1),
                      ...allPayRuns
                          .sorted((a, b) => b.payDate.compareTo(a.payDate))
                          .map((r) => _payRunRow(context, r)),
                    ],
                  ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // ── Leave summary ─────────────────────────────────────────────────────
          const SectionHeader(title: 'Leave Summary'),
          const SizedBox(height: AppSpacing.sm),
          Card(
            elevation: 1,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: leaveTypes.isEmpty
                  ? Text('No leave types configured.',
                      style: tt.bodySmall?.copyWith(color: cs.onSurfaceVariant))
                  : Column(
                      children: leaveTypes
                          .map((lt) => _leaveRow(
                                context,
                                lt.name,
                                leaveTakenByType[lt.name] ?? 0,
                                leavePendingByType[lt.name] ?? 0,
                              ))
                          .toList(),
                    ),
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
        ],
      ),
    );
  }

  Widget _tableHeader(BuildContext context) {
    final tt    = Theme.of(context).textTheme;
    final cs    = Theme.of(context).colorScheme;
    final style = tt.labelSmall?.copyWith(
        fontWeight: FontWeight.w700, color: cs.onSurfaceVariant);
    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      child: Row(
        children: [
          Expanded(flex: 3, child: Text('Period', style: style)),
          Expanded(flex: 2, child: Text('Gross', style: style, textAlign: TextAlign.end)),
          Expanded(flex: 2, child: Text('Net', style: style, textAlign: TextAlign.end)),
          Expanded(flex: 2, child: Text('Status', style: style, textAlign: TextAlign.end)),
        ],
      ),
    );
  }

  Widget _payRunRow(BuildContext context, PayRun r) {
    final tt     = Theme.of(context).textTheme;
    final period = '${_shortFmt.format(r.periodStart)}\u2013${_shortFmt.format(r.periodEnd)}';

    final statusColor = PayrollTokens.payRunStatusColor(r.status);
    final statusLabel = PayrollTokens.payRunStatusLabel(r.status);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md, vertical: AppSpacing.sm),
          child: Row(
            children: [
              Expanded(
                  flex: 3,
                  child: Text(period,
                      style: tt.bodySmall?.copyWith(fontWeight: FontWeight.w500))),
              Expanded(
                  flex: 2,
                  child: Text(_zarFmt.format(r.totalGross),
                      style: tt.bodySmall, textAlign: TextAlign.end)),
              Expanded(
                  flex: 2,
                  child: Text(_zarFmt.format(r.totalNet),
                      style: tt.bodySmall?.copyWith(
                          color: PayrollTokens.green,
                          fontWeight: FontWeight.w600),
                      textAlign: TextAlign.end)),
              Expanded(
                flex: 2,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm, vertical: 3),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      statusLabel,
                      style: tt.labelSmall?.copyWith(
                          fontWeight: FontWeight.w600, color: statusColor),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }

  Widget _leaveRow(BuildContext context, String type, int taken, int pending) {
    final tt = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        children: [
          Expanded(
              child: Text(type,
                  style: tt.bodyMedium?.copyWith(fontWeight: FontWeight.w500))),
          _badge(context, '$taken taken',   PayrollTokens.teal),
          const SizedBox(width: AppSpacing.sm),
          _badge(context, '$pending pending', PayrollTokens.amber),
        ],
      ),
    );
  }

  Widget _badge(BuildContext context, String label, Color color) {
    final tt = Theme.of(context).textTheme;
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.sm, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label,
          style: tt.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: color)),
    );
  }
}

extension _ListSort<T> on List<T> {
  List<T> sorted(int Function(T, T) compare) => [...this]..sort(compare);
}

// ─── PDF report generator ─────────────────────────────────────────────────────

Future<Uint8List> _buildReportPdf({
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
}) async {
  final doc    = pw.Document(title: 'Payroll Report', author: employer.name);
  final navy   = PdfColor.fromHex('1E3A5F');
  final teal   = PdfColor.fromHex('00695C');
  final green  = PdfColor.fromHex('2E7D32');
  final grey   = PdfColor.fromHex('757575');
  final amber  = PdfColor.fromHex('F57F17');
  final cur    = NumberFormat.currency(locale: 'en_ZA', symbol: 'R ', decimalDigits: 2);
  final dateFmt = DateFormat('d MMMM y');
  final shortFmt = DateFormat('d MMM y');

  String statusLabel(PayRunStatus s) => switch (s) {
    PayRunStatus.draft           => 'Draft',
    PayRunStatus.calculated      => 'Calculated',
    PayRunStatus.pendingApproval => 'Pending',
    PayRunStatus.approved        => 'Approved',
    PayRunStatus.disbursed       => 'Disbursed',
    PayRunStatus.cancelled       => 'Cancelled',
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
                    fontSize: 18, fontWeight: pw.FontWeight.bold, color: navy)),
            pw.Text('PAYROLL REPORT',
                style: pw.TextStyle(
                    fontSize: 11, fontWeight: pw.FontWeight.bold, color: grey)),
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

      _pdfSectionHeader('PAYROLL TOTALS (DISBURSED RUNS)', navy),
      pw.SizedBox(height: 6),
      pw.Row(children: [
        _pdfStatBox('Total Gross',       cur.format(totalGross),       green),
        pw.SizedBox(width: 8),
        _pdfStatBox('Total Net',         cur.format(totalNet),         teal),
        pw.SizedBox(width: 8),
        _pdfStatBox('Total Deductions',  cur.format(totalDeductions),  amber),
      ]),
      pw.SizedBox(height: 14),

      _pdfSectionHeader('STATUTORY DEDUCTIONS', navy),
      pw.SizedBox(height: 6),
      pw.Row(children: [
        _pdfStatBox('UIF (EE)',  cur.format(uifTotal),       grey),
        pw.SizedBox(width: 8),
        _pdfStatBox('PAYE',     cur.format(payeTotal),      navy),
        pw.SizedBox(width: 8),
        _pdfStatBox('Voluntary',cur.format(voluntaryTotal), teal),
      ]),
      pw.SizedBox(height: 14),

      _pdfSectionHeader(
          'PAY RUN HISTORY '
          '(${disbursedRuns.length} disbursed run${disbursedRuns.length == 1 ? '' : 's'})',
          navy),
      pw.SizedBox(height: 6),
      if (disbursedRuns.isEmpty)
        pw.Text('No disbursed pay runs recorded.',
            style: pw.TextStyle(color: grey, fontSize: 9))
      else
        pw.TableHelper.fromTextArray(
          headers: ['Period', 'Pay Date', 'Gross', 'Net', 'Deductions', 'Status'],
          headerStyle: pw.TextStyle(
              fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 8),
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
            '${shortFmt.format(r.periodStart)} \u2013 ${shortFmt.format(r.periodEnd)}',
            shortFmt.format(r.payDate),
            cur.format(r.totalGross),
            cur.format(r.totalNet),
            cur.format(r.totalDeductions),
            statusLabel(r.status),
          ]).toList(),
        ),
      pw.SizedBox(height: 14),

      if (leaveTypes.isNotEmpty) ...[
        _pdfSectionHeader('LEAVE SUMMARY', teal),
        pw.SizedBox(height: 6),
        pw.TableHelper.fromTextArray(
          headers: ['Leave Type', 'Days Taken', 'Days Pending'],
          headerStyle: pw.TextStyle(
              fontWeight: pw.FontWeight.bold, color: PdfColors.white, fontSize: 9),
          headerDecoration: pw.BoxDecoration(color: teal),
          cellStyle: const pw.TextStyle(fontSize: 9),
          cellAlignments: {
            0: pw.Alignment.centerLeft,
            1: pw.Alignment.center,
            2: pw.Alignment.center,
          },
          data: leaveTypes.map((lt) => [
            lt.name,
            (leaveTakenByType[lt.name]   ?? 0).toString(),
            (leavePendingByType[lt.name] ?? 0).toString(),
          ]).toList(),
        ),
        pw.SizedBox(height: 14),
      ],

      pw.Divider(color: grey),
      pw.Text(
          'Generated automatically by ${employer.name} Management System. '
          'For official use only.',
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
                fontSize: 9, fontWeight: pw.FontWeight.bold, color: color)),
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
                    fontSize: 11, fontWeight: pw.FontWeight.bold, color: color)),
            pw.SizedBox(height: 2),
            pw.Text(label,
                style: const pw.TextStyle(
                    fontSize: 7, color: PdfColors.grey600)),
          ],
        ),
      ),
    );

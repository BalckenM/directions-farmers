import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/empty_state.dart';
import '../../../../shared/widgets/farm_app_bar.dart';
import '../../../../shared/widgets/farm_scaffold.dart';
import '../../providers/payroll_providers.dart';
import '../../services/emp501_service.dart';
import '../../theme/payroll_tokens.dart';

final _zarD = NumberFormat.currency(locale: 'en_ZA', symbol: 'R ', decimalDigits: 2);

final _emp501ReportProvider = Provider.family<Emp501Report?, int>(
  (ref, taxYear) {
    final employees = ref.watch(activeEmployeesProvider);
    final payslips  = ref.watch(payslipsProvider(const PayslipFilter()));
    if (payslips.isEmpty) return null;

    // Filter to payslips within this SARS tax year (1 Mar Y-1 -> 28 Feb Y)
    final start = DateTime(taxYear - 1, 3, 1);
    final end   = DateTime(taxYear, 2, 28, 23, 59, 59);
    final yearSlips = payslips.where((p) {
      final d = p.periodStart;
      return d.isAfter(start.subtract(const Duration(seconds: 1))) &&
             d.isBefore(end.add(const Duration(seconds: 1)));
    }).toList();
    if (yearSlips.isEmpty) return null;

    final names = {for (final e in employees) e.id: '${e.firstName} ${e.lastName}'};
    final ids   = {for (final e in employees) e.id: e.idOrPassportNumber};

    return Emp501Service.generate(
      payslips:       yearSlips,
      employeeNames:  names,
      employeeIds:    ids,
      employerRef:    'ZA-PAYE-REF',
      tradingName:    '4 Directions Farm',
      taxYear:        taxYear,
      totalEmp201Paye: 0.0,
    );
  },
);

// =============================================================================

class Emp501Screen extends ConsumerStatefulWidget {
  const Emp501Screen({super.key});

  @override
  ConsumerState<Emp501Screen> createState() => _Emp501ScreenState();
}

class _Emp501ScreenState extends ConsumerState<Emp501Screen> {
  int _taxYear = DateTime.now().month >= 3
      ? DateTime.now().year + 1
      : DateTime.now().year;

  void _stepYear(int delta) {
    final next = _taxYear + delta;
    if (next >= 2020 && next <= DateTime.now().year + 1) {
      setState(() => _taxYear = next);
    }
  }

  @override
  Widget build(BuildContext context) {
    final report = ref.watch(_emp501ReportProvider(_taxYear));

    return FarmScaffold(
      appBar: FarmAppBar(
        title: 'EMP501 Reconciliation',
        actions: [
          if (report != null)
            IconButton(
              icon:    const Icon(Icons.download_outlined),
              tooltip: 'Export CSV',
              onPressed: () => _exportCsv(report),
            ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          // ── Tax year header card ─────────────────────────────────────────
          _TaxYearHeader(taxYear: _taxYear, onStep: _stepYear),
          const SizedBox(height: 14),

          if (report == null) ...[
            const SizedBox(height: 48),
            EmptyState(
              icon:     const Icon(Icons.insert_chart_outlined, size: 56),
              title:    'No payslips for ${ _taxYear - 1 }/$_taxYear',
              subtitle: 'Payslips for this tax year will appear here once processed.',
            ),
          ] else ...[
            // ── Summary metric cards ───────────────────────────────────────
            _SummaryMetrics(report: report),
            const SizedBox(height: 18),

            // ── Reconciliation status ──────────────────────────────────────
            _ReconciliationStatus(report: report),
            const SizedBox(height: 18),

            // ── Employee certificate list ──────────────────────────────────
            _CertificateList(report: report),
            const SizedBox(height: 24),

            // ── Regulatory note ────────────────────────────────────────────
            const _RegulatoryNote(),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }

  void _exportCsv(Emp501Report report) {
    final csv = Emp501Service.toCsv(report);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('CSV generated (${csv.split('\n').length - 1} rows)'),
        action: SnackBarAction(
          label: 'Copy',
          onPressed: () {},
        ),
      ),
    );
  }
}

// ─── Tax year header card ──────────────────────────────────────────────────────

class _TaxYearHeader extends StatelessWidget {
  const _TaxYearHeader({required this.taxYear, required this.onStep});

  final int            taxYear;
  final void Function(int) onStep;

  @override
  Widget build(BuildContext context) {
    final tt = Theme.of(context).textTheme;

    return Container(
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color:        Colors.white.withAlpha(22),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.balance_outlined, color: Colors.white, size: 24),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'EMP501 ANNUAL RECONCILIATION',
                      style: tt.labelSmall?.copyWith(
                        color:        Colors.white.withAlpha(170),
                        letterSpacing: 1.4,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'SARS Annual Return',
                      style: tt.titleLarge?.copyWith(
                        color:      Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // year selector row
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
            decoration: BoxDecoration(
              color:        Colors.white.withAlpha(20),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _YearButton(icon: Icons.chevron_left_rounded, onTap: () => onStep(-1)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    '${taxYear - 1} / $taxYear',
                    style: tt.titleMedium?.copyWith(
                      color:      Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                _YearButton(icon: Icons.chevron_right_rounded, onTap: () => onStep(1)),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '1 Mar ${taxYear - 1} – 28 Feb $taxYear',
            style: tt.labelSmall?.copyWith(color: Colors.white.withAlpha(140)),
          ),
        ],
      ),
    );
  }
}

class _YearButton extends StatelessWidget {
  const _YearButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color:        Colors.white.withAlpha(25),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

// ─── Summary metric cards ─────────────────────────────────────────────────────

class _SummaryMetrics extends StatelessWidget {
  const _SummaryMetrics({required this.report});

  final Emp501Report report;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MetricCard(
            icon:        Icons.people_outline_rounded,
            accentColor: PayrollTokens.teal,
            label:       'Employees',
            value:       '${report.irp5Count + report.it3aCount}',
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MetricCard(
            icon:        Icons.account_balance_wallet_outlined,
            accentColor: PayrollTokens.indigo,
            label:       'Total PAYE',
            value:       _zarD.format(report.totalCertificatePaye),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _MetricCard(
            icon:        Icons.bar_chart_rounded,
            accentColor: PayrollTokens.purple,
            label:       'Total Gross',
            value:       _zarD.format(report.totalCertificateGross),
          ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.icon,
    required this.accentColor,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final Color    accentColor;
  final String   label;
  final String   value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs    = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color:        cs.surface,
        borderRadius: BorderRadius.circular(14),
        border:       Border.all(color: cs.outlineVariant),
        boxShadow: [
          BoxShadow(
            color:      Colors.black.withAlpha(10),
            blurRadius: 6,
            offset:     const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width:  34,
            height: 34,
            decoration: BoxDecoration(
              color:        accentColor.withAlpha(22),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: accentColor),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color:      cs.onSurface,
            ),
            maxLines:  1,
            overflow:  TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: cs.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Reconciliation status card ───────────────────────────────────────────────

class _ReconciliationStatus extends StatelessWidget {
  const _ReconciliationStatus({required this.report});

  final Emp501Report report;

  @override
  Widget build(BuildContext context) {
    final theme     = Theme.of(context);
    final cs        = theme.colorScheme;
    final balanced  = report.shortfall.abs() < 0.01;
    final shortfall = report.shortfall >= 0;
    final statusColor = balanced
        ? PayrollTokens.green
        : (shortfall ? PayrollTokens.rose : PayrollTokens.amber);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color:        cs.surface,
        borderRadius: BorderRadius.circular(14),
        border:       Border.all(color: cs.outlineVariant),
        boxShadow: [
          BoxShadow(
            color:      Colors.black.withAlpha(10),
            blurRadius: 6,
            offset:     const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width:  46,
            height: 46,
            decoration: BoxDecoration(
              color:        statusColor.withAlpha(18),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              balanced
                  ? Icons.check_circle_outline
                  : (shortfall ? Icons.error_outline : Icons.info_outline),
              size:  24,
              color: statusColor,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  balanced
                      ? 'Reconciliation Balanced'
                      : (shortfall ? 'Shortfall Detected' : 'Overpayment'),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  balanced
                      ? 'EMP201 PAYE matches certificate totals'
                      : _zarD.format(report.shortfall.abs()),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),
          if (report.totalEtiCredit > 0)
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'ETI Credit',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: cs.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _zarD.format(report.totalEtiCredit),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color:      PayrollTokens.green,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

// ─── Certificate list ─────────────────────────────────────────────────────────

class _CertificateList extends StatelessWidget {
  const _CertificateList({required this.report});

  final Emp501Report report;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs    = theme.colorScheme;

    return Container(
      decoration: BoxDecoration(
        color:        cs.surface,
        borderRadius: BorderRadius.circular(16),
        border:       Border.all(color: cs.outlineVariant),
        boxShadow: [
          BoxShadow(
            color:      Colors.black.withAlpha(10),
            blurRadius: 6,
            offset:     const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              children: [
                Container(
                  width:  34,
                  height: 34,
                  decoration: BoxDecoration(
                    color:        PayrollTokens.navy.withAlpha(18),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.description_outlined,
                    size:  18,
                    color: PayrollTokens.navy,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tax Certificates',
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'IRP5 & IT3(a) · ${report.lines.length} certificates',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: cs.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          const Divider(height: 1),

          if (report.lines.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 32),
              child: EmptyState(
                icon:     const Icon(Icons.description_outlined, size: 56),
                title:    'No certificates',
                subtitle: 'No payslips were found for this tax year.',
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics:    const NeverScrollableScrollPhysics(),
              itemCount:  report.lines.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, i) => _CertificateRow(line: report.lines[i]),
            ),
        ],
      ),
    );
  }
}

class _CertificateRow extends StatelessWidget {
  const _CertificateRow({required this.line});

  final Emp501EmployeeLine line;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs    = theme.colorScheme;
    final isIrp5 = line.certificateType == 'IRP5';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  line.displayName,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color:        isIrp5
                      ? PayrollTokens.sky.withAlpha(22)
                      : PayrollTokens.amber.withAlpha(22),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  line.certificateType,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color:      isIrp5 ? PayrollTokens.sky : PayrollTokens.amber,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              _LineDetail(label: 'Gross',  value: _zarD.format(line.annualGross)),
              const SizedBox(width: 16),
              _LineDetail(
                label: 'PAYE',
                value: _zarD.format(line.annualPaye),
                valueColor: PayrollTokens.rose,
              ),
              const SizedBox(width: 16),
              _LineDetail(label: 'UIF',  value: _zarD.format(line.annualUif)),
              const SizedBox(width: 16),
              _LineDetail(label: 'SDL',  value: _zarD.format(line.annualSdl)),
            ],
          ),
          if (line.employerEtiCredit > 0) ...[
            const SizedBox(height: 4),
            Text(
              'ETI Credit: ${_zarD.format(line.employerEtiCredit)}',
              style: theme.textTheme.labelSmall?.copyWith(
                color: PayrollTokens.green,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _LineDetail extends StatelessWidget {
  const _LineDetail({required this.label, required this.value, this.valueColor});

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs    = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelSmall?.copyWith(color: cs.onSurfaceVariant),
        ),
        Text(
          value,
          style: theme.textTheme.labelMedium?.copyWith(
            color:      valueColor ?? cs.onSurface,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

// ─── Regulatory note ──────────────────────────────────────────────────────────

class _RegulatoryNote extends StatelessWidget {
  const _RegulatoryNote();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs    = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color:        PayrollTokens.sky.withAlpha(12),
        borderRadius: BorderRadius.circular(12),
        border:       Border.all(color: PayrollTokens.sky.withAlpha(40)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, size: 16, color: PayrollTokens.sky),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'EMP501 is submitted to SARS via eFiling at the end of each '
              'tax year (Feb). Ensure your EMP201 monthly submissions match '
              'the totals shown above before filing.',
              style: theme.textTheme.bodySmall?.copyWith(
                color:  cs.onSurfaceVariant,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:printing/printing.dart';

import '../../models/pay_run.dart';
import '../../providers/payroll_providers.dart';
import '../../services/irp5_generator.dart';
import '../../services/payroll_engine.dart';
import '../../theme/payroll_tokens.dart';

final _zarD = NumberFormat.currency(
  locale: 'en_ZA',
  symbol: 'R ',
  decimalDigits: 2,
);

String _bracketLabel(double annualGross) {
  if (annualGross <= 237100) return '18% bracket';
  if (annualGross <= 370500) return '26% bracket';
  if (annualGross <= 512800) return '31% bracket';
  if (annualGross <= 673000) return '36% bracket';
  if (annualGross <= 857900) return '39% bracket';
  if (annualGross <= 1817000) return '41% bracket';
  return '45% bracket';
}

class PayeScreen extends ConsumerStatefulWidget {
  const PayeScreen({super.key});

  @override
  ConsumerState<PayeScreen> createState() => _PayeScreenState();
}

class _PayeScreenState extends ConsumerState<PayeScreen> {
  String? _selectedPayRunId;

  @override
  Widget build(BuildContext context) {
    final allPayRuns = ref.watch(allPayRunsProvider);
    final disbursedOrApproved =
        allPayRuns
            .where(
              (r) =>
                  r.status == PayRunStatus.approved ||
                  r.status == PayRunStatus.disbursed ||
                  r.status == PayRunStatus.calculated,
            )
            .toList()
          ..sort((a, b) => b.payDate.compareTo(a.payDate));

    if (_selectedPayRunId == null && disbursedOrApproved.isNotEmpty) {
      _selectedPayRunId = disbursedOrApproved.first.id;
    }

    final employees = ref.watch(activeEmployeesProvider);
    final payStructures = ref.watch(payStructuresProvider);

    // Build per-employee PAYE rows
    final rows = employees.map((emp) {
      final struct = payStructures
          .where((s) => s.id == emp.payStructureId)
          .firstOrNull;
      final monthly = struct?.baseRate ?? 0.0;
      final annual = monthly * 12;
      final paye = SaStatutory.computeMonthlyPaye(monthly);
      return (emp.fullName, monthly, annual, paye, _bracketLabel(annual));
    }).toList();

    final totalPaye = rows.fold(0.0, (s, r) => s + r.$4);

    String fmtDate(DateTime d) {
      const months = [
        '',
        'Jan',
        'Feb',
        'Mar',
        'Apr',
        'May',
        'Jun',
        'Jul',
        'Aug',
        'Sep',
        'Oct',
        'Nov',
        'Dec',
      ];
      return '${months[d.month]} ${d.year}';
    }

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 244, 246, 249),
      appBar: AppBar(
        backgroundColor: PayrollTokens.navy,
        foregroundColor: Colors.white,
        title: const Text(
          'PAYE / EMP201',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.receipt_long_outlined),
            tooltip: 'Generate EMP201 PDF',
            onPressed: () => _generateEmp201(context, ref),
          ),
          IconButton(
            icon: const Icon(Icons.assignment_outlined),
            tooltip: 'Generate IRP5 Certificates',
            onPressed: () => _generateIrp5(context, ref),
          ),
        ],
      ),
      body: Column(
        children: [
          // Pay period selector
          if (disbursedOrApproved.isNotEmpty)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: DropdownButtonFormField<String>(
                initialValue: _selectedPayRunId,
                decoration: InputDecoration(
                  labelText: 'Pay Period',
                  prefixIcon: const Icon(
                    Icons.calendar_month_outlined,
                    size: 20,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
                items: disbursedOrApproved
                    .map(
                      (r) => DropdownMenuItem(
                        value: r.id,
                        child: Text(fmtDate(r.payDate)),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _selectedPayRunId = v),
              ),
            ),
          // Totals
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: _StatCard(
                    'Employees',
                    '${rows.length}',
                    PayrollTokens.navy,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatCard(
                    'Total Gross',
                    _zarD.format(rows.fold(0.0, (s, r) => s + r.$2)),
                    PayrollTokens.teal,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatCard(
                    'Total PAYE',
                    _zarD.format(totalPaye),
                    PayrollTokens.rose,
                    large: true,
                  ),
                ),
              ],
            ),
          ),
          // Table header
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: const [
                Expanded(
                  flex: 3,
                  child: Text(
                    'Employee',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Monthly',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'PAYE',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Text(
                    'Bracket',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: rows.isEmpty
                ? const Center(
                    child: Text(
                      'No active employees',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.only(bottom: 80),
                    itemCount: rows.length,
                    separatorBuilder: (_, _) =>
                        const Divider(height: 1, indent: 16),
                    itemBuilder: (ctx, i) {
                      final (name, monthly, _, paye, bracket) = rows[i];
                      return Container(
                        color: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    name,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: PayrollTokens.navy,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                _zarD.format(monthly),
                                style: const TextStyle(fontSize: 12),
                                textAlign: TextAlign.right,
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                _zarD.format(paye),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: PayrollTokens.rose,
                                  fontWeight: FontWeight.w700,
                                ),
                                textAlign: TextAlign.right,
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Text(
                                bracket,
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey,
                                ),
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(
                  backgroundColor: PayrollTokens.teal,
                ),
                icon: const Icon(Icons.receipt_long_outlined),
                label: const Text(
                  'Generate EMP201',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                onPressed: () => _generateEmp201(context, ref),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _generateEmp201(BuildContext context, WidgetRef ref) async {
    if (_selectedPayRunId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select a pay period first.')),
      );
      return;
    }
    final payRun = ref.read(payRunProvider(_selectedPayRunId!));
    if (payRun == null) return;
    final payslips = ref.read(
      payslipsProvider(PayslipFilter(payRunId: payRun.id)),
    );
    final employees = ref.read(activeEmployeesProvider);

    try {
      final bytes = await Irp5Generator.generateEmp201(
        payRun: payRun,
        payslips: payslips,
        employees: employees,
      );
      if (!context.mounted) return;
      await Printing.layoutPdf(
        onLayout: (_) async => bytes,
        name: 'EMP201_${DateFormat('yyyy_MM').format(payRun.payDate)}.pdf',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('PDF error: $e')));
      }
    }
  }

  Future<void> _generateIrp5(BuildContext context, WidgetRef ref) async {
    final employees = ref.read(activeEmployeesProvider);
    if (employees.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No active employees found.')),
      );
      return;
    }

    // Determine current SA tax year end (March ? Feb cycle)
    final now = DateTime.now();
    final taxYearEnd = now.month >= 3 ? now.year + 1 : now.year;

    final certs = <Irp5Data>[];
    for (final emp in employees) {
      final payslips = ref.read(
        payslipsProvider(PayslipFilter(employeeId: emp.id)),
      );
      if (payslips.isEmpty) continue;
      certs.add(
        Irp5Data.fromPayslips(
          employee: emp,
          taxYearEnd: taxYearEnd,
          payslips: payslips,
        ),
      );
    }

    if (certs.isEmpty) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No payslip data for this tax year.')),
        );
      }
      return;
    }

    try {
      final bytes = await Irp5Generator.generateBatch(
        certs: certs,
        taxYearEnd: taxYearEnd,
      );
      if (!context.mounted) return;
      if (bytes == null) return;
      await Printing.layoutPdf(
        onLayout: (_) async => bytes,
        name: 'IRP5_TaxYear${taxYearEnd}_4DirectionsFarm.pdf',
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('IRP5 PDF error: $e')));
      }
    }
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard(this.label, this.value, this.color, {this.large = false});
  final String label, value;
  final Color color;
  final bool large;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: color.withValues(alpha: 0.8),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: large ? 14 : 13,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

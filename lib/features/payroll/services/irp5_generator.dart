import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/pay_run.dart';
import '../models/payroll_employee.dart';
import '../models/payslip.dart';

// ─── Brand colours ──────────────────────────────────────────────────────────
final _navy = PdfColor.fromHex('1E3A5F');
final _teal = PdfColor.fromHex('00695C');
final _rose = PdfColor.fromHex('C62828');
final _green = PdfColor.fromHex('2E7D32');
final _amber = PdfColor.fromHex('F57F17');
final _grey = PdfColor.fromHex('757575');

final _zarInt = NumberFormat.currency(
  locale: 'en_ZA',
  symbol: 'R ',
  decimalDigits: 0,
);
final _df = DateFormat('d MMMM y');

// ─── Tax year helper — SA runs 1 March → last day of Feb ───────────────────
String _taxYearLabel(int yearEnd) =>
    '1 March ${yearEnd - 1} – 28 February $yearEnd';
DateTime _taxYearStart(int yearEnd) => DateTime(yearEnd - 1, 3, 1);
DateTime _taxYearEnd(int yearEnd) => DateTime(yearEnd, 2, 28);

/// Aggregated annual tax data per employee, used to build IRP5 certificates.
class Irp5Data {
  const Irp5Data({
    required this.employee,
    required this.taxYearEnd,
    required this.grossIncome,
    required this.payeDeducted,
    required this.uifEmployee,
    required this.netPay,
    required this.payslipCount,
    this.basicSalary = 0, // SARS code 3601
    this.annualPayment = 0, // SARS code 3605
    this.travelAllowance = 0, // SARS code 3713
    this.housingFringeBenefit = 0, // SARS code 3810
    this.payeAlternate = 0, // SARS code 4001 (rare — employer-paid)
  });

  final PayrollEmployee employee;
  final int taxYearEnd;
  final double grossIncome; // SARS code 3701
  final double payeDeducted; // SARS code 4102
  final double uifEmployee; // SARS code 4141
  final double netPay;
  final int payslipCount;

  // ── Additional SARS income/deduction codes ────────────────────────────────
  /// Basic salary / wage. SARS code 3601.
  final double basicSalary;

  /// Once-off / annual payment (bonus, 13th cheque). SARS code 3605.
  final double annualPayment;

  /// Travel allowance (motor vehicle). SARS code 3713.
  final double travelAllowance;

  /// Taxable value of free / subsidised accommodation. SARS code 3810.
  final double housingFringeBenefit;

  /// PAYE paid by employer on employee's behalf. SARS code 4001.
  final double payeAlternate;

  /// Build [Irp5Data] by aggregating [payslips] that fall within [taxYearEnd].
  static Irp5Data fromPayslips({
    required PayrollEmployee employee,
    required int taxYearEnd,
    required List<Payslip> payslips,
  }) {
    final start = _taxYearStart(taxYearEnd);
    final end = _taxYearEnd(taxYearEnd);
    final relevant = payslips
        .where(
          (p) => !p.periodEnd.isBefore(start) && !p.periodStart.isAfter(end),
        )
        .toList();

    double grossIncome = 0;
    double payeDeducted = 0;
    double uifEmployee = 0;
    double netPay = 0;
    double basicSalary = 0;
    double annualPayment = 0;
    double housingFringe = 0;

    for (final p in relevant) {
      grossIncome += p.grossPay;
      netPay += p.netPay;
      basicSalary += p.basicWage;
      housingFringe += p.inKindHousing;
      // Holiday / annual payments map to code 3605 when paid once-off.
      // Treat "otherEarnings" + holidayPay as annual / once-off payment.
      annualPayment += p.holidayPay + p.otherEarnings;
      for (final d in p.deductions) {
        if (d.code == 'PAYE') payeDeducted += d.amount;
        if (d.code == 'UIF_EE') uifEmployee += d.amount;
      }
    }

    // Housing fringe benefit pulled from employee profile if no per-payslip
    // value was captured (legacy data path).
    if (housingFringe == 0 &&
        employee.hasHousingBenefit &&
        employee.housingValuePerMonth != null) {
      housingFringe = (employee.housingValuePerMonth ?? 0) * relevant.length;
    }

    return Irp5Data(
      employee: employee,
      taxYearEnd: taxYearEnd,
      grossIncome: grossIncome,
      payeDeducted: payeDeducted,
      uifEmployee: uifEmployee,
      netPay: netPay,
      payslipCount: relevant.length,
      basicSalary: basicSalary,
      annualPayment: annualPayment,
      housingFringeBenefit: housingFringe,
    );
  }
}

abstract final class Irp5Generator {
  // ─── IRP5 batch (one cert per employee) ─────────────────────────────────

  /// Generates a PDF containing one IRP5 certificate per entry in [certs].
  /// Returns `null` when [certs] is empty.
  static Future<Uint8List?> generateBatch({
    required List<Irp5Data> certs,
    required int taxYearEnd,
  }) async {
    if (certs.isEmpty) return null;

    final doc = pw.Document(
      title: 'IRP5 Certificates — Tax Year $taxYearEnd',
      author: '4Directions Farm',
    );

    for (final cert in certs) {
      doc.addPage(_buildIrp5Page(cert, taxYearEnd));
    }

    return Uint8List.fromList(await doc.save());
  }

  static pw.Page _buildIrp5Page(Irp5Data cert, int taxYearEnd) {
    return pw.Page(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(36),
      build: (ctx) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          _irp5Header(taxYearEnd),
          pw.SizedBox(height: 12),
          _irp5SubTitle('IRP5 / IT3(a) Employee Tax Certificate'),
          pw.SizedBox(height: 10),
          _twoColCard('EMPLOYER DETAILS', _navy, [
            ('Employer Name', '4DIRECTIONS FARM'),
            ('PAYE Reference', '7890123456'),
            ('SDL Reference', 'L000000000'),
            ('UIF Reference', 'U123456'),
            ('Tax Year', _taxYearLabel(taxYearEnd)),
          ]),
          pw.SizedBox(height: 10),
          _twoColCard('EMPLOYEE DETAILS', _teal, [
            (
              'Full Name',
              '${cert.employee.firstName} ${cert.employee.lastName}',
            ),
            ('ID / Passport', cert.employee.idOrPassportNumber),
            ('Occupation', cert.employee.occupationTitle),
            ('Address', cert.employee.address),
            ('Payslips Included', '${cert.payslipCount}'),
          ]),
          pw.SizedBox(height: 10),
          _incomeSection(cert),
          pw.SizedBox(height: 10),
          _deductionSection(cert),
          pw.SizedBox(height: 10),
          _netSection(cert),
          pw.Spacer(),
          _irp5Footer(),
        ],
      ),
    );
  }

  // ─── EMP201 monthly return ─────────────────────────────────────────────────

  /// Generates an EMP201 monthly PAYE return PDF for a given [payRun].
  static Future<Uint8List> generateEmp201({
    required PayRun payRun,
    required List<Payslip> payslips,
    required List<PayrollEmployee> employees,
  }) async {
    final doc = pw.Document(
      title: 'EMP201 — ${DateFormat('MMMM y').format(payRun.payDate)}',
      author: '4Directions Farm',
    );

    double totalGross = 0;
    double totalPaye = 0;
    double totalUif = 0;

    for (final p in payslips) {
      totalGross += p.grossPay;
      for (final d in p.deductions) {
        if (d.code == 'PAYE') totalPaye += d.amount;
        if (d.code == 'UIF_EE') totalUif += d.amount;
      }
    }
    final totalUifEr = totalGross * 0.01; // Employer UIF = 1%
    final totalSdl = totalGross * 0.01; // SDL = 1% if applicable

    doc.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(36),
        build: (ctx) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            _emp201Header(payRun),
            pw.SizedBox(height: 12),
            _irp5SubTitle('EMP201 — Monthly Employer Declaration'),
            pw.SizedBox(height: 10),
            _twoColCard('EMPLOYER DETAILS', _navy, [
              ('Employer Name', '4DIRECTIONS FARM'),
              ('PAYE Reference', '7890123456'),
              (
                'Tax Period',
                '${_df.format(payRun.periodStart)} – ${_df.format(payRun.periodEnd)}',
              ),
              ('Pay Date', _df.format(payRun.payDate)),
              ('Employees', '${payslips.length}'),
            ]),
            pw.SizedBox(height: 10),
            _emp201Totals(
              totalGross: totalGross,
              totalPaye: totalPaye,
              totalUifEe: totalUif,
              totalUifEr: totalUifEr,
              totalSdl: totalSdl,
            ),
            pw.SizedBox(height: 10),
            _emp201EmployeeTable(payslips, employees),
            pw.Spacer(),
            _irp5Footer(),
          ],
        ),
      ),
    );

    return Uint8List.fromList(await doc.save());
  }

  // ─── IRP5 sub-widgets ──────────────────────────────────────────────────────

  static pw.Widget _irp5Header(int taxYearEnd) {
    return pw.Container(
      color: _navy,
      padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            '4DIRECTIONS FARM',
            style: pw.TextStyle(
              color: PdfColors.white,
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.Text(
            'TAX YEAR $taxYearEnd',
            style: pw.TextStyle(
              color: const PdfColor(1, 1, 1, 0.7),
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _emp201Header(PayRun payRun) {
    return pw.Container(
      color: _navy,
      padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            '4DIRECTIONS FARM',
            style: pw.TextStyle(
              color: PdfColors.white,
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.Text(
            DateFormat('MMMM y').format(payRun.payDate).toUpperCase(),
            style: pw.TextStyle(
              color: const PdfColor(1, 1, 1, 0.7),
              fontSize: 10,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _irp5SubTitle(String text) {
    return pw.Text(
      text,
      style: pw.TextStyle(
        fontSize: 12,
        fontWeight: pw.FontWeight.bold,
        color: _navy,
      ),
    );
  }

  static pw.Widget _twoColCard(
    String title,
    PdfColor accent,
    List<(String, String)> rows,
  ) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300, width: 0.5),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            color: PdfColor.fromHex('F5F7FA'),
            width: double.infinity,
            padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: pw.Text(
              title,
              style: pw.TextStyle(
                fontSize: 8,
                fontWeight: pw.FontWeight.bold,
                color: accent,
              ),
            ),
          ),
          pw.Divider(color: PdfColors.grey300, height: 0.5),
          pw.Table(
            columnWidths: {
              0: const pw.FlexColumnWidth(1.2),
              1: const pw.FlexColumnWidth(2.5),
            },
            children: rows
                .map(
                  (r) => pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.fromLTRB(12, 4, 4, 4),
                        child: pw.Text(
                          r.$1,
                          style: pw.TextStyle(fontSize: 8, color: _grey),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.fromLTRB(4, 4, 12, 4),
                        child: pw.Text(
                          r.$2,
                          style: pw.TextStyle(
                            fontSize: 8,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
                .toList(),
          ),
        ],
      ),
    );
  }

  static pw.Widget _incomeSection(Irp5Data cert) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300, width: 0.5),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        children: [
          _cardHeader('INCOME', _green),
          pw.Divider(color: PdfColors.grey300, height: 0.5),
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: pw.Column(
              children: [
                _codeRow(
                  '3601',
                  'Income (Basic Salary / Wages)',
                  cert.basicSalary,
                ),
                _codeRow(
                  '3605',
                  'Annual / Once-off Payment',
                  cert.annualPayment,
                ),
                _codeRow(
                  '3713',
                  'Travel Allowance (Motor Vehicle)',
                  cert.travelAllowance,
                ),
                _codeRow(
                  '3810',
                  'Free / Subsidised Accommodation',
                  cert.housingFringeBenefit,
                ),
                _codeRow(
                  '3701',
                  'Gross Remuneration',
                  cert.grossIncome,
                  bold: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _deductionSection(Irp5Data cert) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300, width: 0.5),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        children: [
          _cardHeader('DEDUCTIONS / TAXES', _rose),
          pw.Divider(color: PdfColors.grey300, height: 0.5),
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: pw.Column(
              children: [
                _codeRow('4102', 'PAYE', cert.payeDeducted),
                _codeRow('4001', 'PAYE (Employer-Paid)', cert.payeAlternate),
                _codeRow('4141', 'UIF (Employee)', cert.uifEmployee),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _netSection(Irp5Data cert) {
    return pw.Container(
      color: _navy,
      padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'NET REMUNERATION PAID',
            style: pw.TextStyle(
              color: PdfColors.white,
              fontWeight: pw.FontWeight.bold,
              fontSize: 10,
            ),
          ),
          pw.Text(
            _zarInt.format(cert.netPay),
            style: pw.TextStyle(
              color: PdfColors.white,
              fontWeight: pw.FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _emp201Totals({
    required double totalGross,
    required double totalPaye,
    required double totalUifEe,
    required double totalUifEr,
    required double totalSdl,
  }) {
    final totalLiability = totalPaye + totalUifEe + totalUifEr + totalSdl;
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300, width: 0.5),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        children: [
          _cardHeader('MONTHLY LIABILITY', _rose),
          pw.Divider(color: PdfColors.grey300, height: 0.5),
          pw.Padding(
            padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: pw.Column(
              children: [
                _codeRow('—', 'Gross Remuneration', totalGross, color: _navy),
                _codeRow('4102', 'PAYE', totalPaye, color: _rose),
                _codeRow(
                  '4141',
                  'UIF — Employee (1%)',
                  totalUifEe,
                  color: _rose,
                ),
                _codeRow(
                  '4142',
                  'UIF — Employer (1%)',
                  totalUifEr,
                  color: _rose,
                ),
                _codeRow('—', 'SDL (1%)', totalSdl, color: _amber),
                pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 4),
                  child: pw.Divider(color: PdfColors.grey300, height: 0.5),
                ),
                _codeRow(
                  '—',
                  'Total Payable to SARS',
                  totalLiability,
                  bold: true,
                  color: _rose,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _emp201EmployeeTable(
    List<Payslip> payslips,
    List<PayrollEmployee> employees,
  ) {
    final empMap = {for (final e in employees) e.id: e};
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300, width: 0.5),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        children: [
          _cardHeader('EMPLOYEE BREAKDOWN', _teal),
          pw.Divider(color: PdfColors.grey300, height: 0.5),
          pw.Padding(
            padding: const pw.EdgeInsets.all(8),
            child: pw.Table(
              columnWidths: {
                0: const pw.FlexColumnWidth(3),
                1: const pw.FlexColumnWidth(2),
                2: const pw.FlexColumnWidth(2),
                3: const pw.FlexColumnWidth(2),
              },
              children: [
                // Header row
                pw.TableRow(
                  decoration: pw.BoxDecoration(
                    color: PdfColor.fromHex('F5F7FA'),
                  ),
                  children: ['EMPLOYEE', 'GROSS', 'PAYE', 'UIF']
                      .map(
                        (h) => pw.Padding(
                          padding: const pw.EdgeInsets.all(4),
                          child: pw.Text(
                            h,
                            style: pw.TextStyle(
                              fontSize: 7,
                              fontWeight: pw.FontWeight.bold,
                              color: _grey,
                            ),
                          ),
                        ),
                      )
                      .toList(),
                ),
                ...payslips.map((p) {
                  final emp = empMap[p.employeeId];
                  double paye = 0, uif = 0;
                  for (final d in p.deductions) {
                    if (d.code == 'PAYE') paye = d.amount;
                    if (d.code == 'UIF_EE') uif = d.amount;
                  }
                  return pw.TableRow(
                    children: [
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text(
                          emp != null
                              ? '${emp.firstName} ${emp.lastName}'
                              : p.employeeId,
                          style: const pw.TextStyle(fontSize: 7),
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text(
                          _zarInt.format(p.grossPay),
                          style: const pw.TextStyle(fontSize: 7),
                          textAlign: pw.TextAlign.right,
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text(
                          _zarInt.format(paye),
                          style: pw.TextStyle(fontSize: 7, color: _rose),
                          textAlign: pw.TextAlign.right,
                        ),
                      ),
                      pw.Padding(
                        padding: const pw.EdgeInsets.all(4),
                        child: pw.Text(
                          _zarInt.format(uif),
                          style: pw.TextStyle(fontSize: 7, color: _teal),
                          textAlign: pw.TextAlign.right,
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _irp5Footer() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: _grey, width: 0.5),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Text(
        'This certificate is issued in terms of Section 9(3) of the Income Tax Act (No. 58 of 1962) '
        'and must be retained by the employee for income tax purposes. '
        'SARS codes reference the Employer Reconciliation Declaration guide (2025).',
        style: pw.TextStyle(fontSize: 6.5, color: _grey),
      ),
    );
  }

  // ─── Shared micro-widgets ───────────────────────────────────────────────────

  static pw.Widget _cardHeader(String title, PdfColor accent) {
    return pw.Container(
      color: PdfColor.fromHex('F5F7FA'),
      width: double.infinity,
      padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: pw.Text(
        title,
        style: pw.TextStyle(
          fontSize: 8,
          fontWeight: pw.FontWeight.bold,
          color: accent,
        ),
      ),
    );
  }

  static pw.Widget _codeRow(
    String code,
    String label,
    double amount, {
    bool bold = false,
    PdfColor? color,
  }) {
    final fg = color ?? PdfColors.black;
    final style = pw.TextStyle(
      fontSize: 9,
      color: fg,
      fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
    );
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        children: [
          pw.SizedBox(
            width: 36,
            child: pw.Text(
              code,
              style: pw.TextStyle(fontSize: 7, color: _grey),
            ),
          ),
          pw.Expanded(child: pw.Text(label, style: style)),
          pw.Text(_zarInt.format(amount), style: style),
        ],
      ),
    );
  }
}

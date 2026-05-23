import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/payroll_employee.dart';
import '../models/payslip.dart';

// ─── Brand colours ─────────────────────────────────────────────────────────────
final _navy  = PdfColor.fromHex('1E3A5F');
final _teal  = PdfColor.fromHex('00695C');
final _green = PdfColor.fromHex('2E7D32');
final _rose  = PdfColor.fromHex('C62828');
final _amber = PdfColor.fromHex('F57F17');
final _grey  = PdfColor.fromHex('757575');

final _zar    = NumberFormat.currency(locale: 'en_ZA', symbol: 'R ', decimalDigits: 2);
final _zarInt = NumberFormat.currency(locale: 'en_ZA', symbol: 'R ', decimalDigits: 0);
final _dateFmt = DateFormat('d MMMM y');
final _mf     = DateFormat('MMMM y');

abstract final class PayslipPdfGenerator {
  /// Returns the raw PDF bytes for [payslip].
  /// [employee] is optional — if null only the employee ID is shown.
  static Future<List<int>> generate({
    required Payslip payslip,
    PayrollEmployee? employee,
  }) async {
    final doc = pw.Document(
      title: 'Payslip — ${_mf.format(payslip.periodStart)}',
      author: '4Directions Farm',
    );

    doc.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.symmetric(horizontal: 36, vertical: 32),
        header: (_) => _header(payslip),
        footer: (_) => _footer(),
        build: (ctx) => [
          pw.SizedBox(height: 12),
          _employeeSection(payslip, employee),
          pw.SizedBox(height: 10),
          _earningsSection(payslip),
          pw.SizedBox(height: 10),
          _deductionsSection(payslip),
          pw.SizedBox(height: 10),
          _netPayBanner(payslip),
          pw.SizedBox(height: 10),
          _uifNote(payslip),
          if (payslip.leaveBalanceSnapshot.isNotEmpty) ...[
            pw.SizedBox(height: 10),
            _leaveSection(payslip),
          ],
          pw.SizedBox(height: 16),
          _statutoryNotice(),
        ],
      ),
    );

    return doc.save();
  }

  // ─── Page header (employer banner) ─────────────────────────────────────────
  static pw.Widget _header(Payslip payslip) {
    return pw.Container(
      color: _navy,
      padding: const pw.EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                '4DIRECTIONS FARM',
                style: pw.TextStyle(
                  color: PdfColors.white,
                  fontSize: 16,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 3),
              pw.Text(
                'Reg: 123/456  ·  UIF: U123456  ·  PAYE: 7890123456',
                style: pw.TextStyle(color: const PdfColor(1, 1, 1, 0.7), fontSize: 8),
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Container(
                padding:
                    const pw.EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: const PdfColor(1, 1, 1, 0.54)),
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Text(
                  'PAYSLIP',
                  style: pw.TextStyle(
                      color: PdfColors.white,
                      fontSize: 10,
                      letterSpacing: 2,
                      fontWeight: pw.FontWeight.bold),
                ),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                _mf.format(payslip.periodStart),
                style: pw.TextStyle(color: const PdfColor(1, 1, 1, 0.7), fontSize: 9),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Page footer ────────────────────────────────────────────────────────────
  static pw.Widget _footer() {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 8),
      child: pw.Divider(color: _grey, height: 0.5),
    );
  }

  // ─── Employee info ──────────────────────────────────────────────────────────
  static pw.Widget _employeeSection(
      Payslip payslip, PayrollEmployee? employee) {
    return _sectionCard(
      title: 'EMPLOYEE',
      titleColor: _navy,
      child: pw.Table(
        columnWidths: {
          0: const pw.FlexColumnWidth(1.2),
          1: const pw.FlexColumnWidth(2),
          2: const pw.FlexColumnWidth(1.2),
          3: const pw.FlexColumnWidth(2),
        },
        children: [
          _tableRow('Name',
              employee != null
                  ? '${employee.firstName} ${employee.lastName}'
                  : payslip.employeeId,
              'Period',
              '${_dateFmt.format(payslip.periodStart)} – '
                  '${_dateFmt.format(payslip.periodEnd)}'),
          if (employee != null)
            _tableRow('ID / Passport', employee.idOrPassportNumber,
                'Pay Date', _dateFmt.format(payslip.payDate)),
          if (employee != null)
            _tableRow('Occupation', employee.occupationTitle, 'Payslip #',
                payslip.payslipNumber ?? '—'),
          if (employee?.bankName != null)
            _tableRow(
              'Bank',
              '${employee!.bankName}  ****'
                  '${employee.bankAccountNumber?.substring(employee.bankAccountNumber!.length > 4 ? employee.bankAccountNumber!.length - 4 : 0) ?? ''}',
              'Branch Code',
              employee.bankBranchCode ?? '—',
            ),
        ],
      ),
    );
  }

  // ─── Earnings ───────────────────────────────────────────────────────────────
  static pw.Widget _earningsSection(Payslip payslip) {
    final rows = <_LineItem>[
      _LineItem('Basic Wage', payslip.basicWage),
      if (payslip.overtimePay > 0) _LineItem('Overtime Pay', payslip.overtimePay),
      if (payslip.holidayPay > 0) _LineItem('Holiday Pay', payslip.holidayPay),
      if (payslip.inKindHousing > 0)
        _LineItem('Housing (in-kind)', payslip.inKindHousing),
      if (payslip.inKindFood > 0) _LineItem('Food (in-kind)', payslip.inKindFood),
      if (payslip.otherEarnings > 0) _LineItem('Other Earnings', payslip.otherEarnings),
    ];

    return _sectionCard(
      title: 'EARNINGS',
      titleColor: _green,
      child: pw.Column(children: [
        ...rows.map((r) => _amountRow(r.label, r.amount)),
        _divider(),
        _amountRow('Gross Pay', payslip.grossPay, bold: true, color: _navy),
      ]),
    );
  }

  // ─── Deductions ─────────────────────────────────────────────────────────────
  static pw.Widget _deductionsSection(Payslip payslip) {
    return _sectionCard(
      title: 'DEDUCTIONS',
      titleColor: _rose,
      child: pw.Column(children: [
        ...payslip.deductions.map((d) => _amountRow(
              '${d.description}${d.isStatutory ? " (Statutory)" : ""}',
              d.amount,
              color: _rose,
            )),
        _divider(),
        _amountRow('Total Deductions', payslip.totalDeductions,
            bold: true, color: _rose, prefix: '-'),
      ]),
    );
  }

  // ─── Net pay ────────────────────────────────────────────────────────────────
  static pw.Widget _netPayBanner(Payslip payslip) {
    return pw.Container(
      color: _navy,
      padding: const pw.EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            'NET PAY',
            style: pw.TextStyle(
                color: PdfColors.white,
                fontWeight: pw.FontWeight.bold,
                fontSize: 12),
          ),
          pw.Text(
            _zarInt.format(payslip.netPay),
            style: pw.TextStyle(
                color: PdfColors.white,
                fontWeight: pw.FontWeight.bold,
                fontSize: 16),
          ),
        ],
      ),
    );
  }

  // ─── UIF employer note ───────────────────────────────────────────────────────
  static pw.Widget _uifNote(Payslip payslip) {
    final uifEr = payslip.grossPay * 0.01;
    return _sectionCard(
      title: 'UIF EMPLOYER CONTRIBUTION',
      titleColor: _amber,
      child: pw.Text(
        'Employer contributes ${_zar.format(uifEr)} (1% of gross, remitted directly — '
        'not deducted from employee). Employee UIF: ${_zar.format(uifEr)}.',
        style: pw.TextStyle(fontSize: 8, color: _grey),
      ),
    );
  }

  // ─── Leave snapshot ─────────────────────────────────────────────────────────
  static pw.Widget _leaveSection(Payslip payslip) {
    return _sectionCard(
      title: 'LEAVE BALANCE SNAPSHOT',
      titleColor: _teal,
      child: pw.Row(
        children: payslip.leaveBalanceSnapshot.entries
            .map((e) => pw.Expanded(
                  child: pw.Row(children: [
                    pw.Text('${e.key}: ',
                        style: pw.TextStyle(
                            fontSize: 8,
                            fontWeight: pw.FontWeight.bold,
                            color: _teal)),
                    pw.Text('${e.value.toStringAsFixed(1)} days',
                        style: pw.TextStyle(fontSize: 8, color: _grey)),
                  ]),
                ))
            .toList(),
      ),
    );
  }

  // ─── Statutory notice ────────────────────────────────────────────────────────
  static pw.Widget _statutoryNotice() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: _grey, width: 0.5),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Text(
        'This payslip is generated in accordance with the Basic Conditions of Employment '
        'Act (BCEA) and the Unemployment Insurance Act (UIA). UIF deductions are remitted '
        'to the Department of Labour. PAYE deductions are remitted to SARS. '
        'Retain this payslip for your records.',
        style: pw.TextStyle(fontSize: 7, color: _grey),
      ),
    );
  }

  // ─── Internal layout helpers ────────────────────────────────────────────────
  static pw.Widget _sectionCard({
    required String title,
    required PdfColor titleColor,
    required pw.Widget child,
  }) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 4),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300, width: 0.5),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            color: PdfColor.fromHex('F5F7FA'),
            padding:
                const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: pw.Text(
              title,
              style: pw.TextStyle(
                  fontSize: 8,
                  fontWeight: pw.FontWeight.bold,
                  color: titleColor),
            ),
          ),
          pw.Divider(color: PdfColors.grey300, height: 0.5),
          pw.Padding(
              padding: const pw.EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: child),
        ],
      ),
    );
  }

  static pw.TableRow _tableRow(
      String l1, String v1, String l2, String v2) {
    final labelStyle =
        pw.TextStyle(fontSize: 8, color: _grey);
    final valueStyle =
        pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold);
    return pw.TableRow(children: [
      pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 3),
          child: pw.Text(l1, style: labelStyle)),
      pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 3),
          child: pw.Text(v1, style: valueStyle)),
      pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 3),
          child: pw.Text(l2, style: labelStyle)),
      pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 3),
          child: pw.Text(v2, style: valueStyle)),
    ]);
  }

  static pw.Widget _amountRow(String label, double amount,
      {bool bold = false,
      PdfColor? color,
      String prefix = ''}) {
    final fg = color ?? PdfColors.black;
    final style = pw.TextStyle(
        fontSize: 9,
        fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        color: fg);
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: style),
          pw.Text('$prefix${_zarInt.format(amount)}', style: style),
        ],
      ),
    );
  }

  static pw.Widget _divider() =>
      pw.Padding(
          padding: const pw.EdgeInsets.symmetric(vertical: 4),
          child: pw.Divider(color: PdfColors.grey300, height: 0.5));
}

// ─── Value class ────────────────────────────────────────────────────────────
class _LineItem {
  const _LineItem(this.label, this.amount);
  final String label;
  final double amount;
}

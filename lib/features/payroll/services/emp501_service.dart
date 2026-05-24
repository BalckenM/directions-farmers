// EMP501 Employer Reconciliation service — SARS submission format.
//
// The EMP501 is the annual reconciliation submitted by the employer at tax year-end
// (March). It reconciles EMP201 monthly declarations against actual employee
// certificates (IRP5/IT3(a)) and pays any shortfall.

import 'package:intl/intl.dart';

import '../models/payslip.dart';

// ─── Data models ─────────────────────────────────────────────────────────────

/// Aggregated annual figures for a single employee's EMP501 certificate line.
class Emp501EmployeeLine {
  const Emp501EmployeeLine({
    required this.employeeId,
    required this.displayName,
    required this.idOrPassport,
    required this.annualGross,
    required this.annualPaye,
    required this.annualUif,
    required this.annualSdl,
    required this.employerEtiCredit,
    required this.certificateType,
    required this.payslipCount,
  });

  final String employeeId;
  final String displayName;
  final String idOrPassport;
  final double annualGross;
  final double annualPaye;
  final double annualUif;
  final double annualSdl;
  final double employerEtiCredit;
  /// 'IRP5' when PAYE was deducted; 'IT3(a)' when no PAYE deducted.
  final String certificateType;
  final int payslipCount;
}

/// The complete EMP501 reconciliation for a tax year.
class Emp501Report {
  const Emp501Report({
    required this.taxYear,
    required this.employerRef,
    required this.tradingName,
    required this.periodStart,
    required this.periodEnd,
    required this.lines,
    required this.totalEmp201Paye,
    required this.generatedAt,
  });

  final int taxYear;           // e.g. 2026 (for 2025/2026 year)
  final String employerRef;    // SARS PAYE reference number
  final String tradingName;
  final DateTime periodStart;
  final DateTime periodEnd;
  final List<Emp501EmployeeLine> lines;
  /// Total PAYE already declared on monthly EMP201 returns.
  /// The shortfall = totalCertificatePaye - totalEmp201Paye.
  final double totalEmp201Paye;
  final DateTime generatedAt;

  double get totalCertificatePaye =>
      lines.fold(0.0, (s, l) => s + l.annualPaye);
  double get totalCertificateGross =>
      lines.fold(0.0, (s, l) => s + l.annualGross);
  double get totalEtiCredit =>
      lines.fold(0.0, (s, l) => s + l.employerEtiCredit);
  double get shortfall => totalCertificatePaye - totalEmp201Paye;
  int get irp5Count => lines.where((l) => l.certificateType == 'IRP5').length;
  int get it3aCount => lines.where((l) => l.certificateType == 'IT3(a)').length;
}

// ─── Service ──────────────────────────────────────────────────────────────────

class Emp501Service {
  Emp501Service._();

  /// Generates an [Emp501Report] from [payslips].
  ///
  /// [employeeNames] maps employeeId → display name.
  /// [employeeIds] maps employeeId → SA ID or passport number.
  /// [totalEmp201Paye] is the sum of all monthly EMP201 PAYE declarations for the year.
  static Emp501Report generate({
    required List<Payslip> payslips,
    required Map<String, String> employeeNames,
    required Map<String, String> employeeIds,
    required String employerRef,
    required String tradingName,
    required int taxYear,
    required double totalEmp201Paye,
  }) {
    final periodStart = DateTime(taxYear - 1, 3, 1);
    final periodEnd   = DateTime(taxYear, 2, 28);

    // Group payslips by employee
    final grouped = <String, List<Payslip>>{};
    for (final p in payslips) {
      (grouped[p.employeeId] ??= []).add(p);
    }

    final lines = grouped.entries.map((entry) {
      final empId = entry.key;
      final slips = entry.value;

      final annualGross = slips.fold(0.0, (s, p) => s + p.grossPay);
      final annualPaye  = slips.fold(0.0, (s, p) {
        final paye = p.deductions
            .where((d) => d.code == 'PAYE')
            .fold(0.0, (ds, d) => ds + d.amount);
        return s + paye;
      });
      final annualUif = slips.fold(0.0, (s, p) {
        final uif = p.deductions
            .where((d) => d.code == 'UIF_EE')
            .fold(0.0, (ds, d) => ds + d.amount);
        return s + uif;
      });
      final annualSdl = slips.fold(0.0, (s, p) {
        final sdl = p.deductions
            .where((d) => d.code == 'SDL')
            .fold(0.0, (ds, d) => ds + d.amount);
        return s + sdl;
      });
      // ETI credit is employer-side — stored in payslip as negative deduction
      // or separate field; here we approximate via the etiCredit field if present.
      const etiCredit = 0.0; // updated when Payslip exposes etiCredit field

      return Emp501EmployeeLine(
        employeeId: empId,
        displayName: employeeNames[empId] ?? empId,
        idOrPassport: employeeIds[empId] ?? '',
        annualGross: _r2(annualGross),
        annualPaye: _r2(annualPaye),
        annualUif: _r2(annualUif),
        annualSdl: _r2(annualSdl),
        employerEtiCredit: etiCredit,
        certificateType: annualPaye > 0 ? 'IRP5' : 'IT3(a)',
        payslipCount: slips.length,
      );
    }).toList()
      ..sort((a, b) => a.displayName.compareTo(b.displayName));

    return Emp501Report(
      taxYear: taxYear,
      employerRef: employerRef,
      tradingName: tradingName,
      periodStart: periodStart,
      periodEnd: periodEnd,
      lines: lines,
      totalEmp201Paye: _r2(totalEmp201Paye),
      generatedAt: DateTime.now(),
    );
  }

  /// Simple CSV export — one row per employee.
  static String toCsv(Emp501Report report) {
    final sb = StringBuffer();
    sb.writeln(
      'Employee ID,Name,ID/Passport,Certificate,Gross,PAYE,UIF,SDL,ETI Credit,Slips',
    );
    for (final l in report.lines) {
      sb.writeln(
        '${l.employeeId},${l.displayName},${l.idOrPassport},'
        '${l.certificateType},${l.annualGross},${l.annualPaye},'
        '${l.annualUif},${l.annualSdl},${l.employerEtiCredit},${l.payslipCount}',
      );
    }
    sb.writeln('');
    sb.writeln('Total Gross,${report.totalCertificateGross}');
    sb.writeln('Total PAYE (certificates),${report.totalCertificatePaye}');
    sb.writeln('Total EMP201 PAYE declared,${report.totalEmp201Paye}');
    sb.writeln('Shortfall / (Overpayment),${report.shortfall}');
    sb.writeln('Total ETI credit,${report.totalEtiCredit}');
    return sb.toString();
  }

  static double _r2(double v) =>
      double.parse(v.toStringAsFixed(2));
}

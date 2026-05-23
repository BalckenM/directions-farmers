import 'package:intl/intl.dart';

import '../models/employer_config.dart';
import '../models/pay_run.dart';
import '../models/payslip.dart';

/// Service producing EMP201 monthly employer declarations as structured
/// data (not PDF). PDF rendering is handled by `Irp5Generator.generateEmp201`.
///
/// Per Sprint 4 of the Payroll Module Plan, EMP201 data captures:
/// PAYE (4102), SDL (4141 employer), UIF (4142), ETI credit, and totals.
abstract final class Emp201ExportService {
  static const double _sdlRate = 0.01;
  static const double _sdlAnnualThreshold = 500000.0;

  /// Returns a map suitable for serialisation to JSON, CSV, or SARS e@syFile
  /// upload formats.
  static Map<String, dynamic> generateEmp201({
    required PayRun payRun,
    required List<Payslip> payslips,
    required EmployerConfig config,
  }) {
    double totalGross = 0;
    double totalPaye = 0;
    double totalUifEe = 0;

    for (final p in payslips) {
      totalGross += p.grossPay;
      for (final d in p.deductions) {
        if (d.code == 'PAYE') totalPaye += d.amount;
        if (d.code == 'UIF_EE') totalUifEe += d.amount;
      }
    }

    // Employer UIF mirrors employee 1% (deemed from same wage base).
    final totalUifEr = totalUifEe;
    // SDL: 1% of gross if annualised payroll exceeds R500k threshold.
    final annualisedPayroll = totalGross * 12;
    final totalSdl = annualisedPayroll > _sdlAnnualThreshold
        ? totalGross * _sdlRate
        : 0.0;

    final etiCredit = payRun.etiCredit;
    // Net liability = PAYE + UIF (EE + ER) + SDL - ETI credit
    final totalLiability =
        totalPaye + totalUifEe + totalUifEr + totalSdl - etiCredit;

    final periodStr = DateFormat('yyyy-MM').format(payRun.payDate);

    return <String, dynamic>{
      'employerRef': config.payeNumber,
      'employerName': config.name,
      'uifReference': config.uifReferenceNumber,
      'period': periodStr,
      'periodStart': payRun.periodStart.toIso8601String(),
      'periodEnd': payRun.periodEnd.toIso8601String(),
      'payDate': payRun.payDate.toIso8601String(),
      'employeeCount': payslips.length,
      'totalGrossRemuneration': _r2(totalGross),
      'paye4102': _r2(totalPaye),
      'sdlEmployer': _r2(totalSdl),
      'uifEmployee4141': _r2(totalUifEe),
      'uifEmployer4142': _r2(totalUifEr),
      'etiCredit': _r2(etiCredit),
      'totalLiability': _r2(totalLiability),
    };
  }

  /// Convenience: filename for an EMP201 export.
  static String filenameFor(EmployerConfig config, DateTime payDate) {
    final periodStr = DateFormat('yyyy-MM').format(payDate);
    final safeName = config.name.replaceAll(RegExp(r'[^A-Za-z0-9]'), '');
    return 'EMP201_${periodStr}_$safeName.json';
  }

  static double _r2(double v) => double.parse(v.toStringAsFixed(2));
}

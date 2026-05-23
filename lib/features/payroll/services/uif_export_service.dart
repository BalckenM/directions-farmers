import 'package:csv/csv.dart';
import 'package:intl/intl.dart';

import '../models/employer_config.dart';
import '../models/payroll_employee.dart';
import '../models/payslip.dart';

/// Service producing UIF UI-19 monthly declaration exports.
///
/// Per Sprint 4 of the Payroll Module Plan, this isolates CSV generation
/// from the UI layer. Columns follow the UIF UI-19 schema:
///
///   Employer Ref, Employee ID, Employee Name, Period (YYYY-MM),
///   Gross Remuneration, UIF Employee (1%), UIF Employer (1%)
abstract final class UifExportService {
  static const double _uifRate = 0.01;
  static const double _uifMonthlyCap = 17712.0;

  /// Generates a UI-19 CSV from a list of [payslips].
  ///
  /// The [employees] list is used to look up names and ID numbers per payslip.
  /// The [period] argument is the YYYY-MM string for the reporting month.
  static String generateUi19Csv({
    required List<Payslip> payslips,
    required List<PayrollEmployee> employees,
    required EmployerConfig config,
    required String period,
  }) {
    final empMap = {for (final e in employees) e.id: e};

    final rows = <List<dynamic>>[
      <dynamic>[
        'Employer Ref',
        'Employee ID',
        'Employee Name',
        'Period',
        'Gross Remuneration (R)',
        'UIF Employee (R)',
        'UIF Employer (R)',
      ],
    ];

    for (final p in payslips) {
      final emp = empMap[p.employeeId];
      final name = emp != null
          ? '${emp.firstName} ${emp.lastName}'
          : p.employeeId;
      final idNo = emp?.idOrPassportNumber ?? '';
      final uifBase = p.grossPay > _uifMonthlyCap ? _uifMonthlyCap : p.grossPay;
      final uifEmployee = p.uifEmployee > 0
          ? p.uifEmployee
          : uifBase * _uifRate;
      final uifEmployer = uifBase * _uifRate;

      rows.add(<dynamic>[
        config.uifReferenceNumber,
        idNo,
        name,
        period,
        p.grossPay.toStringAsFixed(2),
        uifEmployee.toStringAsFixed(2),
        uifEmployer.toStringAsFixed(2),
      ]);
    }

    return const CsvEncoder().convert(rows);
  }

  /// Convenience: builds the filename for a UI-19 export, e.g.
  /// `UI-19_2025-03_4DirectionsFarm.csv`.
  static String filenameFor(EmployerConfig config, DateTime period) {
    final periodStr = DateFormat('yyyy-MM').format(period);
    final safeName = config.name.replaceAll(RegExp(r'[^A-Za-z0-9]'), '');
    return 'UI-19_${periodStr}_$safeName.csv';
  }
}

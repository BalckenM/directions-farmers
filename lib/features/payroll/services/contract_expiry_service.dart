// Contract expiry alerting service.
//
// Checks each employee's [endDate] against today and produces
// [ComplianceAlert] entries used in the compliance dashboard.

import '../models/payroll_employee.dart';

// ─── Alert severity ───────────────────────────────────────────────────────────

enum AlertSeverity { info, warning, critical }

// ─── Alert model ──────────────────────────────────────────────────────────────

class ComplianceAlert {
  const ComplianceAlert({
    required this.employeeId,
    required this.employeeName,
    required this.severity,
    required this.title,
    required this.detail,
    required this.contractEndDate,
    required this.daysUntilExpiry,
  });

  final String employeeId;
  final String employeeName;
  final AlertSeverity severity;
  final String title;
  final String detail;
  final DateTime contractEndDate;
  /// Negative when the contract has already expired.
  final int daysUntilExpiry;

  bool get isExpired => daysUntilExpiry < 0;
}

// ─── Service ──────────────────────────────────────────────────────────────────

class ContractExpiryService {
  ContractExpiryService._();

  /// Returns [ComplianceAlert]s for employees whose contracts are expiring
  /// within [warningDays] days of [asOf] (defaults to today) or already expired.
  ///
  /// Employees with [PayrollEmployee.status] == [EmploymentStatus.terminated]
  /// or no [endDate] are excluded.
  static List<ComplianceAlert> checkExpiring(
    List<PayrollEmployee> employees, {
    int warningDays = 30,
    DateTime? asOf,
  }) {
    final today = _dateOnly(asOf ?? DateTime.now());
    final alerts = <ComplianceAlert>[];

    for (final emp in employees) {
      if (emp.status == EmploymentStatus.terminated) continue;
      if (emp.endDate == null) continue;

      final end = _dateOnly(emp.endDate!);
      final diff = end.difference(today).inDays;

      if (diff > warningDays) continue; // not yet approaching

      final name = '${emp.firstName} ${emp.lastName}';
      final AlertSeverity severity;
      final String title;
      final String detail;

      if (diff < 0) {
        severity = AlertSeverity.critical;
        title = 'Contract Expired';
        detail = 'Contract expired ${(-diff)} day${(-diff) == 1 ? '' : 's'} ago '
            '(${_fmt(end)}). Employee is working without a valid contract.';
      } else if (diff == 0) {
        severity = AlertSeverity.critical;
        title = 'Contract Expires Today';
        detail = 'Contract expires today (${_fmt(end)}). Renew or terminate immediately.';
      } else if (diff <= 7) {
        severity = AlertSeverity.critical;
        title = 'Contract Expiring in $diff Day${diff == 1 ? '' : 's'}';
        detail = 'Contract expires on ${_fmt(end)}. Urgent renewal required.';
      } else {
        severity = AlertSeverity.warning;
        title = 'Contract Expiring in $diff Days';
        detail = 'Contract expires on ${_fmt(end)}. Schedule renewal.';
      }

      alerts.add(ComplianceAlert(
        employeeId: emp.id,
        employeeName: name,
        severity: severity,
        title: title,
        detail: detail,
        contractEndDate: end,
        daysUntilExpiry: diff,
      ));
    }

    // Sort: most urgent first (expired → today → soonest)
    alerts.sort((a, b) => a.daysUntilExpiry.compareTo(b.daysUntilExpiry));
    return alerts;
  }

  static DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  static String _fmt(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
}

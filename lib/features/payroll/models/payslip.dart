// coverage:ignore-file
import 'package:freezed_annotation/freezed_annotation.dart';

part 'payslip.freezed.dart';
part 'payslip.g.dart';

@freezed
abstract class PayslipDeductionLine with _$PayslipDeductionLine {
  const factory PayslipDeductionLine({
    required String code,
    required String description,
    required double amount,
    required bool isStatutory,
  }) = _PayslipDeductionLine;

  factory PayslipDeductionLine.fromJson(Map<String, dynamic> json) =>
      _$PayslipDeductionLineFromJson(<String, dynamic>{
        ...json,
        'code': (json['code'] as String?) ?? '',
        'description': (json['description'] as String?) ?? '',
        'isStatutory': (json['isStatutory'] as bool?) ?? false,
      });
}

@freezed
abstract class Payslip with _$Payslip {
  const Payslip._();

  const factory Payslip({
    required String id,
    required String payRunId,
    required String employeeId,
    required DateTime periodStart,
    required DateTime periodEnd,
    required DateTime payDate,
    required double basicWage,
    required double overtimePay,
    required double holidayPay,
    required double inKindHousing,
    required double inKindFood,
    required double otherEarnings,
    required double grossPay,
    required List<PayslipDeductionLine> deductions,
    required double totalDeductions,
    required double netPay,
    required Map<String, double> leaveBalanceSnapshot,
    String? payslipNumber,
    required DateTime createdAt,
  }) = _Payslip;

  factory Payslip.fromJson(Map<String, dynamic> json) {
    double numOf(dynamic v) => v == null
        ? 0.0
        : (v is num ? v.toDouble() : double.tryParse(v.toString()) ?? 0.0);
    final now = DateTime.now().toIso8601String();
    // Normalize deductions list — backend may use 'breakdowns'
    final rawDed = json['deductions'] ?? json['breakdowns'] ?? const [];
    final deductions = rawDed is List ? rawDed : const [];
    // Normalize leave_balance_snapshot
    final rawSnap =
        json['leave_balance_snapshot'] ?? json['leaveBalanceSnapshot'];
    final leaveSnap = (rawSnap is Map)
        ? rawSnap.map<String, double>(
            (k, v) => MapEntry(k.toString(), numOf(v)),
          )
        : <String, double>{};
    return _$PayslipFromJson(<String, dynamic>{
      'id': json['id']?.toString() ?? '',
      'payRunId':
          (json['payroll_run_id'] ?? json['pay_run_id'] ?? json['payRunId'])
              ?.toString() ??
          '',
      'employeeId':
          (json['employee_id'] ?? json['employeeId'])?.toString() ?? '',
      'periodStart': (json['period_start'] ?? json['periodStart'] ?? now)
          .toString(),
      'periodEnd': (json['period_end'] ?? json['periodEnd'] ?? now).toString(),
      'payDate': (json['pay_date'] ?? json['payDate'] ?? now).toString(),
      'basicWage': numOf(
        json['basic_wage'] ?? json['basic_salary'] ?? json['basicWage'],
      ),
      'overtimePay': numOf(json['overtime_pay'] ?? json['overtimePay']),
      'holidayPay': numOf(json['holiday_pay'] ?? json['holidayPay']),
      'inKindHousing': numOf(json['in_kind_housing'] ?? json['inKindHousing']),
      'inKindFood': numOf(json['in_kind_food'] ?? json['inKindFood']),
      'otherEarnings': numOf(json['other_earnings'] ?? json['otherEarnings']),
      'grossPay': numOf(
        json['gross_pay'] ?? json['gross_salary'] ?? json['grossPay'],
      ),
      'deductions': deductions,
      'totalDeductions': numOf(
        json['total_deductions'] ?? json['totalDeductions'],
      ),
      'netPay': numOf(json['net_pay'] ?? json['net_salary'] ?? json['netPay']),
      'leaveBalanceSnapshot': leaveSnap,
      'payslipNumber': (json['payslip_number'] ?? json['payslipNumber'])
          ?.toString(),
      'createdAt': (json['created_at'] ?? json['createdAt'] ?? now).toString(),
    });
  }

  double get uifEmployee => deductions
      .where((d) => d.code == 'UIF_EE')
      .fold(0, (s, d) => s + d.amount);
  double get paye =>
      deductions.where((d) => d.code == 'PAYE').fold(0, (s, d) => s + d.amount);
}

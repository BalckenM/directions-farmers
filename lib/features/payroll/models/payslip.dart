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

  factory Payslip.fromJson(Map<String, dynamic> json) =>
      _$PayslipFromJson(json);

  double get uifEmployee => deductions
      .where((d) => d.code == 'UIF_EE')
      .fold(0, (s, d) => s + d.amount);
  double get paye =>
      deductions.where((d) => d.code == 'PAYE').fold(0, (s, d) => s + d.amount);
}

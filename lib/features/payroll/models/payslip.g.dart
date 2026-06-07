// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payslip.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PayslipDeductionLine _$PayslipDeductionLineFromJson(
  Map<String, dynamic> json,
) => _PayslipDeductionLine(
  code: json['code'] as String,
  description: json['description'] as String,
  amount: (json['amount'] as num).toDouble(),
  isStatutory: json['isStatutory'] as bool,
);

Map<String, dynamic> _$PayslipDeductionLineToJson(
  _PayslipDeductionLine instance,
) => <String, dynamic>{
  'code': instance.code,
  'description': instance.description,
  'amount': instance.amount,
  'isStatutory': instance.isStatutory,
};

_Payslip _$PayslipFromJson(Map<String, dynamic> json) => _Payslip(
  id: json['id'] as String,
  payRunId: json['payRunId'] as String,
  employeeId: json['employeeId'] as String,
  periodStart: DateTime.parse(json['periodStart'] as String),
  periodEnd: DateTime.parse(json['periodEnd'] as String),
  payDate: DateTime.parse(json['payDate'] as String),
  basicWage: (json['basicWage'] as num).toDouble(),
  overtimePay: (json['overtimePay'] as num).toDouble(),
  holidayPay: (json['holidayPay'] as num).toDouble(),
  inKindHousing: (json['inKindHousing'] as num).toDouble(),
  inKindFood: (json['inKindFood'] as num).toDouble(),
  otherEarnings: (json['otherEarnings'] as num).toDouble(),
  grossPay: (json['grossPay'] as num).toDouble(),
  deductions: (json['deductions'] as List<dynamic>)
      .map((e) => PayslipDeductionLine.fromJson(e as Map<String, dynamic>))
      .toList(),
  totalDeductions: (json['totalDeductions'] as num).toDouble(),
  netPay: (json['netPay'] as num).toDouble(),
  leaveBalanceSnapshot: (json['leaveBalanceSnapshot'] as Map<String, dynamic>)
      .map((k, e) => MapEntry(k, (e as num).toDouble())),
  payslipNumber: json['payslipNumber'] as String?,
  createdAt: DateTime.parse(json['createdAt'] as String),
);

Map<String, dynamic> _$PayslipToJson(_Payslip instance) => <String, dynamic>{
  'id': instance.id,
  'payRunId': instance.payRunId,
  'employeeId': instance.employeeId,
  'periodStart': instance.periodStart.toIso8601String(),
  'periodEnd': instance.periodEnd.toIso8601String(),
  'payDate': instance.payDate.toIso8601String(),
  'basicWage': instance.basicWage,
  'overtimePay': instance.overtimePay,
  'holidayPay': instance.holidayPay,
  'inKindHousing': instance.inKindHousing,
  'inKindFood': instance.inKindFood,
  'otherEarnings': instance.otherEarnings,
  'grossPay': instance.grossPay,
  'deductions': instance.deductions,
  'totalDeductions': instance.totalDeductions,
  'netPay': instance.netPay,
  'leaveBalanceSnapshot': instance.leaveBalanceSnapshot,
  'payslipNumber': instance.payslipNumber,
  'createdAt': instance.createdAt.toIso8601String(),
};

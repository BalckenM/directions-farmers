class PayslipDeductionLine {
  const PayslipDeductionLine({
    required this.code,
    required this.description,
    required this.amount,
    required this.isStatutory,
  });

  final String code;
  final String description;
  final double amount;
  final bool isStatutory;

  factory PayslipDeductionLine.fromJson(Map<String, dynamic> json) => PayslipDeductionLine(
        code: json['code'] as String,
        description: json['description'] as String,
        amount: (json['amount'] as num).toDouble(),
        isStatutory: json['isStatutory'] as bool,
      );

  Map<String, dynamic> toJson() => {
        'code': code,
        'description': description,
        'amount': amount,
        'isStatutory': isStatutory,
      };
}

class Payslip {
  const Payslip({
    required this.id,
    required this.payRunId,
    required this.employeeId,
    required this.periodStart,
    required this.periodEnd,
    required this.payDate,
    required this.basicWage,
    required this.overtimePay,
    required this.holidayPay,
    required this.inKindHousing,
    required this.inKindFood,
    required this.otherEarnings,
    required this.grossPay,
    required this.deductions,
    required this.totalDeductions,
    required this.netPay,
    required this.leaveBalanceSnapshot,
    this.payslipNumber,
    required this.createdAt,
  });

  final String id;
  final String payRunId;
  final String employeeId;
  final DateTime periodStart;
  final DateTime periodEnd;
  final DateTime payDate;
  final double basicWage;
  final double overtimePay;
  final double holidayPay;
  final double inKindHousing;
  final double inKindFood;
  final double otherEarnings;
  final double grossPay;
  final List<PayslipDeductionLine> deductions;
  final double totalDeductions;
  final double netPay;

  /// Snapshot of leave balances at the time the payslip was generated.
  final Map<String, double> leaveBalanceSnapshot;
  final String? payslipNumber;
  final DateTime createdAt;

  double get uifEmployee =>
      deductions.where((d) => d.code == 'UIF_EE').fold(0, (s, d) => s + d.amount);
  double get paye =>
      deductions.where((d) => d.code == 'PAYE').fold(0, (s, d) => s + d.amount);

  factory Payslip.fromJson(Map<String, dynamic> json) => Payslip(
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
        leaveBalanceSnapshot: Map<String, double>.fromEntries(
          (json['leaveBalanceSnapshot'] as Map<String, dynamic>)
              .entries
              .map((e) => MapEntry(e.key, (e.value as num).toDouble())),
        ),
        payslipNumber: json['payslipNumber'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'payRunId': payRunId,
        'employeeId': employeeId,
        'periodStart': periodStart.toIso8601String(),
        'periodEnd': periodEnd.toIso8601String(),
        'payDate': payDate.toIso8601String(),
        'basicWage': basicWage,
        'overtimePay': overtimePay,
        'holidayPay': holidayPay,
        'inKindHousing': inKindHousing,
        'inKindFood': inKindFood,
        'otherEarnings': otherEarnings,
        'grossPay': grossPay,
        'deductions': deductions.map((e) => e.toJson()).toList(),
        'totalDeductions': totalDeductions,
        'netPay': netPay,
        'leaveBalanceSnapshot': leaveBalanceSnapshot,
        'payslipNumber': payslipNumber,
        'createdAt': createdAt.toIso8601String(),
      };
}

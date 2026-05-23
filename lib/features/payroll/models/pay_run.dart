enum PayRunStatus { draft, calculated, pendingApproval, approved, disbursed, cancelled }

class PayslipLineItem {
  const PayslipLineItem({
    required this.code,
    required this.description,
    required this.quantity,
    required this.rate,
    required this.amount,
    this.isStatutory = false,
  });

  final String code;
  final String description;
  final double quantity;
  final double rate;
  final double amount;
  final bool isStatutory;

  factory PayslipLineItem.fromJson(Map<String, dynamic> json) => PayslipLineItem(
        code: json['code'] as String,
        description: json['description'] as String,
        quantity: (json['quantity'] as num).toDouble(),
        rate: (json['rate'] as num).toDouble(),
        amount: (json['amount'] as num).toDouble(),
        isStatutory: json['isStatutory'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'code': code,
        'description': description,
        'quantity': quantity,
        'rate': rate,
        'amount': amount,
        'isStatutory': isStatutory,
      };
}

class PayRun {
  const PayRun({
    required this.id,
    required this.payGroupId,
    required this.periodStart,
    required this.periodEnd,
    required this.payDate,
    required this.status,
    required this.totalGross,
    required this.totalDeductions,
    required this.totalNet,
    required this.employeeCount,
    this.approvedByUserId,
    this.approvedAt,
    this.disbursedAt,
    this.notes,
    required this.complianceAlertIds,
    required this.lineItems,
    this.sdlContribution = 0.0,
    this.etiCredit = 0.0,
    this.totalCoidaContribution = 0.0,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String payGroupId;
  final DateTime periodStart;
  final DateTime periodEnd;
  final DateTime payDate;
  final PayRunStatus status;
  final double totalGross;
  final double totalDeductions;
  final double totalNet;
  final int employeeCount;
  final String? approvedByUserId;
  final DateTime? approvedAt;
  final DateTime? disbursedAt;
  final String? notes;
  final List<String> complianceAlertIds;
  final List<PayslipLineItem> lineItems;
  /// Employer-only SDL levy for this pay run period (1% of gross if annual payroll > R500k).
  final double sdlContribution;
  /// Total ETI credit reducing employer PAYE liability this period.
  final double etiCredit;
  /// Total COIDA assessment contribution across all employees this period.
  final double totalCoidaContribution;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isDisbursed => status == PayRunStatus.disbursed;
  bool get isEditable =>
      status == PayRunStatus.draft || status == PayRunStatus.calculated;

  factory PayRun.fromJson(Map<String, dynamic> json) => PayRun(
        id: json['id'] as String,
        payGroupId: json['payGroupId'] as String,
        periodStart: DateTime.parse(json['periodStart'] as String),
        periodEnd: DateTime.parse(json['periodEnd'] as String),
        payDate: DateTime.parse(json['payDate'] as String),
        status: PayRunStatus.values.byName(json['status'] as String),
        totalGross: (json['totalGross'] as num).toDouble(),
        totalDeductions: (json['totalDeductions'] as num).toDouble(),
        totalNet: (json['totalNet'] as num).toDouble(),
        employeeCount: json['employeeCount'] as int,
        approvedByUserId: json['approvedByUserId'] as String?,
        approvedAt: json['approvedAt'] != null ? DateTime.parse(json['approvedAt'] as String) : null,
        disbursedAt: json['disbursedAt'] != null ? DateTime.parse(json['disbursedAt'] as String) : null,
        notes: json['notes'] as String?,
        complianceAlertIds: (json['complianceAlertIds'] as List<dynamic>)
            .map((e) => e as String)
            .toList(),
        lineItems: (json['lineItems'] as List<dynamic>)
            .map((e) => PayslipLineItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        sdlContribution: (json['sdlContribution'] as num?)?.toDouble() ?? 0.0,
        etiCredit: (json['etiCredit'] as num?)?.toDouble() ?? 0.0,
        totalCoidaContribution: (json['totalCoidaContribution'] as num?)?.toDouble() ?? 0.0,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'payGroupId': payGroupId,
        'periodStart': periodStart.toIso8601String(),
        'periodEnd': periodEnd.toIso8601String(),
        'payDate': payDate.toIso8601String(),
        'status': status.name,
        'totalGross': totalGross,
        'totalDeductions': totalDeductions,
        'totalNet': totalNet,
        'employeeCount': employeeCount,
        'approvedByUserId': approvedByUserId,
        'approvedAt': approvedAt?.toIso8601String(),
        'disbursedAt': disbursedAt?.toIso8601String(),
        'notes': notes,
        'complianceAlertIds': complianceAlertIds,
        'lineItems': lineItems.map((e) => e.toJson()).toList(),
        'sdlContribution': sdlContribution,
        'etiCredit': etiCredit,
        'totalCoidaContribution': totalCoidaContribution,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  PayRun copyWith({
    String? id,
    String? payGroupId,
    DateTime? periodStart,
    DateTime? periodEnd,
    DateTime? payDate,
    PayRunStatus? status,
    double? totalGross,
    double? totalDeductions,
    double? totalNet,
    int? employeeCount,
    String? approvedByUserId,
    DateTime? approvedAt,
    DateTime? disbursedAt,
    String? notes,
    List<String>? complianceAlertIds,
    List<PayslipLineItem>? lineItems,
    double? sdlContribution,
    double? etiCredit,
    double? totalCoidaContribution,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PayRun(
      id: id ?? this.id,
      payGroupId: payGroupId ?? this.payGroupId,
      periodStart: periodStart ?? this.periodStart,
      periodEnd: periodEnd ?? this.periodEnd,
      payDate: payDate ?? this.payDate,
      status: status ?? this.status,
      totalGross: totalGross ?? this.totalGross,
      totalDeductions: totalDeductions ?? this.totalDeductions,
      totalNet: totalNet ?? this.totalNet,
      employeeCount: employeeCount ?? this.employeeCount,
      approvedByUserId: approvedByUserId ?? this.approvedByUserId,
      approvedAt: approvedAt ?? this.approvedAt,
      disbursedAt: disbursedAt ?? this.disbursedAt,
      notes: notes ?? this.notes,
      complianceAlertIds: complianceAlertIds ?? this.complianceAlertIds,
      lineItems: lineItems ?? this.lineItems,
      sdlContribution: sdlContribution ?? this.sdlContribution,
      etiCredit: etiCredit ?? this.etiCredit,
      totalCoidaContribution: totalCoidaContribution ?? this.totalCoidaContribution,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

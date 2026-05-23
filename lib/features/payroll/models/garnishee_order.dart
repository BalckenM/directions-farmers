/// Sprint 6 \u2014 Garnishee orders (Magistrates' Court emoluments attachment orders)
///
/// A garnishee order is a court order directing an employer to deduct
/// a portion of an employee's wages and pay it directly to a creditor.
///
/// Under the National Credit Act / BCEA combined caps, total non-statutory
/// deductions (voluntary + garnishee) may not exceed 25% of net pay after
/// statutory deductions (PAYE, UIF). The Payroll Engine enforces this cap
/// and emits a `DEDUCTION_CAP_EXCEEDED` compliance alert when triggered.
enum GarnisheeStatus { active, satisfied, suspended, cancelled }

class GarnisheeOrder {
  const GarnisheeOrder({
    required this.id,
    required this.employeeId,
    required this.courtOrderRef,
    required this.creditorName,
    required this.monthlyDeductionAmount,
    required this.totalOwed,
    required this.amountDeducted,
    required this.status,
    required this.createdAt,
    this.satisfiedAt,
    this.notes,
  });

  final String id;
  final String employeeId;
  final String courtOrderRef;
  final String creditorName;
  final double monthlyDeductionAmount;
  final double totalOwed;
  final double amountDeducted;
  final GarnisheeStatus status;
  final DateTime createdAt;
  final DateTime? satisfiedAt;
  final String? notes;

  double get outstandingBalance =>
      (totalOwed - amountDeducted).clamp(0.0, double.infinity);

  bool get isActive => status == GarnisheeStatus.active;

  GarnisheeOrder copyWith({
    String? id,
    String? employeeId,
    String? courtOrderRef,
    String? creditorName,
    double? monthlyDeductionAmount,
    double? totalOwed,
    double? amountDeducted,
    GarnisheeStatus? status,
    DateTime? createdAt,
    DateTime? satisfiedAt,
    String? notes,
  }) {
    return GarnisheeOrder(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      courtOrderRef: courtOrderRef ?? this.courtOrderRef,
      creditorName: creditorName ?? this.creditorName,
      monthlyDeductionAmount:
          monthlyDeductionAmount ?? this.monthlyDeductionAmount,
      totalOwed: totalOwed ?? this.totalOwed,
      amountDeducted: amountDeducted ?? this.amountDeducted,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      satisfiedAt: satisfiedAt ?? this.satisfiedAt,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'employeeId': employeeId,
    'courtOrderRef': courtOrderRef,
    'creditorName': creditorName,
    'monthlyDeductionAmount': monthlyDeductionAmount,
    'totalOwed': totalOwed,
    'amountDeducted': amountDeducted,
    'status': status.name,
    'createdAt': createdAt.toIso8601String(),
    'satisfiedAt': satisfiedAt?.toIso8601String(),
    'notes': notes,
  };

  factory GarnisheeOrder.fromJson(Map<String, dynamic> json) => GarnisheeOrder(
    id: json['id'] as String,
    employeeId: json['employeeId'] as String,
    courtOrderRef: json['courtOrderRef'] as String,
    creditorName: json['creditorName'] as String,
    monthlyDeductionAmount: (json['monthlyDeductionAmount'] as num).toDouble(),
    totalOwed: (json['totalOwed'] as num).toDouble(),
    amountDeducted: (json['amountDeducted'] as num).toDouble(),
    status: GarnisheeStatus.values.firstWhere(
      (s) => s.name == json['status'] as String,
    ),
    createdAt: DateTime.parse(json['createdAt'] as String),
    satisfiedAt: json['satisfiedAt'] == null
        ? null
        : DateTime.parse(json['satisfiedAt'] as String),
    notes: json['notes'] as String?,
  );
}

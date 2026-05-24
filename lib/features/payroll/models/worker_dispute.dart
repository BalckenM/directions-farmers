// Worker dispute model — allows farm workers to formally raise payroll
// grievances (pay discrepancies, leave balance disputes, overtime queries, etc.)
// which can then be reviewed and resolved by supervisors / payroll managers.

// ─── Dispute classification ───────────────────────────────────────────────────

enum DisputeType {
  payDiscrepancy,
  leaveBalance,
  overtimePay,
  deductionQuery,
  other,
}

extension DisputeTypeX on DisputeType {
  String get label => switch (this) {
    DisputeType.payDiscrepancy => 'Pay Discrepancy',
    DisputeType.leaveBalance => 'Leave Balance',
    DisputeType.overtimePay => 'Overtime Pay',
    DisputeType.deductionQuery => 'Deduction Query',
    DisputeType.other => 'Other',
  };
}

// ─── Dispute lifecycle status ──────────────────────────────────────────────────

enum DisputeStatus { open, underReview, resolved, dismissed }

extension DisputeStatusX on DisputeStatus {
  String get label => switch (this) {
    DisputeStatus.open => 'Open',
    DisputeStatus.underReview => 'Under Review',
    DisputeStatus.resolved => 'Resolved',
    DisputeStatus.dismissed => 'Dismissed',
  };

  bool get isClosed =>
      this == DisputeStatus.resolved || this == DisputeStatus.dismissed;
}

// ─── WorkerDispute model ───────────────────────────────────────────────────────

class WorkerDispute {
  const WorkerDispute({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.type,
    required this.status,
    required this.description,
    required this.filedAt,
    this.relatedPayRunId,
    this.relatedPayslipId,
    this.resolvedAt,
    this.resolvedBy,
    this.resolutionNote,
  });

  final String id;
  final String employeeId;
  final String employeeName;
  final DisputeType type;
  final DisputeStatus status;
  final String description;

  /// Optional link to the pay run this dispute concerns.
  final String? relatedPayRunId;

  /// Optional link to a specific payslip.
  final String? relatedPayslipId;

  final DateTime filedAt;

  /// When the dispute was closed (resolved or dismissed).
  final DateTime? resolvedAt;

  /// User ID / name of the resolver.
  final String? resolvedBy;

  /// Resolution explanation written by the resolver.
  final String? resolutionNote;

  WorkerDispute copyWith({
    String? id,
    String? employeeId,
    String? employeeName,
    DisputeType? type,
    DisputeStatus? status,
    String? description,
    DateTime? filedAt,
    String? relatedPayRunId,
    String? relatedPayslipId,
    DateTime? resolvedAt,
    String? resolvedBy,
    String? resolutionNote,
  }) => WorkerDispute(
    id: id ?? this.id,
    employeeId: employeeId ?? this.employeeId,
    employeeName: employeeName ?? this.employeeName,
    type: type ?? this.type,
    status: status ?? this.status,
    description: description ?? this.description,
    filedAt: filedAt ?? this.filedAt,
    relatedPayRunId: relatedPayRunId ?? this.relatedPayRunId,
    relatedPayslipId: relatedPayslipId ?? this.relatedPayslipId,
    resolvedAt: resolvedAt ?? this.resolvedAt,
    resolvedBy: resolvedBy ?? this.resolvedBy,
    resolutionNote: resolutionNote ?? this.resolutionNote,
  );

  factory WorkerDispute.fromJson(Map<String, dynamic> json) => WorkerDispute(
    id: json['id'] as String,
    employeeId: json['employeeId'] as String,
    employeeName: json['employeeName'] as String,
    type: DisputeType.values.byName(json['type'] as String),
    status: DisputeStatus.values.byName(json['status'] as String),
    description: json['description'] as String,
    filedAt: DateTime.parse(json['filedAt'] as String),
    relatedPayRunId: json['relatedPayRunId'] as String?,
    relatedPayslipId: json['relatedPayslipId'] as String?,
    resolvedAt: json['resolvedAt'] != null
        ? DateTime.parse(json['resolvedAt'] as String)
        : null,
    resolvedBy: json['resolvedBy'] as String?,
    resolutionNote: json['resolutionNote'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'employeeId': employeeId,
    'employeeName': employeeName,
    'type': type.name,
    'status': status.name,
    'description': description,
    'filedAt': filedAt.toIso8601String(),
    'relatedPayRunId': relatedPayRunId,
    'relatedPayslipId': relatedPayslipId,
    'resolvedAt': resolvedAt?.toIso8601String(),
    'resolvedBy': resolvedBy,
    'resolutionNote': resolutionNote,
  };
}

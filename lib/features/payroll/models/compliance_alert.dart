enum ComplianceSeverity { critical, warning, info }

class ComplianceAlert {
  const ComplianceAlert({
    required this.id,
    required this.code,
    required this.title,
    required this.description,
    required this.severity,
    this.employeeId,
    this.payRunId,
    required this.isResolved,
    this.resolvedByUserId,
    this.resolvedAt,
    this.resolution,
    required this.raisedAt,
  });

  final String id;

  /// Machine code, e.g. 'NMWA_BREACH', 'CONTRACT_EXPIRED', 'UIF_MISSING_BANK'.
  final String code;
  final String title;
  final String description;
  final ComplianceSeverity severity;
  final String? employeeId;
  final String? payRunId;
  final bool isResolved;
  final String? resolvedByUserId;
  final DateTime? resolvedAt;
  final String? resolution;
  final DateTime raisedAt;

  bool get isOpen => !isResolved;

  factory ComplianceAlert.fromJson(Map<String, dynamic> json) => ComplianceAlert(
        id: json['id'] as String,
        code: json['code'] as String,
        title: json['title'] as String,
        description: json['description'] as String,
        severity: ComplianceSeverity.values.byName(json['severity'] as String),
        employeeId: json['employeeId'] as String?,
        payRunId: json['payRunId'] as String?,
        isResolved: json['isResolved'] as bool,
        resolvedByUserId: json['resolvedByUserId'] as String?,
        resolvedAt: json['resolvedAt'] != null ? DateTime.parse(json['resolvedAt'] as String) : null,
        resolution: json['resolution'] as String?,
        raisedAt: DateTime.parse(json['raisedAt'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'code': code,
        'title': title,
        'description': description,
        'severity': severity.name,
        'employeeId': employeeId,
        'payRunId': payRunId,
        'isResolved': isResolved,
        'resolvedByUserId': resolvedByUserId,
        'resolvedAt': resolvedAt?.toIso8601String(),
        'resolution': resolution,
        'raisedAt': raisedAt.toIso8601String(),
      };

  ComplianceAlert copyWith({
    String? id,
    String? code,
    String? title,
    String? description,
    ComplianceSeverity? severity,
    String? employeeId,
    String? payRunId,
    bool? isResolved,
    String? resolvedByUserId,
    DateTime? resolvedAt,
    String? resolution,
    DateTime? raisedAt,
  }) {
    return ComplianceAlert(
      id: id ?? this.id,
      code: code ?? this.code,
      title: title ?? this.title,
      description: description ?? this.description,
      severity: severity ?? this.severity,
      employeeId: employeeId ?? this.employeeId,
      payRunId: payRunId ?? this.payRunId,
      isResolved: isResolved ?? this.isResolved,
      resolvedByUserId: resolvedByUserId ?? this.resolvedByUserId,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      resolution: resolution ?? this.resolution,
      raisedAt: raisedAt ?? this.raisedAt,
    );
  }
}

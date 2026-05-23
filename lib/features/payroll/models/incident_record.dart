enum IncidentType { disciplinary, grievance, healthAndSafety, misconduct, other }

enum IncidentStatus { open, underInvestigation, resolved, closed }

class IncidentRecord {
  const IncidentRecord({
    required this.id,
    required this.employeeId,
    required this.type,
    required this.title,
    required this.description,
    required this.incidentDate,
    required this.status,
    this.actionTaken,
    this.resolvedAt,
    this.resolvedByUserId,
    this.documentPaths,
    required this.reportedByUserId,
    required this.createdAt,
  });

  final String id;
  final String employeeId;
  final IncidentType type;
  final String title;
  final String description;
  final DateTime incidentDate;
  final IncidentStatus status;
  final String? actionTaken;
  final DateTime? resolvedAt;
  final String? resolvedByUserId;
  final List<String>? documentPaths;
  final String reportedByUserId;
  final DateTime createdAt;

  bool get isOpen => status == IncidentStatus.open ||
      status == IncidentStatus.underInvestigation;

  String get typeLabel {
    switch (type) {
      case IncidentType.disciplinary:
        return 'Disciplinary';
      case IncidentType.grievance:
        return 'Grievance';
      case IncidentType.healthAndSafety:
        return 'Health & Safety';
      case IncidentType.misconduct:
        return 'Misconduct';
      case IncidentType.other:
        return 'Other';
    }
  }

  factory IncidentRecord.fromJson(Map<String, dynamic> json) => IncidentRecord(
        id: json['id'] as String,
        employeeId: json['employeeId'] as String,
        type: IncidentType.values.byName(json['type'] as String),
        title: json['title'] as String,
        description: json['description'] as String,
        incidentDate: DateTime.parse(json['incidentDate'] as String),
        status: IncidentStatus.values.byName(json['status'] as String),
        actionTaken: json['actionTaken'] as String?,
        resolvedAt: json['resolvedAt'] != null ? DateTime.parse(json['resolvedAt'] as String) : null,
        resolvedByUserId: json['resolvedByUserId'] as String?,
        documentPaths: json['documentPaths'] != null
            ? (json['documentPaths'] as List<dynamic>).map((e) => e as String).toList()
            : null,
        reportedByUserId: json['reportedByUserId'] as String,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'employeeId': employeeId,
        'type': type.name,
        'title': title,
        'description': description,
        'incidentDate': incidentDate.toIso8601String(),
        'status': status.name,
        'actionTaken': actionTaken,
        'resolvedAt': resolvedAt?.toIso8601String(),
        'resolvedByUserId': resolvedByUserId,
        'documentPaths': documentPaths,
        'reportedByUserId': reportedByUserId,
        'createdAt': createdAt.toIso8601String(),
      };

  IncidentRecord copyWith({
    String? id,
    String? employeeId,
    IncidentType? type,
    String? title,
    String? description,
    DateTime? incidentDate,
    IncidentStatus? status,
    String? actionTaken,
    DateTime? resolvedAt,
    String? resolvedByUserId,
    List<String>? documentPaths,
    String? reportedByUserId,
    DateTime? createdAt,
  }) {
    return IncidentRecord(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      incidentDate: incidentDate ?? this.incidentDate,
      status: status ?? this.status,
      actionTaken: actionTaken ?? this.actionTaken,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      resolvedByUserId: resolvedByUserId ?? this.resolvedByUserId,
      documentPaths: documentPaths ?? this.documentPaths,
      reportedByUserId: reportedByUserId ?? this.reportedByUserId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

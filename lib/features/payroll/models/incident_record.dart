// coverage:ignore-file
import 'package:freezed_annotation/freezed_annotation.dart';

part 'incident_record.freezed.dart';
part 'incident_record.g.dart';

enum IncidentType {
  disciplinary,
  grievance,
  healthAndSafety,
  misconduct,
  other,
}

enum IncidentStatus { open, underInvestigation, resolved, closed }

@freezed
abstract class IncidentRecord with _$IncidentRecord {
  const IncidentRecord._();

  const factory IncidentRecord({
    required String id,
    required String employeeId,
    required IncidentType type,
    required String title,
    required String description,
    required DateTime incidentDate,
    required IncidentStatus status,
    String? actionTaken,
    DateTime? resolvedAt,
    String? resolvedByUserId,
    List<String>? documentPaths,
    required String reportedByUserId,
    required DateTime createdAt,
  }) = _IncidentRecord;

  factory IncidentRecord.fromJson(Map<String, dynamic> json) {
    const typeMap = {
      'disciplinary': 'disciplinary',
      'grievance': 'grievance',
      'health_and_safety': 'healthAndSafety',
      'misconduct': 'misconduct',
      'other': 'other',
    };
    const statusMap = {
      'open': 'open',
      'under_investigation': 'underInvestigation',
      'resolved': 'resolved',
      'closed': 'closed',
    };
    final now = DateTime.now().toIso8601String();
    return _$IncidentRecordFromJson(<String, dynamic>{
      ...json,
      'id': json['id']?.toString() ?? '',
      'employeeId':
          (json['employee_id'] ?? json['employeeId'])?.toString() ?? '',
      'type': typeMap[json['type']] ?? json['type'] ?? 'other',
      'status': statusMap[json['status']] ?? json['status'] ?? 'open',
      'incidentDate': json['incident_date'] ?? json['incidentDate'] ?? now,
      'actionTaken': json['action_taken'] ?? json['actionTaken'],
      'resolvedAt': json['resolved_at'] ?? json['resolvedAt'],
      'resolvedByUserId': (json['resolved_by_id'] ?? json['resolvedByUserId'])
          ?.toString(),
      'documentPaths':
          (json['document_paths'] ?? json['documentPaths'] as List?)
              ?.map((e) => e.toString())
              .toList(),
      'reportedByUserId':
          (json['reported_by_id'] ?? json['reportedByUserId'])?.toString() ??
          '',
      'createdAt': json['created_at'] ?? json['createdAt'] ?? now,
    });
  }

  bool get isOpen =>
      status == IncidentStatus.open ||
      status == IncidentStatus.underInvestigation;

  String get typeLabel => switch (type) {
    IncidentType.disciplinary => 'Disciplinary',
    IncidentType.grievance => 'Grievance',
    IncidentType.healthAndSafety => 'Health & Safety',
    IncidentType.misconduct => 'Misconduct',
    IncidentType.other => 'Other',
  };
}

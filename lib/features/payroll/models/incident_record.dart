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

  factory IncidentRecord.fromJson(Map<String, dynamic> json) =>
      _$IncidentRecordFromJson(json);

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

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'incident_record.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_IncidentRecord _$IncidentRecordFromJson(Map<String, dynamic> json) =>
    _IncidentRecord(
      id: json['id'] as String,
      employeeId: json['employeeId'] as String,
      type: $enumDecode(_$IncidentTypeEnumMap, json['type']),
      title: json['title'] as String,
      description: json['description'] as String,
      incidentDate: DateTime.parse(json['incidentDate'] as String),
      status: $enumDecode(_$IncidentStatusEnumMap, json['status']),
      actionTaken: json['actionTaken'] as String?,
      resolvedAt: json['resolvedAt'] == null
          ? null
          : DateTime.parse(json['resolvedAt'] as String),
      resolvedByUserId: json['resolvedByUserId'] as String?,
      documentPaths: (json['documentPaths'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      reportedByUserId: json['reportedByUserId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$IncidentRecordToJson(_IncidentRecord instance) =>
    <String, dynamic>{
      'id': instance.id,
      'employeeId': instance.employeeId,
      'type': _$IncidentTypeEnumMap[instance.type]!,
      'title': instance.title,
      'description': instance.description,
      'incidentDate': instance.incidentDate.toIso8601String(),
      'status': _$IncidentStatusEnumMap[instance.status]!,
      'actionTaken': instance.actionTaken,
      'resolvedAt': instance.resolvedAt?.toIso8601String(),
      'resolvedByUserId': instance.resolvedByUserId,
      'documentPaths': instance.documentPaths,
      'reportedByUserId': instance.reportedByUserId,
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$IncidentTypeEnumMap = {
  IncidentType.disciplinary: 'disciplinary',
  IncidentType.grievance: 'grievance',
  IncidentType.healthAndSafety: 'healthAndSafety',
  IncidentType.misconduct: 'misconduct',
  IncidentType.other: 'other',
};

const _$IncidentStatusEnumMap = {
  IncidentStatus.open: 'open',
  IncidentStatus.underInvestigation: 'underInvestigation',
  IncidentStatus.resolved: 'resolved',
  IncidentStatus.closed: 'closed',
};

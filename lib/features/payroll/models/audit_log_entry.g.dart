// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audit_log_entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AuditLogEntry _$AuditLogEntryFromJson(Map<String, dynamic> json) =>
    _AuditLogEntry(
      id: json['id'] as String,
      entityType: json['entityType'] as String,
      entityId: json['entityId'] as String,
      action: json['action'] as String,
      changedByUserId: json['changedByUserId'] as String,
      changedByName: json['changedByName'] as String,
      beforeSnapshot: json['beforeSnapshot'] as Map<String, dynamic>?,
      afterSnapshot: json['afterSnapshot'] as Map<String, dynamic>?,
      description: json['description'] as String?,
      occurredAt: DateTime.parse(json['occurredAt'] as String),
    );

Map<String, dynamic> _$AuditLogEntryToJson(_AuditLogEntry instance) =>
    <String, dynamic>{
      'id': instance.id,
      'entityType': instance.entityType,
      'entityId': instance.entityId,
      'action': instance.action,
      'changedByUserId': instance.changedByUserId,
      'changedByName': instance.changedByName,
      'beforeSnapshot': instance.beforeSnapshot,
      'afterSnapshot': instance.afterSnapshot,
      'description': instance.description,
      'occurredAt': instance.occurredAt.toIso8601String(),
    };

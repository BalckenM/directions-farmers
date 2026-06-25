// coverage:ignore-file
import 'dart:convert';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'audit_log_entry.freezed.dart';
part 'audit_log_entry.g.dart';

@freezed
abstract class AuditLogEntry with _$AuditLogEntry {
  const factory AuditLogEntry({
    required String id,
    required String entityType,
    required String entityId,
    required String action,
    required String changedByUserId,
    required String changedByName,
    Map<String, dynamic>? beforeSnapshot,
    Map<String, dynamic>? afterSnapshot,
    String? description,
    required DateTime occurredAt,
  }) = _AuditLogEntry;

  factory AuditLogEntry.fromJson(Map<String, dynamic> json) {
    Map<String, dynamic>? parseJsonField(dynamic v) {
      if (v == null) return null;
      if (v is Map<String, dynamic>) return v;
      if (v is String && v.isNotEmpty) {
        try {
          return jsonDecode(v) as Map<String, dynamic>?;
        } catch (_) {
          return null;
        }
      }
      return null;
    }

    final now = DateTime.now().toIso8601String();
    return _$AuditLogEntryFromJson(<String, dynamic>{
      ...json,
      'id': json['id']?.toString() ?? '',
      'entityType': json['resource'] ?? json['entityType'] ?? '',
      'entityId': (json['resource_id'] ?? json['entityId'])?.toString() ?? '',
      'action': json['action'] ?? '',
      'changedByUserId':
          (json['user_id'] ?? json['changedByUserId'])?.toString() ?? '',
      'changedByName': json['changed_by_name'] ?? json['changedByName'] ?? '',
      'beforeSnapshot': parseJsonField(
        json['old_values'] ?? json['beforeSnapshot'],
      ),
      'afterSnapshot': parseJsonField(
        json['new_values'] ?? json['afterSnapshot'],
      ),
      'description': json['description'],
      'occurredAt': json['created_at'] ?? json['occurredAt'] ?? now,
    });
  }
}

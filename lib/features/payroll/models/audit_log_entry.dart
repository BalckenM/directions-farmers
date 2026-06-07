// coverage:ignore-file
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

  factory AuditLogEntry.fromJson(Map<String, dynamic> json) =>
      _$AuditLogEntryFromJson(json);
}

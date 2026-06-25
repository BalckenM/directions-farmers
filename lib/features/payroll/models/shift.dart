// coverage:ignore-file
import 'package:freezed_annotation/freezed_annotation.dart';

part 'shift.freezed.dart';
part 'shift.g.dart';

enum ShiftStatus { planned, inProgress, completed, cancelled }

@freezed
abstract class Shift with _$Shift {
  const factory Shift({
    required String id,
    required DateTime date,
    required String startTime,
    required String endTime,
    required List<String> employeeIds,
    required String taskCode,
    String? fieldOrArea,
    required ShiftStatus status,
    String? supervisorId,
    String? notes,
    required DateTime createdAt,
  }) = _Shift;

  factory Shift.fromJson(Map<String, dynamic> json) {
    final now = DateTime.now().toIso8601String();
    // Map backend snake_case → camelCase expected by generated code
    final rawIds = json['employee_ids'] ?? json['employeeIds'] ?? const [];
    final employeeIds = (rawIds is List)
        ? rawIds.map((e) => e.toString()).toList()
        : <String>[];
    final rawStatus = (json['status'] ?? 'planned').toString();
    final statusStr = switch (rawStatus.toLowerCase()) {
      'in_progress' || 'inprogress' || 'active' => 'inProgress',
      'completed' || 'done' => 'completed',
      'cancelled' || 'canceled' => 'cancelled',
      _ => 'planned',
    };
    return _$ShiftFromJson(<String, dynamic>{
      'id': json['id']?.toString() ?? '',
      'date': (json['date'] ?? now).toString(),
      'startTime': (json['start_time'] ?? json['startTime'] ?? '').toString(),
      'endTime': (json['end_time'] ?? json['endTime'] ?? '').toString(),
      'employeeIds': employeeIds,
      'taskCode': (json['task_code'] ?? json['taskCode'] ?? '').toString(),
      'fieldOrArea': (json['field_or_area'] ?? json['fieldOrArea'])?.toString(),
      'status': statusStr,
      'supervisorId': (json['supervisor_id'] ?? json['supervisorId'])
          ?.toString(),
      'notes': json['notes']?.toString(),
      'createdAt': (json['created_at'] ?? json['createdAt'] ?? now).toString(),
    });
  }
}

// coverage:ignore-file
import 'package:freezed_annotation/freezed_annotation.dart';

part 'task_assignment.freezed.dart';
part 'task_assignment.g.dart';

enum TaskAssignmentStatus { assigned, inProgress, completed, cancelled }

@freezed
abstract class TaskAssignment with _$TaskAssignment {
  const factory TaskAssignment({
    required String id,
    required String employeeId,
    required DateTime date,
    String? shiftId,
    required String payrollCode,
    required String description,
    String? fieldOrArea,
    required TaskAssignmentStatus status,
    String? notes,
    required DateTime createdAt,
  }) = _TaskAssignment;

  factory TaskAssignment.fromJson(Map<String, dynamic> json) {
    const statusMap = {
      'assigned': 'assigned',
      'in_progress': 'inProgress',
      'completed': 'completed',
      'cancelled': 'cancelled',
    };
    final now = DateTime.now().toIso8601String();
    return _$TaskAssignmentFromJson(<String, dynamic>{
      ...json,
      'id': json['id']?.toString() ?? '',
      'employeeId':
          (json['employee_id'] ?? json['employeeId'])?.toString() ?? '',
      'shiftId': (json['shift_id'] ?? json['shiftId'])?.toString(),
      'payrollCode': json['payroll_code'] ?? json['payrollCode'] ?? '',
      'fieldOrArea': json['field_or_area'] ?? json['fieldOrArea'],
      'status': statusMap[json['status']] ?? json['status'] ?? 'assigned',
      'createdAt': json['created_at'] ?? json['createdAt'] ?? now,
    });
  }
}

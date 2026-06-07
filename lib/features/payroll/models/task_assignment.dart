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

  factory TaskAssignment.fromJson(Map<String, dynamic> json) =>
      _$TaskAssignmentFromJson(json);
}

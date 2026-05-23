enum TaskAssignmentStatus { assigned, inProgress, completed, cancelled }

class TaskAssignment {
  const TaskAssignment({
    required this.id,
    required this.employeeId,
    required this.date,
    this.shiftId,
    required this.payrollCode,
    required this.description,
    this.fieldOrArea,
    required this.status,
    this.notes,
    required this.createdAt,
  });

  final String id;
  final String employeeId;
  final DateTime date;
  final String? shiftId;

  /// Payroll / task code, e.g. 'APPLE_PICK', 'GRAPE_PRUNE'.
  final String payrollCode;
  final String description;
  final String? fieldOrArea;
  final TaskAssignmentStatus status;
  final String? notes;
  final DateTime createdAt;

  TaskAssignment copyWith({
    String? id,
    String? employeeId,
    DateTime? date,
    String? shiftId,
    String? payrollCode,
    String? description,
    String? fieldOrArea,
    TaskAssignmentStatus? status,
    String? notes,
    DateTime? createdAt,
  }) {
    return TaskAssignment(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      date: date ?? this.date,
      shiftId: shiftId ?? this.shiftId,
      payrollCode: payrollCode ?? this.payrollCode,
      description: description ?? this.description,
      fieldOrArea: fieldOrArea ?? this.fieldOrArea,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

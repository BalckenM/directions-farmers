enum ShiftStatus { planned, inProgress, completed, cancelled }

class Shift {
  const Shift({
    required this.id,
    required this.date,
    required this.startTime,
    required this.endTime,
    required this.employeeIds,
    required this.taskCode,
    this.fieldOrArea,
    required this.status,
    this.supervisorId,
    this.notes,
    required this.createdAt,
  });

  final String id;
  final DateTime date;
  final String startTime; // 'HH:mm'
  final String endTime;   // 'HH:mm'
  final List<String> employeeIds;
  final String taskCode;
  final String? fieldOrArea;
  final ShiftStatus status;
  final String? supervisorId;
  final String? notes;
  final DateTime createdAt;

  Shift copyWith({
    String? id,
    DateTime? date,
    String? startTime,
    String? endTime,
    List<String>? employeeIds,
    String? taskCode,
    String? fieldOrArea,
    ShiftStatus? status,
    String? supervisorId,
    String? notes,
    DateTime? createdAt,
  }) {
    return Shift(
      id: id ?? this.id,
      date: date ?? this.date,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      employeeIds: employeeIds ?? this.employeeIds,
      taskCode: taskCode ?? this.taskCode,
      fieldOrArea: fieldOrArea ?? this.fieldOrArea,
      status: status ?? this.status,
      supervisorId: supervisorId ?? this.supervisorId,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

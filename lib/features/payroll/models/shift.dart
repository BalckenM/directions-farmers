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

  factory Shift.fromJson(Map<String, dynamic> json) => Shift(
    id: json['id'] as String,
    date: DateTime.parse(json['date'] as String),
    startTime: json['startTime'] as String,
    endTime: json['endTime'] as String,
    employeeIds: (json['employeeIds'] as List<dynamic>).cast<String>(),
    taskCode: json['taskCode'] as String,
    fieldOrArea: json['fieldOrArea'] as String?,
    status: ShiftStatus.values.byName(json['status'] as String),
    supervisorId: json['supervisorId'] as String?,
    notes: json['notes'] as String?,
    createdAt: DateTime.parse(json['createdAt'] as String),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'date': date.toIso8601String(),
    'startTime': startTime,
    'endTime': endTime,
    'employeeIds': employeeIds,
    'taskCode': taskCode,
    'fieldOrArea': fieldOrArea,
    'status': status.name,
    'supervisorId': supervisorId,
    'notes': notes,
    'createdAt': createdAt.toIso8601String(),
  };
}

enum AttendanceMethod { manual, gps, qrCode, biometric }

enum AttendanceStatus { present, absent, late, onLeave, halfDay, publicHoliday }

class AttendanceRecord {
  const AttendanceRecord({
    required this.id,
    required this.employeeId,
    required this.date,
    required this.status,
    this.clockInTime,
    this.clockOutTime,
    required this.recordedByUserId,
    required this.method,
    this.hoursWorked,
    this.overtimeHours,
    this.shiftId,
    this.leaveRequestId,
    this.notes,
    required this.createdAt,
  });

  final String id;
  final String employeeId;
  final DateTime date;
  final AttendanceStatus status;
  final String? clockInTime;   // 'HH:mm'
  final String? clockOutTime;  // 'HH:mm'
  final String recordedByUserId;
  final AttendanceMethod method;
  final double? hoursWorked;
  final double? overtimeHours;
  final String? shiftId;
  final String? leaveRequestId;
  final String? notes;
  final DateTime createdAt;

  bool get isPresent => status == AttendanceStatus.present ||
      status == AttendanceStatus.late ||
      status == AttendanceStatus.halfDay;

  AttendanceRecord copyWith({
    String? id,
    String? employeeId,
    DateTime? date,
    AttendanceStatus? status,
    String? clockInTime,
    String? clockOutTime,
    String? recordedByUserId,
    AttendanceMethod? method,
    double? hoursWorked,
    double? overtimeHours,
    String? shiftId,
    String? leaveRequestId,
    String? notes,
    DateTime? createdAt,
  }) {
    return AttendanceRecord(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      date: date ?? this.date,
      status: status ?? this.status,
      clockInTime: clockInTime ?? this.clockInTime,
      clockOutTime: clockOutTime ?? this.clockOutTime,
      recordedByUserId: recordedByUserId ?? this.recordedByUserId,
      method: method ?? this.method,
      hoursWorked: hoursWorked ?? this.hoursWorked,
      overtimeHours: overtimeHours ?? this.overtimeHours,
      shiftId: shiftId ?? this.shiftId,
      leaveRequestId: leaveRequestId ?? this.leaveRequestId,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

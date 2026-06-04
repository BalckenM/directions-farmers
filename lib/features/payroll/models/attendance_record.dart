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
    this.nightShiftHours,
    this.shiftId,
    this.leaveRequestId,
    this.notes,
    required this.createdAt,
  });

  final String id;
  final String employeeId;
  final DateTime date;
  final AttendanceStatus status;
  final String? clockInTime; // 'HH:mm'
  final String? clockOutTime; // 'HH:mm'
  final String recordedByUserId;
  final AttendanceMethod method;
  final double? hoursWorked;
  final double? overtimeHours;

  /// Hours worked between 18:00 and 06:00 — attracts BCEA §17 night-shift premium (10%).
  final double? nightShiftHours;
  final String? shiftId;
  final String? leaveRequestId;
  final String? notes;
  final DateTime createdAt;

  bool get isPresent =>
      status == AttendanceStatus.present ||
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
    double? nightShiftHours,
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
      nightShiftHours: nightShiftHours ?? this.nightShiftHours,
      shiftId: shiftId ?? this.shiftId,
      leaveRequestId: leaveRequestId ?? this.leaveRequestId,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) =>
      AttendanceRecord(
        id: json['id'] as String,
        employeeId: json['employeeId'] as String,
        date: DateTime.parse(json['date'] as String),
        status: AttendanceStatus.values.byName(json['status'] as String),
        clockInTime: json['clockInTime'] as String?,
        clockOutTime: json['clockOutTime'] as String?,
        recordedByUserId: json['recordedByUserId'] as String,
        method: AttendanceMethod.values.byName(json['method'] as String),
        hoursWorked: (json['hoursWorked'] as num?)?.toDouble(),
        overtimeHours: (json['overtimeHours'] as num?)?.toDouble(),
        nightShiftHours: (json['nightShiftHours'] as num?)?.toDouble(),
        shiftId: json['shiftId'] as String?,
        leaveRequestId: json['leaveRequestId'] as String?,
        notes: json['notes'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'employeeId': employeeId,
    'date': date.toIso8601String(),
    'status': status.name,
    'clockInTime': clockInTime,
    'clockOutTime': clockOutTime,
    'recordedByUserId': recordedByUserId,
    'method': method.name,
    'hoursWorked': hoursWorked,
    'overtimeHours': overtimeHours,
    'nightShiftHours': nightShiftHours,
    'shiftId': shiftId,
    'leaveRequestId': leaveRequestId,
    'notes': notes,
    'createdAt': createdAt.toIso8601String(),
  };
}

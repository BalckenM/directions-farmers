// coverage:ignore-file
import 'package:freezed_annotation/freezed_annotation.dart';

part 'attendance_record.freezed.dart';
part 'attendance_record.g.dart';

enum AttendanceMethod { manual, gps, qrCode, biometric }

enum AttendanceStatus { present, absent, late, onLeave, halfDay, publicHoliday }

@freezed
abstract class AttendanceRecord with _$AttendanceRecord {
  const AttendanceRecord._();

  const factory AttendanceRecord({
    required String id,
    required String employeeId,
    required DateTime date,
    required AttendanceStatus status,
    String? clockInTime,
    String? clockOutTime,
    required String recordedByUserId,
    required AttendanceMethod method,
    double? hoursWorked,
    double? overtimeHours,
    double? nightShiftHours,
    String? shiftId,
    String? leaveRequestId,
    String? notes,
    required DateTime createdAt,
  }) = _AttendanceRecord;

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) {
    // Map backend check_in_method values to Flutter AttendanceMethod enum names
    final rawMethod = (json['check_in_method'] ?? json['method'] ?? 'manual')
        .toString()
        .toLowerCase();
    final methodStr = switch (rawMethod) {
      'qr_code' || 'qr' => 'qrCode',
      'biometric' => 'biometric',
      'gps' => 'gps',
      _ => 'manual',
    };
    final rawStatus = (json['status'] ?? 'present').toString().toLowerCase();
    final statusStr = switch (rawStatus) {
      'present' => 'present',
      'absent' => 'absent',
      'late' => 'late',
      'on_leave' || 'onleave' || 'on leave' => 'onLeave',
      'half_day' || 'halfday' || 'half day' => 'halfDay',
      'public_holiday' ||
      'publicholiday' ||
      'public holiday' => 'publicHoliday',
      // 'approved' is not an attendance status — treat as present
      _ => 'present',
    };
    final now = DateTime.now().toIso8601String();
    return _$AttendanceRecordFromJson(<String, dynamic>{
      ...json,
      'id': json['id']?.toString() ?? '',
      'employeeId':
          (json['employee_id'] ?? json['employeeId'])?.toString() ?? '',
      'date': json['date'] ?? json['attendance_date'] ?? now,
      'status': statusStr,
      'clockInTime': json['check_in'] ?? json['clockInTime'],
      'clockOutTime': json['check_out'] ?? json['clockOutTime'],
      'recordedByUserId':
          (json['created_by'] ??
                  json['recorded_by'] ??
                  json['recordedByUserId'])
              ?.toString() ??
          '',
      'method': methodStr,
      'hoursWorked':
          (json['hours_worked'] as num?)?.toDouble() ??
          (json['hoursWorked'] as num?)?.toDouble(),
      'overtimeHours':
          (json['overtime_hours'] as num?)?.toDouble() ??
          (json['overtimeHours'] as num?)?.toDouble(),
      'nightShiftHours':
          (json['night_shift_hours'] as num?)?.toDouble() ??
          (json['nightShiftHours'] as num?)?.toDouble(),
      'shiftId': json['shift_id']?.toString() ?? json['shiftId']?.toString(),
      'leaveRequestId':
          json['leave_request_id']?.toString() ??
          json['leaveRequestId']?.toString(),
      'createdAt': json['created_at'] ?? json['createdAt'] ?? now,
    });
  }

  bool get isPresent =>
      status == AttendanceStatus.present ||
      status == AttendanceStatus.late ||
      status == AttendanceStatus.halfDay;
}

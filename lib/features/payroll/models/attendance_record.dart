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

  factory AttendanceRecord.fromJson(Map<String, dynamic> json) =>
      _$AttendanceRecordFromJson(json);

  bool get isPresent =>
      status == AttendanceStatus.present ||
      status == AttendanceStatus.late ||
      status == AttendanceStatus.halfDay;
}

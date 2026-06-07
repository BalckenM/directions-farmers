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

  factory Shift.fromJson(Map<String, dynamic> json) => _$ShiftFromJson(json);
}

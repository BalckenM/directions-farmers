// coverage:ignore-file
import 'package:freezed_annotation/freezed_annotation.dart';

part 'leave_type.freezed.dart';
part 'leave_type.g.dart';

@freezed
abstract class LeaveType with _$LeaveType {
  const factory LeaveType({
    required String id,
    required String code,
    required String name,
    required double annualEntitlementDays,
    required bool isPaid,
    required bool requiresApproval,
    String? colorHex,
    String? description,
  }) = _LeaveType;

  factory LeaveType.fromJson(Map<String, dynamic> json) =>
      _$LeaveTypeFromJson(json);
}

// coverage:ignore-file
import 'package:freezed_annotation/freezed_annotation.dart';

part 'leave_balance.freezed.dart';
part 'leave_balance.g.dart';

@freezed
abstract class LeaveBalance with _$LeaveBalance {
  const LeaveBalance._();

  const factory LeaveBalance({
    required String id,
    required String employeeId,
    required String leaveTypeId,
    required String leaveTypeCode,
    required String leaveTypeName,
    required double totalEntitled,
    required double taken,
    required double pending,
    required DateTime asOfDate,
  }) = _LeaveBalance;

  factory LeaveBalance.fromJson(Map<String, dynamic> json) =>
      _$LeaveBalanceFromJson(json);

  double get remaining => totalEntitled - taken - pending;
}

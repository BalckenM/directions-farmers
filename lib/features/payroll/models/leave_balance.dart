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

  factory LeaveBalance.fromJson(Map<String, dynamic> json) {
    double numOf(dynamic v) => v == null
        ? 0.0
        : (v is num ? v.toDouble() : double.tryParse(v.toString()) ?? 0.0);
    final now = DateTime.now().toIso8601String();
    return _$LeaveBalanceFromJson(<String, dynamic>{
      'id': json['id']?.toString() ?? '',
      'employeeId':
          (json['employee_id'] ?? json['employeeId'])?.toString() ?? '',
      'leaveTypeId':
          (json['leave_type_id'] ?? json['leaveTypeId'])?.toString() ?? '',
      'leaveTypeCode':
          (json['leave_type_code'] ??
                  json['leaveTypeCode'] ??
                  json['code'] ??
                  '')
              .toString(),
      'leaveTypeName':
          (json['leave_type_name'] ??
                  json['leaveTypeName'] ??
                  json['name'] ??
                  '')
              .toString(),
      'totalEntitled': numOf(
        json['total_entitled'] ?? json['totalEntitled'] ?? json['entitled'],
      ),
      'taken': numOf(json['taken'] ?? json['days_taken']),
      'pending': numOf(json['pending'] ?? json['pending_days']),
      'asOfDate':
          (json['as_of_date'] ??
                  json['asOfDate'] ??
                  json['updated_at'] ??
                  json['updatedAt'] ??
                  now)
              .toString(),
    });
  }

  double get remaining => totalEntitled - taken - pending;
}

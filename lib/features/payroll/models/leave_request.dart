// coverage:ignore-file
import 'package:freezed_annotation/freezed_annotation.dart';

part 'leave_request.freezed.dart';
part 'leave_request.g.dart';

enum LeaveStatus { pending, approved, rejected, cancelled }

@freezed
abstract class LeaveRequest with _$LeaveRequest {
  const LeaveRequest._();

  const factory LeaveRequest({
    required String id,
    required String employeeId,
    required String leaveTypeId,
    required DateTime startDate,
    required DateTime endDate,
    required double daysRequested,
    required String reason,
    required LeaveStatus status,
    String? reviewedByUserId,
    DateTime? reviewedAt,
    String? rejectionReason,
    required DateTime submittedAt,
  }) = _LeaveRequest;

  factory LeaveRequest.fromJson(Map<String, dynamic> json) =>
      _$LeaveRequestFromJson(<String, dynamic>{
        ...json,
        'reason': (json['reason'] as String?) ?? '',
        'leaveTypeId': (json['leaveTypeId'] as String?) ?? '',
        'employeeId': (json['employeeId'] as String?) ?? '',
        'id': (json['id'] as String?) ?? '',
      });

  bool get isPending => status == LeaveStatus.pending;
  bool get isApproved => status == LeaveStatus.approved;
}

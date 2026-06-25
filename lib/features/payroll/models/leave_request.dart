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

  factory LeaveRequest.fromJson(
    Map<String, dynamic> json,
  ) => _$LeaveRequestFromJson(<String, dynamic>{
    ...json,
    'id': json['id']?.toString() ?? '',
    'employeeId': (json['employee_id'] ?? json['employeeId'])?.toString() ?? '',
    'leaveTypeId':
        (json['leave_type_id'] ?? json['leaveTypeId'])?.toString() ?? '',
    'startDate': json['start_date'] ?? json['startDate'],
    'endDate': json['end_date'] ?? json['endDate'],
    'daysRequested': (() {
      final v = json['days'] ?? json['daysRequested'];
      if (v == null) return 0.0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0.0;
    })(),
    'reason': (json['reason'] as String?) ?? '',
    'reviewedByUserId':
        (json['approved_by'] ?? json['reviewed_by'] ?? json['reviewedByUserId'])
            ?.toString(),
    'reviewedAt': json['reviewed_at'] ?? json['reviewedAt'],
    'submittedAt':
        json['created_at'] ??
        json['submittedAt'] ??
        DateTime.now().toIso8601String(),
  });

  bool get isPending => status == LeaveStatus.pending;
  bool get isApproved => status == LeaveStatus.approved;
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leave_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_LeaveRequest _$LeaveRequestFromJson(Map<String, dynamic> json) =>
    _LeaveRequest(
      id: json['id'] as String,
      employeeId: json['employeeId'] as String,
      leaveTypeId: json['leaveTypeId'] as String,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      daysRequested: (json['daysRequested'] as num).toDouble(),
      reason: json['reason'] as String,
      status: $enumDecode(_$LeaveStatusEnumMap, json['status']),
      reviewedByUserId: json['reviewedByUserId'] as String?,
      reviewedAt: json['reviewedAt'] == null
          ? null
          : DateTime.parse(json['reviewedAt'] as String),
      rejectionReason: json['rejectionReason'] as String?,
      submittedAt: DateTime.parse(json['submittedAt'] as String),
    );

Map<String, dynamic> _$LeaveRequestToJson(_LeaveRequest instance) =>
    <String, dynamic>{
      'id': instance.id,
      'employeeId': instance.employeeId,
      'leaveTypeId': instance.leaveTypeId,
      'startDate': instance.startDate.toIso8601String(),
      'endDate': instance.endDate.toIso8601String(),
      'daysRequested': instance.daysRequested,
      'reason': instance.reason,
      'status': _$LeaveStatusEnumMap[instance.status]!,
      'reviewedByUserId': instance.reviewedByUserId,
      'reviewedAt': instance.reviewedAt?.toIso8601String(),
      'rejectionReason': instance.rejectionReason,
      'submittedAt': instance.submittedAt.toIso8601String(),
    };

const _$LeaveStatusEnumMap = {
  LeaveStatus.pending: 'pending',
  LeaveStatus.approved: 'approved',
  LeaveStatus.rejected: 'rejected',
  LeaveStatus.cancelled: 'cancelled',
};

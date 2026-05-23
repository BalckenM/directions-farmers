enum LeaveStatus { pending, approved, rejected, cancelled }

class LeaveRequest {
  const LeaveRequest({
    required this.id,
    required this.employeeId,
    required this.leaveTypeId,
    required this.startDate,
    required this.endDate,
    required this.daysRequested,
    required this.reason,
    required this.status,
    this.reviewedByUserId,
    this.reviewedAt,
    this.rejectionReason,
    required this.submittedAt,
  });

  final String id;
  final String employeeId;
  final String leaveTypeId;
  final DateTime startDate;
  final DateTime endDate;
  final double daysRequested;
  final String reason;
  final LeaveStatus status;
  final String? reviewedByUserId;
  final DateTime? reviewedAt;
  final String? rejectionReason;
  final DateTime submittedAt;

  bool get isPending => status == LeaveStatus.pending;
  bool get isApproved => status == LeaveStatus.approved;

  factory LeaveRequest.fromJson(Map<String, dynamic> json) => LeaveRequest(
        id: json['id'] as String,
        employeeId: json['employeeId'] as String,
        leaveTypeId: json['leaveTypeId'] as String,
        startDate: DateTime.parse(json['startDate'] as String),
        endDate: DateTime.parse(json['endDate'] as String),
        daysRequested: (json['daysRequested'] as num).toDouble(),
        reason: json['reason'] as String,
        status: LeaveStatus.values.byName(json['status'] as String),
        reviewedByUserId: json['reviewedByUserId'] as String?,
        reviewedAt: json['reviewedAt'] != null ? DateTime.parse(json['reviewedAt'] as String) : null,
        rejectionReason: json['rejectionReason'] as String?,
        submittedAt: DateTime.parse(json['submittedAt'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'employeeId': employeeId,
        'leaveTypeId': leaveTypeId,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate.toIso8601String(),
        'daysRequested': daysRequested,
        'reason': reason,
        'status': status.name,
        'reviewedByUserId': reviewedByUserId,
        'reviewedAt': reviewedAt?.toIso8601String(),
        'rejectionReason': rejectionReason,
        'submittedAt': submittedAt.toIso8601String(),
      };

  LeaveRequest copyWith({
    String? id,
    String? employeeId,
    String? leaveTypeId,
    DateTime? startDate,
    DateTime? endDate,
    double? daysRequested,
    String? reason,
    LeaveStatus? status,
    String? reviewedByUserId,
    DateTime? reviewedAt,
    String? rejectionReason,
    DateTime? submittedAt,
  }) {
    return LeaveRequest(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      leaveTypeId: leaveTypeId ?? this.leaveTypeId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      daysRequested: daysRequested ?? this.daysRequested,
      reason: reason ?? this.reason,
      status: status ?? this.status,
      reviewedByUserId: reviewedByUserId ?? this.reviewedByUserId,
      reviewedAt: reviewedAt ?? this.reviewedAt,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      submittedAt: submittedAt ?? this.submittedAt,
    );
  }
}

class LeaveBalance {
  const LeaveBalance({
    required this.id,
    required this.employeeId,
    required this.leaveTypeId,
    required this.leaveTypeCode,
    required this.leaveTypeName,
    required this.totalEntitled,
    required this.taken,
    required this.pending,
    required this.asOfDate,
  });

  final String id;
  final String employeeId;
  final String leaveTypeId;
  final String leaveTypeCode;
  final String leaveTypeName;
  final double totalEntitled;
  final double taken;
  final double pending;
  final DateTime asOfDate;

  double get remaining => totalEntitled - taken - pending;

  factory LeaveBalance.fromJson(Map<String, dynamic> json) => LeaveBalance(
        id: json['id'] as String,
        employeeId: json['employeeId'] as String,
        leaveTypeId: json['leaveTypeId'] as String,
        leaveTypeCode: json['leaveTypeCode'] as String,
        leaveTypeName: json['leaveTypeName'] as String,
        totalEntitled: (json['totalEntitled'] as num).toDouble(),
        taken: (json['taken'] as num).toDouble(),
        pending: (json['pending'] as num).toDouble(),
        asOfDate: DateTime.parse(json['asOfDate'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'employeeId': employeeId,
        'leaveTypeId': leaveTypeId,
        'leaveTypeCode': leaveTypeCode,
        'leaveTypeName': leaveTypeName,
        'totalEntitled': totalEntitled,
        'taken': taken,
        'pending': pending,
        'asOfDate': asOfDate.toIso8601String(),
      };

  LeaveBalance copyWith({
    String? id,
    String? employeeId,
    String? leaveTypeId,
    String? leaveTypeCode,
    String? leaveTypeName,
    double? totalEntitled,
    double? taken,
    double? pending,
    DateTime? asOfDate,
  }) {
    return LeaveBalance(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      leaveTypeId: leaveTypeId ?? this.leaveTypeId,
      leaveTypeCode: leaveTypeCode ?? this.leaveTypeCode,
      leaveTypeName: leaveTypeName ?? this.leaveTypeName,
      totalEntitled: totalEntitled ?? this.totalEntitled,
      taken: taken ?? this.taken,
      pending: pending ?? this.pending,
      asOfDate: asOfDate ?? this.asOfDate,
    );
  }
}

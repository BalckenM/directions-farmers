// coverage:ignore-file
import 'package:freezed_annotation/freezed_annotation.dart';

part 'worker_dispute.freezed.dart';
part 'worker_dispute.g.dart';

enum DisputeType {
  payDiscrepancy,
  leaveBalance,
  overtimePay,
  deductionQuery,
  other,
}

extension DisputeTypeX on DisputeType {
  String get label => switch (this) {
    DisputeType.payDiscrepancy => 'Pay Discrepancy',
    DisputeType.leaveBalance => 'Leave Balance',
    DisputeType.overtimePay => 'Overtime Pay',
    DisputeType.deductionQuery => 'Deduction Query',
    DisputeType.other => 'Other',
  };
}

enum DisputeStatus { open, underReview, resolved, dismissed }

extension DisputeStatusX on DisputeStatus {
  String get label => switch (this) {
    DisputeStatus.open => 'Open',
    DisputeStatus.underReview => 'Under Review',
    DisputeStatus.resolved => 'Resolved',
    DisputeStatus.dismissed => 'Dismissed',
  };
  bool get isClosed =>
      this == DisputeStatus.resolved || this == DisputeStatus.dismissed;
}

@freezed
abstract class WorkerDispute with _$WorkerDispute {
  const WorkerDispute._();

  const factory WorkerDispute({
    required String id,
    required String employeeId,
    required String employeeName,
    required DisputeType type,
    required DisputeStatus status,
    required String description,
    required DateTime filedAt,
    String? relatedPayRunId,
    String? relatedPayslipId,
    DateTime? resolvedAt,
    String? resolvedBy,
    String? resolutionNote,
  }) = _WorkerDispute;

  factory WorkerDispute.fromJson(Map<String, dynamic> json) {
    const typeMap = {
      'pay_discrepancy': 'payDiscrepancy',
      'leave_balance': 'leaveBalance',
      'overtime_pay': 'overtimePay',
      'deduction_query': 'deductionQuery',
      'other': 'other',
    };
    const statusMap = {
      'open': 'open',
      'under_review': 'underReview',
      'resolved': 'resolved',
      'dismissed': 'dismissed',
    };
    final now = DateTime.now().toIso8601String();
    final user = json['employee'] is Map
        ? (json['employee'] as Map<String, dynamic>)['user']
              as Map<String, dynamic>?
        : null;
    final empName =
        user?['name'] as String? ??
        json['employee_name'] as String? ??
        json['employeeName'] as String? ??
        '';
    return _$WorkerDisputeFromJson(<String, dynamic>{
      ...json,
      'id': json['id']?.toString() ?? '',
      'employeeId':
          (json['employee_id'] ?? json['employeeId'])?.toString() ?? '',
      'employeeName': empName,
      'type': typeMap[json['type']] ?? json['type'] ?? 'other',
      'status': statusMap[json['status']] ?? json['status'] ?? 'open',
      'filedAt': json['filed_at'] ?? json['filedAt'] ?? now,
      'relatedPayRunId': (json['related_pay_run_id'] ?? json['relatedPayRunId'])
          ?.toString(),
      'relatedPayslipId':
          (json['related_payslip_id'] ?? json['relatedPayslipId'])?.toString(),
      'resolvedAt': json['resolved_at'] ?? json['resolvedAt'],
      'resolvedBy': (json['resolved_by_id'] ?? json['resolvedBy'])?.toString(),
      'resolutionNote': json['resolution_note'] ?? json['resolutionNote'],
    });
  }

  bool get isClosed => status.isClosed;
}

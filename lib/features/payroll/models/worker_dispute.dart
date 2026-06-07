// coverage:ignore-file
import 'package:freezed_annotation/freezed_annotation.dart';

part 'worker_dispute.freezed.dart';
part 'worker_dispute.g.dart';

enum DisputeType { payDiscrepancy, leaveBalance, overtimePay, deductionQuery, other }

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

  factory WorkerDispute.fromJson(Map<String, dynamic> json) =>
      _$WorkerDisputeFromJson(json);

  bool get isClosed => status.isClosed;
}

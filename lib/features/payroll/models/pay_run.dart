// coverage:ignore-file
import 'package:freezed_annotation/freezed_annotation.dart';

part 'pay_run.freezed.dart';
part 'pay_run.g.dart';

enum PayRunStatus {
  draft,
  calculated,
  pendingApproval,
  approved,
  disbursed,
  cancelled,
}

@freezed
abstract class ApprovalEntry with _$ApprovalEntry {
  const factory ApprovalEntry({
    required String userId,
    required String displayName,
    required String role,
    required DateTime decidedAt,
    required bool approved,
    String? comment,
  }) = _ApprovalEntry;

  factory ApprovalEntry.fromJson(Map<String, dynamic> json) =>
      _$ApprovalEntryFromJson(json);
}

@freezed
abstract class PayslipLineItem with _$PayslipLineItem {
  const factory PayslipLineItem({
    required String code,
    required String description,
    required double quantity,
    required double rate,
    required double amount,
    @Default(false) bool isStatutory,
  }) = _PayslipLineItem;

  factory PayslipLineItem.fromJson(Map<String, dynamic> json) =>
      _$PayslipLineItemFromJson(json);
}

@freezed
abstract class PayRun with _$PayRun {
  const PayRun._();

  const factory PayRun({
    required String id,
    required String payGroupId,
    required DateTime periodStart,
    required DateTime periodEnd,
    required DateTime payDate,
    required PayRunStatus status,
    required double totalGross,
    required double totalDeductions,
    required double totalNet,
    required int employeeCount,
    String? approvedByUserId,
    DateTime? approvedAt,
    DateTime? disbursedAt,
    String? notes,
    required List<String> complianceAlertIds,
    required List<PayslipLineItem> lineItems,
    @Default(0.0) double sdlContribution,
    @Default(0.0) double etiCredit,
    @Default(0.0) double totalCoidaContribution,
    @Default([]) List<ApprovalEntry> approvalChain,
    @Default(1) int requiredApprovers,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _PayRun;

  factory PayRun.fromJson(Map<String, dynamic> json) {
    // Map backend status strings to Flutter PayRunStatus enum names.
    // Backend: draft | completed | approved | paid | cancelled | rejected
    // Flutter: draft | calculated | pendingApproval | approved | disbursed | cancelled
    const statusMap = <String, String>{
      'draft': 'draft',
      'calculated': 'calculated', // pass-through if set by Flutter
      'completed': 'pendingApproval', // backend 'completed' = awaiting approval
      'approved': 'approved',
      'paid': 'disbursed',
      'cancelled': 'cancelled',
      'rejected': 'cancelled', // map rejected to cancelled in Flutter UI
    };
    final rawStatus = json['status'] as String? ?? 'draft';

    double numOf(dynamic v) => v == null
        ? 0.0
        : (v is num ? v.toDouble() : double.tryParse(v.toString()) ?? 0.0);

    final totalGross = numOf(json['total_gross'] ?? json['totalGross']);
    final totalNet = numOf(json['total_net'] ?? json['totalNet']);
    final rawDeductions = numOf(
      json['total_deductions'] ?? json['totalDeductions'],
    );
    final totalDeductions = rawDeductions > 0
        ? rawDeductions
        : totalGross - totalNet;

    final now = DateTime.now().toIso8601String();

    return _$PayRunFromJson(<String, dynamic>{
      ...json,
      'id': json['id']?.toString() ?? '',
      'payGroupId':
          (json['payroll_group_id'] ?? json['payGroupId'])?.toString() ?? '',
      'periodStart': json['period_start'] ?? json['periodStart'] ?? now,
      'periodEnd': json['period_end'] ?? json['periodEnd'] ?? now,
      'payDate': json['pay_date'] ?? json['payDate'] ?? now,
      'status': statusMap[rawStatus] ?? rawStatus,
      'totalGross': totalGross,
      'totalDeductions': totalDeductions,
      'totalNet': totalNet,
      'employeeCount':
          json['worker_count'] as int? ??
          json['employee_count'] as int? ??
          json['employeeCount'] as int? ??
          0,
      'complianceAlertIds': json['complianceAlertIds'] ?? const [],
      'lineItems': json['lineItems'] ?? const [],
      'createdAt': json['created_at'] ?? json['createdAt'] ?? now,
      'updatedAt':
          json['updated_at'] ?? json['updatedAt'] ?? json['created_at'] ?? now,
    });
  }

  bool get isFullyApproved =>
      approvalChain.where((e) => e.approved).length >= requiredApprovers;
  bool get isDisbursed => status == PayRunStatus.disbursed;
  bool get isEditable =>
      status == PayRunStatus.draft || status == PayRunStatus.calculated;
}

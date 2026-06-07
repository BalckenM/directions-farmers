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

  factory PayRun.fromJson(Map<String, dynamic> json) =>
      _$PayRunFromJson(json);

  bool get isFullyApproved =>
      approvalChain.where((e) => e.approved).length >= requiredApprovers;
  bool get isDisbursed => status == PayRunStatus.disbursed;
  bool get isEditable =>
      status == PayRunStatus.draft || status == PayRunStatus.calculated;
}

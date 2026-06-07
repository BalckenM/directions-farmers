// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pay_run.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ApprovalEntry _$ApprovalEntryFromJson(Map<String, dynamic> json) =>
    _ApprovalEntry(
      userId: json['userId'] as String,
      displayName: json['displayName'] as String,
      role: json['role'] as String,
      decidedAt: DateTime.parse(json['decidedAt'] as String),
      approved: json['approved'] as bool,
      comment: json['comment'] as String?,
    );

Map<String, dynamic> _$ApprovalEntryToJson(_ApprovalEntry instance) =>
    <String, dynamic>{
      'userId': instance.userId,
      'displayName': instance.displayName,
      'role': instance.role,
      'decidedAt': instance.decidedAt.toIso8601String(),
      'approved': instance.approved,
      'comment': instance.comment,
    };

_PayslipLineItem _$PayslipLineItemFromJson(Map<String, dynamic> json) =>
    _PayslipLineItem(
      code: json['code'] as String,
      description: json['description'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      rate: (json['rate'] as num).toDouble(),
      amount: (json['amount'] as num).toDouble(),
      isStatutory: json['isStatutory'] as bool? ?? false,
    );

Map<String, dynamic> _$PayslipLineItemToJson(_PayslipLineItem instance) =>
    <String, dynamic>{
      'code': instance.code,
      'description': instance.description,
      'quantity': instance.quantity,
      'rate': instance.rate,
      'amount': instance.amount,
      'isStatutory': instance.isStatutory,
    };

_PayRun _$PayRunFromJson(Map<String, dynamic> json) => _PayRun(
  id: json['id'] as String,
  payGroupId: json['payGroupId'] as String,
  periodStart: DateTime.parse(json['periodStart'] as String),
  periodEnd: DateTime.parse(json['periodEnd'] as String),
  payDate: DateTime.parse(json['payDate'] as String),
  status: $enumDecode(_$PayRunStatusEnumMap, json['status']),
  totalGross: (json['totalGross'] as num).toDouble(),
  totalDeductions: (json['totalDeductions'] as num).toDouble(),
  totalNet: (json['totalNet'] as num).toDouble(),
  employeeCount: (json['employeeCount'] as num).toInt(),
  approvedByUserId: json['approvedByUserId'] as String?,
  approvedAt: json['approvedAt'] == null
      ? null
      : DateTime.parse(json['approvedAt'] as String),
  disbursedAt: json['disbursedAt'] == null
      ? null
      : DateTime.parse(json['disbursedAt'] as String),
  notes: json['notes'] as String?,
  complianceAlertIds: (json['complianceAlertIds'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  lineItems: (json['lineItems'] as List<dynamic>)
      .map((e) => PayslipLineItem.fromJson(e as Map<String, dynamic>))
      .toList(),
  sdlContribution: (json['sdlContribution'] as num?)?.toDouble() ?? 0.0,
  etiCredit: (json['etiCredit'] as num?)?.toDouble() ?? 0.0,
  totalCoidaContribution:
      (json['totalCoidaContribution'] as num?)?.toDouble() ?? 0.0,
  approvalChain:
      (json['approvalChain'] as List<dynamic>?)
          ?.map((e) => ApprovalEntry.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  requiredApprovers: (json['requiredApprovers'] as num?)?.toInt() ?? 1,
  createdAt: DateTime.parse(json['createdAt'] as String),
  updatedAt: DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$PayRunToJson(_PayRun instance) => <String, dynamic>{
  'id': instance.id,
  'payGroupId': instance.payGroupId,
  'periodStart': instance.periodStart.toIso8601String(),
  'periodEnd': instance.periodEnd.toIso8601String(),
  'payDate': instance.payDate.toIso8601String(),
  'status': _$PayRunStatusEnumMap[instance.status]!,
  'totalGross': instance.totalGross,
  'totalDeductions': instance.totalDeductions,
  'totalNet': instance.totalNet,
  'employeeCount': instance.employeeCount,
  'approvedByUserId': instance.approvedByUserId,
  'approvedAt': instance.approvedAt?.toIso8601String(),
  'disbursedAt': instance.disbursedAt?.toIso8601String(),
  'notes': instance.notes,
  'complianceAlertIds': instance.complianceAlertIds,
  'lineItems': instance.lineItems,
  'sdlContribution': instance.sdlContribution,
  'etiCredit': instance.etiCredit,
  'totalCoidaContribution': instance.totalCoidaContribution,
  'approvalChain': instance.approvalChain,
  'requiredApprovers': instance.requiredApprovers,
  'createdAt': instance.createdAt.toIso8601String(),
  'updatedAt': instance.updatedAt.toIso8601String(),
};

const _$PayRunStatusEnumMap = {
  PayRunStatus.draft: 'draft',
  PayRunStatus.calculated: 'calculated',
  PayRunStatus.pendingApproval: 'pendingApproval',
  PayRunStatus.approved: 'approved',
  PayRunStatus.disbursed: 'disbursed',
  PayRunStatus.cancelled: 'cancelled',
};

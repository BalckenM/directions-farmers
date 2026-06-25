// coverage:ignore-file
import 'package:freezed_annotation/freezed_annotation.dart';

part 'compliance_alert.freezed.dart';
part 'compliance_alert.g.dart';

enum ComplianceSeverity { critical, warning, info }

@freezed
abstract class ComplianceAlert with _$ComplianceAlert {
  const ComplianceAlert._();

  const factory ComplianceAlert({
    required String id,
    required String code,
    required String title,
    required String description,
    required ComplianceSeverity severity,
    String? employeeId,
    String? payRunId,
    required bool isResolved,
    String? resolvedByUserId,
    DateTime? resolvedAt,
    String? resolution,
    required DateTime raisedAt,
  }) = _ComplianceAlert;

  factory ComplianceAlert.fromJson(Map<String, dynamic> json) {
    final now = DateTime.now().toIso8601String();
    return _$ComplianceAlertFromJson(<String, dynamic>{
      ...json,
      'id': json['id']?.toString() ?? '',
      'employeeId': (json['employee_id'] ?? json['employeeId'])?.toString(),
      'payRunId': (json['pay_run_id'] ?? json['payRunId'])?.toString(),
      'isResolved': json['is_resolved'] ?? json['isResolved'] ?? false,
      'resolvedByUserId': (json['resolved_by_id'] ?? json['resolvedByUserId'])
          ?.toString(),
      'resolvedAt': json['resolved_at'] ?? json['resolvedAt'],
      'raisedAt': json['raised_at'] ?? json['raisedAt'] ?? now,
    });
  }

  bool get isOpen => !isResolved;
}

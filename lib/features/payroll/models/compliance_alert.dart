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

  factory ComplianceAlert.fromJson(Map<String, dynamic> json) =>
      _$ComplianceAlertFromJson(json);

  bool get isOpen => !isResolved;
}

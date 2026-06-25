// coverage:ignore-file
import 'package:freezed_annotation/freezed_annotation.dart';

part 'employment_contract.freezed.dart';
part 'employment_contract.g.dart';

enum ContractType { permanent, fixedTerm, seasonal, casual }

enum ContractStatus { draft, signed, expired, terminated }

@freezed
abstract class EmploymentContract with _$EmploymentContract {
  const EmploymentContract._();

  const factory EmploymentContract({
    required String id,
    required String employeeId,
    required ContractType type,
    required DateTime startDate,
    DateTime? endDate,
    required String jobDescription,
    required double grossMonthlySalary,
    @Default('ZAR') String currency,
    required ContractStatus status,
    DateTime? signedAt,
    String? signedByName,
    String? signatureImageBase64,
    String? pdfPath,
    @Default(1) int version,
    required DateTime createdAt,
  }) = _EmploymentContract;

  factory EmploymentContract.fromJson(Map<String, dynamic> json) {
    const typeMap = {
      'permanent': 'permanent',
      'fixed_term': 'fixedTerm',
      'seasonal': 'seasonal',
      'casual': 'casual',
    };
    final now = DateTime.now().toIso8601String();
    return _$EmploymentContractFromJson(<String, dynamic>{
      ...json,
      'id': json['id']?.toString() ?? '',
      'employeeId':
          (json['employee_id'] ?? json['employeeId'])?.toString() ?? '',
      'type': typeMap[json['type']] ?? json['type'] ?? 'permanent',
      'startDate': json['start_date'] ?? json['startDate'] ?? now,
      'endDate': json['end_date'] ?? json['endDate'],
      'jobDescription': json['job_description'] ?? json['jobDescription'] ?? '',
      'grossMonthlySalary':
          (json['gross_monthly_salary'] as num?)?.toDouble() ??
          (json['grossMonthlySalary'] as num?)?.toDouble() ??
          0.0,
      'signedAt': json['signed_at'] ?? json['signedAt'],
      'signedByName': json['signed_by_name'] ?? json['signedByName'],
      'signatureImageBase64':
          json['signature_image_base64'] ?? json['signatureImageBase64'],
      'pdfPath': json['pdf_path'] ?? json['pdfPath'],
      'createdAt': json['created_at'] ?? json['createdAt'] ?? now,
    });
  }

  bool get isActive => status == ContractStatus.signed;
  bool get isExpired =>
      status == ContractStatus.expired ||
      (endDate != null && endDate!.isBefore(DateTime.now()));
}

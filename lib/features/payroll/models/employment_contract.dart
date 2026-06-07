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

  factory EmploymentContract.fromJson(Map<String, dynamic> json) =>
      _$EmploymentContractFromJson(json);

  bool get isActive => status == ContractStatus.signed;
  bool get isExpired =>
      status == ContractStatus.expired ||
      (endDate != null && endDate!.isBefore(DateTime.now()));
}

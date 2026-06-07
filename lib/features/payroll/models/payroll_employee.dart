// coverage:ignore-file
import 'package:freezed_annotation/freezed_annotation.dart';

part 'payroll_employee.freezed.dart';
part 'payroll_employee.g.dart';

enum EmploymentStatus { active, inactive, terminated }

enum EngagementType { permanent, seasonal, casual, contractor }

enum DisbursementMethod { bank, cash, mtnEwallet, orangeMoney }

@freezed
abstract class PayrollEmployee with _$PayrollEmployee {
  const PayrollEmployee._();

  const factory PayrollEmployee({
    required String id,
    required String firstName,
    required String lastName,
    required String idOrPassportNumber,
    String? phone,
    String? email,
    required String address,
    required String nextOfKinName,
    required String nextOfKinPhone,
    required EmploymentStatus status,
    required EngagementType engagementType,
    required String occupationTitle,
    String? payGroupId,
    String? payStructureId,
    required DateTime startDate,
    DateTime? endDate,
    String? bankName,
    String? bankAccountNumber,
    String? bankBranchCode,
    required DisbursementMethod disbursementMethod,
    required String preferredLanguage,
    required bool hasHousingBenefit,
    double? housingValuePerMonth,
    required bool hasFoodBenefit,
    double? foodValuePerMonth,
    DateTime? dateOfBirth,
    String? profileImageUrl,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _PayrollEmployee;

  factory PayrollEmployee.fromJson(Map<String, dynamic> json) =>
      _$PayrollEmployeeFromJson(json);

  String get fullName => '$firstName $lastName';
  bool get isActive => status == EmploymentStatus.active;
}

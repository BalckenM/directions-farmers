// coverage:ignore-file
import 'dart:convert';

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

  /// Constructs a [PayrollEmployee] from the backend JSON response.
  ///
  /// Handles three shapes:
  ///   • GET /employees list/detail  → `{id, job_title, user: {name, email}, ...}`
  ///   • PUT /employees/:id          → same shape
  ///   • POST /employees (merged)    → caller merges `{...employee, user: user}`
  factory PayrollEmployee.fromJson(Map<String, dynamic> json) {
    final user = json['user'] as Map<String, dynamic>? ?? {};
    final fullName =
        (user['name'] as String?) ?? (json['name'] as String?) ?? '';
    final parts = fullName.trim().split(RegExp(r'\s+'));
    final firstName = parts.isNotEmpty ? parts.first : '';
    final lastName = parts.length > 1 ? parts.sublist(1).join(' ') : '';

    // emergency_contact may be a Map or a JSON string
    Map<String, dynamic> ec = {};
    final rawEc = json['emergency_contact'];
    if (rawEc is Map<String, dynamic>) {
      ec = rawEc;
    } else if (rawEc is String && rawEc.isNotEmpty) {
      try {
        ec = jsonDecode(rawEc) as Map<String, dynamic>;
      } catch (_) {}
    }

    // Map backend employment_status → Flutter EmploymentStatus enum name
    final rawStatus = (json['employment_status'] as String? ?? 'active')
        .toLowerCase();
    final statusStr = switch (rawStatus) {
      'terminated' => 'terminated',
      'on_leave' || 'suspended' => 'inactive',
      _ => 'active',
    };

    // Map agr_employment_type / employment_type → Flutter EngagementType
    final rawEng =
        ((json['agr_employment_type'] ?? json['employment_type']) as String? ??
                'permanent')
            .toLowerCase();
    final engStr = switch (rawEng) {
      String s when s.contains('seasonal') => 'seasonal',
      String s
          when s == 'daily_casual' ||
              s == 'part_time' ||
              s.contains('casual') =>
        'casual',
      'contract' || 'contractor' => 'contractor',
      _ => 'permanent',
    };

    final now = DateTime.now().toIso8601String();

    return _$PayrollEmployeeFromJson(<String, dynamic>{
      'id': json['id']?.toString() ?? '',
      'firstName': firstName,
      'lastName': lastName,
      'idOrPassportNumber':
          json['national_id']?.toString() ?? json['tpin']?.toString() ?? '',
      'phone': json['phone'],
      'email': user['email'] ?? json['email'],
      'address': json['address'] ?? '',
      'nextOfKinName':
          ec['name'] as String? ?? ec['contact_name'] as String? ?? '',
      'nextOfKinPhone':
          ec['phone'] as String? ?? ec['contact_phone'] as String? ?? '',
      'status': statusStr,
      'engagementType': engStr,
      'occupationTitle': json['job_title'] ?? '',
      // payGroupId is not a direct employee field on backend (join table)
      'payGroupId': null,
      'payStructureId': null,
      'startDate': json['start_date'] ?? now,
      'endDate': json['end_date'],
      'bankName': json['bank_name'],
      'bankAccountNumber': json['bank_account_no'],
      'bankBranchCode': json['bank_branch'],
      'disbursementMethod': 'bank',
      'preferredLanguage': 'en',
      'hasHousingBenefit': json['agr_housing_provided'] ?? false,
      'housingValuePerMonth': (json['agr_housing_value'] as num?)?.toDouble(),
      'hasFoodBenefit': json['agr_meals_provided'] ?? false,
      'foodValuePerMonth': (json['agr_meals_daily_value'] as num?)?.toDouble(),
      'dateOfBirth': json['date_of_birth'],
      'profileImageUrl': json['photo_url'],
      'createdAt': json['created_at'] ?? now,
      'updatedAt': json['updated_at'] ?? json['created_at'] ?? now,
    });
  }

  String get fullName => '$firstName $lastName';
  bool get isActive => status == EmploymentStatus.active;
}

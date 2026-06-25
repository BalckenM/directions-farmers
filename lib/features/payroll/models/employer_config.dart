// coverage:ignore-file
import 'package:freezed_annotation/freezed_annotation.dart';

part 'employer_config.freezed.dart';
part 'employer_config.g.dart';

@freezed
abstract class EmployerConfig with _$EmployerConfig {
  const EmployerConfig._();

  const factory EmployerConfig({
    String? id,
    String? farmOwnerId,
    required String name,
    String? companyName,
    required String registrationNumber,
    required String payeNumber,
    String? taxNumber,
    required String uifReferenceNumber,
    String? uifNumber,
    String? sdlNumber,
    @Default(25) int payDay,
    @Default(1.5) double overtimeMultiplier,
    @Default('ZAR') String currency,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) = _EmployerConfig;

  factory EmployerConfig.fromJson(Map<String, dynamic> json) {
    final now = DateTime.now().toIso8601String();
    return _$EmployerConfigFromJson(<String, dynamic>{
      ...json,
      'id': json['id']?.toString(),
      'name': json['company_name'] ?? json['name'] ?? '',
      'companyName': json['company_name'] ?? json['companyName'],
      'registrationNumber':
          json['company_reg_no'] ?? json['registrationNumber'] ?? '',
      'payeNumber':
          json['paye_number'] ??
          json['tax_reference'] ??
          json['payeNumber'] ??
          '',
      'taxNumber': json['tax_reference'] ?? json['taxNumber'],
      'uifReferenceNumber':
          json['uif_reference_number'] ?? json['uifReferenceNumber'] ?? '',
      'uifNumber': json['uif_number'] ?? json['uifNumber'],
      'sdlNumber': json['sdl_number'] ?? json['sdlNumber'],
      'payDay': json['pay_day'] as int? ?? json['payDay'] as int? ?? 25,
      'overtimeMultiplier':
          (json['overtime_multiplier'] as num?)?.toDouble() ??
          (json['overtimeMultiplier'] as num?)?.toDouble() ??
          1.5,
      'currency': json['currency'] ?? 'ZAR',
      'notes': json['employer_notes'] ?? json['notes'],
      'createdAt': json['created_at'] ?? json['createdAt'],
      'updatedAt':
          json['updated_at'] ?? json['updatedAt'] ?? json['created_at'] ?? now,
    });
  }

  String get statutoryLine =>
      'Reg: $registrationNumber | UIF: $uifReferenceNumber | PAYE: $payeNumber';

  static const defaultConfig = EmployerConfig(
    name: '4Directions Farm',
    registrationNumber: '123/456',
    uifReferenceNumber: 'U123456',
    payeNumber: '7890123456',
  );
}

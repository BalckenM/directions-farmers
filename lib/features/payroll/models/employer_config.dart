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

  factory EmployerConfig.fromJson(Map<String, dynamic> json) =>
      _$EmployerConfigFromJson(json);

  String get statutoryLine =>
      'Reg: $registrationNumber | UIF: $uifReferenceNumber | PAYE: $payeNumber';

  static const defaultConfig = EmployerConfig(
    name: '4Directions Farm',
    registrationNumber: '123/456',
    uifReferenceNumber: 'U123456',
    payeNumber: '7890123456',
  );
}

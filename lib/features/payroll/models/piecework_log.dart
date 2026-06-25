// coverage:ignore-file
import 'package:freezed_annotation/freezed_annotation.dart';

part 'piecework_log.freezed.dart';
part 'piecework_log.g.dart';

@freezed
abstract class PieceworkLog with _$PieceworkLog {
  const PieceworkLog._();

  const factory PieceworkLog({
    required String id,
    required String employeeId,
    required DateTime date,
    String? shiftId,
    required String payrollCode,
    required String unit,
    required double quantity,
    required double ratePerUnit,
    required String recordedByUserId,
    String? notes,
    required DateTime createdAt,
  }) = _PieceworkLog;

  factory PieceworkLog.fromJson(Map<String, dynamic> json) {
    final now = DateTime.now().toIso8601String();
    return _$PieceworkLogFromJson(<String, dynamic>{
      ...json,
      'id': json['id']?.toString() ?? '',
      'employeeId':
          (json['employee_id'] ?? json['employeeId'])?.toString() ?? '',
      'shiftId': (json['shift_id'] ?? json['shiftId'])?.toString(),
      'payrollCode': json['payroll_code'] ?? json['payrollCode'] ?? '',
      'ratePerUnit':
          (json['rate_per_unit'] as num?)?.toDouble() ??
          (json['ratePerUnit'] as num?)?.toDouble() ??
          0.0,
      'recordedByUserId':
          (json['recorded_by_id'] ?? json['recordedByUserId'])?.toString() ??
          '',
      'createdAt': json['created_at'] ?? json['createdAt'] ?? now,
    });
  }

  double get totalEarnings => quantity * ratePerUnit;
}

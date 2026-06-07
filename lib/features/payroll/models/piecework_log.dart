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

  factory PieceworkLog.fromJson(Map<String, dynamic> json) =>
      _$PieceworkLogFromJson(json);

  double get totalEarnings => quantity * ratePerUnit;
}

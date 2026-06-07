// coverage:ignore-file
import 'package:freezed_annotation/freezed_annotation.dart';

part 'garnishee_order.freezed.dart';
part 'garnishee_order.g.dart';

enum GarnisheeStatus { active, satisfied, suspended, cancelled }

@freezed
abstract class GarnisheeOrder with _$GarnisheeOrder {
  const GarnisheeOrder._();

  const factory GarnisheeOrder({
    required String id,
    required String employeeId,
    required String courtOrderRef,
    required String creditorName,
    required double monthlyDeductionAmount,
    required double totalOwed,
    required double amountDeducted,
    required GarnisheeStatus status,
    required DateTime createdAt,
    DateTime? satisfiedAt,
    String? notes,
  }) = _GarnisheeOrder;

  factory GarnisheeOrder.fromJson(Map<String, dynamic> json) =>
      _$GarnisheeOrderFromJson(json);

  double get outstandingBalance =>
      (totalOwed - amountDeducted).clamp(0.0, double.infinity);
  bool get isActive => status == GarnisheeStatus.active;
}

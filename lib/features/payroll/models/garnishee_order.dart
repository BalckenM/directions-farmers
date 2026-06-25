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

  factory GarnisheeOrder.fromJson(Map<String, dynamic> json) {
    final now = DateTime.now().toIso8601String();
    return _$GarnisheeOrderFromJson(<String, dynamic>{
      ...json,
      'id': json['id']?.toString() ?? '',
      'employeeId':
          (json['employee_id'] ?? json['employeeId'])?.toString() ?? '',
      'courtOrderRef': json['court_order_ref'] ?? json['courtOrderRef'] ?? '',
      'creditorName': json['creditor_name'] ?? json['creditorName'] ?? '',
      'monthlyDeductionAmount':
          (json['monthly_deduction_amount'] as num?)?.toDouble() ??
          (json['monthlyDeductionAmount'] as num?)?.toDouble() ??
          0.0,
      'totalOwed':
          (json['total_owed'] as num?)?.toDouble() ??
          (json['totalOwed'] as num?)?.toDouble() ??
          0.0,
      'amountDeducted':
          (json['amount_deducted'] as num?)?.toDouble() ??
          (json['amountDeducted'] as num?)?.toDouble() ??
          0.0,
      'createdAt': json['created_at'] ?? json['createdAt'] ?? now,
      'satisfiedAt': json['satisfied_at'] ?? json['satisfiedAt'],
    });
  }

  double get outstandingBalance =>
      (totalOwed - amountDeducted).clamp(0.0, double.infinity);
  bool get isActive => status == GarnisheeStatus.active;
}

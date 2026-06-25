// coverage:ignore-file
import 'package:freezed_annotation/freezed_annotation.dart';

part 'payment_transaction.freezed.dart';
part 'payment_transaction.g.dart';

enum TransactionStatus { initiated, processing, completed, failed, reversed }

@freezed
abstract class PaymentTransaction with _$PaymentTransaction {
  const PaymentTransaction._();

  const factory PaymentTransaction({
    required String id,
    required String payRunId,
    required String employeeId,
    required String type,
    required String description,
    required double amount,
    required String currency,
    required String method,
    required TransactionStatus status,
    String? reference,
    String? bankName,
    String? accountNumber,
    DateTime? initiatedAt,
    DateTime? completedAt,
    String? failureReason,
    required DateTime transactionDate,
    required DateTime createdAt,
  }) = _PaymentTransaction;

  factory PaymentTransaction.fromJson(Map<String, dynamic> json) {
    final now = DateTime.now().toIso8601String();
    return _$PaymentTransactionFromJson(<String, dynamic>{
      ...json,
      'id': json['id']?.toString() ?? '',
      'payRunId': (json['pay_run_id'] ?? json['payRunId'])?.toString() ?? '',
      'employeeId':
          (json['employee_id'] ?? json['employeeId'])?.toString() ?? '',
      'bankName': json['bank_name'] ?? json['bankName'],
      'accountNumber': json['account_number'] ?? json['accountNumber'],
      'initiatedAt': json['initiated_at'] ?? json['initiatedAt'],
      'completedAt': json['completed_at'] ?? json['completedAt'],
      'failureReason': json['failure_reason'] ?? json['failureReason'],
      'transactionDate':
          json['transaction_date'] ?? json['transactionDate'] ?? now,
      'createdAt': json['created_at'] ?? json['createdAt'] ?? now,
    });
  }

  bool get isCompleted => status == TransactionStatus.completed;
}

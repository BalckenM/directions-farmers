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

  factory PaymentTransaction.fromJson(Map<String, dynamic> json) =>
      _$PaymentTransactionFromJson(json);

  bool get isCompleted => status == TransactionStatus.completed;
}

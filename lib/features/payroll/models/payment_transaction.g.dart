// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'payment_transaction.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_PaymentTransaction _$PaymentTransactionFromJson(Map<String, dynamic> json) =>
    _PaymentTransaction(
      id: json['id'] as String,
      payRunId: json['payRunId'] as String,
      employeeId: json['employeeId'] as String,
      type: json['type'] as String,
      description: json['description'] as String,
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String,
      method: json['method'] as String,
      status: $enumDecode(_$TransactionStatusEnumMap, json['status']),
      reference: json['reference'] as String?,
      bankName: json['bankName'] as String?,
      accountNumber: json['accountNumber'] as String?,
      initiatedAt: json['initiatedAt'] == null
          ? null
          : DateTime.parse(json['initiatedAt'] as String),
      completedAt: json['completedAt'] == null
          ? null
          : DateTime.parse(json['completedAt'] as String),
      failureReason: json['failureReason'] as String?,
      transactionDate: DateTime.parse(json['transactionDate'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$PaymentTransactionToJson(_PaymentTransaction instance) =>
    <String, dynamic>{
      'id': instance.id,
      'payRunId': instance.payRunId,
      'employeeId': instance.employeeId,
      'type': instance.type,
      'description': instance.description,
      'amount': instance.amount,
      'currency': instance.currency,
      'method': instance.method,
      'status': _$TransactionStatusEnumMap[instance.status]!,
      'reference': instance.reference,
      'bankName': instance.bankName,
      'accountNumber': instance.accountNumber,
      'initiatedAt': instance.initiatedAt?.toIso8601String(),
      'completedAt': instance.completedAt?.toIso8601String(),
      'failureReason': instance.failureReason,
      'transactionDate': instance.transactionDate.toIso8601String(),
      'createdAt': instance.createdAt.toIso8601String(),
    };

const _$TransactionStatusEnumMap = {
  TransactionStatus.initiated: 'initiated',
  TransactionStatus.processing: 'processing',
  TransactionStatus.completed: 'completed',
  TransactionStatus.failed: 'failed',
  TransactionStatus.reversed: 'reversed',
};

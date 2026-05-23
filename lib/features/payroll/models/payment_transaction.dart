enum TransactionStatus { initiated, processing, completed, failed, reversed }

class PaymentTransaction {
  const PaymentTransaction({
    required this.id,
    required this.payRunId,
    required this.employeeId,
    required this.amount,
    required this.currency,
    required this.method,
    required this.status,
    this.reference,
    this.bankName,
    this.accountNumber,
    this.initiatedAt,
    this.completedAt,
    this.failureReason,
    required this.createdAt,
  });

  final String id;
  final String payRunId;
  final String employeeId;
  final double amount;
  final String currency;
  final String method;  // 'bank', 'cash', 'ewallet'
  final TransactionStatus status;
  final String? reference;
  final String? bankName;
  final String? accountNumber;
  final DateTime? initiatedAt;
  final DateTime? completedAt;
  final String? failureReason;
  final DateTime createdAt;

  factory PaymentTransaction.fromJson(Map<String, dynamic> json) => PaymentTransaction(
        id: json['id'] as String,
        payRunId: json['payRunId'] as String,
        employeeId: json['employeeId'] as String,
        amount: (json['amount'] as num).toDouble(),
        currency: json['currency'] as String,
        method: json['method'] as String,
        status: TransactionStatus.values.byName(json['status'] as String),
        reference: json['reference'] as String?,
        bankName: json['bankName'] as String?,
        accountNumber: json['accountNumber'] as String?,
        initiatedAt: json['initiatedAt'] != null ? DateTime.parse(json['initiatedAt'] as String) : null,
        completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt'] as String) : null,
        failureReason: json['failureReason'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'payRunId': payRunId,
        'employeeId': employeeId,
        'amount': amount,
        'currency': currency,
        'method': method,
        'status': status.name,
        'reference': reference,
        'bankName': bankName,
        'accountNumber': accountNumber,
        'initiatedAt': initiatedAt?.toIso8601String(),
        'completedAt': completedAt?.toIso8601String(),
        'failureReason': failureReason,
        'createdAt': createdAt.toIso8601String(),
      };

  bool get isCompleted => status == TransactionStatus.completed;
}

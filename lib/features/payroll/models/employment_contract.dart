enum ContractType { permanent, fixedTerm, seasonal, casual }

enum ContractStatus { draft, signed, expired, terminated }

const _sentinel = Object();

class EmploymentContract {
  const EmploymentContract({
    required this.id,
    required this.employeeId,
    required this.type,
    required this.startDate,
    this.endDate,
    required this.jobDescription,
    required this.grossMonthlySalary,
    this.currency = 'ZAR',
    required this.status,
    this.signedAt,
    this.signedByName,
    this.signatureImageBase64,
    this.pdfPath,
    this.version = 1,
    required this.createdAt,
  });

  final String id;
  final String employeeId;
  final ContractType type;
  final DateTime startDate;
  final DateTime? endDate;
  final String jobDescription;
  final double grossMonthlySalary;
  final String currency;
  final ContractStatus status;
  final DateTime? signedAt;
  final String? signedByName;
  /// Base64-encoded PNG of the handwritten signature strokes.
  final String? signatureImageBase64;
  final String? pdfPath;
  final int version;
  final DateTime createdAt;

  bool get isActive => status == ContractStatus.signed;
  bool get isExpired =>
      status == ContractStatus.expired ||
      (endDate != null && endDate!.isBefore(DateTime.now()));

  factory EmploymentContract.fromJson(Map<String, dynamic> json) => EmploymentContract(
        id: json['id'] as String,
        employeeId: json['employeeId'] as String,
        type: ContractType.values.byName(json['type'] as String),
        startDate: DateTime.parse(json['startDate'] as String),
        endDate: json['endDate'] != null ? DateTime.parse(json['endDate'] as String) : null,
        jobDescription: json['jobDescription'] as String,
        grossMonthlySalary: (json['grossMonthlySalary'] as num).toDouble(),
        currency: json['currency'] as String? ?? 'ZAR',
        status: ContractStatus.values.byName(json['status'] as String),
        signedAt: json['signedAt'] != null ? DateTime.parse(json['signedAt'] as String) : null,
        signedByName: json['signedByName'] as String?,
        signatureImageBase64: json['signatureImageBase64'] as String?,
        pdfPath: json['pdfPath'] as String?,
        version: json['version'] as int? ?? 1,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'employeeId': employeeId,
        'type': type.name,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate?.toIso8601String(),
        'jobDescription': jobDescription,
        'grossMonthlySalary': grossMonthlySalary,
        'currency': currency,
        'status': status.name,
        'signedAt': signedAt?.toIso8601String(),
        'signedByName': signedByName,
        'signatureImageBase64': signatureImageBase64,
        'pdfPath': pdfPath,
        'version': version,
        'createdAt': createdAt.toIso8601String(),
      };

  EmploymentContract copyWith({
    String? id,
    String? employeeId,
    ContractType? type,
    DateTime? startDate,
    DateTime? endDate,
    String? jobDescription,
    double? grossMonthlySalary,
    String? currency,
    ContractStatus? status,
    DateTime? signedAt,
    String? signedByName,
    Object? signatureImageBase64 = _sentinel,
    String? pdfPath,
    int? version,
    DateTime? createdAt,
  }) {
    return EmploymentContract(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      type: type ?? this.type,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      jobDescription: jobDescription ?? this.jobDescription,
      grossMonthlySalary: grossMonthlySalary ?? this.grossMonthlySalary,
      currency: currency ?? this.currency,
      status: status ?? this.status,
      signedAt: signedAt ?? this.signedAt,
      signedByName: signedByName ?? this.signedByName,
      signatureImageBase64: signatureImageBase64 == _sentinel
          ? this.signatureImageBase64
          : signatureImageBase64 as String?,
      pdfPath: pdfPath ?? this.pdfPath,
      version: version ?? this.version,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

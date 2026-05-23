// ignore_for_file: avoid_positional_boolean_parameters

enum EmploymentStatus { active, inactive, terminated }

enum EngagementType { permanent, seasonal, casual, contractor }

enum DisbursementMethod { bank, cash, mtnEwallet, orangeMoney }

class PayrollEmployee {
  const PayrollEmployee({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.idOrPassportNumber,
    this.phone,
    this.email,
    required this.address,
    required this.nextOfKinName,
    required this.nextOfKinPhone,
    required this.status,
    required this.engagementType,
    required this.occupationTitle,
    this.payGroupId,
    this.payStructureId,
    required this.startDate,
    this.endDate,
    this.bankName,
    this.bankAccountNumber,
    this.bankBranchCode,
    required this.disbursementMethod,
    required this.preferredLanguage,
    required this.hasHousingBenefit,
    this.housingValuePerMonth,
    required this.hasFoodBenefit,
    this.foodValuePerMonth,
    this.dateOfBirth,
    required this.createdAt,
    required this.updatedAt,
  });

  final String id;
  final String firstName;
  final String lastName;
  final String idOrPassportNumber;
  final String? phone;
  final String? email;
  final String address;
  final String nextOfKinName;
  final String nextOfKinPhone;
  final EmploymentStatus status;
  final EngagementType engagementType;
  final String occupationTitle;
  final String? payGroupId;
  final String? payStructureId;
  final DateTime startDate;
  final DateTime? endDate;
  final String? bankName;
  final String? bankAccountNumber;
  final String? bankBranchCode;
  final DisbursementMethod disbursementMethod;
  final String preferredLanguage;
  final bool hasHousingBenefit;
  final double? housingValuePerMonth;
  final bool hasFoodBenefit;
  final double? foodValuePerMonth;
  /// Date of birth — required for ETI youth employment subsidy eligibility check.
  final DateTime? dateOfBirth;
  final DateTime createdAt;
  final DateTime updatedAt;

  String get fullName => '$firstName $lastName';
  bool get isActive => status == EmploymentStatus.active;

  factory PayrollEmployee.fromJson(Map<String, dynamic> json) => PayrollEmployee(
        id: json['id'] as String,
        firstName: json['firstName'] as String,
        lastName: json['lastName'] as String,
        idOrPassportNumber: json['idOrPassportNumber'] as String,
        phone: json['phone'] as String?,
        email: json['email'] as String?,
        address: json['address'] as String,
        nextOfKinName: json['nextOfKinName'] as String,
        nextOfKinPhone: json['nextOfKinPhone'] as String,
        status: EmploymentStatus.values.byName(json['status'] as String),
        engagementType: EngagementType.values.byName(json['engagementType'] as String),
        occupationTitle: json['occupationTitle'] as String,
        payGroupId: json['payGroupId'] as String?,
        payStructureId: json['payStructureId'] as String?,
        startDate: DateTime.parse(json['startDate'] as String),
        endDate: json['endDate'] != null ? DateTime.parse(json['endDate'] as String) : null,
        bankName: json['bankName'] as String?,
        bankAccountNumber: json['bankAccountNumber'] as String?,
        bankBranchCode: json['bankBranchCode'] as String?,
        disbursementMethod: DisbursementMethod.values.byName(json['disbursementMethod'] as String),
        preferredLanguage: json['preferredLanguage'] as String,
        hasHousingBenefit: json['hasHousingBenefit'] as bool,
        housingValuePerMonth: json['housingValuePerMonth'] != null
            ? (json['housingValuePerMonth'] as num).toDouble()
            : null,
        hasFoodBenefit: json['hasFoodBenefit'] as bool,
        foodValuePerMonth: json['foodValuePerMonth'] != null
            ? (json['foodValuePerMonth'] as num).toDouble()
            : null,
        dateOfBirth: json['dateOfBirth'] != null
            ? DateTime.parse(json['dateOfBirth'] as String)
            : null,
        createdAt: DateTime.parse(json['createdAt'] as String),
        updatedAt: DateTime.parse(json['updatedAt'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'firstName': firstName,
        'lastName': lastName,
        'idOrPassportNumber': idOrPassportNumber,
        'phone': phone,
        'email': email,
        'address': address,
        'nextOfKinName': nextOfKinName,
        'nextOfKinPhone': nextOfKinPhone,
        'status': status.name,
        'engagementType': engagementType.name,
        'occupationTitle': occupationTitle,
        'payGroupId': payGroupId,
        'payStructureId': payStructureId,
        'startDate': startDate.toIso8601String(),
        'endDate': endDate?.toIso8601String(),
        'bankName': bankName,
        'bankAccountNumber': bankAccountNumber,
        'bankBranchCode': bankBranchCode,
        'disbursementMethod': disbursementMethod.name,
        'preferredLanguage': preferredLanguage,
        'hasHousingBenefit': hasHousingBenefit,
        'housingValuePerMonth': housingValuePerMonth,
        'hasFoodBenefit': hasFoodBenefit,
        'foodValuePerMonth': foodValuePerMonth,
        'dateOfBirth': dateOfBirth?.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  PayrollEmployee copyWith({
    String? id,
    String? firstName,
    String? lastName,
    String? idOrPassportNumber,
    String? phone,
    String? email,
    String? address,
    String? nextOfKinName,
    String? nextOfKinPhone,
    EmploymentStatus? status,
    EngagementType? engagementType,
    String? occupationTitle,
    String? payGroupId,
    String? payStructureId,
    DateTime? startDate,
    DateTime? endDate,
    String? bankName,
    String? bankAccountNumber,
    String? bankBranchCode,
    DisbursementMethod? disbursementMethod,
    String? preferredLanguage,
    bool? hasHousingBenefit,
    double? housingValuePerMonth,
    bool? hasFoodBenefit,
    double? foodValuePerMonth,
    DateTime? dateOfBirth,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PayrollEmployee(
      id: id ?? this.id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      idOrPassportNumber: idOrPassportNumber ?? this.idOrPassportNumber,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      nextOfKinName: nextOfKinName ?? this.nextOfKinName,
      nextOfKinPhone: nextOfKinPhone ?? this.nextOfKinPhone,
      status: status ?? this.status,
      engagementType: engagementType ?? this.engagementType,
      occupationTitle: occupationTitle ?? this.occupationTitle,
      payGroupId: payGroupId ?? this.payGroupId,
      payStructureId: payStructureId ?? this.payStructureId,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      bankName: bankName ?? this.bankName,
      bankAccountNumber: bankAccountNumber ?? this.bankAccountNumber,
      bankBranchCode: bankBranchCode ?? this.bankBranchCode,
      disbursementMethod: disbursementMethod ?? this.disbursementMethod,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      hasHousingBenefit: hasHousingBenefit ?? this.hasHousingBenefit,
      housingValuePerMonth: housingValuePerMonth ?? this.housingValuePerMonth,
      hasFoodBenefit: hasFoodBenefit ?? this.hasFoodBenefit,
      foodValuePerMonth: foodValuePerMonth ?? this.foodValuePerMonth,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

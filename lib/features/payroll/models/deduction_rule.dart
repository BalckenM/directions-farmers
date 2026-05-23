enum DeductionType { statutory, voluntary, benefit, garnishee }

enum DeductionBasis { percentage, fixedAmount }

class DeductionRule {
  const DeductionRule({
    required this.id,
    required this.code,
    required this.label,
    required this.type,
    required this.basis,
    required this.value,
    this.cappedAt,
    this.employeeIds,
    required this.isActive,
    required this.createdAt,
  });

  final String id;

  /// Short machine code, e.g. 'UIF_EE', 'HOUSING', 'LOAN_01'.
  final String code;
  final String label;
  final DeductionType type;
  final DeductionBasis basis;

  /// Percentage (0–100) if basis == percentage; ZAR amount if fixedAmount.
  final double value;

  /// Optional maximum ZAR cap regardless of basis.
  final double? cappedAt;

  /// null → applies to all employees; non-null → specific employees only.
  final List<String>? employeeIds;
  final bool isActive;
  final DateTime createdAt;

  String get typeLabel {
    switch (type) {
      case DeductionType.statutory:
        return 'Statutory';
      case DeductionType.voluntary:
        return 'Voluntary';
      case DeductionType.benefit:
        return 'Benefit';
      case DeductionType.garnishee:
        return 'Garnishee';
    }
  }

  factory DeductionRule.fromJson(Map<String, dynamic> json) => DeductionRule(
        id: json['id'] as String,
        code: json['code'] as String,
        label: json['label'] as String,
        type: DeductionType.values.byName(json['type'] as String),
        basis: DeductionBasis.values.byName(json['basis'] as String),
        value: (json['value'] as num).toDouble(),
        cappedAt: json['cappedAt'] != null ? (json['cappedAt'] as num).toDouble() : null,
        employeeIds: json['employeeIds'] != null
            ? (json['employeeIds'] as List<dynamic>).map((e) => e as String).toList()
            : null,
        isActive: json['isActive'] as bool,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'code': code,
        'label': label,
        'type': type.name,
        'basis': basis.name,
        'value': value,
        'cappedAt': cappedAt,
        'employeeIds': employeeIds,
        'isActive': isActive,
        'createdAt': createdAt.toIso8601String(),
      };

  DeductionRule copyWith({
    String? id,
    String? code,
    String? label,
    DeductionType? type,
    DeductionBasis? basis,
    double? value,
    double? cappedAt,
    List<String>? employeeIds,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return DeductionRule(
      id: id ?? this.id,
      code: code ?? this.code,
      label: label ?? this.label,
      type: type ?? this.type,
      basis: basis ?? this.basis,
      value: value ?? this.value,
      cappedAt: cappedAt ?? this.cappedAt,
      employeeIds: employeeIds ?? this.employeeIds,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

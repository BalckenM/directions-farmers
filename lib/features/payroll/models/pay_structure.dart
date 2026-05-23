enum WageType { monthlySalary, hourlyRate, dailyRate, piecework }

class PayStructure {
  const PayStructure({
    required this.id,
    required this.name,
    required this.wageType,
    required this.baseRate,
    this.nmwaEnforced = true,
    this.overtimeMultiplier = 1.5,
    this.sundayMultiplier = 2.0,
    this.publicHolidayMultiplier = 2.0,
    this.pieceworkUnit,
    this.pieceworkMinUnitsPerDay,
    required this.createdAt,
  });

  final String id;
  final String name;
  final WageType wageType;

  /// Meaning depends on [wageType]:
  /// monthlySalary → ZAR per month, hourlyRate → ZAR per hour,
  /// dailyRate → ZAR per day, piecework → ZAR per unit.
  final double baseRate;

  /// Whether to auto-check NMWA compliance on every pay calculation.
  final bool nmwaEnforced;
  final double overtimeMultiplier;
  final double sundayMultiplier;
  final double publicHolidayMultiplier;

  /// e.g. 'kg', 'crates', 'trees' — only used for piecework.
  final String? pieceworkUnit;
  final double? pieceworkMinUnitsPerDay;
  final DateTime createdAt;

  String get wageTypeLabel {
    switch (wageType) {
      case WageType.monthlySalary:
        return 'Monthly Salary';
      case WageType.hourlyRate:
        return 'Hourly Rate';
      case WageType.dailyRate:
        return 'Daily Rate';
      case WageType.piecework:
        return 'Piecework';
    }
  }

  factory PayStructure.fromJson(Map<String, dynamic> json) => PayStructure(
        id: json['id'] as String,
        name: json['name'] as String,
        wageType: WageType.values.byName(json['wageType'] as String),
        baseRate: (json['baseRate'] as num).toDouble(),
        nmwaEnforced: json['nmwaEnforced'] as bool? ?? true,
        overtimeMultiplier: (json['overtimeMultiplier'] as num?)?.toDouble() ?? 1.5,
        sundayMultiplier: (json['sundayMultiplier'] as num?)?.toDouble() ?? 2.0,
        publicHolidayMultiplier: (json['publicHolidayMultiplier'] as num?)?.toDouble() ?? 2.0,
        pieceworkUnit: json['pieceworkUnit'] as String?,
        pieceworkMinUnitsPerDay: json['pieceworkMinUnitsPerDay'] != null
            ? (json['pieceworkMinUnitsPerDay'] as num).toDouble()
            : null,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'wageType': wageType.name,
        'baseRate': baseRate,
        'nmwaEnforced': nmwaEnforced,
        'overtimeMultiplier': overtimeMultiplier,
        'sundayMultiplier': sundayMultiplier,
        'publicHolidayMultiplier': publicHolidayMultiplier,
        'pieceworkUnit': pieceworkUnit,
        'pieceworkMinUnitsPerDay': pieceworkMinUnitsPerDay,
        'createdAt': createdAt.toIso8601String(),
      };

  PayStructure copyWith({
    String? id,
    String? name,
    WageType? wageType,
    double? baseRate,
    bool? nmwaEnforced,
    double? overtimeMultiplier,
    double? sundayMultiplier,
    double? publicHolidayMultiplier,
    String? pieceworkUnit,
    double? pieceworkMinUnitsPerDay,
    DateTime? createdAt,
  }) {
    return PayStructure(
      id: id ?? this.id,
      name: name ?? this.name,
      wageType: wageType ?? this.wageType,
      baseRate: baseRate ?? this.baseRate,
      nmwaEnforced: nmwaEnforced ?? this.nmwaEnforced,
      overtimeMultiplier: overtimeMultiplier ?? this.overtimeMultiplier,
      sundayMultiplier: sundayMultiplier ?? this.sundayMultiplier,
      publicHolidayMultiplier:
          publicHolidayMultiplier ?? this.publicHolidayMultiplier,
      pieceworkUnit: pieceworkUnit ?? this.pieceworkUnit,
      pieceworkMinUnitsPerDay:
          pieceworkMinUnitsPerDay ?? this.pieceworkMinUnitsPerDay,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

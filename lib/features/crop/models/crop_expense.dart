enum ExpenseCategory {
  seed,
  fertilizer,
  chemical,
  fuel,
  labor,
  machinery,
  irrigation,
  transport,
  other,
}

extension ExpenseCategoryX on ExpenseCategory {
  String get label => switch (this) {
        ExpenseCategory.seed => 'Seed',
        ExpenseCategory.fertilizer => 'Fertilizer',
        ExpenseCategory.chemical => 'Chemicals',
        ExpenseCategory.fuel => 'Fuel',
        ExpenseCategory.labor => 'Labour',
        ExpenseCategory.machinery => 'Machinery',
        ExpenseCategory.irrigation => 'Irrigation',
        ExpenseCategory.transport => 'Transport',
        ExpenseCategory.other => 'Other',
      };

  static ExpenseCategory fromString(String v) => switch (v) {
        'seed' => ExpenseCategory.seed,
        'fertilizer' => ExpenseCategory.fertilizer,
        'chemical' => ExpenseCategory.chemical,
        'fuel' => ExpenseCategory.fuel,
        'labor' => ExpenseCategory.labor,
        'machinery' => ExpenseCategory.machinery,
        'irrigation' => ExpenseCategory.irrigation,
        'transport' => ExpenseCategory.transport,
        _ => ExpenseCategory.other,
      };
}

class CropExpense {
  const CropExpense({
    required this.id,
    required this.farmId,
    this.fieldId,
    this.planId,
    required this.category,
    required this.description,
    required this.amountZar,
    required this.date,
    this.supplier,
    this.quantity,
    this.unit,
  });

  final String id;
  final String farmId;
  final String? fieldId;
  final String? planId;
  final ExpenseCategory category;
  final String description;
  final double amountZar;
  final DateTime date;
  final String? supplier;
  final double? quantity;
  final String? unit;

  factory CropExpense.fromJson(Map<String, dynamic> json) => CropExpense(
        id: json['id'] as String,
        farmId: json['farm_id'] as String,
        fieldId: json['field_id'] as String?,
        planId: json['plan_id'] as String?,
        category: ExpenseCategoryX.fromString(json['category'] as String),
        description: json['description'] as String,
        amountZar: (json['amount_zar'] as num).toDouble(),
        date: DateTime.parse(json['date'] as String),
        supplier: json['supplier'] as String?,
        quantity: (json['quantity'] as num?)?.toDouble(),
        unit: json['unit'] as String?,
      );
}

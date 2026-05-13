class FinancialTransaction {
  const FinancialTransaction({
    required this.id,
    required this.date,
    required this.type,
    required this.category,
    required this.description,
    required this.amountZar,
    this.reference,
    this.notes,
    this.animalIds = const [],
  });

  final String id;
  final String date;
  final String type; // 'income' | 'expense'
  final String category;
  final String description;
  final double amountZar;
  final String? reference;
  final String? notes;
  final List<String> animalIds;

  bool get isIncome => type == 'income';
  bool get isExpense => type == 'expense';

  factory FinancialTransaction.fromJson(Map<String, dynamic> json) {
    return FinancialTransaction(
      id: json['id'] as String? ?? '',
      date: json['date'] as String? ?? '',
      type: json['type'] as String? ?? 'expense',
      category: json['category'] as String? ?? '',
      description: json['description'] as String? ?? '',
      amountZar: (json['amount_zar'] as num?)?.toDouble() ?? 0.0,
      reference: json['reference'] as String?,
      notes: json['notes'] as String?,
      animalIds: (json['animal_ids'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );
  }
}

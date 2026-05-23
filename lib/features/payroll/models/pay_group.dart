enum PayFrequency { weekly, biweekly, monthly, daily }

class PayGroup {
  const PayGroup({
    required this.id,
    required this.name,
    required this.frequency,
    required this.payDayOffset,
    this.description,
    required this.isActive,
    required this.createdAt,
  });

  final String id;
  final String name;
  final PayFrequency frequency;

  /// For monthly: day-of-month (1=1st, 25=25th).
  /// For weekly: day-of-week (1=Mon … 5=Fri).
  final int payDayOffset;
  final String? description;
  final bool isActive;
  final DateTime createdAt;

  String get frequencyLabel {
    switch (frequency) {
      case PayFrequency.weekly:
        return 'Weekly';
      case PayFrequency.biweekly:
        return 'Bi-weekly';
      case PayFrequency.monthly:
        return 'Monthly';
      case PayFrequency.daily:
        return 'Daily';
    }
  }

  factory PayGroup.fromJson(Map<String, dynamic> json) => PayGroup(
        id: json['id'] as String,
        name: json['name'] as String,
        frequency: PayFrequency.values.byName(json['frequency'] as String),
        payDayOffset: json['payDayOffset'] as int,
        description: json['description'] as String?,
        isActive: json['isActive'] as bool,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'frequency': frequency.name,
        'payDayOffset': payDayOffset,
        'description': description,
        'isActive': isActive,
        'createdAt': createdAt.toIso8601String(),
      };

  PayGroup copyWith({
    String? id,
    String? name,
    PayFrequency? frequency,
    int? payDayOffset,
    String? description,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return PayGroup(
      id: id ?? this.id,
      name: name ?? this.name,
      frequency: frequency ?? this.frequency,
      payDayOffset: payDayOffset ?? this.payDayOffset,
      description: description ?? this.description,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

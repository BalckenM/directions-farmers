class WeightRecord {
  const WeightRecord({
    required this.id,
    required this.animalId,
    required this.animalType,
    required this.weighDate,
    required this.weightKg,
    this.bodyConditionScore,
    this.adgSinceLastKg,
    this.method,
    this.notes,
  });

  final String id;
  final String animalId;
  final String animalType;
  final String weighDate;
  final double weightKg;
  final int? bodyConditionScore;
  final double? adgSinceLastKg;
  final String? method;
  final String? notes;

  factory WeightRecord.fromJson(Map<String, dynamic> json) {
    return WeightRecord(
      id: json['id'] as String? ?? '',
      animalId: json['animal_id'] as String? ?? '',
      animalType: json['animal_type'] as String? ?? '',
      weighDate: json['weigh_date'] as String? ?? '',
      weightKg: (json['weight_kg'] as num?)?.toDouble() ?? 0,
      bodyConditionScore: json['body_condition_score'] as int?,
      adgSinceLastKg: (json['adg_since_last_kg'] as num?)?.toDouble(),
      method: json['method'] as String?,
      notes: json['notes'] as String?,
    );
  }
}

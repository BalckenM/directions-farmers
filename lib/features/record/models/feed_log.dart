class FeedLog {
  const FeedLog({
    required this.id,
    required this.date,
    required this.species,
    required this.groupId,
    required this.groupName,
    required this.animalCount,
    required this.feedType,
    required this.quantityKg,
    required this.costZar,
    required this.recordedBy,
    this.notes,
  });

  final String id;
  final String date;
  final String species;
  final String groupId;
  final String groupName;
  final int animalCount;
  final String feedType;
  final double quantityKg;
  final double costZar;
  final String recordedBy;
  final String? notes;

  double get costPerAnimalZar =>
      animalCount > 0 ? costZar / animalCount : 0.0;

  factory FeedLog.fromJson(Map<String, dynamic> json) {
    return FeedLog(
      id: json['id'] as String? ?? '',
      date: json['date'] as String? ?? '',
      species: json['species'] as String? ?? '',
      groupId: json['group_id'] as String? ?? '',
      groupName: json['group_name'] as String? ?? '',
      animalCount: (json['animal_count'] as num?)?.toInt() ?? 0,
      feedType: json['feed_type'] as String? ?? '',
      quantityKg: (json['quantity_kg'] as num?)?.toDouble() ?? 0.0,
      costZar: (json['cost_zar'] as num?)?.toDouble() ?? 0.0,
      recordedBy: json['recorded_by'] as String? ?? '',
      notes: json['notes'] as String?,
    );
  }
}

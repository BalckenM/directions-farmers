class Group {
  const Group({
    required this.id,
    required this.farmId,
    required this.name,
    required this.species,
    required this.animalCount,
    this.purpose,
    this.location,
    this.description,
    this.avgWeightKg,
    this.avgAgeMonths,
  });

  final String id;
  final String farmId;
  final String name;
  final String species;
  final int animalCount;
  final String? purpose;
  final String? location;
  final String? description;
  final double? avgWeightKg;
  final double? avgAgeMonths;

  factory Group.fromJson(Map<String, dynamic> json) {
    return Group(
      id: json['id'] as String? ?? '',
      farmId: json['farm_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      species: json['species'] as String? ?? '',
      animalCount: json['animal_count'] as int? ?? 0,
      purpose: json['purpose'] as String?,
      location: json['location'] as String?,
      description: json['description'] as String?,
      avgWeightKg: (json['avg_weight_kg'] as num?)?.toDouble(),
      avgAgeMonths: (json['avg_age_months'] as num?)?.toDouble(),
    );
  }

  Group copyWith({
    String? id,
    String? farmId,
    String? name,
    String? species,
    int? animalCount,
    String? purpose,
    String? location,
    String? description,
    double? avgWeightKg,
    double? avgAgeMonths,
  }) {
    return Group(
      id: id ?? this.id,
      farmId: farmId ?? this.farmId,
      name: name ?? this.name,
      species: species ?? this.species,
      animalCount: animalCount ?? this.animalCount,
      purpose: purpose ?? this.purpose,
      location: location ?? this.location,
      description: description ?? this.description,
      avgWeightKg: avgWeightKg ?? this.avgWeightKg,
      avgAgeMonths: avgAgeMonths ?? this.avgAgeMonths,
    );
  }

  String get displayPurpose {
    if (purpose == null) return '';
    return purpose!.replaceAll('_', ' ').toUpperCase();
  }
}

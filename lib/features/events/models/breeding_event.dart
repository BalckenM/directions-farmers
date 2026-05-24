class BreedingEvent {
  const BreedingEvent({
    required this.id,
    required this.animalId,
    required this.animalType,
    required this.eventType,
    required this.serviceDate,
    this.serviceMethod,
    this.sireName,
    this.sireBreed,
    this.expectedBirthDate,
    this.pregnancyResult,
    this.notes,
  });

  final String id;
  final String animalId;
  final String animalType;
  final String eventType;
  final String serviceDate;
  final String? serviceMethod;
  final String? sireName;
  final String? sireBreed;
  final String? expectedBirthDate;
  final String? pregnancyResult;
  final String? notes;

  factory BreedingEvent.fromJson(Map<String, dynamic> json) {
    return BreedingEvent(
      id: json['id'] as String? ?? '',
      animalId: json['animal_id'] as String? ?? '',
      animalType: json['animal_type'] as String? ?? '',
      eventType: json['event_type'] as String? ?? '',
      serviceDate: json['service_date'] as String? ?? '',
      serviceMethod: json['service_method'] as String?,
      sireName: json['sire_name'] as String?,
      sireBreed: json['sire_breed'] as String?,
      expectedBirthDate: json['expected_birth_date'] as String?,
      pregnancyResult: json['pregnancy_result'] as String?,
      notes: json['notes'] as String?,
    );
  }

  String get displayType => eventType.replaceAll('_', ' ').toUpperCase();

  BreedingEvent copyWith({
    String? id,
    String? animalId,
    String? animalType,
    String? eventType,
    String? serviceDate,
    String? serviceMethod,
    String? sireName,
    String? sireBreed,
    String? expectedBirthDate,
    String? pregnancyResult,
    String? notes,
  }) => BreedingEvent(
    id: id ?? this.id,
    animalId: animalId ?? this.animalId,
    animalType: animalType ?? this.animalType,
    eventType: eventType ?? this.eventType,
    serviceDate: serviceDate ?? this.serviceDate,
    serviceMethod: serviceMethod ?? this.serviceMethod,
    sireName: sireName ?? this.sireName,
    sireBreed: sireBreed ?? this.sireBreed,
    expectedBirthDate: expectedBirthDate ?? this.expectedBirthDate,
    pregnancyResult: pregnancyResult ?? this.pregnancyResult,
    notes: notes ?? this.notes,
  );
}

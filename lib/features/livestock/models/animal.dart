/// FMD zone classification for SA livestock movement compliance.
enum FmdZone {
  protectionZone,
  surveillanceZone,
  freeZone,
}

/// Represents a single livestock animal record from the API.
class Animal {
  const Animal({
    required this.id,
    required this.farmId,
    required this.species,
    required this.tagNumber,
    required this.name,
    required this.breed,
    required this.sex,
    required this.status,
    required this.productionType,
    this.dateOfBirth,
    this.ageMonths,
    this.currentWeightKg,
    this.lastWeighedDate,
    this.bodyConditionScore,
    this.locationPaddock,
    this.vaccinationStatus,
    this.lastHealthCheck,
    this.herdId,
    // SA Compliance fields
    this.rfidNumber,
    this.brandNumber,
    this.brandPosition,
    this.earmarkDesc,
    this.studBookNumber,
    this.fmdZone,
    this.rmisAnimalId,
    this.brucellaTested = false,
    this.brucellaTestDate,
    this.importPermitNo,
  });

  final String id;
  final String farmId;
  final String species;
  final String tagNumber;
  final String name;
  final String breed;
  final String sex;
  final String status;
  final String productionType;
  final String? dateOfBirth;
  final int? ageMonths;
  final double? currentWeightKg;
  final String? lastWeighedDate;
  final int? bodyConditionScore;
  final String? locationPaddock;
  final String? vaccinationStatus;
  final String? lastHealthCheck;
  final String? herdId;

  // ── SA Animal Identification Act 6/2002 compliance ──────────────────────────
  /// ISO 11784/11785 RFID tag number; linked to RMIS from Nov 2025
  final String? rfidNumber;

  /// Fire or freeze brand number (legally required for cattle in SA)
  final String? brandNumber;

  /// Brand position on body — e.g., "Left rib, T7"
  final String? brandPosition;

  /// Notarial earmark description per Animal Identification Act
  final String? earmarkDesc;

  /// SA Studbook registration number (stud animals)
  final String? studBookNumber;

  /// RMIS national traceability ID (mandatory from November 2025)
  final String? rmisAnimalId;

  /// FMD zone classification — affects movement permit requirements
  final FmdZone? fmdZone;

  /// Brucellosis test status (statutory for herd sales)
  final bool brucellaTested;

  /// Date of most recent Brucellosis test
  final String? brucellaTestDate;

  /// Import permit number (if applicable)
  final String? importPermitNo;

  bool get isActive => status == 'active';

  /// Whether this animal has been registered in RMIS
  bool get isRmisRegistered => rmisAnimalId != null && rmisAnimalId!.isNotEmpty;

  /// Whether this animal is in an FMD-restricted zone
  bool get isInFmdZone =>
      fmdZone == FmdZone.protectionZone ||
      fmdZone == FmdZone.surveillanceZone;

  factory Animal.fromJson(Map<String, dynamic> json) {
    FmdZone? fmdZone;
    final fmdZoneStr = json['fmd_zone'] as String?;
    if (fmdZoneStr != null) {
      fmdZone = switch (fmdZoneStr) {
        'protection_zone' => FmdZone.protectionZone,
        'surveillance_zone' => FmdZone.surveillanceZone,
        'free_zone' => FmdZone.freeZone,
        _ => null,
      };
    }

    return Animal(
      id: json['id'] as String? ?? '',
      farmId: json['farm_id'] as String? ?? '',
      species: json['species'] as String? ?? '',
      tagNumber: json['tag_number'] as String? ?? '',
      name: json['name'] as String? ?? '',
      breed: json['breed'] as String? ?? '',
      sex: json['sex'] as String? ?? '',
      status: json['status'] as String? ?? '',
      productionType: json['production_type'] as String? ?? '',
      dateOfBirth: json['date_of_birth'] as String?,
      ageMonths: json['age_months'] as int?,
      currentWeightKg: (json['current_weight_kg'] as num?)?.toDouble(),
      lastWeighedDate: json['last_weighed_date'] as String?,
      bodyConditionScore: json['body_condition_score'] as int?,
      locationPaddock: json['location_paddock'] as String?,
      vaccinationStatus: json['vaccination_status'] as String?,
      lastHealthCheck: json['last_health_check'] as String?,
      herdId: json['herd_id'] as String?,
      rfidNumber: json['rfid_number'] as String?,
      brandNumber: json['brand_number'] as String?,
      brandPosition: json['brand_position'] as String?,
      earmarkDesc: json['earmark_desc'] as String?,
      studBookNumber: json['stud_book_number'] as String?,
      rmisAnimalId: json['rmis_animal_id'] as String?,
      fmdZone: fmdZone,
      brucellaTested: json['brucella_tested'] as bool? ?? false,
      brucellaTestDate: json['brucella_test_date'] as String?,
      importPermitNo: json['import_permit_no'] as String?,
    );
  }

  String get displaySex => sex == 'male' ? 'Male' : 'Female';
  String get displayWeight =>
      currentWeightKg != null ? '${currentWeightKg!.toStringAsFixed(0)} kg' : '—';
  String get displayAge =>
      ageMonths != null ? '${ageMonths! ~/ 12}y ${ageMonths! % 12}m' : '—';

  String get displayFmdZone => switch (fmdZone) {
    FmdZone.protectionZone => 'Protection Zone',
    FmdZone.surveillanceZone => 'Surveillance Zone',
    FmdZone.freeZone => 'Free Zone',
    null => 'Unknown',
  };
}

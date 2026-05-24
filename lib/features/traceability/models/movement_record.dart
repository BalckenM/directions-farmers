/// Type of livestock movement per SA RMIS B313 permit categories.
enum MovementType {
  farmToFarm,
  farmToAbattoir,
  farmToAuction,
  auctionToFarm,
  importFromAbroad,
  exportToAbroad,
}

/// SA B313 Movement Permit record.
/// Required by the Animal Diseases Act 35/1984 and Animal Identification Act 6/2002.
/// From November 2025, all movements must be submitted to RMIS.
class MovementRecord {
  const MovementRecord({
    required this.id,
    required this.farmId,
    required this.movementDate,
    required this.species,
    required this.animalIds,
    required this.movementType,
    required this.fromLocation,
    required this.toLocation,
    this.fromFarmRegistrationNo,
    this.toFarmRegistrationNo,
    this.transporterName,
    this.vehicleRegNo,
    this.permitNumber,
    this.veterinaryHealthCertRef,
    this.moveInspectedBy,
    this.distanceKm,
    this.rmisSubmitted = false,
    this.rmisSubmitDate,
    this.rmisTransactionId,
    this.notes,
  });

  final String id;
  final String farmId;
  final String movementDate;
  final String species;

  /// List of animal IDs included in this movement
  final List<String> animalIds;

  final MovementType movementType;

  /// Departure property / facility name
  final String fromLocation;

  /// Destination property / abattoir / auction name
  final String toLocation;

  /// Livestock producer registration number of origin farm (DLRD)
  final String? fromFarmRegistrationNo;

  /// Livestock producer registration number of destination farm (DLRD)
  final String? toFarmRegistrationNo;

  /// Transport company or contractor name
  final String? transporterName;

  /// Vehicle registration number (truck/trailer)
  final String? vehicleRegNo;

  /// B313 permit number issued by the state vet
  final String? permitNumber;

  /// Veterinary Health Certificate reference (required for auction/export)
  final String? veterinaryHealthCertRef;

  /// Name/designation of inspection official
  final String? moveInspectedBy;

  /// Estimated transport distance (km)
  final double? distanceKm;

  /// Whether this movement has been submitted to RMIS
  final bool rmisSubmitted;

  /// Date RMIS submission was completed
  final String? rmisSubmitDate;

  /// RMIS transaction/submission ID
  final String? rmisTransactionId;

  final String? notes;

  /// Number of animals in this movement
  int get animalCount => animalIds.length;

  /// Whether this movement needs a veterinary health certificate
  bool get requiresVetCert =>
      movementType == MovementType.farmToAuction ||
      movementType == MovementType.exportToAbroad ||
      movementType == MovementType.importFromAbroad;

  String get displayMovementType => switch (movementType) {
    MovementType.farmToFarm => 'Farm to Farm',
    MovementType.farmToAbattoir => 'Farm to Abattoir',
    MovementType.farmToAuction => 'Farm to Auction',
    MovementType.auctionToFarm => 'Auction to Farm',
    MovementType.importFromAbroad => 'Import',
    MovementType.exportToAbroad => 'Export',
  };

  factory MovementRecord.fromJson(Map<String, dynamic> json) {
    MovementType type;
    final typeStr = json['movement_type'] as String? ?? '';
    type = switch (typeStr) {
      'farm_to_farm' => MovementType.farmToFarm,
      'farm_to_abattoir' => MovementType.farmToAbattoir,
      'farm_to_auction' => MovementType.farmToAuction,
      'auction_to_farm' => MovementType.auctionToFarm,
      'import' => MovementType.importFromAbroad,
      'export' => MovementType.exportToAbroad,
      _ => MovementType.farmToFarm,
    };

    final rawAnimalIds = json['animal_ids'];
    final animalIds = rawAnimalIds is List
        ? rawAnimalIds.map((e) => e.toString()).toList()
        : <String>[];

    return MovementRecord(
      id: json['id'] as String? ?? '',
      farmId: json['farm_id'] as String? ?? '',
      movementDate: json['movement_date'] as String? ?? '',
      species: json['species'] as String? ?? '',
      animalIds: animalIds,
      movementType: type,
      fromLocation: json['from_location'] as String? ?? '',
      toLocation: json['to_location'] as String? ?? '',
      fromFarmRegistrationNo: json['from_farm_registration_no'] as String?,
      toFarmRegistrationNo: json['to_farm_registration_no'] as String?,
      transporterName: json['transporter_name'] as String?,
      vehicleRegNo: json['vehicle_reg_no'] as String?,
      permitNumber: json['permit_number'] as String?,
      veterinaryHealthCertRef: json['veterinary_health_cert_ref'] as String?,
      moveInspectedBy: json['move_inspected_by'] as String?,
      distanceKm: (json['distance_km'] as num?)?.toDouble(),
      rmisSubmitted: json['rmis_submitted'] as bool? ?? false,
      rmisSubmitDate: json['rmis_submit_date'] as String?,
      rmisTransactionId: json['rmis_transaction_id'] as String?,
      notes: json['notes'] as String?,
    );
  }

  MovementRecord copyWith({
    String? id,
    String? farmId,
    String? movementDate,
    String? species,
    List<String>? animalIds,
    MovementType? movementType,
    String? fromLocation,
    String? toLocation,
    String? fromFarmRegistrationNo,
    String? toFarmRegistrationNo,
    String? transporterName,
    String? vehicleRegNo,
    String? permitNumber,
    String? veterinaryHealthCertRef,
    String? moveInspectedBy,
    double? distanceKm,
    bool? rmisSubmitted,
    String? rmisSubmitDate,
    String? rmisTransactionId,
    String? notes,
  }) => MovementRecord(
    id: id ?? this.id,
    farmId: farmId ?? this.farmId,
    movementDate: movementDate ?? this.movementDate,
    species: species ?? this.species,
    animalIds: animalIds ?? this.animalIds,
    movementType: movementType ?? this.movementType,
    fromLocation: fromLocation ?? this.fromLocation,
    toLocation: toLocation ?? this.toLocation,
    fromFarmRegistrationNo:
        fromFarmRegistrationNo ?? this.fromFarmRegistrationNo,
    toFarmRegistrationNo: toFarmRegistrationNo ?? this.toFarmRegistrationNo,
    transporterName: transporterName ?? this.transporterName,
    vehicleRegNo: vehicleRegNo ?? this.vehicleRegNo,
    permitNumber: permitNumber ?? this.permitNumber,
    veterinaryHealthCertRef:
        veterinaryHealthCertRef ?? this.veterinaryHealthCertRef,
    moveInspectedBy: moveInspectedBy ?? this.moveInspectedBy,
    distanceKm: distanceKm ?? this.distanceKm,
    rmisSubmitted: rmisSubmitted ?? this.rmisSubmitted,
    rmisSubmitDate: rmisSubmitDate ?? this.rmisSubmitDate,
    rmisTransactionId: rmisTransactionId ?? this.rmisTransactionId,
    notes: notes ?? this.notes,
  );
}

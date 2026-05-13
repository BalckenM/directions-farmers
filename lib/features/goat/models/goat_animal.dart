/// Individual goat / caprine animal record.
///
/// Goats are tracked individually (unlike poultry which uses a batch model).
/// Production-type-specific data is nested in [meatSpecific], [dairySpecific],
/// [fiberSpecific], or [breederSpecific].
class GoatAnimal {
  const GoatAnimal({
    required this.id,
    required this.farmId,
    required this.tagNumber,
    this.name,
    required this.breed,
    required this.productionType,
    required this.sex,
    required this.status,
    required this.herdId,
    required this.dateOfBirth,
    this.damId,
    this.sireId,
    this.purchaseDate,
    this.purchasePrice,
    this.currentWeightKg,
    this.targetWeightKg,
    this.bodyConditionScore,
    required this.isPregnant,
    this.expectedKiddingDate,
    this.lastKiddingDate,
    this.totalKidsRaised,
    required this.isLactating,
    this.dryOffDate,
    this.currentMilkLitrePd,
    this.lactationNumber,
    this.lastShearingDate,
    this.lastDewormingDate,
    this.famachaScore,
    this.registrationNumber,
    this.notes,
    this.createdAt,
    this.updatedAt,
    this.meatSpecific,
    this.dairySpecific,
    this.fiberSpecific,
    this.breederSpecific,
    // ── South African compliance ──────────────────────────────────────────
    this.brandNumber,
    this.brandPosition,
    this.earmarkDesc,
    this.brucellaTested = false,
    this.brucellaTestDate,
    this.fmdZone,
    this.rmisAnimalId,
    this.importPermitNo,
  });

  final String id;
  final String farmId;
  final String tagNumber;
  final String? name;
  final String breed;
  /// One of: meat / dairy / fiber / breeding / communal
  final String productionType;
  /// One of: doe / buck / kid_female / kid_male / wether
  final String sex;
  /// One of: active / sold / slaughtered / deceased / culled / dry
  final String status;
  final String herdId;
  /// ISO 8601 date string (YYYY-MM-DD)
  final String dateOfBirth;
  final String? damId;
  final String? sireId;
  final String? purchaseDate;
  final double? purchasePrice;
  final double? currentWeightKg;
  final double? targetWeightKg;
  /// Body condition score 1.0–5.0 (0.5 increments)
  final double? bodyConditionScore;
  final bool isPregnant;
  final String? expectedKiddingDate;
  final String? lastKiddingDate;
  final int? totalKidsRaised;
  final bool isLactating;
  final String? dryOffDate;
  final double? currentMilkLitrePd;
  final int? lactationNumber;
  final String? lastShearingDate;
  final String? lastDewormingDate;
  /// FAMACHA score 1–5 (1 = healthy, 5 = severely anaemic)
  final int? famachaScore;
  final String? registrationNumber;
  final String? notes;
  final String? createdAt;
  final String? updatedAt;

  // ── Type-specific nested data ─────────────────────────────────────────────
  final MeatSpecific? meatSpecific;
  final DairySpecific? dairySpecific;
  final FiberSpecific? fiberSpecific;
  final BreederSpecific? breederSpecific;

  // ── South African compliance fields ──────────────────────────────────────
  /// Brand number registered with the relevant provincial authority.
  final String? brandNumber;
  /// Body position of the brand (e.g. 'left rib', 'right hip').
  final String? brandPosition;
  /// Description of earmark notch pattern.
  final String? earmarkDesc;
  /// Whether the animal has a current brucellosis negative test certificate.
  final bool brucellaTested;
  /// Date of most recent brucellosis test (ISO 8601).
  final String? brucellaTestDate;
  /// Foot-and-Mouth Disease zone classification (e.g. 'free', 'protection', 'surveillance').
  final String? fmdZone;
  /// RMIS (Red Meat Industry Services) animal identifier.
  final String? rmisAnimalId;
  /// Import permit number (for animals imported into South Africa).
  final String? importPermitNo;

  // ── Computed helpers ──────────────────────────────────────────────────────

  /// Display name: prefers [name] if non-empty, otherwise [tagNumber].
  String get displayName =>
      (name != null && name!.isNotEmpty) ? name! : tagNumber;

  /// Age in complete months from [dateOfBirth] to today.
  int get ageMonths {
    try {
      final dob = DateTime.parse(dateOfBirth);
      final now = DateTime.now();
      return (now.difference(dob).inDays / 30.44).floor();
    } catch (_) {
      return 0;
    }
  }

  /// True when the animal is younger than 12 months.
  bool get isKid => ageMonths < 12;

  /// True for does and kid_females.
  bool get isFemale => sex == 'doe' || sex == 'kid_female';

  /// True for bucks, wethers, and kid_males.
  bool get isMale => sex == 'buck' || sex == 'kid_male' || sex == 'wether';

  /// True when the animal's status is not a terminal/exit status.
  bool get isAlive =>
      status != 'sold' &&
      status != 'slaughtered' &&
      status != 'deceased' &&
      status != 'culled';

  // ── copyWith ──────────────────────────────────────────────────────────────
  GoatAnimal copyWith({
    String? id,
    String? farmId,
    String? tagNumber,
    String? name,
    String? breed,
    String? productionType,
    String? sex,
    String? status,
    String? herdId,
    String? dateOfBirth,
    String? damId,
    String? sireId,
    String? purchaseDate,
    double? purchasePrice,
    double? currentWeightKg,
    double? targetWeightKg,
    double? bodyConditionScore,
    bool? isPregnant,
    String? expectedKiddingDate,
    String? lastKiddingDate,
    int? totalKidsRaised,
    bool? isLactating,
    String? dryOffDate,
    double? currentMilkLitrePd,
    int? lactationNumber,
    String? lastShearingDate,
    String? lastDewormingDate,
    int? famachaScore,
    String? registrationNumber,
    String? notes,
    String? createdAt,
    String? updatedAt,
    MeatSpecific? meatSpecific,
    DairySpecific? dairySpecific,
    FiberSpecific? fiberSpecific,
    BreederSpecific? breederSpecific,
    String? brandNumber,
    String? brandPosition,
    String? earmarkDesc,
    bool? brucellaTested,
    String? brucellaTestDate,
    String? fmdZone,
    String? rmisAnimalId,
    String? importPermitNo,
  }) =>
      GoatAnimal(
        id: id ?? this.id,
        farmId: farmId ?? this.farmId,
        tagNumber: tagNumber ?? this.tagNumber,
        name: name ?? this.name,
        breed: breed ?? this.breed,
        productionType: productionType ?? this.productionType,
        sex: sex ?? this.sex,
        status: status ?? this.status,
        herdId: herdId ?? this.herdId,
        dateOfBirth: dateOfBirth ?? this.dateOfBirth,
        damId: damId ?? this.damId,
        sireId: sireId ?? this.sireId,
        purchaseDate: purchaseDate ?? this.purchaseDate,
        purchasePrice: purchasePrice ?? this.purchasePrice,
        currentWeightKg: currentWeightKg ?? this.currentWeightKg,
        targetWeightKg: targetWeightKg ?? this.targetWeightKg,
        bodyConditionScore: bodyConditionScore ?? this.bodyConditionScore,
        isPregnant: isPregnant ?? this.isPregnant,
        expectedKiddingDate: expectedKiddingDate ?? this.expectedKiddingDate,
        lastKiddingDate: lastKiddingDate ?? this.lastKiddingDate,
        totalKidsRaised: totalKidsRaised ?? this.totalKidsRaised,
        isLactating: isLactating ?? this.isLactating,
        dryOffDate: dryOffDate ?? this.dryOffDate,
        currentMilkLitrePd: currentMilkLitrePd ?? this.currentMilkLitrePd,
        lactationNumber: lactationNumber ?? this.lactationNumber,
        lastShearingDate: lastShearingDate ?? this.lastShearingDate,
        lastDewormingDate: lastDewormingDate ?? this.lastDewormingDate,
        famachaScore: famachaScore ?? this.famachaScore,
        registrationNumber: registrationNumber ?? this.registrationNumber,
        notes: notes ?? this.notes,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        meatSpecific: meatSpecific ?? this.meatSpecific,
        dairySpecific: dairySpecific ?? this.dairySpecific,
        fiberSpecific: fiberSpecific ?? this.fiberSpecific,
        breederSpecific: breederSpecific ?? this.breederSpecific,
        brandNumber: brandNumber ?? this.brandNumber,
        brandPosition: brandPosition ?? this.brandPosition,
        earmarkDesc: earmarkDesc ?? this.earmarkDesc,
        brucellaTested: brucellaTested ?? this.brucellaTested,
        brucellaTestDate: brucellaTestDate ?? this.brucellaTestDate,
        fmdZone: fmdZone ?? this.fmdZone,
        rmisAnimalId: rmisAnimalId ?? this.rmisAnimalId,
        importPermitNo: importPermitNo ?? this.importPermitNo,
      );

  factory GoatAnimal.fromJson(Map<String, dynamic> j) => GoatAnimal(
        id: j['id'] as String,
        farmId: j['farmId'] as String,
        tagNumber: j['tagNumber'] as String,
        name: j['name'] as String?,
        breed: j['breed'] as String,
        productionType: j['productionType'] as String,
        sex: j['sex'] as String,
        status: j['status'] as String,
        herdId: j['herdId'] as String,
        dateOfBirth: j['dateOfBirth'] as String,
        damId: j['damId'] as String?,
        sireId: j['sireId'] as String?,
        purchaseDate: j['purchaseDate'] as String?,
        purchasePrice: (j['purchasePrice'] as num?)?.toDouble(),
        currentWeightKg: (j['currentWeightKg'] as num?)?.toDouble(),
        targetWeightKg: (j['targetWeightKg'] as num?)?.toDouble(),
        bodyConditionScore: (j['bodyConditionScore'] as num?)?.toDouble(),
        isPregnant: j['isPregnant'] as bool? ?? false,
        expectedKiddingDate: j['expectedKiddingDate'] as String?,
        lastKiddingDate: j['lastKiddingDate'] as String?,
        totalKidsRaised: j['totalKidsRaised'] as int?,
        isLactating: j['isLactating'] as bool? ?? false,
        dryOffDate: j['dryOffDate'] as String?,
        currentMilkLitrePd: (j['currentMilkLitrePd'] as num?)?.toDouble(),
        lactationNumber: j['lactationNumber'] as int?,
        lastShearingDate: j['lastShearingDate'] as String?,
        lastDewormingDate: j['lastDewormingDate'] as String?,
        famachaScore: j['famachaScore'] as int?,
        registrationNumber: j['registrationNumber'] as String?,
        notes: j['notes'] as String?,
        createdAt: j['createdAt'] as String?,
        updatedAt: j['updatedAt'] as String?,
        meatSpecific: j['meatSpecific'] != null
            ? MeatSpecific.fromJson(j['meatSpecific'] as Map<String, dynamic>)
            : null,
        dairySpecific: j['dairySpecific'] != null
            ? DairySpecific.fromJson(j['dairySpecific'] as Map<String, dynamic>)
            : null,
        fiberSpecific: j['fiberSpecific'] != null
            ? FiberSpecific.fromJson(j['fiberSpecific'] as Map<String, dynamic>)
            : null,
        breederSpecific: j['breederSpecific'] != null
            ? BreederSpecific.fromJson(
                j['breederSpecific'] as Map<String, dynamic>)
            : null,
        brandNumber: j['brandNumber'] as String?,
        brandPosition: j['brandPosition'] as String?,
        earmarkDesc: j['earmarkDesc'] as String?,
        brucellaTested: j['brucellaTested'] as bool? ?? false,
        brucellaTestDate: j['brucellaTestDate'] as String?,
        fmdZone: j['fmdZone'] as String?,
        rmisAnimalId: j['rmisAnimalId'] as String?,
        importPermitNo: j['importPermitNo'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'farmId': farmId,
        'tagNumber': tagNumber,
        if (name != null) 'name': name,
        'breed': breed,
        'productionType': productionType,
        'sex': sex,
        'status': status,
        'herdId': herdId,
        'dateOfBirth': dateOfBirth,
        if (damId != null) 'damId': damId,
        if (sireId != null) 'sireId': sireId,
        if (purchaseDate != null) 'purchaseDate': purchaseDate,
        if (purchasePrice != null) 'purchasePrice': purchasePrice,
        if (currentWeightKg != null) 'currentWeightKg': currentWeightKg,
        if (targetWeightKg != null) 'targetWeightKg': targetWeightKg,
        if (bodyConditionScore != null)
          'bodyConditionScore': bodyConditionScore,
        'isPregnant': isPregnant,
        if (expectedKiddingDate != null)
          'expectedKiddingDate': expectedKiddingDate,
        if (lastKiddingDate != null) 'lastKiddingDate': lastKiddingDate,
        if (totalKidsRaised != null) 'totalKidsRaised': totalKidsRaised,
        'isLactating': isLactating,
        if (dryOffDate != null) 'dryOffDate': dryOffDate,
        if (currentMilkLitrePd != null)
          'currentMilkLitrePd': currentMilkLitrePd,
        if (lactationNumber != null) 'lactationNumber': lactationNumber,
        if (lastShearingDate != null) 'lastShearingDate': lastShearingDate,
        if (lastDewormingDate != null) 'lastDewormingDate': lastDewormingDate,
        if (famachaScore != null) 'famachaScore': famachaScore,
        if (registrationNumber != null)
          'registrationNumber': registrationNumber,
        if (notes != null) 'notes': notes,
        if (meatSpecific != null) 'meatSpecific': meatSpecific!.toJson(),
        if (dairySpecific != null) 'dairySpecific': dairySpecific!.toJson(),
        if (fiberSpecific != null) 'fiberSpecific': fiberSpecific!.toJson(),
        if (breederSpecific != null)
          'breederSpecific': breederSpecific!.toJson(),
        if (brandNumber != null) 'brandNumber': brandNumber,
        if (brandPosition != null) 'brandPosition': brandPosition,
        if (earmarkDesc != null) 'earmarkDesc': earmarkDesc,
        'brucellaTested': brucellaTested,
        if (brucellaTestDate != null) 'brucellaTestDate': brucellaTestDate,
        if (fmdZone != null) 'fmdZone': fmdZone,
        if (rmisAnimalId != null) 'rmisAnimalId': rmisAnimalId,
        if (importPermitNo != null) 'importPermitNo': importPermitNo,
      };
}

// ── Production-type-specific nested classes ───────────────────────────────────

class MeatSpecific {
  const MeatSpecific({
    this.adgGPerDay,
    this.targetSlaughterAgeMonths,
    this.dressingPct,
  });

  final double? adgGPerDay;
  final int? targetSlaughterAgeMonths;
  final double? dressingPct;

  factory MeatSpecific.fromJson(Map<String, dynamic> j) => MeatSpecific(
        adgGPerDay: (j['adgGPerDay'] as num?)?.toDouble(),
        targetSlaughterAgeMonths: j['targetSlaughterAgeMonths'] as int?,
        dressingPct: (j['dressingPct'] as num?)?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        if (adgGPerDay != null) 'adgGPerDay': adgGPerDay,
        if (targetSlaughterAgeMonths != null)
          'targetSlaughterAgeMonths': targetSlaughterAgeMonths,
        if (dressingPct != null) 'dressingPct': dressingPct,
      };
}

class DairySpecific {
  const DairySpecific({
    this.peakMilkLitrePd,
    this.totalMilkThisLactation,
    this.dryMatterIntakeKgPd,
    this.milkFatPct,
    this.milkProteinPct,
    this.projectedDryOffDate,
  });

  final double? peakMilkLitrePd;
  final double? totalMilkThisLactation;
  final double? dryMatterIntakeKgPd;
  final double? milkFatPct;
  final double? milkProteinPct;
  final String? projectedDryOffDate;

  factory DairySpecific.fromJson(Map<String, dynamic> j) => DairySpecific(
        peakMilkLitrePd: (j['peakMilkLitrePd'] as num?)?.toDouble(),
        totalMilkThisLactation:
            (j['totalMilkThisLactation'] as num?)?.toDouble(),
        dryMatterIntakeKgPd: (j['dryMatterIntakeKgPd'] as num?)?.toDouble(),
        milkFatPct: (j['milkFatPct'] as num?)?.toDouble(),
        milkProteinPct: (j['milkProteinPct'] as num?)?.toDouble(),
        projectedDryOffDate: j['projectedDryOffDate'] as String?,
      );

  Map<String, dynamic> toJson() => {
        if (peakMilkLitrePd != null) 'peakMilkLitrePd': peakMilkLitrePd,
        if (totalMilkThisLactation != null)
          'totalMilkThisLactation': totalMilkThisLactation,
        if (dryMatterIntakeKgPd != null)
          'dryMatterIntakeKgPd': dryMatterIntakeKgPd,
        if (milkFatPct != null) 'milkFatPct': milkFatPct,
        if (milkProteinPct != null) 'milkProteinPct': milkProteinPct,
        if (projectedDryOffDate != null)
          'projectedDryOffDate': projectedDryOffDate,
      };
}

class FiberSpecific {
  const FiberSpecific({
    this.avgFleeceMassKg,
    this.stapleLength,
    this.micronRating,
    this.colorGrade,
    this.lastMohairPricePerKg,
  });

  final double? avgFleeceMassKg;
  final double? stapleLength;
  final double? micronRating;
  final String? colorGrade;
  final double? lastMohairPricePerKg;

  factory FiberSpecific.fromJson(Map<String, dynamic> j) => FiberSpecific(
        avgFleeceMassKg: (j['avgFleeceMassKg'] as num?)?.toDouble(),
        stapleLength: (j['stapleLength'] as num?)?.toDouble(),
        micronRating: (j['micronRating'] as num?)?.toDouble(),
        colorGrade: j['colorGrade'] as String?,
        lastMohairPricePerKg: (j['lastMohairPricePerKg'] as num?)?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        if (avgFleeceMassKg != null) 'avgFleeceMassKg': avgFleeceMassKg,
        if (stapleLength != null) 'stapleLength': stapleLength,
        if (micronRating != null) 'micronRating': micronRating,
        if (colorGrade != null) 'colorGrade': colorGrade,
        if (lastMohairPricePerKg != null)
          'lastMohairPricePerKg': lastMohairPricePerKg,
      };
}

class BreederSpecific {
  const BreederSpecific({
    this.studBookNumber,
    this.registeredBreeder = false,
    this.breedingFee,
    this.doesServedCount,
    this.kidRatio,
  });

  final String? studBookNumber;
  final bool registeredBreeder;
  final double? breedingFee;
  final int? doesServedCount;
  final double? kidRatio;

  factory BreederSpecific.fromJson(Map<String, dynamic> j) => BreederSpecific(
        studBookNumber: j['studBookNumber'] as String?,
        registeredBreeder: j['registeredBreeder'] as bool? ?? false,
        breedingFee: (j['breedingFee'] as num?)?.toDouble(),
        doesServedCount: j['doesServedCount'] as int?,
        kidRatio: (j['kidRatio'] as num?)?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        if (studBookNumber != null) 'studBookNumber': studBookNumber,
        'registeredBreeder': registeredBreeder,
        if (breedingFee != null) 'breedingFee': breedingFee,
        if (doesServedCount != null) 'doesServedCount': doesServedCount,
        if (kidRatio != null) 'kidRatio': kidRatio,
      };
}

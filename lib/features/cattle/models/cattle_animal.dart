/// Individual cattle / bovine animal record.
///
/// Each animal carries a [productionType] of either 'beef' or 'dairy'.
/// Beef-specific metrics live in [beefSpecific]; dairy metrics in [dairySpecific].
/// FAMACHA is not used for cattle (goat/sheep only).
/// [DippingRecord] is cattle-specific and stored in cattle_records.dart.
class CattleAnimal {
  const CattleAnimal({
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
    this.expectedCalvingDate,
    this.lastCalvingDate,
    this.totalCalvesRaised,
    required this.isLactating,
    this.dryOffDate,
    this.currentMilkLitrePd,
    this.lactationNumber,
    this.lastDewormingDate,
    this.lastDippingDate,
    this.registrationNumber,
    this.notes,
    this.createdAt,
    this.updatedAt,
    this.beefSpecific,
    this.dairySpecific,
    // ── South African compliance ──────────────────────────────────────────────
    this.brandNumber,
    this.brandPosition,
    this.earmarkDesc,
    this.brucellaTested = false,
    this.brucellaTestDate,
    this.fmdZone,
    this.niisEidNumber,
  });

  final String id;
  final String farmId;
  final String tagNumber;
  final String? name;
  final String breed;

  /// One of: beef / dairy
  final String productionType;

  /// One of: cow / bull / heifer / steer / calf_female / calf_male
  final String sex;

  /// One of: active / sold / deceased / culled
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
  final String? expectedCalvingDate;
  final String? lastCalvingDate;
  final int? totalCalvesRaised;
  final bool isLactating;
  final String? dryOffDate;
  final double? currentMilkLitrePd;
  final int? lactationNumber;
  final String? lastDewormingDate;

  /// Date of most recent dipping treatment (cattle-specific).
  final String? lastDippingDate;

  final String? registrationNumber;
  final String? notes;
  final String? createdAt;
  final String? updatedAt;

  // ── Type-specific nested data ─────────────────────────────────────────────────
  final BeefSpecific? beefSpecific;
  final DairySpecific? dairySpecific;

  // ── South African compliance fields ──────────────────────────────────────────
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

  /// NIIS (National Identification and Information System) electronic ID number.
  final String? niisEidNumber;

  // ── Computed helpers ──────────────────────────────────────────────────────────

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
  bool get isCalf => ageMonths < 12;

  /// True for cows, heifers, and calf_females.
  bool get isFemale =>
      sex == 'cow' || sex == 'heifer' || sex == 'calf_female';

  /// True for bulls, steers, and calf_males.
  bool get isMale =>
      sex == 'bull' || sex == 'steer' || sex == 'calf_male';

  /// True when the animal's status is not a terminal/exit status.
  bool get isAlive =>
      status != 'sold' && status != 'deceased' && status != 'culled';

  // ── copyWith ──────────────────────────────────────────────────────────────────
  CattleAnimal copyWith({
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
    String? expectedCalvingDate,
    String? lastCalvingDate,
    int? totalCalvesRaised,
    bool? isLactating,
    String? dryOffDate,
    double? currentMilkLitrePd,
    int? lactationNumber,
    String? lastDewormingDate,
    String? lastDippingDate,
    String? registrationNumber,
    String? notes,
    String? createdAt,
    String? updatedAt,
    BeefSpecific? beefSpecific,
    DairySpecific? dairySpecific,
    String? brandNumber,
    String? brandPosition,
    String? earmarkDesc,
    bool? brucellaTested,
    String? brucellaTestDate,
    String? fmdZone,
    String? niisEidNumber,
  }) =>
      CattleAnimal(
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
        expectedCalvingDate: expectedCalvingDate ?? this.expectedCalvingDate,
        lastCalvingDate: lastCalvingDate ?? this.lastCalvingDate,
        totalCalvesRaised: totalCalvesRaised ?? this.totalCalvesRaised,
        isLactating: isLactating ?? this.isLactating,
        dryOffDate: dryOffDate ?? this.dryOffDate,
        currentMilkLitrePd: currentMilkLitrePd ?? this.currentMilkLitrePd,
        lactationNumber: lactationNumber ?? this.lactationNumber,
        lastDewormingDate: lastDewormingDate ?? this.lastDewormingDate,
        lastDippingDate: lastDippingDate ?? this.lastDippingDate,
        registrationNumber: registrationNumber ?? this.registrationNumber,
        notes: notes ?? this.notes,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        beefSpecific: beefSpecific ?? this.beefSpecific,
        dairySpecific: dairySpecific ?? this.dairySpecific,
        brandNumber: brandNumber ?? this.brandNumber,
        brandPosition: brandPosition ?? this.brandPosition,
        earmarkDesc: earmarkDesc ?? this.earmarkDesc,
        brucellaTested: brucellaTested ?? this.brucellaTested,
        brucellaTestDate: brucellaTestDate ?? this.brucellaTestDate,
        fmdZone: fmdZone ?? this.fmdZone,
        niisEidNumber: niisEidNumber ?? this.niisEidNumber,
      );

  factory CattleAnimal.fromJson(Map<String, dynamic> j) => CattleAnimal(
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
        expectedCalvingDate: j['expectedCalvingDate'] as String?,
        lastCalvingDate: j['lastCalvingDate'] as String?,
        totalCalvesRaised: j['totalCalvesRaised'] as int?,
        isLactating: j['isLactating'] as bool? ?? false,
        dryOffDate: j['dryOffDate'] as String?,
        currentMilkLitrePd: (j['currentMilkLitrePd'] as num?)?.toDouble(),
        lactationNumber: j['lactationNumber'] as int?,
        lastDewormingDate: j['lastDewormingDate'] as String?,
        lastDippingDate: j['lastDippingDate'] as String?,
        registrationNumber: j['registrationNumber'] as String?,
        notes: j['notes'] as String?,
        createdAt: j['createdAt'] as String?,
        updatedAt: j['updatedAt'] as String?,
        beefSpecific: j['beefSpecific'] != null
            ? BeefSpecific.fromJson(
                j['beefSpecific'] as Map<String, dynamic>)
            : null,
        dairySpecific: j['dairySpecific'] != null
            ? DairySpecific.fromJson(
                j['dairySpecific'] as Map<String, dynamic>)
            : null,
        brandNumber: j['brandNumber'] as String?,
        brandPosition: j['brandPosition'] as String?,
        earmarkDesc: j['earmarkDesc'] as String?,
        brucellaTested: j['brucellaTested'] as bool? ?? false,
        brucellaTestDate: j['brucellaTestDate'] as String?,
        fmdZone: j['fmdZone'] as String?,
        niisEidNumber: j['niisEidNumber'] as String?,
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
        if (bodyConditionScore != null) 'bodyConditionScore': bodyConditionScore,
        'isPregnant': isPregnant,
        if (expectedCalvingDate != null) 'expectedCalvingDate': expectedCalvingDate,
        if (lastCalvingDate != null) 'lastCalvingDate': lastCalvingDate,
        if (totalCalvesRaised != null) 'totalCalvesRaised': totalCalvesRaised,
        'isLactating': isLactating,
        if (dryOffDate != null) 'dryOffDate': dryOffDate,
        if (currentMilkLitrePd != null) 'currentMilkLitrePd': currentMilkLitrePd,
        if (lactationNumber != null) 'lactationNumber': lactationNumber,
        if (lastDewormingDate != null) 'lastDewormingDate': lastDewormingDate,
        if (lastDippingDate != null) 'lastDippingDate': lastDippingDate,
        if (registrationNumber != null) 'registrationNumber': registrationNumber,
        if (notes != null) 'notes': notes,
        if (createdAt != null) 'createdAt': createdAt,
        if (updatedAt != null) 'updatedAt': updatedAt,
        if (beefSpecific != null) 'beefSpecific': beefSpecific!.toJson(),
        if (dairySpecific != null) 'dairySpecific': dairySpecific!.toJson(),
        if (brandNumber != null) 'brandNumber': brandNumber,
        if (brandPosition != null) 'brandPosition': brandPosition,
        if (earmarkDesc != null) 'earmarkDesc': earmarkDesc,
        'brucellaTested': brucellaTested,
        if (brucellaTestDate != null) 'brucellaTestDate': brucellaTestDate,
        if (fmdZone != null) 'fmdZone': fmdZone,
        if (niisEidNumber != null) 'niisEidNumber': niisEidNumber,
      };
}

// ── Production-type-specific nested classes ───────────────────────────────────

/// Beef-specific performance metrics.
class BeefSpecific {
  const BeefSpecific({
    this.averageDailyGainKg,
    this.feedConversionRatio,
    this.feedlotPenId,
    this.slaughterWeightKg,
    this.dressingPercent,
  });

  /// Average daily gain in kg/day.
  final double? averageDailyGainKg;

  /// Feed conversion ratio: kg feed per kg of liveweight gain.
  final double? feedConversionRatio;

  /// Feedlot pen identifier (if on feed).
  final String? feedlotPenId;

  /// Target or actual slaughter weight in kg.
  final double? slaughterWeightKg;

  /// Dressing percentage (carcass weight / live weight × 100).
  final double? dressingPercent;

  factory BeefSpecific.fromJson(Map<String, dynamic> j) => BeefSpecific(
        averageDailyGainKg: (j['averageDailyGainKg'] as num?)?.toDouble(),
        feedConversionRatio: (j['feedConversionRatio'] as num?)?.toDouble(),
        feedlotPenId: j['feedlotPenId'] as String?,
        slaughterWeightKg: (j['slaughterWeightKg'] as num?)?.toDouble(),
        dressingPercent: (j['dressingPercent'] as num?)?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        if (averageDailyGainKg != null) 'averageDailyGainKg': averageDailyGainKg,
        if (feedConversionRatio != null) 'feedConversionRatio': feedConversionRatio,
        if (feedlotPenId != null) 'feedlotPenId': feedlotPenId,
        if (slaughterWeightKg != null) 'slaughterWeightKg': slaughterWeightKg,
        if (dressingPercent != null) 'dressingPercent': dressingPercent,
      };
}

/// Dairy-specific production metrics.
class DairySpecific {
  const DairySpecific({
    this.somaticCellCount,
    this.butterfatPct,
    this.proteinPct,
    this.milkingSchedule,
    this.totalMilkThisLactation,
    this.peakMilkLitrePd,
  });

  /// Somatic cell count (cells/mL) — indicator of udder health.
  final int? somaticCellCount;

  /// Butterfat percentage of milk.
  final double? butterfatPct;

  /// Protein percentage of milk.
  final double? proteinPct;

  /// Milking schedule: 'once' | 'twice' | 'thrice'
  final String? milkingSchedule;

  /// Cumulative milk yield this lactation in litres.
  final double? totalMilkThisLactation;

  /// Peak daily yield in litres per day during this lactation.
  final double? peakMilkLitrePd;

  factory DairySpecific.fromJson(Map<String, dynamic> j) => DairySpecific(
        somaticCellCount: j['somaticCellCount'] as int?,
        butterfatPct: (j['butterfatPct'] as num?)?.toDouble(),
        proteinPct: (j['proteinPct'] as num?)?.toDouble(),
        milkingSchedule: j['milkingSchedule'] as String?,
        totalMilkThisLactation:
            (j['totalMilkThisLactation'] as num?)?.toDouble(),
        peakMilkLitrePd: (j['peakMilkLitrePd'] as num?)?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        if (somaticCellCount != null) 'somaticCellCount': somaticCellCount,
        if (butterfatPct != null) 'butterfatPct': butterfatPct,
        if (proteinPct != null) 'proteinPct': proteinPct,
        if (milkingSchedule != null) 'milkingSchedule': milkingSchedule,
        if (totalMilkThisLactation != null)
          'totalMilkThisLactation': totalMilkThisLactation,
        if (peakMilkLitrePd != null) 'peakMilkLitrePd': peakMilkLitrePd,
      };
}

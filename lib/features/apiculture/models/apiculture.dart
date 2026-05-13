/// Apiculture (bee-keeping) domain models.
///
/// Models: [Apiary], [Hive], [HiveInspection].
/// SA alert thresholds:
///   Varroa infestation rate > 3 %  → treatment needed
///   Inspection overdue             → [Hive.inspectionOverdue] == true
library;

// ── Apiary ────────────────────────────────────────────────────────────────────

/// A managed group of hives at a single location.
class Apiary {
  const Apiary({
    required this.id,
    required this.farmId,
    required this.apiaryName,
    this.locationDescription,
    this.forageDescription,
    this.accessNotes,
    this.waterSourceNearby,
    required this.totalHives,
  });

  final String id;
  final String farmId;
  final String apiaryName;
  final String? locationDescription;
  final String? forageDescription;
  final String? accessNotes;
  final bool? waterSourceNearby;
  final int totalHives;

  factory Apiary.fromJson(Map<String, dynamic> json) => Apiary(
        id: json['id'] as String? ?? '',
        farmId: json['farm_id'] as String? ?? '',
        apiaryName: json['apiary_name'] as String? ?? '',
        locationDescription: json['location_description'] as String?,
        forageDescription: json['forage_description'] as String?,
        accessNotes: json['access_notes'] as String?,
        waterSourceNearby: json['water_source_nearby'] as bool?,
        totalHives: json['total_hives'] as int? ?? 0,
      );
}

// ── Hive ──────────────────────────────────────────────────────────────────────

/// A single managed bee colony / hive box.
class Hive {
  const Hive({
    required this.id,
    required this.apiaryId,
    required this.farmId,
    required this.hiveNumber,
    required this.hiveType,
    required this.beeSubspecies,
    this.origin,
    this.installationDate,
    required this.hiveStatus,
    this.queenAgeMonths,
    this.queenMarked,
    this.queenColorYear,
    this.queenStatus,
    this.colonyStrengthScore,
    this.supersOn,
    this.honeyStoresFrames,
    this.lastInspectionDate,
    this.nextInspectionDue,
    this.inspectionOverdue,
    this.varroaLastCountDate,
    this.varroaInfestationRatePct,
    this.totalHoneyHarvestedKg,
  });

  final String id;
  final String apiaryId;
  final String farmId;

  /// e.g. "H-001"
  final String hiveNumber;

  /// 'Langstroth' | 'Warre' | 'Top-bar' | 'Dadant'
  final String hiveType;

  /// 'Apis mellifera scutellata' | 'Apis mellifera capensis' etc.
  final String beeSubspecies;
  final String? origin;
  final String? installationDate;

  /// 'active' | 'queenless' | 'absconded' | 'dead'
  final String hiveStatus;

  final int? queenAgeMonths;
  final bool? queenMarked;
  final String? queenColorYear;

  /// 'present_laying' | 'present_not_laying' | 'absent' | 'supersedure'
  final String? queenStatus;

  /// Colony strength 1–10 (frames of bees).
  final int? colonyStrengthScore;

  /// Number of honey supers currently on the hive.
  final int? supersOn;
  final double? honeyStoresFrames;
  final String? lastInspectionDate;
  final String? nextInspectionDue;
  final bool? inspectionOverdue;
  final String? varroaLastCountDate;

  /// Varroa infestation rate as a percentage (> 3 % = treatment needed).
  final double? varroaInfestationRatePct;
  final double? totalHoneyHarvestedKg;

  // ── Alert helpers ─────────────────────────────────────────────────────────────

  bool get isVarroaAlert =>
      varroaInfestationRatePct != null && varroaInfestationRatePct! > 3.0;

  bool get isQueenAlert =>
      queenStatus == 'absent' || hiveStatus == 'queenless';

  bool get isActive => hiveStatus == 'active';

  factory Hive.fromJson(Map<String, dynamic> json) => Hive(
        id: json['id'] as String? ?? '',
        apiaryId: json['apiary_id'] as String? ?? '',
        farmId: json['farm_id'] as String? ?? '',
        hiveNumber: json['hive_number'] as String? ?? '',
        hiveType: json['hive_type'] as String? ?? '',
        beeSubspecies: json['bee_subspecies'] as String? ?? '',
        origin: json['origin'] as String?,
        installationDate: json['installation_date'] as String?,
        hiveStatus: json['hive_status'] as String? ?? 'active',
        queenAgeMonths: json['queen_age_months'] as int?,
        queenMarked: json['queen_marked'] as bool?,
        queenColorYear: json['queen_color_year'] as String?,
        queenStatus: json['queen_status'] as String?,
        colonyStrengthScore: json['colony_strength_score'] as int?,
        supersOn: json['supers_on'] as int?,
        honeyStoresFrames:
            (json['honey_stores_frames'] as num?)?.toDouble(),
        lastInspectionDate: json['last_inspection_date'] as String?,
        nextInspectionDue: json['next_inspection_due'] as String?,
        inspectionOverdue: json['inspection_overdue'] as bool?,
        varroaLastCountDate: json['varroa_last_count_date'] as String?,
        varroaInfestationRatePct:
            (json['varroa_infestation_rate_pct'] as num?)?.toDouble(),
        totalHoneyHarvestedKg:
            (json['total_honey_harvested_kg'] as num?)?.toDouble(),
      );
}

// ── HiveInspection ────────────────────────────────────────────────────────────

/// A single hive inspection record.
class HiveInspection {
  const HiveInspection({
    required this.id,
    required this.hiveId,
    required this.inspectionDate,
    this.inspector,
    this.weather,
    this.colonyTemperament,
    this.beePopulationFrames,
    this.broodFrames,
    this.broodPattern,
    this.queenSeen,
    this.queenCondition,
    this.eggsSeen,
    this.honeyStoresFrames,
    this.swarmCellsPresent,
    this.supersedureCells,
    this.diseaseSigns,
    this.actionTaken,
    this.nextInspectionDate,
  });

  final String id;
  final String hiveId;
  final String inspectionDate;
  final String? inspector;
  final String? weather;
  final String? colonyTemperament;
  final int? beePopulationFrames;
  final int? broodFrames;

  /// 'solid' | 'spotty' | 'poor'
  final String? broodPattern;
  final bool? queenSeen;
  final String? queenCondition;
  final bool? eggsSeen;
  final double? honeyStoresFrames;
  final bool? swarmCellsPresent;
  final bool? supersedureCells;
  final String? diseaseSigns;
  final String? actionTaken;
  final String? nextInspectionDate;

  factory HiveInspection.fromJson(Map<String, dynamic> json) =>
      HiveInspection(
        id: json['id'] as String? ?? '',
        hiveId: json['hive_id'] as String? ?? '',
        inspectionDate: json['inspection_date'] as String? ?? '',
        inspector: json['inspector'] as String?,
        weather: json['weather'] as String?,
        colonyTemperament: json['colony_temperament'] as String?,
        beePopulationFrames: json['bee_population_frames'] as int?,
        broodFrames: json['brood_frames'] as int?,
        broodPattern: json['brood_pattern'] as String?,
        queenSeen: json['queen_seen'] as bool?,
        queenCondition: json['queen_condition'] as String?,
        eggsSeen: json['eggs_seen'] as bool?,
        honeyStoresFrames:
            (json['honey_stores_frames'] as num?)?.toDouble(),
        swarmCellsPresent: json['swarm_cells_present'] as bool?,
        supersedureCells: json['supersedure_cells'] as bool?,
        diseaseSigns: json['disease_signs'] as String?,
        actionTaken: json['action_taken'] as String?,
        nextInspectionDate: json['next_inspection_date'] as String?,
      );
}

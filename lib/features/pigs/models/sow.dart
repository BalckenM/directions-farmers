/// Pig / swine domain models.
///
/// Models: [Sow], [PigSpecific], [FarrowingRecord], [SowServiceRecord].
/// SA alert thresholds:
///   PSY < 22               → alert
///   Pre-wean mortality > 12 % → warning
///   BCS 3 / 5 is optimal   → BCS < 2.5 or BCS > 3.5 = concern
library;

// ── PigSpecific ───────────────────────────────────────────────────────────────

/// Pig-specific reproductive and production data embedded in a [Sow].
class PigSpecific {
  const PigSpecific({
    this.parity,
    this.currentStage,
    this.backfatMm,
    this.weanToServiceDays,
    this.totalBornAliveLifetime,
    this.psyCurrentYear,
    this.lastServiceDate,
    this.expectedFarrowingDate,
    this.farrowingDateActual,
    this.totalBorn,
    this.bornAlive,
    this.bornDead,
    this.currentLitterWeaned,
    this.avgBirthWeightKg,
    this.preWeanMortalityPct,
  });

  /// Litter number (0 = gilt, 1 = first parity, etc.).
  final int? parity;

  /// 'Service' | 'Gestation' | 'Farrowing' | 'Lactating' | 'Weaned' | 'Empty'
  final String? currentStage;

  /// P2 backfat measurement in mm.
  final double? backfatMm;

  /// Days from weaning to next confirmed service.
  final double? weanToServiceDays;

  /// Total pigs born alive across all completed parities.
  final int? totalBornAliveLifetime;

  /// Pigs Saved per Sow per Year (current calendar year).
  final double? psyCurrentYear;

  final String? lastServiceDate;
  final String? expectedFarrowingDate;
  final String? farrowingDateActual;

  final int? totalBorn;
  final int? bornAlive;
  final int? bornDead;

  /// Number weaned from the most recent litter.
  final int? currentLitterWeaned;
  final double? avgBirthWeightKg;
  final double? preWeanMortalityPct;

  // ── Alert helpers ─────────────────────────────────────────────────────────────

  bool get isPsyAlert =>
      psyCurrentYear != null && psyCurrentYear! < 22.0;

  bool get isPreWeanAlert =>
      preWeanMortalityPct != null && preWeanMortalityPct! > 12.0;

  factory PigSpecific.fromJson(Map<String, dynamic> json) => PigSpecific(
        parity: json['parity'] as int?,
        currentStage: json['current_stage'] as String?,
        backfatMm: (json['backfat_mm'] as num?)?.toDouble(),
        weanToServiceDays:
            (json['wean_to_service_days'] as num?)?.toDouble(),
        totalBornAliveLifetime: json['total_born_alive_lifetime'] as int?,
        psyCurrentYear:
            (json['psy_current_year'] as num?)?.toDouble(),
        lastServiceDate: json['last_service_date'] as String?,
        expectedFarrowingDate:
            json['expected_farrowing_date'] as String?,
        farrowingDateActual: json['farrowing_date_actual'] as String?,
        totalBorn: json['total_born'] as int?,
        bornAlive: json['born_alive'] as int?,
        bornDead: json['born_dead'] as int?,
        currentLitterWeaned: json['current_litter_weaned'] as int?,
        avgBirthWeightKg:
            (json['avg_birth_weight_kg'] as num?)?.toDouble(),
        preWeanMortalityPct:
            (json['pre_wean_mortality_pct'] as num?)?.toDouble(),
      );
}

// ── Sow ───────────────────────────────────────────────────────────────────────

/// A breeding sow record (mirrors the generic livestock animal shape).
class Sow {
  const Sow({
    required this.id,
    required this.farmId,
    required this.tagNumber,
    this.name,
    required this.category,
    required this.breed,
    required this.status,
    this.dateOfBirth,
    this.ageMonths,
    this.penId,
    this.currentWeightKg,
    this.bodyConditionScore,
    this.pigSpecific,
  });

  final String id;
  final String farmId;
  final String tagNumber;
  final String? name;

  /// 'breeding_sow' | 'gilt' | 'boar'
  final String category;
  final String breed;

  /// 'active' | 'culled' | 'sold' | 'deceased'
  final String status;

  final String? dateOfBirth;
  final int? ageMonths;
  final String? penId;
  final double? currentWeightKg;

  /// Body Condition Score 1–5 (3 = optimal).
  final double? bodyConditionScore;
  final PigSpecific? pigSpecific;

  // ── Computed helpers ──────────────────────────────────────────────────────────

  String get displayName => name?.isNotEmpty == true ? name! : tagNumber;

  bool get isActive => status == 'active';

  String get currentStage =>
      pigSpecific?.currentStage ?? '—';

  bool get isPregnant =>
      pigSpecific?.currentStage == 'Gestation' ||
      pigSpecific?.currentStage == 'gestation';

  bool get isLactating =>
      pigSpecific?.currentStage == 'Lactating' ||
      pigSpecific?.currentStage == 'lactating';

  int? get daysToFarrowing {
    final dateStr = pigSpecific?.expectedFarrowingDate;
    if (dateStr == null) return null;
    try {
      final farrow = DateTime.parse(dateStr);
      return farrow.difference(DateTime.now()).inDays;
    } catch (_) {
      return null;
    }
  }

  factory Sow.fromJson(Map<String, dynamic> json) {
    final pig = json['pig_specific'] as Map<String, dynamic>?;
    return Sow(
      id: json['id'] as String? ?? '',
      farmId: json['farm_id'] as String? ?? '',
      tagNumber: json['tag_number'] as String? ?? '',
      name: json['name'] as String?,
      category: json['category'] as String? ?? 'breeding_sow',
      breed: json['breed'] as String? ?? '',
      status: json['status'] as String? ?? 'active',
      dateOfBirth: json['date_of_birth'] as String?,
      ageMonths: json['age_months'] as int?,
      penId: json['pen_id'] as String?,
      currentWeightKg: (json['current_weight_kg'] as num?)?.toDouble(),
      bodyConditionScore:
          (json['body_condition_score'] as num?)?.toDouble(),
      pigSpecific: pig != null ? PigSpecific.fromJson(pig) : null,
    );
  }
}

// ── FarrowingRecord ───────────────────────────────────────────────────────────

/// A single farrowing event for a sow.
class FarrowingRecord {
  const FarrowingRecord({
    required this.id,
    required this.sowId,
    this.sowTag,
    this.farrowingDate,
    this.parity,
    this.totalBorn,
    this.bornAlive,
    this.bornDead,
    this.mummified,
    this.weaningDate,
    this.weaned,
    this.avgBirthWeightKg,
    this.preWeanMortalityPct,
    this.status,
    this.notes,
    this.attendedBy,
  });

  final String id;
  final String sowId;
  final String? sowTag;
  final String? farrowingDate;
  final int? parity;
  final int? totalBorn;
  final int? bornAlive;
  final int? bornDead;
  final int? mummified;
  final String? weaningDate;
  final int? weaned;
  final double? avgBirthWeightKg;
  final double? preWeanMortalityPct;

  /// 'completed' | 'pending_farrowing' | 'in_progress'
  final String? status;
  final String? notes;
  final String? attendedBy;

  bool get isCompleted => status == 'completed';
  bool get isPreWeanAlert =>
      preWeanMortalityPct != null && preWeanMortalityPct! > 12.0;

  factory FarrowingRecord.fromJson(Map<String, dynamic> json) =>
      FarrowingRecord(
        id: json['id'] as String? ?? '',
        sowId: json['sow_id'] as String? ?? '',
        sowTag: json['sow_tag'] as String?,
        farrowingDate: json['farrowing_date'] as String?,
        parity: json['parity'] as int?,
        totalBorn: json['total_born'] as int?,
        bornAlive: json['born_alive'] as int?,
        bornDead: json['born_dead'] as int?,
        mummified: json['mummified'] as int?,
        weaningDate: json['weaning_date'] as String?,
        weaned: json['weaned'] as int?,
        avgBirthWeightKg:
            (json['avg_birth_weight_kg'] as num?)?.toDouble(),
        preWeanMortalityPct:
            (json['pre_wean_mortality_pct'] as num?)?.toDouble(),
        status: json['status'] as String?,
        notes: json['notes'] as String?,
        attendedBy: json['attended_by'] as String?,
      );
}

// ── SowServiceRecord ──────────────────────────────────────────────────────────

/// A breeding / artificial insemination service event.
class SowServiceRecord {
  const SowServiceRecord({
    required this.id,
    required this.sowId,
    this.sowTag,
    this.serviceDate,
    this.secondServiceDate,
    this.boarId,
    this.boarTag,
    this.serviceMethod,
    this.expectedFarrowingDate,
    this.pregnancyCheckDate,
    this.pregnancyResult,
    this.weanToServiceDays,
    this.notes,
  });

  final String id;
  final String sowId;
  final String? sowTag;
  final String? serviceDate;
  final String? secondServiceDate;
  final String? boarId;
  final String? boarTag;

  /// 'AI' | 'natural_mating' | 'embryo_transfer'
  final String? serviceMethod;
  final String? expectedFarrowingDate;
  final String? pregnancyCheckDate;

  /// 'confirmed_pregnant' | 'not_pregnant' | 'pending'
  final String? pregnancyResult;
  final int? weanToServiceDays;
  final String? notes;

  bool get isConfirmed => pregnancyResult == 'confirmed_pregnant';

  factory SowServiceRecord.fromJson(Map<String, dynamic> json) =>
      SowServiceRecord(
        id: json['id'] as String? ?? '',
        sowId: json['sow_id'] as String? ?? '',
        sowTag: json['sow_tag'] as String?,
        serviceDate: json['service_date'] as String?,
        secondServiceDate: json['second_service_date'] as String?,
        boarId: json['boar_id'] as String?,
        boarTag: json['boar_tag'] as String?,
        serviceMethod: json['service_method'] as String?,
        expectedFarrowingDate:
            json['expected_farrowing_date'] as String?,
        pregnancyCheckDate: json['pregnancy_check_date'] as String?,
        pregnancyResult: json['pregnancy_result'] as String?,
        weanToServiceDays: json['wean_to_service_days'] as int?,
        notes: json['notes'] as String?,
      );
}

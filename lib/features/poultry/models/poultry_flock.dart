/// Represents a single poultry flock (batch) record from the API.
///
/// Poultry is managed in a batch/flock model — not individual birds.
/// All production types (broiler, layer, duck_meat) share this model,
/// with type-specific data nested in [broilerSpecific] or [layerSpecific].
class PoultryFlock {
  const PoultryFlock({
    required this.id,
    required this.farmId,
    required this.batchName,
    required this.species,
    required this.productionType,
    required this.strain,
    this.breed,
    required this.houseId,
    required this.status,
    required this.placementDate,
    required this.placementCount,
    required this.currentCount,
    required this.mortalityTotal,
    required this.mortalityPct,
    required this.dayOfAge,
    this.livabilityPct,
    this.currentAvgWeightG,
    this.feedConsumedTotalKg,
    this.fcrToDate,
    this.projectedSlaughterDate,
    this.targetSlaughterWeightG,
    this.weekOfAge,
    this.currentStage,
    this.unitCostPerChick,
    this.broilerSpecific,
    this.layerSpecific,
    this.duckSpecific,
    this.breederSpecific,
    this.turkeySpecific,
    this.quailSpecific,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String farmId;

  /// Human-readable flock / batch name (e.g. "Broiler Batch July 2024").
  final String batchName;

  /// Species string: "chicken", "duck", "turkey", etc.
  final String species;

  /// Production classification: "broiler", "layer", "duck_meat", etc.
  final String productionType;

  /// Commercial genetic strain / line (e.g. "Ross 308", "Lohmann Brown Classic").
  final String strain;

  /// Underlying breed / variety (e.g. "White Plymouth Rock cross", "Pekin").
  /// Distinct from [strain] — [strain] is the commercial line, [breed] is the variety.
  final String? breed;

  /// House / pen identifier this flock is housed in.
  final String houseId;

  /// Lifecycle status: "active", "completed", "sold", "culled".
  final String status;

  /// ISO 8601 date string of day-old chick placement.
  final String placementDate;

  /// Number of birds placed at start of the batch.
  final int placementCount;

  /// Current live bird count.
  final int currentCount;

  /// Cumulative mortality since placement.
  final int mortalityTotal;

  /// Mortality as a percentage of [placementCount].
  final double mortalityPct;

  /// Current age of the flock in days since placement.
  final int dayOfAge;

  /// Livability expressed as a percentage (100 - mortalityPct).
  final double? livabilityPct;

  /// Current average live weight in grams.
  final double? currentAvgWeightG;

  /// Total feed consumed by the flock since placement, in kilograms.
  final double? feedConsumedTotalKg;

  /// Feed conversion ratio from placement to today.
  final double? fcrToDate;

  /// ISO 8601 date string of projected / scheduled slaughter.
  final String? projectedSlaughterDate;

  /// Target live weight at slaughter, in grams.
  final int? targetSlaughterWeightG;

  /// Current age expressed in complete weeks (layers).
  final int? weekOfAge;

  /// Named production stage (e.g. "Production", "Rearing") — layers only.
  final String? currentStage;

  /// Unit cost per day-old chick in ZAR (used for DOC cost auto-population).
  final double? unitCostPerChick;

  /// Broiler-specific performance and program data.
  final BroilerSpecific? broilerSpecific;

  /// Layer-specific production data.
  final LayerSpecific? layerSpecific;

  /// Duck-specific data.
  final DuckSpecific? duckSpecific;

  /// Breeder / parent-stock specific data.
  final BreederSpecific? breederSpecific;

  /// Turkey-specific data.
  final TurkeySpecific? turkeySpecific;

  /// Quail-specific data.
  final QuailSpecific? quailSpecific;

  final String? createdAt;
  final String? updatedAt;

  // ── Computed helpers ──────────────────────────────────────────────────────────

  bool get isActive => status == 'active';
  bool get isBroiler => productionType == 'broiler';
  bool get isLayer => productionType == 'layer';
  bool get isDuck => productionType == 'duck_meat' || species == 'duck';
  /// Hatchery: incubator-based chick production (distinct from [isBreeder]).
  bool get isHatchery => productionType == 'hatchery';
  /// Breeder / parent stock: flocks kept to produce fertile eggs for the hatchery.
  bool get isBreeder => productionType == 'breeder';
  bool get isTurkey => productionType == 'turkey' || species == 'turkey';
  bool get isQuail => productionType == 'quail' || species == 'quail';

  /// Progress through the grow-out cycle as a value from 0.0 to 1.0.
  /// Uses [projectedSlaughterDate] if available, otherwise returns null.
  double? get growOutProgress {
    if (projectedSlaughterDate == null) return null;
    final placement = DateTime.tryParse(placementDate);
    final slaughter = DateTime.tryParse(projectedSlaughterDate!);
    if (placement == null || slaughter == null) return null;
    final total = slaughter.difference(placement).inDays;
    if (total <= 0) return null;
    return (dayOfAge / total).clamp(0.0, 1.0);
  }

  factory PoultryFlock.fromJson(Map<String, dynamic> json) {
    return PoultryFlock(
      id: json['id'] as String? ?? '',
      farmId: json['farm_id'] as String? ?? '',
      batchName: json['batch_name'] as String? ?? '',
      species: json['species'] as String? ?? '',
      productionType: json['production_type'] as String? ?? '',
      strain: json['strain'] as String? ?? '',
      breed: json['breed'] as String?,
      houseId: json['house_id'] as String? ?? '',
      status: json['status'] as String? ?? '',
      placementDate: json['placement_date'] as String? ?? '',
      placementCount: json['placement_count'] as int? ?? 0,
      currentCount: json['current_count'] as int? ?? 0,
      mortalityTotal: json['mortality_total'] as int? ?? 0,
      mortalityPct: (json['mortality_pct'] as num?)?.toDouble() ?? 0.0,
      dayOfAge: json['day_of_age'] as int? ?? 0,
      livabilityPct: (json['livability_pct'] as num?)?.toDouble(),
      currentAvgWeightG: (json['current_avg_weight_g'] as num?)?.toDouble(),
      feedConsumedTotalKg:
          (json['feed_consumed_total_kg'] as num?)?.toDouble(),
      fcrToDate: (json['fcr_to_date'] as num?)?.toDouble(),
      projectedSlaughterDate: json['projected_slaughter_date'] as String?,
      targetSlaughterWeightG: json['target_slaughter_weight_g'] as int?,
      weekOfAge: json['week_of_age'] as int?,
      currentStage: json['current_stage'] as String?,
      unitCostPerChick: (json['unit_cost_per_chick'] as num?)?.toDouble(),
      broilerSpecific: json['broiler_specific'] != null
          ? BroilerSpecific.fromJson(
              json['broiler_specific'] as Map<String, dynamic>)
          : null,
      layerSpecific: json['layer_specific'] != null
          ? LayerSpecific.fromJson(
              json['layer_specific'] as Map<String, dynamic>)
          : null,
      duckSpecific: json['duck_specific'] != null
          ? DuckSpecific.fromJson(
              json['duck_specific'] as Map<String, dynamic>)
          : null,
      breederSpecific: json['breeder_specific'] != null
          ? BreederSpecific.fromJson(
              json['breeder_specific'] as Map<String, dynamic>)
          : null,
      turkeySpecific: json['turkey_specific'] != null
          ? TurkeySpecific.fromJson(
              json['turkey_specific'] as Map<String, dynamic>)
          : null,
      quailSpecific: json['quail_specific'] != null
          ? QuailSpecific.fromJson(
              json['quail_specific'] as Map<String, dynamic>)
          : null,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }
}

// ── Nested: BroilerSpecific ───────────────────────────────────────────────────

class BroilerSpecific {
  const BroilerSpecific({
    this.target7dWeightG,
    this.target14dWeightG,
    this.target21dWeightG,
    this.target28dWeightG,
    this.target35dWeightG,
    this.target42dWeightG,
    this.actual7dWeightG,
    this.actual14dWeightG,
    this.actual21dWeightG,
    this.actual28dWeightG,
    this.actual35dWeightG,
    this.actual42dWeightG,
    this.uniformityPct,
    this.targetFcr42d,
    this.epefCurrent,
    this.lightingProgram,
    this.ventilationMode,
  });

  final int? target7dWeightG;
  final int? target14dWeightG;
  final int? target21dWeightG;
  final int? target28dWeightG;
  final int? target35dWeightG;
  final int? target42dWeightG;
  final int? actual7dWeightG;
  final int? actual14dWeightG;
  final int? actual21dWeightG;
  final int? actual28dWeightG;
  final int? actual35dWeightG;
  final int? actual42dWeightG;
  final double? uniformityPct;
  final double? targetFcr42d;
  final int? epefCurrent;
  final String? lightingProgram;
  final String? ventilationMode;

  factory BroilerSpecific.fromJson(Map<String, dynamic> json) {
    return BroilerSpecific(
      target7dWeightG: json['target_7d_weight_g'] as int?,
      target14dWeightG: json['target_14d_weight_g'] as int?,
      target21dWeightG: json['target_21d_weight_g'] as int?,
      target28dWeightG: json['target_28d_weight_g'] as int?,
      target35dWeightG: json['target_35d_weight_g'] as int?,
      target42dWeightG: json['target_42d_weight_g'] as int?,
      actual7dWeightG: json['actual_7d_weight_g'] as int?,
      actual14dWeightG: json['actual_14d_weight_g'] as int?,
      actual21dWeightG: json['actual_21d_weight_g'] as int?,
      actual28dWeightG: json['actual_28d_weight_g'] as int?,
      actual35dWeightG: json['actual_35d_weight_g'] as int?,
      actual42dWeightG: json['actual_42d_weight_g'] as int?,
      uniformityPct: (json['uniformity_pct'] as num?)?.toDouble(),
      targetFcr42d: (json['target_fcr_42d'] as num?)?.toDouble(),
      epefCurrent: json['epef_current'] as int?,
      lightingProgram: json['lighting_program'] as String?,
      ventilationMode: json['ventilation_mode'] as String?,
    );
  }
}

// ── Nested: LayerSpecific ─────────────────────────────────────────────────────

class LayerSpecific {
  const LayerSpecific({
    this.pointOfLayDate,
    this.peakProductionDate,
    this.peakHdpPct,
    this.currentHdpPct,
    this.totalEggsProduced,
    this.avgEggWeightG,
    this.feedPerDozenKg,
    this.projectedMoltDate,
    this.lightingProgram,
    this.henHousedAvgPct,
    this.eggMassGPerHenPerDay,
  });

  final String? pointOfLayDate;
  final String? peakProductionDate;
  final double? peakHdpPct;
  final double? currentHdpPct;
  final int? totalEggsProduced;
  final double? avgEggWeightG;
  final double? feedPerDozenKg;
  final String? projectedMoltDate;
  final String? lightingProgram;
  /// Hen-housed average production % (cumulative eggs / placement count × 100).
  final double? henHousedAvgPct;
  /// Egg mass in grams per hen per day (avgEggWeightG × hdpPct / 100).
  final double? eggMassGPerHenPerDay;

  factory LayerSpecific.fromJson(Map<String, dynamic> json) {
    return LayerSpecific(
      pointOfLayDate: json['point_of_lay_date'] as String?,
      peakProductionDate: json['peak_production_date'] as String?,
      peakHdpPct: (json['peak_hdp_pct'] as num?)?.toDouble(),
      currentHdpPct: (json['current_hdp_pct'] as num?)?.toDouble(),
      totalEggsProduced: json['total_eggs_produced'] as int?,
      avgEggWeightG: (json['avg_egg_weight_g'] as num?)?.toDouble(),
      feedPerDozenKg: (json['feed_per_dozen_kg'] as num?)?.toDouble(),
      projectedMoltDate: json['projected_molt_date'] as String?,
      lightingProgram: json['lighting_program'] as String?,
      henHousedAvgPct: (json['hen_housed_avg_pct'] as num?)?.toDouble(),
      eggMassGPerHenPerDay:
          (json['egg_mass_g_per_hen_per_day'] as num?)?.toDouble(),
    );
  }
}

// ── Nested: DuckSpecific ──────────────────────────────────────────────────────

class DuckSpecific {
  const DuckSpecific({
    this.waterAccess,
    this.target42dWeightG,
    this.targetFcr42d,
  });

  final bool? waterAccess;
  final int? target42dWeightG;
  final double? targetFcr42d;

  factory DuckSpecific.fromJson(Map<String, dynamic> json) {
    return DuckSpecific(
      waterAccess: json['water_access'] as bool?,
      target42dWeightG: json['target_42d_weight_g'] as int?,
      targetFcr42d: (json['target_fcr_42d'] as num?)?.toDouble(),
    );
  }
}

// ── Nested: BreederSpecific ───────────────────────────────────────────────────

class BreederSpecific {
  const BreederSpecific({
    this.henCount,
    this.roosterCount,
    this.maleFemaleRatio,
    this.pointOfLayDate,
    this.peakProductionDate,
    this.peakHdpPct,
    this.currentHdpPct,
    this.fertilityPct,
    this.hatchabilityPct,
    this.totalHatchingEggs,
    this.totalChicksProduced,
    this.totalChicksSold,
    this.avgChickWeightG,
    this.lightingProgram,
    this.projectedDepletionDate,
  });

  /// Number of females (hens) in the flock.
  final int? henCount;

  /// Number of males (roosters) in the flock.
  final int? roosterCount;

  /// Male-to-female ratio, e.g. "1:10.4".
  final String? maleFemaleRatio;

  /// Date hens first started producing hatching eggs.
  final String? pointOfLayDate;

  /// Date peak HDP% was reached.
  final String? peakProductionDate;

  /// Peak hen-day production %.
  final double? peakHdpPct;

  /// Current hen-day production % (hatching eggs).
  final double? currentHdpPct;

  /// Average fertility % of hatching eggs set.
  final double? fertilityPct;

  /// Average hatchability % (chicks hatched / eggs set).
  final double? hatchabilityPct;

  /// Cumulative hatching eggs collected since lay start.
  final int? totalHatchingEggs;

  /// Cumulative day-old chicks (DOC) produced.
  final int? totalChicksProduced;

  /// Cumulative DOC sold.
  final int? totalChicksSold;

  /// Average DOC weight in grams (target ~42 g).
  final double? avgChickWeightG;

  /// Lighting programme, e.g. "14L_10D".
  final String? lightingProgram;

  /// Projected flock depletion / sell-off date.
  final String? projectedDepletionDate;

  factory BreederSpecific.fromJson(Map<String, dynamic> json) {
    return BreederSpecific(
      henCount: json['hen_count'] as int?,
      roosterCount: json['rooster_count'] as int?,
      maleFemaleRatio: json['male_female_ratio'] as String?,
      pointOfLayDate: json['point_of_lay_date'] as String?,
      peakProductionDate: json['peak_production_date'] as String?,
      peakHdpPct: (json['peak_hdp_pct'] as num?)?.toDouble(),
      currentHdpPct: (json['current_hdp_pct'] as num?)?.toDouble(),
      fertilityPct: (json['fertility_pct'] as num?)?.toDouble(),
      hatchabilityPct: (json['hatchability_pct'] as num?)?.toDouble(),
      totalHatchingEggs: json['total_hatching_eggs'] as int?,
      totalChicksProduced: json['total_chicks_produced'] as int?,
      totalChicksSold: json['total_chicks_sold'] as int?,
      avgChickWeightG: (json['avg_chick_weight_g'] as num?)?.toDouble(),
      lightingProgram: json['lighting_program'] as String?,
      projectedDepletionDate: json['projected_depletion_date'] as String?,
    );
  }
}

// ── Nested: TurkeySpecific ────────────────────────────────────────────────────

class TurkeySpecific {
  const TurkeySpecific({
    this.targetMarketWeightG,
    this.targetFcr,
    this.lightingProgram,
  });

  final int? targetMarketWeightG;
  final double? targetFcr;
  final String? lightingProgram;

  factory TurkeySpecific.fromJson(Map<String, dynamic> json) {
    return TurkeySpecific(
      targetMarketWeightG: json['target_market_weight_g'] as int?,
      targetFcr: (json['target_fcr'] as num?)?.toDouble(),
      lightingProgram: json['lighting_program'] as String?,
    );
  }
}

// ── Nested: QuailSpecific ─────────────────────────────────────────────────────

class QuailSpecific {
  const QuailSpecific({
    this.targetEggProductionPct,
    this.avgEggWeightG,
  });

  /// Target egg production as hen-day percentage.
  final double? targetEggProductionPct;
  final double? avgEggWeightG;

  factory QuailSpecific.fromJson(Map<String, dynamic> json) {
    return QuailSpecific(
      targetEggProductionPct:
          (json['target_egg_production_pct'] as num?)?.toDouble(),
      avgEggWeightG: (json['avg_egg_weight_g'] as num?)?.toDouble(),
    );
  }
}

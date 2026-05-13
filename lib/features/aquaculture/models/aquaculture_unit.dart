/// Models for aquaculture production units (ponds, tanks, cages) and their
/// stocking batches.
///
/// JSON source: data/mock/api/livestock/aquaculture.json
library;

// ── StockingBatch ─────────────────────────────────────────────────────────────

class StockingBatch {
  const StockingBatch({
    required this.id,
    required this.unitId,
    required this.species,
    this.strain,
    required this.stockingDate,
    required this.initialCount,
    required this.currentCount,
    required this.mortalityCount,
    required this.avgWeightG,
    required this.fcrToDate,
    required this.daysInCulture,
    required this.targetHarvestWeightG,
    this.expectedHarvestDate,
    required this.status,
    this.estimatedBiomassKg,
    this.survivalRatePct,
    this.sgrPct,
    this.feedConsumedTotalKg,
  });

  final String id;
  final String unitId;
  final String species;
  final String? strain;
  final DateTime stockingDate;
  final int initialCount;
  final int currentCount;
  final int mortalityCount;
  final double avgWeightG;
  final double fcrToDate;
  final int daysInCulture;
  final double targetHarvestWeightG;
  final DateTime? expectedHarvestDate;
  final String status;
  final double? estimatedBiomassKg;
  final double? survivalRatePct;
  final double? sgrPct;
  final double? feedConsumedTotalKg;

  /// Estimated total biomass in kg (count × avg weight).
  double get biomassKg =>
      estimatedBiomassKg ?? (currentCount * avgWeightG / 1000);

  factory StockingBatch.fromJson(Map<String, dynamic> json, {
    required String unitId,
    required String species,
  }) {
    final initialCount = (json['initial_count'] as num? ?? 0).toInt();
    final currentCount =
        (json['current_estimated_count'] as num? ?? initialCount).toInt();

    return StockingBatch(
      id: json['batch_id'] as String? ?? '',
      unitId: unitId,
      species: species,
      strain: json['strain'] as String?,
      stockingDate: DateTime.tryParse(json['stocking_date'] as String? ?? '') ??
          DateTime.now(),
      initialCount: initialCount,
      currentCount: currentCount,
      mortalityCount: initialCount - currentCount,
      avgWeightG:
          (json['current_avg_weight_g'] as num? ?? 0).toDouble(),
      fcrToDate: (json['fcr_to_date'] as num? ?? 0).toDouble(),
      daysInCulture: (json['days_since_stocking'] as num? ?? 0).toInt(),
      targetHarvestWeightG:
          (json['target_harvest_weight_g'] as num? ?? 0).toDouble(),
      expectedHarvestDate: json['expected_harvest_date'] != null
          ? DateTime.tryParse(json['expected_harvest_date'] as String)
          : null,
      status: 'active',
      estimatedBiomassKg:
          (json['estimated_total_biomass_kg'] as num?)?.toDouble(),
      survivalRatePct:
          (json['survival_rate_pct'] as num?)?.toDouble(),
      sgrPct: (json['sgr_pct'] as num?)?.toDouble(),
      feedConsumedTotalKg:
          (json['feed_consumed_total_kg'] as num?)?.toDouble(),
    );
  }
}

// ── AquacultureUnit ───────────────────────────────────────────────────────────

class AquacultureUnit {
  const AquacultureUnit({
    required this.id,
    required this.farmId,
    required this.unitName,
    required this.unitType,
    required this.species,
    this.productionSystem,
    this.capacityM3,
    this.areaM2,
    this.depthM,
    this.currentBatchId,
    required this.status,
    this.waterSource,
    this.aerationType,
    required this.alerts,
    this.currentDoMgL,
    this.currentPh,
    this.currentTempC,
    this.currentAmmoniaMgL,
    this.doAlert = false,
    this.phAlert = false,
    this.ammoniaAlert = false,
    this.currentBatch,
  });

  final String id;
  final String farmId;
  final String unitName;

  /// Raw type string from JSON e.g. "earthen_pond", "ras_tank", "net_cage".
  final String unitType;

  final String species;
  final String? productionSystem;
  final double? capacityM3;
  final double? areaM2;
  final double? depthM;
  final String? currentBatchId;
  final String status;
  final String? waterSource;
  final String? aerationType;
  final List<Map<String, dynamic>> alerts;

  // ── Latest water quality snapshot ────────────────────────────────────────────
  final double? currentDoMgL;
  final double? currentPh;
  final double? currentTempC;
  final double? currentAmmoniaMgL;

  // ── Alert flags (derived from latest water quality) ───────────────────────────
  /// DO below 4.0 mg/L triggers a warning; below 2.0 is an emergency.
  final bool doAlert;
  final bool phAlert;
  final bool ammoniaAlert;

  final StockingBatch? currentBatch;

  // ── Derived helpers ───────────────────────────────────────────────────────────

  bool get isDoEmergency => currentDoMgL != null && currentDoMgL! < 2.0;
  bool get isDoWarning =>
      currentDoMgL != null && currentDoMgL! < 4.0 && currentDoMgL! >= 2.0;

  /// True if any alert present, regardless of severity.
  bool get hasAlerts => alerts.isNotEmpty;

  bool get hasEmergency =>
      isDoEmergency ||
      alerts.any((a) => (a['severity'] as String?) == 'emergency');

  /// Human-readable unit type label.
  String get unitTypeLabel => switch (unitType) {
        'earthen_pond' => 'Pond',
        'concrete_pond' => 'Pond',
        'ras_tank' => 'RAS',
        'net_cage' => 'Cage',
        _ => unitType
            .split('_')
            .map((w) => w.isEmpty
                ? ''
                : '${w[0].toUpperCase()}${w.substring(1)}')
            .join(' '),
      };

  factory AquacultureUnit.fromJson(Map<String, dynamic> json) {
    final wq =
        json['latest_water_quality'] as Map<String, dynamic>? ?? {};

    final do_ = (wq['dissolved_oxygen_mg_l'] as num?)?.toDouble();
    final ph = (wq['ph'] as num?)?.toDouble();
    final ammonia = (wq['ammonia_mg_l'] as num?)?.toDouble();

    final doAlert = do_ != null && do_ < 4.0;
    final phAlert = ph != null && (ph < 6.5 || ph > 9.0);
    final ammoniaAlert = ammonia != null && ammonia > 1.0;

    final id = json['id'] as String? ?? '';
    final species = json['species'] as String? ?? '';

    StockingBatch? batch;
    if (json['current_batch'] != null) {
      batch = StockingBatch.fromJson(
        json['current_batch'] as Map<String, dynamic>,
        unitId: id,
        species: species,
      );
    }

    return AquacultureUnit(
      id: id,
      farmId: json['farm_id'] as String? ?? '',
      unitName: json['unit_name'] as String? ?? '',
      unitType: json['unit_type'] as String? ?? 'unknown',
      species: species,
      productionSystem: json['production_system'] as String?,
      capacityM3: (json['volume_m3'] as num?)?.toDouble(),
      areaM2: (json['area_m2'] as num?)?.toDouble(),
      depthM: (json['depth_m'] as num?)?.toDouble(),
      currentBatchId: batch?.id,
      status: json['status'] as String? ?? 'unknown',
      waterSource: json['water_source'] as String?,
      aerationType: json['aeration_system'] as String?,
      alerts: (json['alerts'] as List<dynamic>? ?? [])
          .cast<Map<String, dynamic>>(),
      currentDoMgL: do_,
      currentPh: ph,
      currentTempC: (wq['temperature_c'] as num?)?.toDouble(),
      currentAmmoniaMgL: ammonia,
      doAlert: doAlert,
      phAlert: phAlert,
      ammoniaAlert: ammoniaAlert,
      currentBatch: batch,
    );
  }
}

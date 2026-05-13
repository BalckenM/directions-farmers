class HarvestRecord {
  const HarvestRecord({
    required this.id,
    required this.planId,
    required this.fieldId,
    required this.cropId,
    required this.harvestDate,
    required this.actualYieldTons,
    required this.areaHarvestedHa,
    required this.yieldTHa,
    this.qualityGrade,
    this.moisturePercent,
    this.storageLocation,
    this.lossesTons,
    this.lossReason,
    this.notes,
  });

  final String id;
  final String planId;
  final String fieldId;
  final String cropId;
  final DateTime harvestDate;
  final double actualYieldTons;
  final double areaHarvestedHa;
  final double yieldTHa;
  final String? qualityGrade;
  final double? moisturePercent;
  final String? storageLocation;
  final double? lossesTons;
  final String? lossReason;
  final String? notes;

  factory HarvestRecord.fromJson(Map<String, dynamic> json) => HarvestRecord(
        id: json['id'] as String,
        planId: json['plan_id'] as String,
        fieldId: json['field_id'] as String,
        cropId: json['crop_id'] as String,
        harvestDate: DateTime.parse(json['harvest_date'] as String),
        actualYieldTons: (json['actual_yield_tons'] as num).toDouble(),
        areaHarvestedHa: (json['area_harvested_ha'] as num).toDouble(),
        yieldTHa: (json['yield_t_ha'] as num).toDouble(),
        qualityGrade: json['quality_grade'] as String?,
        moisturePercent: (json['moisture_percent'] as num?)?.toDouble(),
        storageLocation: json['storage_location'] as String?,
        lossesTons: (json['losses_tons'] as num?)?.toDouble(),
        lossReason: json['loss_reason'] as String?,
        notes: json['notes'] as String?,
      );
}

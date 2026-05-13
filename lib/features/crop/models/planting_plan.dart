class PlantingPlan {
  const PlantingPlan({
    required this.id,
    required this.fieldId,
    required this.seasonId,
    required this.cropId,
    this.plannedPlantingDate,
    this.plannedHarvestDate,
    this.targetYieldTHa,
    required this.status,
    required this.createdAt,
  });

  final String id;
  final String fieldId;
  final String seasonId;
  final String cropId;
  final DateTime? plannedPlantingDate;
  final DateTime? plannedHarvestDate;
  final double? targetYieldTHa;
  final String status;
  final DateTime createdAt;

  factory PlantingPlan.fromJson(Map<String, dynamic> json) => PlantingPlan(
        id: json['id'] as String,
        fieldId: json['field_id'] as String,
        seasonId: json['season_id'] as String,
        cropId: json['crop_id'] as String,
        plannedPlantingDate: json['planned_planting_date'] != null
            ? DateTime.parse(json['planned_planting_date'] as String)
            : null,
        plannedHarvestDate: json['planned_harvest_date'] != null
            ? DateTime.parse(json['planned_harvest_date'] as String)
            : null,
        targetYieldTHa: (json['target_yield_t_ha'] as num?)?.toDouble(),
        status: json['status'] as String,
        createdAt: DateTime.parse(json['created_at'] as String),
      );

  bool get isActive => status == 'active';
  bool get isCompleted => status == 'completed';
}

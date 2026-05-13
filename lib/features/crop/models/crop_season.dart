class CropSeason {
  const CropSeason({
    required this.id,
    required this.farmId,
    required this.name,
    required this.seasonType,
    required this.startDate,
    required this.endDate,
    required this.status,
    this.notes,
  });

  final String id;
  final String farmId;
  final String name;
  final String seasonType;
  final DateTime startDate;
  final DateTime endDate;
  final String status;
  final String? notes;

  factory CropSeason.fromJson(Map<String, dynamic> json) => CropSeason(
        id: json['id'] as String,
        farmId: json['farm_id'] as String,
        name: json['name'] as String,
        seasonType: json['season_type'] as String,
        startDate: DateTime.parse(json['start_date'] as String),
        endDate: DateTime.parse(json['end_date'] as String),
        status: json['status'] as String,
        notes: json['notes'] as String?,
      );

  bool get isActive => status == 'active';
  bool get isCompleted => status == 'completed';
  bool get isPlanned => status == 'planned';
}

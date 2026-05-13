class Paddock {
  const Paddock({
    required this.id,
    required this.name,
    required this.areaHa,
    required this.campNumber,
    required this.status,
    required this.currentAnimalCount,
    required this.forageType,
    required this.waterSource,
    required this.restPeriodDays,
    this.species = const [],
    this.currentGroupId,
    this.currentGroupName,
    this.lastGrazed,
    this.gpsLat,
    this.gpsLng,
    this.notes,
  });

  final String id;
  final String name;
  final double areaHa;
  final String campNumber;
  final String status; // 'occupied' | 'resting' | 'empty'
  final int currentAnimalCount;
  final String forageType;
  final String waterSource;
  final int restPeriodDays;
  final List<String> species;
  final String? currentGroupId;
  final String? currentGroupName;
  final String? lastGrazed;
  final double? gpsLat;
  final double? gpsLng;
  final String? notes;

  bool get isOccupied => status == 'occupied';
  bool get isResting => status == 'resting';
  bool get isEmpty => status == 'empty';

  double get stockingRateAu => areaHa > 0 ? currentAnimalCount / areaHa : 0.0;

  factory Paddock.fromJson(Map<String, dynamic> json) {
    return Paddock(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      areaHa: (json['area_ha'] as num?)?.toDouble() ?? 0.0,
      campNumber: json['camp_number'] as String? ?? '',
      status: json['status'] as String? ?? 'empty',
      currentAnimalCount: (json['current_animal_count'] as num?)?.toInt() ?? 0,
      forageType: json['forage_type'] as String? ?? '',
      waterSource: json['water_source'] as String? ?? '',
      restPeriodDays: (json['rest_period_days'] as num?)?.toInt() ?? 0,
      species: (json['species'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      currentGroupId: json['current_group_id'] as String?,
      currentGroupName: json['current_group_name'] as String?,
      lastGrazed: json['last_grazed'] as String?,
      gpsLat: (json['gps_lat'] as num?)?.toDouble(),
      gpsLng: (json['gps_lng'] as num?)?.toDouble(),
      notes: json['notes'] as String?,
    );
  }
}

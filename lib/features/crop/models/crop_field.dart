class CropFieldGps {
  const CropFieldGps({required this.lat, required this.lng});
  final double lat;
  final double lng;

  factory CropFieldGps.fromJson(Map<String, dynamic> json) => CropFieldGps(
        lat: (json['lat'] as num).toDouble(),
        lng: (json['lng'] as num).toDouble(),
      );
}

class CropField {
  const CropField({
    required this.id,
    required this.farmId,
    required this.name,
    required this.sizeHectares,
    required this.soilType,
    required this.irrigationType,
    this.priorCropId,
    this.gpsCenter,
    this.notes,
  });

  final String id;
  final String farmId;
  final String name;
  final double sizeHectares;
  final String soilType;
  final String irrigationType;
  final String? priorCropId;
  final CropFieldGps? gpsCenter;
  final String? notes;

  factory CropField.fromJson(Map<String, dynamic> json) => CropField(
        id: json['id'] as String,
        farmId: json['farm_id'] as String,
        name: json['name'] as String,
        sizeHectares: (json['size_hectares'] as num).toDouble(),
        soilType: json['soil_type'] as String,
        irrigationType: json['irrigation_type'] as String,
        priorCropId: json['prior_crop_id'] as String?,
        gpsCenter: json['gps_center'] != null
            ? CropFieldGps.fromJson(
                json['gps_center'] as Map<String, dynamic>)
            : null,
        notes: json['notes'] as String?,
      );

  String get irrigationLabel => switch (irrigationType) {
        'dryland' => 'Dryland',
        'irrigated' => 'Irrigated',
        'mixed' => 'Mixed',
        _ => irrigationType,
      };

  String get soilTypeLabel => soilType.replaceAll('_', ' ').toUpperCase();
}

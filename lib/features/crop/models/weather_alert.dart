enum WeatherAlertType {
  frostWarning,
  heatStress,
  rainForecast,
  droughtWarning,
  spraySuitable,
  sprayUnsuitable,
  plantingOpportunity,
}

extension WeatherAlertTypeX on WeatherAlertType {
  String get label => switch (this) {
        WeatherAlertType.frostWarning => 'Frost Warning',
        WeatherAlertType.heatStress => 'Heat Stress',
        WeatherAlertType.rainForecast => 'Rain Forecast',
        WeatherAlertType.droughtWarning => 'Drought Warning',
        WeatherAlertType.spraySuitable => 'Spray Suitable',
        WeatherAlertType.sprayUnsuitable => 'Spray Unsuitable',
        WeatherAlertType.plantingOpportunity => 'Planting Opportunity',
      };

  static WeatherAlertType fromString(String v) => switch (v) {
        'frost_warning' => WeatherAlertType.frostWarning,
        'heat_stress' => WeatherAlertType.heatStress,
        'rain_forecast' => WeatherAlertType.rainForecast,
        'drought_warning' => WeatherAlertType.droughtWarning,
        'spray_suitable' => WeatherAlertType.spraySuitable,
        'spray_unsuitable' => WeatherAlertType.sprayUnsuitable,
        'planting_opportunity' => WeatherAlertType.plantingOpportunity,
        _ => WeatherAlertType.rainForecast,
      };
}

class WeatherAlert {
  const WeatherAlert({
    required this.id,
    required this.farmId,
    required this.alertType,
    required this.severity,
    required this.title,
    required this.message,
    required this.issuedAt,
    required this.validUntil,
    required this.actionRequired,
    required this.cropIdsAffected,
  });

  final String id;
  final String farmId;
  final WeatherAlertType alertType;
  final String severity;
  final String title;
  final String message;
  final DateTime issuedAt;
  final DateTime validUntil;
  final bool actionRequired;
  final List<String> cropIdsAffected;

  factory WeatherAlert.fromJson(Map<String, dynamic> json) => WeatherAlert(
        id: json['id'] as String,
        farmId: json['farm_id'] as String,
        alertType:
            WeatherAlertTypeX.fromString(json['alert_type'] as String),
        severity: json['severity'] as String,
        title: json['title'] as String,
        message: json['message'] as String,
        issuedAt: DateTime.parse(json['issued_at'] as String),
        validUntil: DateTime.parse(json['valid_until'] as String),
        actionRequired: json['action_required'] as bool,
        cropIdsAffected:
            (json['crop_ids_affected'] as List<dynamic>).cast<String>(),
      );

  bool get isActive => DateTime.now().isBefore(validUntil);
}

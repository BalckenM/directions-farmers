import '../models/farm_weather.dart';
import '../models/weather_alert.dart';
import 'weather_data_source.dart';

// Simulates current SA (Limpopo) autumn weather — May 2026.
// Rotate through realistic conditions on each cold-start.
class WeatherMockDataSource implements WeatherDataSource {
  static const _kDelay = Duration(milliseconds: 400);

  static final _now = DateTime.now();

  // ── Current conditions ────────────────────────────────────────────────────

  static final _current = FarmWeather(
    farmId: 'FARM-001',
    condition: WeatherCondition.partlyCloudy,
    tempC: 23.4,
    feelsLikeC: 22.1,
    humidity: 52,
    windKmh: 12.0,
    windDirection: 'NE',
    rainfallMm24h: 0.0,
    rainfallMm7d: 8.2,
    uvIndex: 5,
    frostRisk: false,
    sprayWindow: SprayWindow.suitable,
    fetchedAt: _now,
    locationName: 'Polokwane, Limpopo',
  );

  // ── 10-day forecast ───────────────────────────────────────────────────────

  static final List<WeatherForecastDay> _forecast = [
    WeatherForecastDay(
      date: _now,
      condition: WeatherCondition.partlyCloudy,
      maxTempC: 26.0,
      minTempC: 13.0,
      rainfallMm: 0.0,
      humidity: 52,
      windKmh: 12.0,
      frostRisk: false,
      sprayWindow: SprayWindow.suitable,
    ),
    WeatherForecastDay(
      date: _now.add(const Duration(days: 1)),
      condition: WeatherCondition.sunny,
      maxTempC: 28.5,
      minTempC: 14.0,
      rainfallMm: 0.0,
      humidity: 45,
      windKmh: 9.0,
      frostRisk: false,
      sprayWindow: SprayWindow.suitable,
    ),
    WeatherForecastDay(
      date: _now.add(const Duration(days: 2)),
      condition: WeatherCondition.lightRain,
      maxTempC: 21.0,
      minTempC: 15.5,
      rainfallMm: 12.0,
      humidity: 78,
      windKmh: 18.0,
      frostRisk: false,
      sprayWindow: SprayWindow.unsuitable,
    ),
    WeatherForecastDay(
      date: _now.add(const Duration(days: 3)),
      condition: WeatherCondition.rain,
      maxTempC: 18.5,
      minTempC: 13.0,
      rainfallMm: 28.0,
      humidity: 88,
      windKmh: 22.0,
      frostRisk: false,
      sprayWindow: SprayWindow.unsuitable,
    ),
    WeatherForecastDay(
      date: _now.add(const Duration(days: 4)),
      condition: WeatherCondition.cloudy,
      maxTempC: 20.0,
      minTempC: 11.0,
      rainfallMm: 4.0,
      humidity: 70,
      windKmh: 14.0,
      frostRisk: false,
      sprayWindow: SprayWindow.marginal,
    ),
    WeatherForecastDay(
      date: _now.add(const Duration(days: 5)),
      condition: WeatherCondition.partlyCloudy,
      maxTempC: 24.0,
      minTempC: 10.0,
      rainfallMm: 0.0,
      humidity: 55,
      windKmh: 10.0,
      frostRisk: false,
      sprayWindow: SprayWindow.suitable,
    ),
    WeatherForecastDay(
      date: _now.add(const Duration(days: 6)),
      condition: WeatherCondition.sunny,
      maxTempC: 27.0,
      minTempC: 9.0,
      rainfallMm: 0.0,
      humidity: 42,
      windKmh: 8.0,
      frostRisk: false,
      sprayWindow: SprayWindow.suitable,
    ),
    WeatherForecastDay(
      date: _now.add(const Duration(days: 7)),
      condition: WeatherCondition.sunny,
      maxTempC: 29.0,
      minTempC: 8.0,
      rainfallMm: 0.0,
      humidity: 38,
      windKmh: 7.0,
      frostRisk: false,
      sprayWindow: SprayWindow.suitable,
    ),
    WeatherForecastDay(
      date: _now.add(const Duration(days: 8)),
      condition: WeatherCondition.partlyCloudy,
      maxTempC: 25.0,
      minTempC: 7.5,
      rainfallMm: 0.0,
      humidity: 44,
      windKmh: 11.0,
      frostRisk: true,
      sprayWindow: SprayWindow.suitable,
    ),
    WeatherForecastDay(
      date: _now.add(const Duration(days: 9)),
      condition: WeatherCondition.frosty,
      maxTempC: 19.0,
      minTempC: 1.5,
      rainfallMm: 0.0,
      humidity: 60,
      windKmh: 6.0,
      frostRisk: true,
      sprayWindow: SprayWindow.marginal,
    ),
  ];

  // ── Agricultural alerts auto-derived from forecast ────────────────────────

  static final List<WeatherAlert> _alerts = [
    WeatherAlert(
      id: 'WALERT-001',
      farmId: 'FARM-001',
      alertType: WeatherAlertType.rainForecast,
      severity: 'moderate',
      title: 'Rain Forecast: 28mm in 3 Days',
      message:
          'Significant rainfall expected in 3 days. Complete any scheduled '
          'spraying before then. Check drainage on low-lying fields. '
          'Postpone fertilizer application until after rain event.',
      issuedAt: _now,
      validUntil: _now.add(const Duration(days: 4)),
      actionRequired: true,
      cropIdsAffected: ['CROP-MAIZE', 'CROP-SOYA'],
    ),
    WeatherAlert(
      id: 'WALERT-002',
      farmId: 'FARM-001',
      alertType: WeatherAlertType.spraySuitable,
      severity: 'info',
      title: 'Good Spray Window: Next 2 Days',
      message:
          'Wind speed below 15 km/h, no rain forecast for 48 hours. '
          'Ideal conditions to apply pending pesticide or herbicide treatments. '
          'UV Index 5 — avoid spraying between 11:00–15:00.',
      issuedAt: _now,
      validUntil: _now.add(const Duration(days: 2)),
      actionRequired: false,
      cropIdsAffected: [],
    ),
    WeatherAlert(
      id: 'WALERT-003',
      farmId: 'FARM-001',
      alertType: WeatherAlertType.frostWarning,
      severity: 'high',
      title: 'Frost Risk: Days 9–10',
      message:
          'Minimum temperatures forecast to drop to 1.5°C in 9 days. '
          'Risk of frost damage to sensitive crops. '
          'Ensure frost protection for tomatoes and other frost-sensitive crops. '
          'Avoid irrigating the evening before expected frost.',
      issuedAt: _now,
      validUntil: _now.add(const Duration(days: 10)),
      actionRequired: true,
      cropIdsAffected: ['CROP-TOMATO', 'CROP-POTATO'],
    ),
    WeatherAlert(
      id: 'WALERT-004',
      farmId: 'FARM-001',
      alertType: WeatherAlertType.droughtWarning,
      severity: 'low',
      title: 'Dry Spell After Rain Event',
      message:
          'Extended dry period (7+ days) expected after the current rain event. '
          'Plan irrigation scheduling accordingly. '
          'Soil moisture monitoring recommended for sandy soils.',
      issuedAt: _now,
      validUntil: _now.add(const Duration(days: 12)),
      actionRequired: false,
      cropIdsAffected: ['CROP-MAIZE', 'CROP-SORGHUM'],
    ),
  ];

  // ── Interface implementation ───────────────────────────────────────────────

  @override
  Future<FarmWeather> getCurrentWeather(String farmId) async {
    await Future.delayed(_kDelay);
    return _current;
  }

  @override
  Future<List<WeatherForecastDay>> getForecast(String farmId) async {
    await Future.delayed(_kDelay);
    return List.unmodifiable(_forecast);
  }

  @override
  Future<List<WeatherAlert>> getAgriculturalAlerts(String farmId) async {
    await Future.delayed(_kDelay);
    return List.unmodifiable(_alerts);
  }
}

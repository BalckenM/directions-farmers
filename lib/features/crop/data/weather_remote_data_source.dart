import '../models/farm_weather.dart';
import '../models/weather_alert.dart';
import 'weather_data_source.dart';

// Stub — weather module not yet active. No HTTP calls are made.
class WeatherRemoteDataSource implements WeatherDataSource {
  WeatherRemoteDataSource(dynamic _);

  @override Future<FarmWeather> getCurrentWeather(String farmId) async =>
      throw UnsupportedError('module not active');
  @override Future<List<WeatherForecastDay>> getForecast(String farmId) async => const [];
  @override Future<List<WeatherAlert>> getAgriculturalAlerts(String farmId) async => const [];
}

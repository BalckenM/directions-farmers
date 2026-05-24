import '../models/farm_weather.dart';
import '../models/weather_alert.dart';
import 'weather_data_source.dart';

class WeatherRemoteDataSource implements WeatherDataSource {
  @override
  Future<FarmWeather> getCurrentWeather(String farmId) =>
      throw UnimplementedError('getCurrentWeather not implemented');

  @override
  Future<List<WeatherForecastDay>> getForecast(String farmId) =>
      throw UnimplementedError('getForecast not implemented');

  @override
  Future<List<WeatherAlert>> getAgriculturalAlerts(String farmId) =>
      throw UnimplementedError('getAgriculturalAlerts not implemented');
}

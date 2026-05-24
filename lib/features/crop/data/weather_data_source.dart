import '../models/farm_weather.dart';
import '../models/weather_alert.dart';

abstract class WeatherDataSource {
  Future<FarmWeather> getCurrentWeather(String farmId);
  Future<List<WeatherForecastDay>> getForecast(String farmId);
  Future<List<WeatherAlert>> getAgriculturalAlerts(String farmId);
}

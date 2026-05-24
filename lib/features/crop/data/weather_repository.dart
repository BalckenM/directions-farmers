import '../../../core/errors/app_exception.dart';
import '../../../core/errors/failure.dart';
import '../models/farm_weather.dart';
import '../models/weather_alert.dart';
import 'weather_data_source.dart';

class WeatherRepository {
  WeatherRepository(this._source);

  final WeatherDataSource _source;

  // Short-lived cache — weather data refreshes every 30 min in production.
  FarmWeather? _cachedWeather;
  List<WeatherForecastDay>? _cachedForecast;
  List<WeatherAlert>? _cachedAlerts;
  DateTime? _lastFetch;

  bool get _isCacheStale =>
      _lastFetch == null ||
      DateTime.now().difference(_lastFetch!) > const Duration(minutes: 30);

  Future<FarmWeather> getCurrentWeather(String farmId) async {
    try {
      if (_cachedWeather == null || _isCacheStale) {
        _cachedWeather = await _source.getCurrentWeather(farmId);
        _lastFetch = DateTime.now();
      }
      return _cachedWeather!;
    } on AppException catch (e) {
      throw Failure.fromException(e);
    } catch (e) {
      throw Failure.fromException(UnexpectedException(e.toString()));
    }
  }

  Future<List<WeatherForecastDay>> getForecast(String farmId) async {
    try {
      if (_cachedForecast == null || _isCacheStale) {
        _cachedForecast = await _source.getForecast(farmId);
      }
      return List.unmodifiable(_cachedForecast!);
    } on AppException catch (e) {
      throw Failure.fromException(e);
    } catch (e) {
      throw Failure.fromException(UnexpectedException(e.toString()));
    }
  }

  Future<List<WeatherAlert>> getAgriculturalAlerts(String farmId) async {
    try {
      if (_cachedAlerts == null || _isCacheStale) {
        _cachedAlerts = await _source.getAgriculturalAlerts(farmId);
      }
      return List.unmodifiable(_cachedAlerts!);
    } on AppException catch (e) {
      throw Failure.fromException(e);
    } catch (e) {
      throw Failure.fromException(UnexpectedException(e.toString()));
    }
  }

  void invalidateCache() {
    _cachedWeather = null;
    _cachedForecast = null;
    _cachedAlerts = null;
    _lastFetch = null;
  }
}

import 'package:dio/dio.dart';

import '../models/farm_weather.dart';
import '../models/weather_alert.dart';
import 'weather_data_source.dart';

/// Production remote data source — calls the FarmTrack REST API via Dio.
class WeatherRemoteDataSource implements WeatherDataSource {
  WeatherRemoteDataSource(this._dio);

  final Dio _dio;

  dynamic _unwrap(dynamic body) =>
      (body is Map<String, dynamic> && body.containsKey('data'))
          ? body['data']
          : body;

  @override
  Future<FarmWeather> getCurrentWeather(String farmId) async {
    final res = await _dio.get('/weather/current', queryParameters: {'farmId': farmId});
    return FarmWeather.fromJson(_unwrap(res.data) as Map<String, dynamic>);
  }

  @override
  Future<List<WeatherForecastDay>> getForecast(String farmId) async {
    final res = await _dio.get('/weather/forecast', queryParameters: {'farmId': farmId});
    final list = _unwrap(res.data) as List<dynamic>;
    return list.map((j) => WeatherForecastDay.fromJson(j as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<WeatherAlert>> getAgriculturalAlerts(String farmId) async {
    final res = await _dio.get('/weather/alerts', queryParameters: {'farmId': farmId});
    final list = _unwrap(res.data) as List<dynamic>;
    return list.map((j) => WeatherAlert.fromJson(j as Map<String, dynamic>)).toList();
  }
}

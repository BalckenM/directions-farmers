import 'package:dio/dio.dart';

import '../models/breeding_event.dart';
import '../models/health_event.dart';
import '../models/weight_record.dart';
import 'events_data_source.dart';

/// Production remote data source — calls the FarmTrack REST API via Dio.
class EventsRemoteDataSource implements EventsDataSource {
  EventsRemoteDataSource(this._dio);

  final Dio _dio;

  dynamic _unwrap(dynamic body) =>
      (body is Map<String, dynamic> && body.containsKey('data'))
          ? body['data']
          : body;

  @override
  Future<List<HealthEvent>> getHealthEvents() async {
    final res = await _dio.get('/events/health');
    final list = _unwrap(res.data) as List<dynamic>;
    return list.map((j) => HealthEvent.fromJson(j as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<WeightRecord>> getWeightRecords() async {
    final res = await _dio.get('/events/weights');
    final list = _unwrap(res.data) as List<dynamic>;
    return list.map((j) => WeightRecord.fromJson(j as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<BreedingEvent>> getBreedingEvents() async {
    final res = await _dio.get('/events/breeding');
    final list = _unwrap(res.data) as List<dynamic>;
    return list.map((j) => BreedingEvent.fromJson(j as Map<String, dynamic>)).toList();
  }

  @override
  Future<void> addHealthEvent(HealthEvent event) async {
    await _dio.post('/events/health', data: event.toJson());
  }

  @override
  Future<void> addWeightRecord(WeightRecord record) async {
    await _dio.post('/events/weights', data: record.toJson());
  }

  @override
  Future<void> addBreedingEvent(BreedingEvent event) async {
    await _dio.post('/events/breeding', data: event.toJson());
  }
}

import 'package:dio/dio.dart';

import 'poultry_data_source.dart';
import '../models/poultry_flock.dart';
import '../models/flock.dart';
import '../models/inventory_item.dart';

/// Production remote data source — calls the FarmTrack REST API via Dio.
class PoultryRemoteDataSource implements PoultryDataSource {
  PoultryRemoteDataSource(this._dio);

  final Dio _dio;

  dynamic _unwrap(dynamic body) =>
      (body is Map<String, dynamic> && body.containsKey('data'))
          ? body['data']
          : body;

  @override
  Future<List<PoultryFlock>> getFlocks() async {
    final res = await _dio.get('/poultry/flocks');
    final list = _unwrap(res.data) as List<dynamic>;
    return list.map((j) => PoultryFlock.fromJson(j as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<DailyRecord>> getDailyRecords() async {
    final res = await _dio.get('/poultry/daily-records');
    final list = _unwrap(res.data) as List<dynamic>;
    return list.map((j) => DailyRecord.fromJson(j as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<VaccinationSchedule>> getVaccinationSchedules() async {
    final res = await _dio.get('/poultry/vaccination-schedules');
    final list = _unwrap(res.data) as List<dynamic>;
    return list.map((j) => VaccinationSchedule.fromJson(j as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<FeedPhase>> getFeedPhases() async {
    final res = await _dio.get('/poultry/feed-phases');
    final list = _unwrap(res.data) as List<dynamic>;
    return list.map((j) => FeedPhase.fromJson(j as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<HarvestRecord>> getHarvestRecords() async {
    final res = await _dio.get('/poultry/harvest-records');
    final list = _unwrap(res.data) as List<dynamic>;
    return list.map((j) => HarvestRecord.fromJson(j as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<MedicationLog>> getMedicationLogs() async {
    final res = await _dio.get('/poultry/medication-logs');
    final list = _unwrap(res.data) as List<dynamic>;
    return list.map((j) => MedicationLog.fromJson(j as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<DiseaseEvent>> getDiseaseEvents() async {
    final res = await _dio.get('/poultry/disease-events');
    final list = _unwrap(res.data) as List<dynamic>;
    return list.map((j) => DiseaseEvent.fromJson(j as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<EnvironmentReading>> getEnvironmentReadings() async {
    final res = await _dio.get('/poultry/environment-readings');
    final list = _unwrap(res.data) as List<dynamic>;
    return list.map((j) => EnvironmentReading.fromJson(j as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<InventoryItem>> getInventoryItems() async {
    final res = await _dio.get('/poultry/inventory-items');
    final list = _unwrap(res.data) as List<dynamic>;
    return list.map((j) => InventoryItem.fromJson(j as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<EggSale>> getEggSales() async {
    final res = await _dio.get('/poultry/egg-sales');
    final list = _unwrap(res.data) as List<dynamic>;
    return list.map((j) => EggSale.fromJson(j as Map<String, dynamic>)).toList();
  }

  @override
  Future<List<ChickSale>> getChickSales() async {
    final res = await _dio.get('/poultry/chick-sales');
    final list = _unwrap(res.data) as List<dynamic>;
    return list.map((j) => ChickSale.fromJson(j as Map<String, dynamic>)).toList();
  }
}
